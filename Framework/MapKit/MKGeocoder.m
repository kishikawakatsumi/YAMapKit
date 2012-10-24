//
//  MKGeocoder.m
//  MapKit
//
//  Created by Rick Fillion on 11-01-02.
//  Copyright 2011 Centrix.ca. All rights reserved.
//

/*
 Note:  Read comments at the top of MKReverseGeocoder, as they apply here too.
 */

#import <MapKit/MKGeocoder.h>
#import <MapKit/MKPlacemark.h>
#import <MapKit/MKWebView.h>
#import <MapKit/MKWebScriptEngine.h>
#import <MapKit/MKWebScriptObject.h>

@interface MKGeocoder () <UIWebViewDelegate>

@end

@interface MKGeocoder (WebViewIntegration)

- (void)didSucceedWithResult:(NSString *)jsonEncodedGeocoderResult;
- (void)didFailWithError:(NSString *)status;
- (void)didReachQueryLimit;

@end

@interface MKGeocoder (Private)

- (void)createWebView;
- (void)destroyWebView;
- (void)_start;

@end

@implementation MKGeocoder

@synthesize delegate;
@synthesize address;
@synthesize coordinate;
@synthesize querying;

+ (NSString *) webScriptNameForSelector:(SEL)sel
{
    NSString *name = nil;
    
    if (sel == @selector(didSucceedWithResult:))
    {
        name = @"didSucceedWithResult";
    }
    
    if (sel == @selector(didFailWithError:))
    {
        name = @"didFailWithError";
    }
    
    if (sel == @selector(didReachQueryLimit))
    {
	name = @"didReachQueryLimit";
    }
    
    
    return name;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
    if (aSelector == @selector(didSucceedWithResult:))
    {
        return NO;
    }
    
    if (aSelector == @selector(didFailWithError:))
    {
        return NO;
    }
    
    if (aSelector == @selector(didReachQueryLimit))
    {
	return NO;
    }
    
    return YES;
}


- (id)initWithAddress:(NSString *)anAddress
{
    if (self = [super init])
    {
        [self createWebView];
        address = anAddress;
        hasOriginatingCoordinate = NO;
    }
    return self;
}

- (id)initWithAddress:(NSString *)anAddress nearCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    if (self = [super init])
    {
        [self createWebView];
        address = anAddress;
        hasOriginatingCoordinate = YES;
        originatingCoordinate = aCoordinate;
    }
    return self;
}

- (void)dealloc
{
    [self destroyWebView];
}

- (void)start
{
    if (querying)
        return;
    querying = YES;
    if (webViewLoaded)
        [self _start];
}

- (void)cancel
{
    if (!querying)
        return;
    querying = NO;
}

#pragma mark WebViewIntegration

- (void)didSucceedWithResult:(NSString *)jsonEncodedGeocoderResult;
{
    if (!querying)
        return;
    
    id result = [NSJSONSerialization JSONObjectWithData:[jsonEncodedGeocoderResult dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    MKPlacemark *aPlacemark = [[MKPlacemark alloc] initWithGoogleGeocoderResult: result];
    coordinate = aPlacemark.coordinate;
    
    if (delegate && [delegate respondsToSelector:@selector(geocoder:didFindCoordinate:)])
    {
        [delegate geocoder:self didFindCoordinate:self.coordinate];
    }

    querying = NO;
}

- (void)didFailWithError:(NSString *)domain
{
    if (!querying)
        return;
    
    NSError *error = [NSError errorWithDomain:domain code:0 userInfo:nil];
    // TODO create error
    
    if (delegate && [delegate respondsToSelector:@selector(geocoder:didFailWithError:)])
    {
        [delegate geocoder:self didFailWithError:error];
    }
    querying = NO;
}

- (void)didReachQueryLimit
{
    // Retry again in half a second
    if (self.querying)
    {
	[self performSelector:@selector(_start) withObject:nil afterDelay:0.5];
    }
}

#pragma mark WebFrameLoadDelegate

//- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame
//{
//    [windowScriptObject setValue:self forKey:@"MKGeocoder"];
//}

- (void)webView:(MKWebView *)webView didFailLoadWithError:(NSError *)error
{
//    [[webView windowScriptObject] setValue:self forKey:@"MKGeocoder"];
//    webViewLoaded = YES;
//    if (self.querying && [sender mainFrame] == frame)
//    {
//        [self _start];
//    }
}

#pragma mark Private

- (void)createWebView
{
    webView = [[MKWebView alloc] initWithFrame:CGRectZero];
    webView.delegate = self;
    
#include "MapKit.html.h"
    NSString *html = [[NSString alloc] initWithBytes:MapKit_html length:MapKit_html_len encoding:NSUTF8StringEncoding];
    [webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:@"MapKit.html"]];
}

- (void)destroyWebView
{
    webView = nil;
}

- (void)_start
{
    NSArray *args = nil;
    if (hasOriginatingCoordinate)
        args = @[self.address, @(originatingCoordinate.latitude), @(originatingCoordinate.longitude)];
    else {
        args = @[self.address];
    }

    MKWebScriptObject *webScriptObject = [webView windowScriptObject];
    id val = [webScriptObject.scriptEngine callWebScriptMethod:@"geocode" withArguments:args];
    if (!val)
    {
        // something went wrong, call the failure delegate
        [self performSelector:@selector(_start) withObject:nil afterDelay:0.1];
    }
}

@end
