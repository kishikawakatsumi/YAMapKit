//
//  WebScriptObject.m
//  YAMapKit
//
//  Created by kishikawa katsumi on 2012/09/21.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import "WebScriptObject.h"
#import "WebScriptEngine.h"

@interface WebScriptObject ()

@property (strong, nonatomic) WebScriptEngine *scriptEngine;
@property (strong, nonatomic) NSString *scriptObject;

@end

@implementation WebScriptObject

- (id)initWithScriptEngine:(WebScriptEngine *)engine script:(NSString *)script {
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
