//
//  MKMapView.m
//  YAMapKit
//
//  Created by kishikawa katsumi on 2012/09/21.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import "MKMapView.h"
#import "MKUserLocation.h"
#import "MKCircleView.h"
#import "MKCircle.h"
#import "MKPolyline.h"
#import "MKPolygon.h"
#import "MKAnnotationView.h"
#import "MKPointAnnotation.h"
#import "MKWebView.h"
#import "WebScriptEngine.h"
#import "WebScriptObject.h"

typedef void (^DelayedAction)();

static MKWebView *webView;

@interface MKUserLocation (Private)

- (void)_setLocation:(CLLocation *)aLocation;
- (void)_setUpdating:(BOOL)value;

@end

@interface MKMapView () <UIWebViewDelegate, CLLocationManagerDelegate> {
    BOOL webViewLoaded;
    NSMutableArray *actions;
}

@end

#pragma mark - MKMapView+Private

@implementation MKMapView (Private)

- (void)customInit
{
    // Initialization code here.
    if (!webView) {
        webView = [[MKWebView alloc] initWithFrame:self.bounds];
    }
    if (!actions) {
        actions = [[NSMutableArray alloc] init];
    }
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.delegate = self;
    
    // Create the overlay data structures
    overlays = [[NSMutableArray alloc] init];
    overlayViews = [[NSMutableDictionary alloc] init];
    overlayScriptObjects = [[NSMutableDictionary alloc] init];
    
    // Create the annotation data structures
    annotations = [[NSMutableArray alloc] init];
    selectedAnnotations = [[NSMutableArray alloc] init];
    annotationViews = [[NSMutableDictionary alloc] init];
    annotationScriptObjects = [[NSMutableDictionary alloc] init];
    
    [self loadMapKitHtml];
    
    // Create a user location
    self.userLocation = [[MKUserLocation alloc] init];
}

- (void)loadMapKitHtml
{
    webView.scrollView.scrollEnabled = NO;
#include "MapKit.html.h"
    [webView loadHTMLString:[NSString stringWithCString:MapKit_html length:MapKit_html_len] baseURL:[NSURL fileURLWithPath:@"MapKit.html"]];
    [self addSubview:webView];
}

- (void)invokeLater:(DelayedAction)action
{
    if (webViewLoaded) {
        action();
    } else {
        [actions addObject:[action copy]];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return [request.URL.absoluteString hasSuffix:@"MapKit.html"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    webViewLoaded = YES;
    for (DelayedAction action in actions) {
        action();
    }
    
    [actions removeAllObjects];
}

@end

#pragma mark - MKMapView+DelegateWrappers

@implementation MKMapView (DelegateWrappers)

- (void)delegateRegionWillChangeAnimated:(BOOL)animated
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:)]) {
        [self.delegate mapView:self regionWillChangeAnimated:animated];
    }
}

- (void)delegateRegionDidChangeAnimated:(BOOL)animated
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)]) {
        [self.delegate mapView:self regionDidChangeAnimated:animated];
    }
}

- (void)delegateDidUpdateUserLocation
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:didUpdateUserLocation:)]) {
        [self.delegate mapView:self didUpdateUserLocation:self.userLocation];
    }
}

- (void)delegateDidFailToLocateUserWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:didFailToLocateUserWithError:)]) {
        [self.delegate mapView:self didFailToLocateUserWithError:error];
    }
}

- (void)delegateWillStartLocatingUser
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapViewWillStartLocatingUser:)]) {
        [self.delegate mapViewWillStartLocatingUser:self];
    }
}

- (void)delegateDidStopLocatingUser
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapViewDidStopLocatingUser:)]) {
        [self.delegate mapViewDidStopLocatingUser:self];
    }
}

- (void)delegateDidAddOverlayViews:(NSArray *)someOverlayViews
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:didAddOverlayViews:)]) {
        [self.delegate mapView:self didAddOverlayViews:someOverlayViews];
    }
}

- (void)delegateDidAddAnnotationViews:(NSArray *)someAnnotationViews
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:didAddAnnotationViews:)]) {
        [self.delegate mapView:self didAddAnnotationViews:someAnnotationViews];
    }
}

- (void)delegateDidSelectAnnotationView:(MKAnnotationView *)view
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]) {
        [self.delegate mapView:self didSelectAnnotationView:view];
    }
}

- (void)delegateDidDeselectAnnotationView:(MKAnnotationView *)view
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:didDeselectAnnotationView:)]) {
        [self.delegate mapView:self didDeselectAnnotationView:view];
    }
}

- (void)delegateAnnotationView:(MKAnnotationView *)annotationView
            didChangeDragState:(MKAnnotationViewDragState)newState
                  fromOldState:(MKAnnotationViewDragState)oldState
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:annotationView:didChangeDragState:fromOldState:)]) {
        [self.delegate mapView:self annotationView:annotationView didChangeDragState:newState fromOldState:oldState];
    }
}

- (void)delegateWillStartLoadingMap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapViewWillStartLoadingMap:)]) {
        [self.delegate mapViewWillStartLoadingMap:self];
    }
}

- (void)delegateDidFinishLoadingMap;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapViewDidFinishLoadingMap:)]) {
        [self.delegate mapViewDidFinishLoadingMap:self];
    }
}

- (void)delegateDidFailLoadingMapWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapViewDidFailLoadingMap:withError:)]) {
        [self.delegate mapViewDidFailLoadingMap:self withError:error];
    }
}

// MacMapKit additions
- (void)delegateUserDidClickAndHoldAtCoordinate:(CLLocationCoordinate2D)coordinate;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:userDidClickAndHoldAtCoordinate:)]) {
        [self.delegate mapView:self userDidClickAndHoldAtCoordinate:coordinate];
    }
    
}

