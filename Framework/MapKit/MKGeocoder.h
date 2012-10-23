//
//  MKGeocoder.h
//  MapKit
//
//  Created by Rick Fillion on 11-01-02.
//  Copyright 2011 Centrix.ca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <MapKit/MKTypes.h>

@protocol MKGeocoderDelegate;
@class MKWebView;

@interface MKGeocoder : NSObject {
    NSString *address;
    BOOL hasOriginatingCoordinate;
    CLLocationCoordinate2D originatingCoordinate;
    CLLocationCoordinate2D coordinate;
    BOOL querying;
@private
    MKWebView *webView;
    BOOL webViewLoaded;
}

- (id)initWithAddress:(NSString *)anAddress;
- (id)initWithAddress:(NSString *)anAddress nearCoordinate:(CLLocationCoordinate2D)aCoordinate;


// A MKGeocoder object should only be started once.
- (void)start;
- (void)cancel;

@property (nonatomic, weak) id<MKGeocoderDelegate> delegate;
@property (nonatomic, readonly) NSString *address;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;      // the resulting geocoded coordinate.
@property (nonatomic, readonly, getter=isQuerying) BOOL querying;

@end

@protocol MKGeocoderDelegate <NSObject>
@required
- (void)geocoder:(MKGeocoder *)geocoder didFindCoordinate:(CLLocationCoordinate2D)coordinate;
// There are at least two types of errors:
//   - Errors sent up from the underlying connection (temporary condition)
//   - Result not found errors (permanent condition).  The result not found errors
//     will have the domain MKErrorDomain and the code MKErrorPlacemarkNotFound
- (void)geocoder:(MKGeocoder *)geocoder didFailWithError:(NSError *)error;

@end
