//
//  MKPointAnnotation.h
//  MapKit
//
//  Created by Rick Fillion on 7/18/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "MKShape.h"

@interface MKPointAnnotation : MKShape {
    @package
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

