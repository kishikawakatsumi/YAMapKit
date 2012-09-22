//
//  WebScriptObject.h
//  YAMapKit
//
//  Created by katsumi-kishikawa on 2012/09/21.
//  Copyright (c) 2012年 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WebScriptEngine;

@interface WebScriptObject : NSObject

- (id)initWithScriptEngine:(WebScriptEngine *)engine script:(NSString *)script;
- (id)scriptEngine;
- (id)scriptObject;

@end
