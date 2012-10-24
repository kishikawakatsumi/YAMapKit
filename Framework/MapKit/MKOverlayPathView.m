//
//  MKOverlayPathView.m
//  MapKit
//
//  Created by Rick Fillion on 7/12/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import <MKOverlayPathView.h>

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
        [options setObject:[self convertColorToHexStringWithColor:fillColor] forKey:@"fillColor"];
        [options setObject:@(CGColorGetAlpha(fillColor.CGColor)) forKey:@"fillOpacity"];
    }
    if (strokeColor) {
        [options setObject:[self convertColorToHexStringWithColor:strokeColor] forKey:@"strokeColor"];
        [options setObject:@(CGColorGetAlpha(strokeColor.CGColor)) forKey:@"strokeOpacity"];

    }
    
    return [options copy];
}

- (NSString *)convertColorToHexStringWithColor:(UIColor *)color
{
    CGFloat redFloatValue, greenFloatValue, blueFloatValue;
    int redIntValue, greenIntValue, blueIntValue;
    NSString *redHexValue, *greenHexValue, *blueHexValue;
    
    //Convert the UIColor to the RGB color space before we can access its components
    UIColor *convertedColor = color;
    
    if (convertedColor) {
        // Get the red, green, and blue components of the color
        [convertedColor getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:NULL];
        
        // Convert the components to numbers (unsigned decimal integer) between 0 and 255
        redIntValue = redFloatValue * 255.99999f;
        greenIntValue = greenFloatValue * 255.99999f;
        blueIntValue = blueFloatValue * 255.99999f;
        
        // Convert the numbers to hex strings
        redHexValue = [NSString stringWithFormat:@"%02x", redIntValue];
        greenHexValue = [NSString stringWithFormat:@"%02x", greenIntValue];
        blueHexValue = [NSString stringWithFormat:@"%02x", blueIntValue];
        
        // Concatenate the red, green, and blue components' hex strings together with a "#"
        return [NSString stringWithFormat:@"#%@%@%@", redHexValue, greenHexValue, blueHexValue];
    }
    return nil;
}

@end