- (NSArray *)delegateContextMenuItemsForAnnotationView:(MKAnnotationView *)view
{
    NSArray *items = [NSArray array];
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:contextMenuItemsForAnnotationView:)]) {
        items = [self.delegate mapView:self contextMenuItemsForAnnotationView:view];
    }
    return items;
}

@end

// MKAnnotation has a readonly coordinate property, but draggable annotations
// need the ability to set them.
@protocol MKDraggableAnnotation <NSObject>

// Center latitude and longitude of the annotion view.
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

#pragma mark - MKMapView+WebViewIntegration

@implementation MKMapView (WebViewIntegration)

+ (NSString *) webScriptNameForSelector:(SEL)sel
{
    NSString *name = nil;
    
    if (sel == @selector(annotationScriptObjectSelected:)) {
        name = @"annotationScriptObjectSelected";
    }
    
    if (sel == @selector(webviewReportingRegionChange)) {
        name = @"webviewReportingRegionChange";
    }
    
    if (sel == @selector(webviewReportingLoadFailure)) {
        name = @"webviewReportingLoadFailure";
    }
    
    if (sel == @selector(webviewReportingClick:)) {
        name = @"webviewReportingClick";
    }
    
    if (sel == @selector(webviewReportingReloadGmaps)) {
        name = @"webviewReportingReloadGmaps";
    }
    
    if (sel == @selector(annotationScriptObjectDragStart:)) {
        name = @"annotationScriptObjectDragStart";
    }
    
    if (sel == @selector(annotationScriptObjectDrag:)) {
        name = @"annotationScriptObjectDrag";
    }
    
    if (sel == @selector(annotationScriptObjectDragEnd:)) {
        name = @"annotationScriptObjectDragEnd";
    }
    
    if (sel == @selector(annotationScriptObjectRightClick:)) {
        name = @"annotationScriptObjectRightClick";
    }
    
    return name;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
    if (aSelector == @selector(annotationScriptObjectSelected:)) {
        return NO;
    }
    
    if (aSelector == @selector(webviewReportingRegionChange)) {
        return NO;
    }
    
    if (aSelector == @selector(webviewReportingLoadFailure)) {
        return NO;
    }
    
    if (aSelector == @selector(webviewReportingClick:)) {
        return NO;
    }
    
    if (aSelector == @selector(webviewReportingReloadGmaps)) {
        return NO;
    }
    
    if (aSelector == @selector(annotationScriptObjectDragStart:)) {
        return NO;
    }
    
    if (aSelector == @selector(annotationScriptObjectDrag:)) {
        return NO;
    }
    
    if (aSelector == @selector(annotationScriptObjectDragEnd:)) {
        return NO;
    }
    
    if (aSelector == @selector(annotationScriptObjectRightClick:)) {
        return NO;
    }
    
    return YES;
}

- (void)setUserLocationMarkerVisible:(BOOL)visible
{
    DelayedAction action = ^
    {
        NSArray *args = [NSArray arrayWithObjects:@(visible), nil];
        WebScriptObject *webScriptObject = [webView windowScriptObject];
        [webScriptObject.scriptEngine callWebScriptMethod:@"setUserLocationVisible" withArguments:args];
    };
    
    [self invokeLater:action];
}

- (void)updateUserLocationMarkerWithLocaton:(CLLocation *)location
{
    DelayedAction action = ^
    {
        WebScriptObject *webScriptObject = [webView windowScriptObject];
        
        CLLocationAccuracy accuracy = MAX(location.horizontalAccuracy, location.verticalAccuracy);
        NSArray *args = @[[NSNumber numberWithDouble: accuracy]];
        [webScriptObject.scriptEngine callWebScriptMethod:@"setUserLocationRadius" withArguments:args];
        args = @[[NSNumber numberWithDouble:location.coordinate.latitude], [NSNumber numberWithDouble:location.coordinate.longitude]];
        [webScriptObject.scriptEngine callWebScriptMethod:@"setUserLocationLatitudeLongitude" withArguments:args];
    };
    
    [self invokeLater:action];
}

- (void)updateOverlayZIndexes
{
    //NSLog(@"updating overlay z indexes of :%@", overlays);
    NSUInteger zIndex = 4000; // some arbitrary starting value
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    for (id <MKOverlay> overlay in self.overlays) {
        WebScriptObject *overlayScriptObject = [overlayScriptObjects objectForKey:@([overlay hash])];
        if (overlayScriptObject) {
            NSArray *args = [NSArray arrayWithObjects: overlayScriptObject, @"zIndex", [NSNumber numberWithInteger:zIndex], nil];
            [webScriptObject.scriptEngine callWebScriptMethod:@"setOverlayOption" withArguments:args];
        }
        zIndex++;
    }
}

