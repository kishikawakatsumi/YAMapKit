//
//  MKView.m
//  MapKit
//
//  Created by Rick Fillion on 7/19/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import "MKView.h"
#import "WebScriptEngine.h"
#import "WebScriptObject.h"

@implementation MKView

- (NSString *)viewPrototypeName
{
    return @"MVCObject";
}

- (NSDictionary *)options
{
    return [NSDictionary dictionary];
}

- (void)draw:(WebScriptObject *)overlayScriptObject
{
    WebScriptEngine *windowScriptObject = overlayScriptObject.scriptEngine;
    NSDictionary *theOptions = [self options];
    
    for (NSString *key in [theOptions allKeys]) {
        id value = [theOptions objectForKey:key];
        [windowScriptObject callWebScriptMethod:@"setOverlayOption" withArguments:[NSArray arrayWithObjects:overlayScriptObject, key, value, nil]];
    }
}

- (WebScriptObject *)overlayScriptObjectFromMapScriptObject:(WebScriptObject *)mapScriptObject
{
    NSString *script = [NSString stringWithFormat:@"new %@()", [self viewPrototypeName]];
    WebScriptObject *object = [mapScriptObject.scriptEngine evaluateWebScript:script];
    return object;
}

@end
