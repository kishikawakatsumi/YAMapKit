//
//  MKTypes.h
//  MapKit
//
//  Created by kishikawa katsumi on 2012/10/21.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MKFoundation.h>

enum {
    MKMapTypeStandard = 0,
    MKMapTypeSatellite,
    MKMapTypeHybrid
};
typedef NSUInteger MKMapType;


MK_EXTERN NSString *MKErrorDomain;

enum MKErrorCode {
    MKErrorUnknown = 1,
    MKErrorServerFailure,
    MKErrorLoadingThrottled,
    MKErrorPlacemarkNotFound,
};