- (void)updateAnnotationZIndexes {
    NSUInteger zIndex = 6000; // some arbitrary starting value
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    
    NSArray *sortedAnnotations = [self.annotations sortedArrayUsingComparator: ^(id <MKAnnotation> ann1, id <MKAnnotation> ann2) {
        if (ann1.coordinate.latitude < ann2.coordinate.latitude) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (ann1.coordinate.latitude > ann2.coordinate.latitude) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    for (id <MKAnnotation> annotation in sortedAnnotations) {
        WebScriptObject *overlayScriptObject = (WebScriptObject *)[annotationScriptObjects objectForKey: annotation];
        if (overlayScriptObject) {
            NSArray *args = [NSArray arrayWithObjects: overlayScriptObject, @"zIndex", [NSNumber numberWithInteger:zIndex], nil];
            [webScriptObject.scriptEngine callWebScriptMethod:@"setOverlayOption" withArguments:args];
        }
        zIndex++;
    }
}

- (void)annotationScriptObjectSelected:(WebScriptObject *)annotationScriptObject
{
    // Deselect everything that was selected
    [self setSelectedAnnotations:[NSArray array]];
    
    for (id <MKAnnotation> annotation in self.annotations) {
        WebScriptObject *scriptObject = (WebScriptObject *)[annotationScriptObjects objectForKey: annotation];
        if ([scriptObject isEqual:annotationScriptObject]) {
            [self selectAnnotation:annotation animated:NO];
        }
    }
}

- (void)annotationScriptObjectDragStart:(WebScriptObject *)annotationScriptObject
{
    //NSLog(@"annotationScriptObjectDragStart:");
    for (id <MKAnnotation> annotation in self.annotations) {
        WebScriptObject *scriptObject = [annotationScriptObjects objectForKey: annotation];
        if ([scriptObject isEqual:annotationScriptObject]) {
            // it has to be an annotation that actually supports moving.
            if ([annotation respondsToSelector:@selector(setCoordinate:)]) {
                MKAnnotationView *view = [annotationViews objectForKey: annotation];
                view.dragState = MKAnnotationViewDragStateStarting;
                [self delegateAnnotationView:view didChangeDragState:MKAnnotationViewDragStateStarting fromOldState:MKAnnotationViewDragStateNone];
            }
        }
    }
}

- (void)annotationScriptObjectDrag:(WebScriptObject *)annotationScriptObject
{
    //NSLog(@"annotationScriptObjectDrag:");
    for (id <MKAnnotation> annotation in self.annotations) {
        WebScriptObject *scriptObject = [annotationScriptObjects objectForKey: annotation];
        if ([scriptObject isEqual:annotationScriptObject]) {
            // it has to be an annotation that actually supports moving.
            if ([annotation respondsToSelector:@selector(setCoordinate:)]) {
                CLLocationCoordinate2D newCoordinate = [self coordinateForAnnotationScriptObject:annotationScriptObject];
                [(id <MKDraggableAnnotation> )annotation setCoordinate:newCoordinate];
                MKAnnotationView *view = [annotationViews objectForKey: annotation];
                if (view.dragState != MKAnnotationViewDragStateDragging) {
                    view.dragState = MKAnnotationViewDragStateNone;
                    [self delegateAnnotationView:view didChangeDragState:MKAnnotationViewDragStateDragging fromOldState:MKAnnotationViewDragStateStarting];
                }
            }
        }
    }
}

- (void)annotationScriptObjectDragEnd:(WebScriptObject *)annotationScriptObject
{
    //NSLog(@"annotationScriptObjectDragEnd");
    for (id <MKAnnotation> annotation in self.annotations) {
        WebScriptObject *scriptObject = [annotationScriptObjects objectForKey: annotation];
        if ([scriptObject isEqual:annotationScriptObject]) {
            // it has to be an annotation that actually supports moving.
            if ([annotation respondsToSelector:@selector(setCoordinate:)]) {
                CLLocationCoordinate2D newCoordinate = [self coordinateForAnnotationScriptObject:annotationScriptObject];
                [(id <MKDraggableAnnotation>)annotation setCoordinate:newCoordinate];
                MKAnnotationView *view = [annotationViews objectForKey: annotation];
                view.dragState = MKAnnotationViewDragStateNone;
                [self delegateAnnotationView:view didChangeDragState:MKAnnotationViewDragStateNone fromOldState:MKAnnotationViewDragStateDragging];
            }
        }
    }
}

- (void)webviewReportingRegionChange
{
    [self delegateRegionDidChangeAnimated:NO];
    [self willChangeValueForKey:@"centerCoordinate"];
    [self didChangeValueForKey:@"centerCoordinate"];
    [self willChangeValueForKey:@"region"];
    [self didChangeValueForKey:@"region"];
}

- (void)webviewReportingLoadFailure
{
    NSError *error = [NSError errorWithDomain:@"ca.centrix.MapKit" code:0 userInfo:nil];
    [self delegateDidFailLoadingMapWithError:error];
}

- (void)webviewReportingClick:(NSString *)jsonEncodedLatLng
{
    // Deselect all annoations
    NSArray * currentlySelectedAnnotations = [self selectedAnnotations];
    for (id <MKAnnotation> annotation in currentlySelectedAnnotations) {
        [self deselectAnnotation:annotation animated:YES];
    }
    
    // Give the delegate the opportunity to do something
    // if the clicked and held for more than 0.5 secs.
    NSTimeInterval timeSinceMouseDown = [[NSDate date] timeIntervalSinceDate:[webView lastHitTestDate]];
    if (timeSinceMouseDown > 0.5) {
        NSDictionary *latlong = [NSJSONSerialization JSONObjectWithData:[jsonEncodedLatLng dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        NSNumber *latitude = [latlong objectForKey:@"latitude"];
        NSNumber *longitude = [latlong objectForKey:@"longitude"];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [latitude doubleValue];
        coordinate.longitude = [longitude doubleValue];
        [self delegateUserDidClickAndHoldAtCoordinate:coordinate];
    }
}

- (void)webviewReportingReloadGmaps
{
    [self loadMapKitHtml];
}

- (void)annotationScriptObjectRightClick:(WebScriptObject *)annotationScriptObject
{
//    //NSLog(@"annotationScriptObjectRightClick");
//
//    // Find the actual MKAnnotationView
//    MKAnnotationView *annotationView = nil;
//    for (id <MKAnnotation> annotation in self.annotations) {
//        WebScriptObject *scriptObject = (WebScriptObject *)[annotationScriptObjects objectForKey: annotation];
//        if ([scriptObject isEqual:annotationScriptObject])
//        {
//	    annotationView = (MKAnnotationView *)[annotationViews objectForKey: annotation];
//        }
//    }
//
//    // If not found, bail.
//    if (!annotationView)
//	return;
//
//
//    // Create a corresponding NSEvent object so that we can popup a context menu
//    CGPoint pointOnScreen = [NSEvent mouseLocation];
//    CGPoint pointInBase = [[self window] convertScreenToBase: pointOnScreen];
//
//    NSEvent *event = [NSEvent mouseEventWithType:NSRightMouseUp
//                                        location:pointInBase
//				   modifierFlags:[NSEvent modifierFlags]
//				       timestamp:0
//				    windowNumber:[[self window] windowNumber]
//					 context:[NSGraphicsContext currentContext]
//				     eventNumber:0
//				      clickCount:1
//					pressure:1.0];
//
//    // Create the menu and display it if it has anything.
//    NSMenu *menu = [[[NSMenu alloc] initWithTitle:@""] autorelease];
//    NSArray *items = [self delegateContextMenuItemsForAnnotationView:annotationView];
//    if ([items count] > 0)
//    {
//	for (NSMenuItem *item in items)
//	{
//	    [menu addItem:item];
//	}
//	[NSMenu popUpContextMenu:menu withEvent:event forView:self];
//    }
}

- (CLLocationCoordinate2D)coordinateForAnnotationScriptObject:(WebScriptObject *)annotationScriptObject
{
    CLLocationCoordinate2D coord;
    coord.latitude = 0.0;
    coord.longitude = 0.0;
    WebScriptObject *windowScriptObject = [webView windowScriptObject];
    
    NSString *json = [windowScriptObject.scriptEngine callWebScriptMethod:@"coordinateForAnnotation" withArguments:[NSArray arrayWithObject:annotationScriptObject]];
    NSDictionary *latlong = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSNumber *latitude = [latlong objectForKey:@"latitude"];
    NSNumber *longitude = [latlong objectForKey:@"longitude"];
    
    coord.latitude = [latitude doubleValue];
    coord.longitude = [longitude doubleValue];
    
    return coord;
}

@end

#pragma mark - MKMapView+Additions

@implementation MKMapView (Additions)

- (void)addJavascriptTag:(NSString *)urlString
{
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    NSURL *url = [NSURL URLWithString:urlString];
    NSArray *args = [NSArray arrayWithObject:[url filePathURL]];
    [webScriptObject.scriptEngine callWebScriptMethod:@"addJavascriptTag" withArguments:args];
}

- (void)addStylesheetTag:(NSString *)urlString
{
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    NSArray *args = [NSArray arrayWithObject:urlString];
    [webScriptObject.scriptEngine callWebScriptMethod:@"addStylesheetTag" withArguments:args];
}

- (void)showAddress:(NSString *)address
{
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    NSArray *args = [NSArray arrayWithObject:address];
    [webScriptObject.scriptEngine callWebScriptMethod:@"showAddress" withArguments:args];
}

#pragma mark NSControl

- (void)takeStringValueFrom:(id)sender
{
    if (![sender respondsToSelector:@selector(stringValue)]) {
        NSLog(@"sender must respond to -stringValue");
        return;
    }
    NSString *stringValue = [sender stringValue];
    [self showAddress:stringValue];
}

@end

@implementation MKMapView

@synthesize overlays;
@synthesize annotations;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self customInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder]) {
        [self customInit];
        [self setMapType:[decoder decodeIntegerForKey:@"mapType"]];
        [self setShowsUserLocation:[decoder decodeBoolForKey:@"showsUserLocation"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeInteger:[self mapType] forKey:@"mapType"];
    [encoder encodeBool:[self showsUserLocation] forKey:@"showsUserLocation"];
}

- (void)dealloc
{
    webView.delegate = nil;
    [webView removeFromSuperview];
    [locationManager stopUpdatingLocation];
}

- (void)setFrame:(CGRect)frameRect
{
    [self delegateRegionWillChangeAnimated:NO];
    [super setFrame:frameRect];
    [self willChangeValueForKey:@"region"];
    [self didChangeValueForKey:@"region"];
    [self willChangeValueForKey:@"centerCoordinate"];
    [self didChangeValueForKey:@"centerCoordinate"];
    [self delegateRegionDidChangeAnimated:NO];
}

- (void)setMapType:(MKMapType)type
{
    DelayedAction action = ^
    {
        _mapType = type;
        WebScriptObject *webScriptObject = [webView windowScriptObject];
        NSArray *args = [NSArray arrayWithObject:[NSNumber numberWithInt:_mapType]];
        [webScriptObject.scriptEngine callWebScriptMethod:@"setMapType" withArguments:args];
    };
    
    [self invokeLater:action];
}

- (CLLocationCoordinate2D)centerCoordinate
{
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    NSNumber *latitude = nil;
    NSNumber *longitude = nil;
    NSString *json = [webScriptObject.scriptEngine evaluateWebScript:@"getCenterCoordinate()"];
    if ([json isKindOfClass:[NSString class]]) {
        NSDictionary *latlong = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        latitude = [latlong objectForKey:@"latitude"];
        longitude = [latlong objectForKey:@"longitude"];
    }
    
    CLLocationCoordinate2D centerCoordinate;
    centerCoordinate.latitude = [latitude doubleValue];
    centerCoordinate.longitude = [longitude doubleValue];
    return centerCoordinate;
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self setCenterCoordinate:coordinate animated:NO];
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated
{
    DelayedAction action = ^
    {
        [self willChangeValueForKey:@"region"];
        NSArray *args = [NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:coordinate.latitude],
                         [NSNumber numberWithDouble:coordinate.longitude],
                         [NSNumber numberWithBool:animated],
                         nil];
        WebScriptObject *webScriptObject = [webView windowScriptObject];
        [webScriptObject.scriptEngine callWebScriptMethod:@"setCenterCoordinateAnimated" withArguments:args];
        [self didChangeValueForKey:@"region"];
        hasSetCenterCoordinate = YES;
    };
    
    [self invokeLater:action];
}

- (MKCoordinateRegion)region
{
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    NSString *json = [webScriptObject.scriptEngine evaluateWebScript:@"getRegion()"];
    NSDictionary *regionDict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
     
    NSNumber *centerLatitude = [regionDict valueForKeyPath:@"center.latitude"];
    NSNumber *centerLongitude = [regionDict valueForKeyPath:@"center.longitude"];
    NSNumber *latitudeDelta = [regionDict objectForKey:@"latitudeDelta"];
    NSNumber *longitudeDelta = [regionDict objectForKey:@"longitudeDelta"];
    
    MKCoordinateRegion region;
    region.center.longitude = [centerLongitude doubleValue];
    region.center.latitude = [centerLatitude doubleValue];
    region.span.latitudeDelta = [latitudeDelta doubleValue];
    region.span.longitudeDelta = [longitudeDelta doubleValue];
    return region;
}

- (void)setRegion:(MKCoordinateRegion)region
{
    [self setRegion:region animated: NO];
}

- (void)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated
{
    DelayedAction action = ^
    {
        [self delegateRegionWillChangeAnimated:animated];
        [self willChangeValueForKey:@"centerCoordinate"];
        WebScriptObject *webScriptObject = [webView windowScriptObject];
        NSArray *args = @[@(region.center.latitude), @(region.center.longitude), @(region.span.latitudeDelta), @(region.span.longitudeDelta), @(animated)];
        [webScriptObject.scriptEngine callWebScriptMethod:@"setRegionAnimated" withArguments:args];
        [self didChangeValueForKey:@"centerCoordinate"];
        [self delegateRegionDidChangeAnimated:animated];
    };
    
    [self invokeLater:action];
}

- (void)setShowsUserLocation:(BOOL)show
{
    DelayedAction action = ^
    {
        BOOL oldValue = _showsUserLocation;
        _showsUserLocation = show;
        
        if (oldValue == NO && _showsUserLocation == YES) {
            [self delegateWillStartLocatingUser];
            // To be sure we get all of the delegate calls from CoreLocation, we have to recreate the manager.
            // Unfortunately if you just call stop/start, it'll never resend the kCLErrorDenied error.
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        }
        
        if (_showsUserLocation) {
            [_userLocation _setUpdating:YES];
            [locationManager startUpdatingLocation];
        } else {
            [self setUserLocationMarkerVisible: NO];
            [_userLocation _setUpdating:NO];
            [locationManager stopUpdatingLocation];
            locationManager = nil;
            [_userLocation _setLocation:nil];
        }
        
        if (oldValue == YES && _showsUserLocation == NO) {
            [self delegateDidStopLocatingUser];
        }
    };
    
    [self invokeLater:action];
}

- (BOOL)isUserLocationVisible
{
    if (!self.showsUserLocation || !_userLocation.location) {
        return NO;
    }
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    NSString *visible = [webScriptObject.scriptEngine callWebScriptMethod:@"isUserLocationVisible" withArguments:[NSArray array]];
    return visible.boolValue;
}

#pragma mark Overlays

- (NSArray *)overlays
{
    return [self.overlays copy];
}

- (void)addOverlay:(id < MKOverlay >)overlay
{
    [self insertOverlay:overlay atIndex:[self.overlays count]];
}

- (void)addOverlays:(NSArray *)someOverlays
{
    for (id<MKOverlay>overlay in someOverlays)
    {
        [self addOverlay: overlay];
    }
}

- (void)exchangeOverlayAtIndex:(NSUInteger)index1 withOverlayAtIndex:(NSUInteger)index2
{
    if (index1 >= [self.overlays count] || index2 >= [self.overlays count]) {
        NSLog(@"exchangeOverlayAtIndex: either index1 or index2 is above the bounds of the overlays array.");
        return;
    }
    
    id <MKOverlay> overlay1 = [overlays objectAtIndex: index1];
    id <MKOverlay> overlay2 = [overlays objectAtIndex: index2];
    [overlays replaceObjectAtIndex:index2 withObject:overlay1];
    [overlays replaceObjectAtIndex:index1 withObject:overlay2];
    [self updateOverlayZIndexes];
}

- (void)insertOverlay:(id <MKOverlay>)overlay aboveOverlay:(id <MKOverlay>)sibling
{
    if (![self.overlays containsObject:sibling]) {
        return;
    }
    
    NSUInteger indexOfSibling = [self.overlays indexOfObject:sibling];
    [self insertOverlay:overlay atIndex: indexOfSibling+1];
}

- (void)insertOverlay:(id < MKOverlay >)overlay atIndex:(NSUInteger)index
{
    // check if maybe we already have this one.
    if ([self.overlays containsObject:overlay]) {
        return;
    }
    
    // Make sure we have a valid index.
    if (index > [self.overlays count]) {
        index = [self.overlays count];
    }
    
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    
    MKOverlayView *overlayView = nil;
    if ([self.delegate respondsToSelector:@selector(mapView:viewForOverlay:)]) {
        overlayView = [self.delegate mapView:self viewForOverlay:overlay];
    }
    if (!overlayView) {
        // TODO: Handle the case where we have no view
        NSLog(@"Wasn't able to create a MKOverlayView for overlay: %@", overlay);
        return;
    }
    
    WebScriptObject *overlayScriptObject = [overlayView overlayScriptObjectFromMapScriptObject:webScriptObject];
    if (!overlayScriptObject) {
        NSLog(@"Error creating internal representation of overlay view for overlay: %@", overlay);
        return;
    }
    
    [overlays insertObject:overlay atIndex:index];
    [overlayViews setObject:overlayView forKey:@([overlay hash])];
    [overlayScriptObjects setObject:overlayScriptObject forKey:@([overlay hash])];
    
    NSArray *args = [NSArray arrayWithObject:overlayScriptObject];
    [webScriptObject.scriptEngine callWebScriptMethod:@"addOverlay" withArguments:args];
    [overlayView draw:overlayScriptObject];
    
    [self updateOverlayZIndexes];
    
    // TODO: refactor how this works so that we can send one batch call
    // when they called addOverlays:
    [self delegateDidAddOverlayViews:[NSArray arrayWithObject:overlayView]];
}

- (void)insertOverlay:(id < MKOverlay >)overlay belowOverlay:(id < MKOverlay >)sibling
{
    if (![self.overlays containsObject:sibling]) {
        return;
    }
    
    NSUInteger indexOfSibling = [self.overlays indexOfObject:sibling];
    [self insertOverlay:overlay atIndex: indexOfSibling];
}

- (void)removeOverlay:(id < MKOverlay >)overlay
{
    if (![self.overlays containsObject:overlay]) {
        return;
    }
    
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    WebScriptObject *overlayScriptObject = [overlayScriptObjects objectForKey:@([overlay hash])];
    NSArray *args = [NSArray arrayWithObject:overlayScriptObject];
    [webScriptObject.scriptEngine callWebScriptMethod:@"removeOverlay" withArguments:args];
    
    [overlayViews removeObjectForKey:@([overlay hash])];
    [overlayScriptObjects removeObjectForKey:@([overlay hash])];
    
    [self.overlays removeObject:overlay];
    [self updateOverlayZIndexes];
}

- (void)removeOverlays:(NSArray *)someOverlays
{
    for (id<MKOverlay>overlay in someOverlays) {
        [self removeOverlay:overlay];
    }
}

- (MKOverlayView *)viewForOverlay:(id < MKOverlay >)overlay
{
    if (![self.overlays containsObject:overlay]) {
        return nil;
    }
    return [overlayViews objectForKey:@([overlay hash])];
}

#pragma mark Annotations

- (NSMutableArray *)annotations
{
    return [annotations mutableCopy];
}

- (void)addAnnotation:(id <MKAnnotation>)annotation
{
    DelayedAction action = ^
    {
        // check if maybe we already have this one.
        if ([self.annotations containsObject:annotation]) {
            return;
        }
        
        WebScriptObject *webScriptObject = [webView windowScriptObject];
        
        MKAnnotationView *annotationView = nil;
        if ([self.delegate respondsToSelector:@selector(mapView:viewForAnnotation:)]) {
            annotationView = [self.delegate mapView:self viewForAnnotation:annotation];
        }
        if (!annotationView) {
            // TODO: Handle the case where we have no view
            NSLog(@"Wasn't able to create a MKAnnotationView for annotation: %@", annotation);
            return;
        }
        
        WebScriptObject *annotationScriptObject = [annotationView overlayScriptObjectFromMapScriptObject:webScriptObject];
        if (![annotationScriptObject isKindOfClass:[WebScriptObject class]]) {
            NSLog(@"Error creating internal representation of annotation view for annotation: %@", annotation);
            return;
        }
        
        [self.annotations addObject:annotation];
        [annotationViews setObject:annotationView forKey:@([annotation hash])];
        [annotationScriptObjects setObject:annotationScriptObject forKey:@([annotation hash])];
        
        NSArray *args = [NSArray arrayWithObject:annotationScriptObject];
        [webScriptObject.scriptEngine callWebScriptMethod:@"addAnnotation" withArguments:args];
        [annotationView draw:annotationScriptObject];
        
        [self updateAnnotationZIndexes];
        
        // TODO: refactor how this works so that we can send one batch call
        // when they called addAnnotations:
        [self delegateDidAddAnnotationViews:[NSArray arrayWithObject:annotationView]];
    };
    
    [self invokeLater:action];
}

- (void)addAnnotations:(NSArray *)someAnnotations
{
    for (id<MKAnnotation>annotation in someAnnotations) {
        [self addAnnotation: annotation];
    }
}

- (void)removeAnnotation:(id < MKAnnotation >)annotation
{
    if (![self.annotations containsObject:annotation]) {
        return;
    }
    
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    WebScriptObject *annotationScriptObject = (WebScriptObject *)[annotationScriptObjects objectForKey: annotation];
    NSArray *args = [NSArray arrayWithObject:annotationScriptObject];
    [webScriptObject.scriptEngine callWebScriptMethod:@"removeAnnotation" withArguments:args];
    
    [annotationViews removeObjectForKey: annotation];
    [annotationScriptObjects removeObjectForKey: annotation];
    
    [self.annotations removeObject:annotation];
}

- (void)removeAnnotations:(NSArray *)someAnnotations
{
    for (id<MKAnnotation>annotation in someAnnotations) {
        [self removeAnnotation: annotation];
    }
}

- (MKAnnotationView *)viewForAnnotation:(id < MKAnnotation >)annotation
{
    if (![self.annotations containsObject:annotation]) {
        return nil;
    }
    return (MKAnnotationView *)[annotationViews objectForKey: annotation];
}

- (MKAnnotationView *)dequeueReusableAnnotationViewWithIdentifier:(NSString *)identifier
{
    // Unsupported for now.
    return nil;
}

- (void)selectAnnotation:(id <MKAnnotation>)annotation animated:(BOOL)animated
{
    __block BOOL retry = NO;
    DelayedAction action = ^
    {
        if ([selectedAnnotations containsObject:annotation]) {
            return;
        }
        
        MKAnnotationView *annotationView = [annotationViews objectForKey:annotation];
        if (!annotationView) {
            retry = YES;
        }
        [self.selectedAnnotations addObject:annotation];
        [self delegateDidSelectAnnotationView:annotationView];
        
        WebScriptObject *webScriptObject = [webView windowScriptObject];
        WebScriptObject *annotationScriptObject = (WebScriptObject *)[annotationScriptObjects objectForKey: annotation];
        
        if (annotation.title)
        {
            NSArray *args = [NSArray arrayWithObjects:annotationScriptObject, annotation.title, nil];
            [webScriptObject.scriptEngine callWebScriptMethod:@"setAnnotationCalloutText" withArguments:args];
            args = [NSArray arrayWithObjects:annotationScriptObject, [NSNumber numberWithBool:NO], nil];
            [webScriptObject.scriptEngine callWebScriptMethod:@"setAnnotationCalloutHidden" withArguments:args];
        }
    };
    
    [self invokeLater:action];
    
    if (retry) {
        DelayedAction clone = [action copy];
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            clone();
        });
    }
}

