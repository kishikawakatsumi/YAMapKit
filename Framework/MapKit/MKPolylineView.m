//
//  MKPolylineView.m
//  MapKit
//
//  Created by Rick Fillion on 7/15/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import <MapKit/MKPolylineView.h>
#import <MapKit/MKWebScriptObject.h>

@implementation MKPolylineView

- (id)initWithPolyline:(MKPolyline *)polyline;
{
    if (self = [super initWithOverlay:polyline]) {
        self.fillColor = [UIColor clearColor];
    }
    return self;
}

- (MKPolyline *)polyline
{
    return [super overlay];
}

- (NSString *)viewPrototypeName
{
    return @"google.maps.Polyline";
}

- (NSDictionary *)options
{
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:[super options]];
    
    if (path) {
        [options setObject:path forKey:@"path"];
    }
    
    return [options copy];
}

- (void)draw:(MKWebScriptObject *)overlayScriptObject
{
    if (!path) {
        CLLocationCoordinate2D *coordinates = malloc(sizeof(CLLocationCoordinate2D) * [self polyline].coordinateCount);
        NSRange range = NSMakeRange(0, [self polyline].coordinateCount);
        [[self polyline] getCoordinates:coordinates range:range];
        NSMutableArray *newPath = [NSMutableArray array];

        for (int i = 0; i< [self polyline].coordinateCount; i++) {
            CLLocationCoordinate2D coordinate = coordinates[i];
            NSString *script = [NSString stringWithFormat:@"new google.maps.LatLng(%f, %f)", coordinate.latitude, coordinate.longitude];
            [newPath addObject:script];
        }
        path = [newPath copy];
    }
    
    [super draw:overlayScriptObject];
}

@end
