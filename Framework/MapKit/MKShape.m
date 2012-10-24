//
//  MKShape.m
//  MapKit
//
//  Created by Rick Fillion on 7/12/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import <MapKit/MKShape.h>

@implementation MKShape

@synthesize title, subtitle;

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coord;
    coord.longitude = 0.0;
    coord.latitude = 0.0;
    return coord;
}

@end