- (void)deselectAnnotation:(id < MKAnnotation >)annotation animated:(BOOL)animated
{
    // TODO : animate this if called for.
    if (![self.selectedAnnotations containsObject:annotation]) {
        return;
    }
    
    MKAnnotationView *annotationView = [annotationViews objectForKey:annotation];
    [self.selectedAnnotations removeObject:annotation];
    [self delegateDidDeselectAnnotationView:annotationView];
    
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    WebScriptObject *annotationScriptObject = (WebScriptObject *)[annotationScriptObjects objectForKey: annotation];
    
    NSArray *args = [NSArray arrayWithObjects:annotationScriptObject, [NSNumber numberWithBool:YES], nil];
    [webScriptObject.scriptEngine callWebScriptMethod:@"setAnnotationCalloutHidden" withArguments:args];
}

- (NSMutableArray *)selectedAnnotations
{
    return [selectedAnnotations mutableCopy];
}

- (void)setSelectedAnnotations:(NSArray *)someAnnotations
{
    // Deselect whatever was selected
    NSArray *oldSelectedAnnotations = [self selectedAnnotations];
    for (id <MKAnnotation> annotation in oldSelectedAnnotations) {
        [self deselectAnnotation:annotation animated:NO];
    }
    NSMutableArray *newSelectedAnnotations = [NSMutableArray arrayWithArray: [someAnnotations copy]];
    self.selectedAnnotations = newSelectedAnnotations;
    
    // If it's manually set and there's more than one, you only select the first according to the docs.
    if ([self.selectedAnnotations count] > 0) {
        [self selectAnnotation:[self.selectedAnnotations objectAtIndex:0] animated:NO];
    }
}

