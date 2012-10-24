//
//  MKWebView.m
//  YAMapKit
//
//  Created by kishikawa katsumi on 2012/09/21.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import <MapKit/MKWebView.h>
#import <MapKit/MKWebScriptEngine.h>
#import <MapKit/MKWebScriptObject.h>

@interface MKWebView ()

@property (nonatomic, readwrite) MKWebScriptObject *webScriptObject;

@end

@implementation MKWebView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    _lastHitTestDate = [NSDate date];
    return [super hitTest:point withEvent:event];
}

- (MKWebScriptObject *)windowScriptObject {
    if (!_webScriptObject) {
        _webScriptEngine = [[MKWebScriptEngine alloc] initWithWebView:self];
        _webScriptObject = [[MKWebScriptObject alloc] initWithScriptEngine:_webScriptEngine script:nil];
    }
    
    return _webScriptObject;
}

@end
