//
//  MKCircleView.m
//  MapKit
//
//  Created by Rick Fillion on 7/12/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import <MapKit/MKCircleView.h>
#import <MapKit/MKCircle.h>
#import <MapKit/MKWebScriptObject.h>

@implementation MKCircleView

- (id)initWithCircle:(MKCircle *)aCircle
{
    if (self = [super initWithOverlay:aCircle]) {
        
    }
    return self;
}

- (MKCircle *)circle
{
    return [super overlay];
}

- (NSString *)viewPrototypeName
{
    return @"google.maps.Circle";
}

- (NSDictionary *)options
{
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:[super options]];
    
    [options setObject:[NSNumber numberWithFloat:[self circle].radius] forKey:@"radius"];
    
    if (latlngCenter) {
        [options setObject:latlngCenter forKey:@"center"];
    }
    
    return [options copy];
}

- (void)draw:(MKWebScriptObject *)overlayScriptObject
{
    NSString *script = [NSString stringWithFormat:@"new google.maps.LatLng(%f, %f)", self.circle.coordinate.latitude, self.circle.coordinate.longitude];
    latlngCenter = [[MKWebScriptObject alloc] initWithScriptEngine:overlayScriptObject.scriptEngine script:script];
    [super draw:overlayScriptObject];
}

@end