#pragma mark Converting Map Coordinates

- (CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate toPointToView:(UIView *)view
{
    CGPoint point = {0,0};
    NSArray *args = [NSArray arrayWithObjects:
                     [NSNumber numberWithDouble:coordinate.latitude],
                     [NSNumber numberWithDouble:coordinate.longitude],
                     nil];
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    NSString *json = [webScriptObject.scriptEngine callWebScriptMethod:@"convertCoordinate" withArguments:args];
    NSNumber *x = nil;
    NSNumber *y = nil;
    if ([json isKindOfClass:[NSString class]]) {
        NSDictionary *xy = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        x = [xy objectForKey:@"x"];
        y = [xy objectForKey:@"y"];
    }
    
    point.x = [x integerValue];
    point.y = [y integerValue];
    
    point = [webView convertPoint:point toView:view];
    
    return point;
}

- (CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(UIView *)view
{
    // TODO: Implement
    NSLog(@"-[MKMapView convertPoint: toCoordinateFromView:] not implemented yet");
    CLLocationCoordinate2D coordinate;
    
    return coordinate;
}

- (MKCoordinateRegion)convertRect:(CGRect)rect toRegionFromView:(UIView *)view
{
    // TODO: Implement
    NSLog(@"-[MKMapView convertRect: toRegionFromView:] not implemented yet");
    MKCoordinateRegion region;
    
    return region;
}

- (CGRect)convertRegion:(MKCoordinateRegion)region toRectToView:(UIView *)view
{
    // TODO: Implement
    NSLog(@"-[MKMapView convertRegion: toRectToView:] not implemented yet");
    return CGRectZero;
}

#pragma mark Faked Properties

- (BOOL)isScrollEnabled
{
    return YES;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    if (!scrollEnabled) {
        NSLog(@"setting scrollEnabled to NO on MKMapView not supported.");
    }
}

- (BOOL)isZoomEnabled
{
    return YES;
}

- (void)setZoomEnabled:(BOOL)zoomEnabled
{
    if (!zoomEnabled) {
        NSLog(@"setting zoomEnabled to NO on MKMapView not supported");
    }
}

#pragma mark CoreLocationManagerDelegate

- (void)locationManager: (CLLocationManager *)manager didUpdateToLocation: (CLLocation *)newLocation fromLocation: (CLLocation *)oldLocation
{
    if (!hasSetCenterCoordinate) {
        [self setCenterCoordinate:newLocation.coordinate];
    }
    [_userLocation _setLocation:newLocation];
    [self updateUserLocationMarkerWithLocaton:newLocation];
    [self setUserLocationMarkerVisible:YES];
    [self delegateDidUpdateUserLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self delegateDidFailToLocateUserWithError:error];
    [self setUserLocationMarkerVisible:NO];
    
    if ([error code] == kCLErrorDenied) {
        [self setShowsUserLocation:NO];
    }
}

#pragma mark -

#define MKDirectionModeCar             @"MKDirectionModeCar"
#define MKDirectionModeWalking         @"w"
#define MKDirectionModePublicTransport @"r"

void MKOpenDirectionInGoogleMaps(CLLocationCoordinate2D startingPoint, CLLocationCoordinate2D endPoint, NSString *directionMode) {
	NSString *googleMapsURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
							   startingPoint.latitude,startingPoint.longitude, endPoint.latitude, endPoint.longitude];
    
	if (![directionMode isEqualToString:MKDirectionModeCar]) {
		googleMapsURL = [googleMapsURL stringByAppendingFormat:@"&dirflg=%@", directionMode];
	}
    
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURL]];
}

