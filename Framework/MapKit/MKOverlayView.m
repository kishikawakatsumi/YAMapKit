//
//  MKOverlayView.m
//  MapKit
//
//  Created by Rick Fillion on 7/12/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import <MapKit/MKOverlayView.h>

@implementation MKOverlayView

@synthesize overlay;

- (id)initWithOverlay:(id <MKOverlay>)anOverlay
{
    if (self = [super init]) {
        overlay = anOverlay;
    }
    return self;
}

@end
