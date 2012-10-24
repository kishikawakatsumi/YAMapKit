//
//  MKView.m
//  MapKit
//
//  Created by Rick Fillion on 7/19/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import <MapKit/MKView.h>
#import <MapKit/MKWebScriptEngine.h>
#import <MapKit/MKWebScriptObject.h>

@implementation MKView

- (NSString *)viewPrototypeName
{
    return @"MVCObject";
}

- (NSDictionary *)options
{
    return [NSDictionary dictionary];
}

- (void)draw:(MKWebScriptObject *)overlayScriptObject
{
    MKWebScriptEngine *windowScriptObject = overlayScriptObject.scriptEngine;
    NSDictionary *theOptions = [self options];
    
    for (NSString *key in [theOptions allKeys]) {
        id value = [theOptions objectForKey:key];
        [windowScriptObject callWebScriptMethod:@"setOverlayOption" withArguments:[NSArray arrayWithObjects:overlayScriptObject, key, value, nil]];
    }
}

- (MKWebScriptObject *)overlayScriptObjectFromMapScriptObject:(MKWebScriptObject *)mapScriptObject
{
    NSString *script = [NSString stringWithFormat:@"new %@()", [self viewPrototypeName]];
    MKWebScriptObject *object = [mapScriptObject.scriptEngine evaluateWebScript:script];
    return object;
}

@end