// Thanks to Stefan Bachl for providing the algorithm
void MKRotateViewForDirectionFromCoordinateToCoordinate(UIView *view, CLHeading *heading, CLLocationCoordinate2D fromLocation, CLLocationCoordinate2D toLocation, BOOL animated) {
    if (heading.headingAccuracy > 0) {
        float fromLatitude = fromLocation.latitude / 180.f * M_PI;
        float fromLongitude = fromLocation.longitude / 180.f * M_PI;
        float toLatitude = toLocation.latitude / 180.f * M_PI;
        float toLongitude = toLocation.longitude / 180.f * M_PI;
        float direction = atan2(sin(toLongitude-fromLongitude)*cos(toLatitude), cos(fromLatitude)*sin(toLatitude)-sin(fromLatitude)*cos(toLatitude)*cos(toLongitude-fromLongitude));
        double directionToSet = (direction * 180.0f / M_PI) - heading.magneticHeading;
        
        [UIView animateWithDuration:animated ? 0.5f : 0.0f animations:^(void) {
            [view setTransform:CGAffineTransformMakeRotation(directionToSet * M_PI/180.f)];
        }];
    }
}

#import <objc/runtime.h>

#define kDefaultGoogleBadgeOriginX 12.f
#define kDefaultGoogleBadgeYOffset 27.f

