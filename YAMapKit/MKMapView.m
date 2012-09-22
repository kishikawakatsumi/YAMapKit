//
//  MKMapView.m
//  YAMapKit
//
//  Created by katsumi-kishikawa on 2012/09/21.
//  Copyright (c) 2012年 kishikawa katsumi. All rights reserved.
//

#import "MKMapView.h"
#import "MKMapView+Private.h"
#import "MKMapView+DelegateWrappers.h"
#import "MKMapView+WebViewIntegration.h"
#import "MKUserLocation.h"
#import "MKUserLocation+Private.h"
#import "MKCircleView.h"
#import "MKCircle.h"
#import "MKPolyline.h"
#import "MKPolygon.h"
#import "MKAnnotationView.h"
#import "MKPointAnnotation.h"
#import "MKWebView.h"
#import "WebScriptEngine.h"
#import "WebScriptObject.h"
#import "JSONKit.h"

@interface MKMapView () <CLLocationManagerDelegate>

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
    _mapType = type;
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    NSArray *args = [NSArray arrayWithObject:[NSNumber numberWithInt:_mapType]];
    [webScriptObject.scriptEngine callWebScriptMethod:@"setMapType" withArguments:args];
}

- (CLLocationCoordinate2D)centerCoordinate
{
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    NSNumber *latitude = nil;
    NSNumber *longitude = nil;
    NSString *json = [webScriptObject.scriptEngine evaluateWebScript:@"getCenterCoordinate()"];
    if ([json isKindOfClass:[NSString class]]) {
        NSDictionary *latlong = [json objectFromJSONString];
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
}


- (MKCoordinateRegion)region
{
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    NSString *json = [webScriptObject.scriptEngine evaluateWebScript:@"getRegion()"];
    NSDictionary *regionDict = [json objectFromJSONString];
    
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
    [self delegateRegionWillChangeAnimated:animated];
    [self willChangeValueForKey:@"centerCoordinate"];
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    NSArray *args = @[[NSNumber numberWithDouble:region.center.latitude],
                     [NSNumber numberWithDouble:region.center.longitude],
                     [NSNumber numberWithDouble:region.span.latitudeDelta],
                     [NSNumber numberWithDouble:region.span.longitudeDelta],
                     [NSNumber numberWithBool:animated]];
    [webScriptObject.scriptEngine callWebScriptMethod:@"setRegionAnimated" withArguments:args];
    [self didChangeValueForKey:@"centerCoordinate"];
    [self delegateRegionDidChangeAnimated:animated];
}

- (void)setShowsUserLocation:(BOOL)show
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
}

- (BOOL)isUserLocationVisible
{
    if (!self.showsUserLocation || !_userLocation.location)
        return NO;
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
    if ([self.overlays containsObject:overlay])
        return;
    
    // Make sure we have a valid index.
    if (index > [self.overlays count])
        index = [self.overlays count];
    
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
    [overlayViews setObject:overlayView forKey:overlay];
    [overlayScriptObjects setObject:overlayScriptObject forKey:overlay];
    
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
    if (![self.overlays containsObject:sibling])
        return;
    
    NSUInteger indexOfSibling = [self.overlays indexOfObject:sibling];
    [self insertOverlay:overlay atIndex: indexOfSibling];
}

- (void)removeOverlay:(id < MKOverlay >)overlay
{
    if (![self.overlays containsObject:overlay])
        return;
    
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    WebScriptObject *overlayScriptObject = (WebScriptObject *)[overlayScriptObjects objectForKey: overlay];
    NSArray *args = [NSArray arrayWithObject:overlayScriptObject];
    [webScriptObject.scriptEngine callWebScriptMethod:@"removeOverlay" withArguments:args];
    
    [overlayViews removeObjectForKey:overlay];
    [overlayScriptObjects removeObjectForKey:overlay];
    
    [self.overlays removeObject:overlay];
    [self updateOverlayZIndexes];
}

