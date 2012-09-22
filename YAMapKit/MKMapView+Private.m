//
//  MKMapView+Private.m
//  MapKit
//
//  Created by Rick Fillion on 11-06-28.
//  Copyright 2011 Centrix.ca. All rights reserved.
//

#import "MKMapView+Private.h"
#import "MKWebView.h"
#import "MKUserLocation.h"

@interface MKMapView () <UIWebViewDelegate>

@end

@implementation MKMapView (Private)

- (void)customInit
{
    // Initialization code here.    
    if (!webView) {
        webView = [[MKWebView alloc] initWithFrame:[self bounds]];
    }
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.delegate = self;
    
    // Create the overlay data structures
    overlays = [[NSMutableArray alloc] init];
    overlayViews = [NSMapTable strongToStrongObjectsMapTable];
    overlayScriptObjects = [NSMapTable strongToStrongObjectsMapTable];
    
    // Create the annotation data structures
    annotations = [[NSMutableArray alloc] init];
    selectedAnnotations = [[NSMutableArray alloc] init];
    annotationViews = [NSMapTable strongToStrongObjectsMapTable];
    annotationScriptObjects = [NSMapTable strongToStrongObjectsMapTable];
    
    [self loadMapKitHtml];
    
    // Create a user location
    self.userLocation = [[MKUserLocation alloc] init];
}

- (void)loadMapKitHtml
{
    // TODO : make this suck less.
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[MKMapView class]];
    NSString *path = [frameworkBundle pathForResource:@"MapKit" ofType:@"html"];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
//    [[[webView mainFrame] frameView] setAllowsScrolling:NO];
    [self addSubview:webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [request.URL.absoluteString hasSuffix:@"MapKit.html"];
}

@end