#define MKLocationGoogleBadgeTag 666
#define MKLocationHeadingViewTag 667

static char headingAngleViewKey;

+ (id)mapViewInSuperview:(UIView *)superview
{
    MKMapView *mapView = [[[self class] alloc] initWithFrame:CGRectZero];
    
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [superview addSubview:mapView];
    [mapView sizeToFitTrackingModeFollowWithHeading];
    [mapView addGoogleBadge];
    [mapView addHeadingAngleView];
    
    return mapView;
}

- (void)sizeToFitTrackingModeFollowWithHeading
{
    CGRect newFrame = self.frame;
    CGRect bounds = self.superview.bounds;
    // pythagoras ftw.
    CGFloat superviewDiagonal = ceilf(sqrtf(bounds.size.width * bounds.size.width + bounds.size.height * bounds.size.height));
    
    // set new size of frame
    newFrame.size.width = superviewDiagonal + 5.f;
    newFrame.size.height = superviewDiagonal + 5.f;
    self.frame = newFrame;
    
    // center in superview
    self.center = self.superview.center;
    self.frame = CGRectIntegral(self.frame);
}

- (void)addGoogleBadge
{
    CGPoint p;
    
    p.x = kDefaultGoogleBadgeOriginX;
    p.y = self.superview.frame.origin.y + self.superview.frame.size.height - kDefaultGoogleBadgeYOffset;
    
    [self addGoogleBadgeAtPoint:p];
}

