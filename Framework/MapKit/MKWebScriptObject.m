//
//  MKWebScriptObject.m
//  YAMapKit
//
//  Created by kishikawa katsumi on 2012/09/21.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import <MapKit/MKWebScriptObject.h>
#import <MapKit/MKWebScriptEngine.h>

@interface MKWebScriptObject ()

@property (strong, nonatomic) MKWebScriptEngine *scriptEngine;
@property (strong, nonatomic) NSString *scriptObject;

@end

@implementation MKWebScriptObject

- (id)initWithScriptEngine:(MKWebScriptEngine *)engine script:(NSString *)script {
    self = [super init];
    if (self) {
        self.scriptEngine = engine;
        self.scriptObject = script;
    }
    return self;
}

- (id)scriptEngine
{
    return _scriptEngine;
}

- (id)scriptObject
{
    return _scriptObject;
}

@end
