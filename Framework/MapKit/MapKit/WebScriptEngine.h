//
//  WebScriptEngine.h
//  YAMapKit
//
//  Created by kishikawa katsumi on 2012/09/22.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebScriptEngine : NSObject

- (id)initWithWebView:(UIWebView *)webView;
- (id)evaluateWebScript:(NSString *)script;
- (id)callWebScriptMethod:(NSString *)name withArguments:(NSArray *)args;

@end
