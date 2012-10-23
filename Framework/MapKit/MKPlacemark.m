//
//  MKPlacemark.m
//  MapKit
//
//  Created by Rick Fillion on 7/24/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import "MKPlacemark.h"

@interface MKPlacemark ()

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

@end

@implementation MKPlacemark

@synthesize coordinate;
@synthesize addressDictionary;
@synthesize thoroughfare;
@synthesize subThoroughfare;
@synthesize locality;
@synthesize subLocality;
@synthesize administrativeArea;
@synthesize subAdministrativeArea;
@synthesize postalCode;
@synthesize country;
@synthesize countryCode;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate
       addressDictionary:(NSDictionary *)anAddressDictionary
{
    if (self = [super init])
    {
        coordinate = aCoordinate;
        addressDictionary = anAddressDictionary;        
    }
    return self;
}

- (id)initWithGoogleGeocoderResult:(NSDictionary *)result
{
    if (self = [super init])
    {
        coordinate = [self _coordinateFromGoogleGeocoderResult:result];
        NSArray *components = [result objectForKey:@"address_components"];
        if (components)
        {
            for (NSDictionary *component in components)
            {
                NSString *longValue = [component objectForKey:@"long_name"];
                NSString *shortValue = [component objectForKey:@"short_name"];
                NSArray *types = [component objectForKey:@"types"];
                for (NSString *type in types)
                {
                    if ([type isEqualToString:@"street_number"])
                    {
                        thoroughfare = longValue;
                    }
                    if ([type isEqualToString:@"route"])
                    {
                        NSString *newThoroughfare = [thoroughfare stringByAppendingFormat:@" %@", longValue];
                        thoroughfare = newThoroughfare;
                    }
                    if ([type isEqualToString:@"locality"])
                    {
                        locality = longValue;
                    }
                    if ([type isEqualToString:@"administrative_area_level_2"])
                    {
                        subAdministrativeArea = longValue;
                    }
                    if ([type isEqualToString:@"administrative_area_level_1"])
                    {
                        administrativeArea = shortValue;
                    }
                    if ([type isEqualToString:@"country"])
                    {
                        country = longValue;
                        countryCode = shortValue;
                    }
                }
            }
        }
        
    }
    return self;
}

#pragma mark -
#pragma mark Really Private

- (CLLocationCoordinate2D)_coordinateFromGoogleGeocoderResult:(NSDictionary *)result
{
    NSDictionary *location = [result valueForKeyPath:@"geometry.location"];
    NSArray *orderedKeys = [[location allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSString *latitudeKey = [orderedKeys objectAtIndex:0];
    NSString *longitudeKey = [orderedKeys objectAtIndex:1];
    NSNumber *latitude = [location objectForKey:latitudeKey];
    NSNumber *longitude = [location objectForKey:longitudeKey];
    CLLocationCoordinate2D aCoordinate;
    aCoordinate.latitude = [latitude doubleValue];
    aCoordinate.longitude = [longitude doubleValue];
    return aCoordinate;
}

- (NSString *)description
{
    NSString *superDescription = [super description];
    return [superDescription stringByAppendingFormat:
            @" (%f, %f) {thoroughfare: %@,\n subThoroughfare: %@,\n locality: %@,\n subLocality: %@,\n administrativeArea: %@,\n subAdministrativeArea: %@,\n postalCode: %@,\n country: %@,\n countryCode: %@\n}",
            coordinate.latitude, coordinate.longitude, thoroughfare, subThoroughfare, locality, subLocality, administrativeArea, subAdministrativeArea, postalCode, country, countryCode];
}

@end
