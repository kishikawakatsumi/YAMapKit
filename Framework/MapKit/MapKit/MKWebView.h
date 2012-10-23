//
//  MKWebView.h
//  YAMapKit
//
//  Created by kishikawa katsumi on 2012/09/21.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebScriptEngine;
@class WebScriptObject;

@interface MKWebView : UIWebView

@property (nonatomic, readonly) NSDate *lastHitTestDate;
@property (nonatomic, readonly) WebScriptEngine *webScriptEngine;

- (WebScriptObject *)windowScriptObject;

@end
