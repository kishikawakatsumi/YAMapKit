//
//  MKWebView.h
//  YAMapKit
//
//  Created by kishikawa katsumi on 2012/09/21.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKWebScriptEngine;
@class MKWebScriptObject;

@interface MKWebView : UIWebView

@property (nonatomic, readonly) NSDate *lastHitTestDate;
@property (nonatomic, readonly) MKWebScriptEngine *webScriptEngine;

- (MKWebScriptObject *)windowScriptObject;

@end