- (void)addGoogleBadgeAtPoint:(CGPoint)topLeftOfGoogleBadge
{
    UIImageView *googleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GoogleBadge"]];
    googleView.tag = MKLocationGoogleBadgeTag;
    googleView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    googleView.frame = CGRectMake(topLeftOfGoogleBadge.x, topLeftOfGoogleBadge.y,
                                  googleView.frame.size.width, googleView.frame.size.height);
    
    [self.superview addSubview:googleView];
}

- (void)addHeadingAngleView
{
    UIImageView *headingAngleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HeadingAngleSmall"]];
    headingAngleView.hidden = YES;
    headingAngleView.tag = MKLocationHeadingViewTag;
    
    // add to superview
    [self.superview addSubview:headingAngleView];
    // add as associated object to MapView
    objc_setAssociatedObject(self, &headingAngleViewKey, headingAngleView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showHeadingAngleView
{
    id headingAngleView = objc_getAssociatedObject(self, &headingAngleViewKey);
    
    [headingAngleView setHidden:NO];
}

- (void)hideHeadingAngleView
{
    id headingAngleView = objc_getAssociatedObject(self, &headingAngleViewKey);
    
    [headingAngleView setHidden:YES];
}

- (void)moveHeadingAngleViewToCoordinate:(CLLocationCoordinate2D)coordinate
{
    CGPoint center = [self convertCoordinate:coordinate toPointToView:self.superview];
    id headingAngleView = objc_getAssociatedObject(self, &headingAngleViewKey);
    
    center.y -= [headingAngleView frame].size.height/2 + 8;
    [headingAngleView setCenter:center];
}

- (void)rotateToHeading:(CLHeading *)heading
{
    [self rotateToHeading:heading animated:YES];
}

- (void)rotateToHeading:(CLHeading *)heading animated:(BOOL)animated
{
	if (heading.headingAccuracy > 0) {
        WebScriptObject *webScriptObject = [webView windowScriptObject];
        NSArray *args = @[@(heading.magneticHeading)];
        [webScriptObject.scriptEngine callWebScriptMethod:@"rotateToHeadingAnimated" withArguments:args];
    }
}

- (void)resetHeadingRotation {
    [self resetHeadingRotationAnimated:YES];
}

- (void)resetHeadingRotationAnimated:(BOOL)animated
{
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    NSArray *args = @[@0];
    [webScriptObject.scriptEngine callWebScriptMethod:@"rotateToHeadingAnimated" withArguments:args];
}

@end
