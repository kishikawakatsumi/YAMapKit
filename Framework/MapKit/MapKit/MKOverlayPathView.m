//
//  MKOverlayPathView.m
//  MapKit
//
//  Created by Rick Fillion on 7/12/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import "MKOverlayPathView.h"
#import "UIColor+Additions.h"

@implementation MKOverlayPathView

@synthesize fillColor, strokeColor, lineWidth;

- (id)initWithOverlay:(id <MKOverlay>)anOverlay
{
    if (self = [super initWithOverlay:anOverlay]) {
        self.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.3f];
        self.strokeColor = [UIColor redColor];
        self.lineWidth = 1.0;
    }
    return self;
}

- (NSDictionary *)options
{
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:[super options]];
    
    [options setObject:[NSNumber numberWithFloat:lineWidth] forKey:@"strokeWeight"];
    [options setObject:[NSNumber numberWithBool:NO] forKey:@"clickable"];

    if (fillColor) {
        [options setObject:[fillColor hexString] forKey:@"fillColor"];
        CGFloat alpha;
        [fillColor getWhite:nil alpha:&alpha];
        [options setObject:[NSNumber numberWithFloat:alpha] forKey:@"fillOpacity"];
    }
    if (strokeColor) {
        [options setObject:[strokeColor hexString] forKey:@"strokeColor"];
        CGFloat alpha;
        [strokeColor getWhite:nil alpha:&alpha];
        [options setObject:[NSNumber numberWithFloat:alpha] forKey:@"strokeOpacity"];

    }
    
    return [options copy];
}

@end
