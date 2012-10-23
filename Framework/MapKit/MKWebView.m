//
//  MKWebView.m
//  YAMapKit
//
//  Created by kishikawa katsumi on 2012/09/21.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import "MKWebView.h"
#import "WebScriptEngine.h"
#import "WebScriptObject.h"

@interface MKWebView ()

@property (nonatomic, readwrite) WebScriptObject *webScriptObject;

@end

@implementation MKWebView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    _lastHitTestDate = [NSDate date];
    return [super hitTest:point withEvent:event];
}

- (WebScriptObject *)windowScriptObject {
    if (!_webScriptObject) {
        _webScriptEngine = [[WebScriptEngine alloc] initWithWebView:self];
        _webScriptObject = [[WebScriptObject alloc] initWithScriptEngine:_webScriptEngine script:nil];
    }
    
    return _webScriptObject;
}

@end