- (void)removeOverlays:(NSArray *)someOverlays
{
    for (id<MKOverlay>overlay in someOverlays)
    {
        [self removeOverlay: overlay];
    }
}

- (MKOverlayView *)viewForOverlay:(id < MKOverlay >)overlay
{
    if (![self.overlays containsObject:overlay])
        return nil;
    return (MKOverlayView *)[overlayViews objectForKey: overlay];
}

#pragma mark Annotations

- (NSMutableArray *)annotations
{
    return [annotations mutableCopy];
}

- (void)addAnnotation:(id <MKAnnotation>)annotation
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
    [annotationViews setObject:annotationView forKey:annotation];
    [annotationScriptObjects setObject:annotationScriptObject forKey:annotation];
    
    NSArray *args = [NSArray arrayWithObject:annotationScriptObject];
    [webScriptObject.scriptEngine callWebScriptMethod:@"addAnnotation" withArguments:args];
    [annotationView draw:annotationScriptObject];
    
    [self updateAnnotationZIndexes];
    
    // TODO: refactor how this works so that we can send one batch call
    // when they called addAnnotations:
    [self delegateDidAddAnnotationViews:[NSArray arrayWithObject:annotationView]];
}

- (void)addAnnotations:(NSArray *)someAnnotations
{
    for (id<MKAnnotation>annotation in someAnnotations)
    {
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
    for (id<MKAnnotation>annotation in someAnnotations)
    {
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
    if ([selectedAnnotations containsObject:annotation]) {
        return;
    }
    
    MKAnnotationView *annotationView = (id)[annotationViews objectForKey: annotation];
    [self.selectedAnnotations addObject:annotation];
    [self delegateDidSelectAnnotationView:annotationView];
    
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    WebScriptObject *annotationScriptObject = (WebScriptObject *)[annotationScriptObjects objectForKey: annotation];
    
    if (annotation.title && annotationView.canShowCallout)
    {
        NSArray *args = [NSArray arrayWithObjects:annotationScriptObject, annotation.title, nil];
        [webScriptObject.scriptEngine callWebScriptMethod:@"setAnnotationCalloutText" withArguments:args];
        args = [NSArray arrayWithObjects:annotationScriptObject, [NSNumber numberWithBool:NO], nil];
        [webScriptObject.scriptEngine callWebScriptMethod:@"setAnnotationCalloutHidden" withArguments:args];
    }
    
}

- (void)deselectAnnotation:(id < MKAnnotation >)annotation animated:(BOOL)animated
{
    // TODO : animate this if called for.
    if (![self.selectedAnnotations containsObject:annotation]) {
        return;
    }
    
    MKAnnotationView *annotationView = (id)[annotationViews objectForKey: annotation];
    [self.selectedAnnotations removeObject:annotation];
    [self delegateDidDeselectAnnotationView:annotationView];
    
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    WebScriptObject *annotationScriptObject = (WebScriptObject *)[annotationScriptObjects objectForKey: annotation];
    
    NSArray *args = [NSArray arrayWithObjects:annotationScriptObject, [NSNumber numberWithBool:YES], nil];
    [webScriptObject.scriptEngine callWebScriptMethod:@"setAnnotationCalloutHidden" withArguments:args];
}

- (NSMutableArray *)selectedAnnotations
{
    return [self.selectedAnnotations mutableCopy];
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
    if ([self.selectedAnnotations count] > 0)
        [self selectAnnotation:[self.selectedAnnotations objectAtIndex:0] animated:NO];
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
        NSDictionary *xy = [json objectFromJSONString];
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
    if (!scrollEnabled)
        NSLog(@"setting scrollEnabled to NO on MKMapView not supported.");
}

- (BOOL)isZoomEnabled
{
    return YES;
}

- (void)setZoomEnabled:(BOOL)zoomEnabled
{
    if (!zoomEnabled)
        NSLog(@"setting zoomEnabled to NO on MKMapView not supported");
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
    
    if ([error code] == kCLErrorDenied)
    {
        [self setShowsUserLocation:NO];
    }
}

@end
