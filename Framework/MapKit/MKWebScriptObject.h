//
//  WebScriptObject.h
//  YAMapKit
//
//  Created by kishikawa katsumi on 2012/09/21.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKWebScriptEngine;

@interface MKWebScriptObject : NSObject

- (id)initWithScriptEngine:(MKWebScriptEngine *)engine script:(NSString *)script;
- (id)scriptEngine;
- (id)scriptObject;

@end
