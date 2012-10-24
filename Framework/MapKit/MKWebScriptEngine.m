//
//  WebScriptEngine.m
//  YAMapKit
//
//  Created by kishikawa katsumi on 2012/09/22.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import <MapKit/MKWebScriptEngine.h>
#import <MapKit/MKWebScriptObject.h>

@interface MKWebScriptEngine ()

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation MKWebScriptEngine

- (id)initWithWebView:(UIWebView *)webView
{
    self = [super init];
    if (self) {
        self.webView = webView;
    }
    return self;
}

- (id)evaluateWebScript:(NSString *)script {
    static NSUInteger objectNumber = 0;
    
    if ([script hasPrefix:@"new "]) {
        NSString *varName = [NSString stringWithFormat:@"object%d", objectNumber++];
        NSString *newScript = [NSString stringWithFormat:@"var %@ = %@", varName, script];
//        NSLog(@"%@", newScript);
        [self.webView stringByEvaluatingJavaScriptFromString:newScript];
        MKWebScriptObject *scriptObject = [[MKWebScriptObject alloc] initWithScriptEngine:self script:varName];
        return scriptObject;
    } else {
        return [self.webView stringByEvaluatingJavaScriptFromString:script];
    }
}

- (id)callWebScriptMethod:(NSString *)name withArguments:(NSArray *)args {
    NSMutableString *script = [NSMutableString stringWithString:name];
    [script appendString:@"("];
    for (NSInteger i = 0; i < args.count; i++) {
        id arg = args[i];
        if ([arg isKindOfClass:[MKWebScriptObject class]]) {
            MKWebScriptObject *scriptObject = (MKWebScriptObject *)arg;
            [script appendFormat:@"%@", scriptObject.scriptObject];
        } else if ([arg isKindOfClass:[NSNumber class]]) {
            [script appendFormat:@"%@", arg];
        } else if ([arg isKindOfClass:[NSArray class]]) {
            [script appendFormat:@"[%@]", [arg componentsJoinedByString:@","]];
        } else {
            [script appendFormat:@"'%@'", arg];
        }
        if (i < args.count - 1) {
            [script appendString:@", "];
        }
    }
    [script appendString:@");"];
//    NSLog(@"%@", script);
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    return self;
}

@end
