//
//  MKMapView.h
//  YAMapKit
//
//  Created by kishikawa katsumi on 2012/09/21.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import <MapKit/MKAnnotationView.h>
#import <MapKit/MKFoundation.h>
#import <MapKit/MKGeometry.h>
#import <MapKit/MKTypes.h>
#import <MapKit/MKOverlay.h>
#import <MapKit/MKOverlayView.h>
#import <MapKit/MKPointAnnotation.h>
#import <MapKit/MKPolygon.h>
#import <MapKit/MKPolyline.h>
#import <MapKit/MKCircle.h>
#import <MapKit/MKPolygonView.h>
#import <MapKit/MKPolylineView.h>
#import <MapKit/MKCircleView.h>

@class MKUserLocation;
@class MKMapViewInternal;

@protocol MKMapViewDelegate;

#if (__IPHONE_5_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED)
enum {
    MKUserTrackingModeSearching = -1,
	MKUserTrackingModeNone = 0, // the user's location is not followed
	MKUserTrackingModeFollow, // the map follows the user's location
	MKUserTrackingModeFollowWithHeading, // the map follows the user's location and heading
};
#endif
typedef NSInteger MKUserTrackingMode;

#define MKLocationManagerDidUpdateToLocationFromLocation    @"MKLocationManagerDidUpdateToLocationFromLocation"
#define MKLocationManagerDidFailWithError                   @"MKLocationManagerDidFailWithError"
#define MKLocationManagerDidUpdateHeading                   @"MKLocationManagerDidUpdateHeading"
#define MKLocationManagerDidEnterRegion                     @"MKLocationManagerDidEnterRegion"
#define MKLocationManagerDidExitRegion                      @"MKLocationManagerDidExitRegion"
#define MKLocationManagerMonitoringDidFailForRegion         @"MKLocationManagerMonitoringDidFailForRegion"
#define MKLocationManagerDidChangeAuthorizationStatus       @"MKLocationManagerDidChangeAuthorizationStatus"

#define MKLocationManagerDidStopUpdatingHeading             @"MKLocationManagerDidStopUpdatingHeading"
#define MKLocationManagerDidStopUpdatingServices            @"MKLocationManagerDidStopUpdatingServices"

#define MKLocationLocationManagerKey                        @"locationManager"
#define MKLocationNewLocationKey                            @"newLocation"
#define MKLocationOldLocationKey                            @"oldLocation"
#define MKLocationNewHeadingKey                             @"newHeading"
#define MKLocationRegionKey                                 @"region"
#define MKLocationErrorKey                                  @"error"
#define MKLocationAuthorizationStatusKey                    @"status"

// block-type of block that gets executed when location changes
typedef void (^mk_location_changed_block)(CLLocation *location);
typedef void (^mk_location_error_block)(NSError *error);

// Helper Functions for easier retreival of Notification UserInfos

NS_INLINE CLLocationManager* MKLocationGetLocationManager(NSNotification *notification)
{
    return [notification.userInfo valueForKey:MKLocationLocationManagerKey];
}

NS_INLINE CLLocation* MKLocationGetNewLocation(NSNotification *notification)
{
    return [notification.userInfo valueForKey:MKLocationNewLocationKey];
}

NS_INLINE CLLocation* MKLocationGetOldLocation(NSNotification *notification)
{
    return [notification.userInfo valueForKey:MKLocationOldLocationKey];
}

NS_INLINE CLHeading* MKLocationGetNewHeading(NSNotification *notification)
{
    return [notification.userInfo valueForKey:MKLocationNewHeadingKey];
}

NS_INLINE CLRegion* MKLocationGetRegion(NSNotification *notification)
{
    return [notification.userInfo valueForKey:MKLocationRegionKey];
}

NS_INLINE NSError* MKLocationGetError(NSNotification *notification)
{
    return [notification.userInfo valueForKey:MKLocationErrorKey];
}

NS_INLINE CLAuthorizationStatus MKLocationGetAuthorizationStatus(NSNotification *notification)
{
    return (CLAuthorizationStatus)[[notification.userInfo valueForKey:MKLocationAuthorizationStatusKey] intValue];
}

MK_CLASS_AVAILABLE(NA, 3_0)
@interface MKMapView : UIView <NSCoding> {
    NSMutableArray *overlays;
    NSMutableArray *annotations;
    NSMutableArray *selectedAnnotations;
@private
//    MKWebView *webView;
    CLLocationManager *locationManager;
    BOOL hasSetCenterCoordinate;
    // Overlays
    NSMutableDictionary *overlayViews;
    NSMutableDictionary *overlayScriptObjects;
    // Annotations
    NSMutableDictionary *annotationViews;
    NSMutableDictionary *annotationScriptObjects;
}

@property (assign, nonatomic) id <MKMapViewDelegate> delegate;

@property(assign, nonatomic) MKMapType mapType;
@property(strong, nonatomic) MKUserLocation *userLocation;
@property (nonatomic) MKUserTrackingMode userTrackingMode NS_AVAILABLE(NA, 5_0);
//- (void)setUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated NS_AVAILABLE(NA, 5_0);
@property(assign, nonatomic) MKCoordinateRegion region;
@property(assign, nonatomic) CLLocationCoordinate2D centerCoordinate;
@property(assign, nonatomic) BOOL showsUserLocation;
@property(assign, nonatomic, getter=isScrollEnabled) BOOL scrollEnabled;
@property(assign, nonatomic, getter=isZoomEnabled) BOOL zoomEnabled;
@property(assign, nonatomic, readonly, getter=isUserLocationVisible) BOOL userLocationVisible;
@property(strong, nonatomic, readonly) NSMutableArray *overlays;
@property(strong, nonatomic, readonly) NSMutableArray *annotations;
@property(copy, nonatomic) NSMutableArray *selectedAnnotations;

- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated;

// Overlays
- (void)addOverlay:(id <MKOverlay>)overlay;
- (void)addOverlays:(NSArray *)overlays;
- (void)exchangeOverlayAtIndex:(NSUInteger)index1 withOverlayAtIndex:(NSUInteger)index2;
- (void)insertOverlay:(id <MKOverlay>)overlay aboveOverlay:(id <MKOverlay>)sibling;
- (void)insertOverlay:(id <MKOverlay>)overlay atIndex:(NSUInteger)index;
- (void)insertOverlay:(id <MKOverlay>)overlay belowOverlay:(id <MKOverlay>)sibling;
- (void)removeOverlay:(id <MKOverlay>)overlay;
- (void)removeOverlays:(NSArray *)overlays;
- (MKOverlayView *)viewForOverlay:(id < MKOverlay >)overlay;

// Annotations
- (void)addAnnotation:(id <MKAnnotation>)annotation;
- (void)addAnnotations:(NSArray *)annotations;
- (void)removeAnnotation:(id <MKAnnotation>)annotation;
- (void)removeAnnotations:(NSArray *)annotations;
- (MKAnnotationView *)viewForAnnotation:(id <MKAnnotation>)annotation;
- (MKAnnotationView *)dequeueReusableAnnotationViewWithIdentifier:(NSString *)identifier;
- (void)selectAnnotation:(id <MKAnnotation>)annotation animated:(BOOL)animated;
- (void)deselectAnnotation:(id <MKAnnotation>)annotation animated:(BOOL)animated;

// Converting Map Coordinates
- (CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate toPointToView:(UIView *)view;
- (CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(UIView *)view;
- (MKCoordinateRegion)convertRect:(CGRect)rect toRegionFromView:(UIView *)view;
- (CGRect)convertRegion:(MKCoordinateRegion)region toRectToView:(UIView *)view;

// creates and initializes a MapView and adds it to superview
+ (id)mapViewInSuperview:(UIView *)superview;

// sizes to MapView so that it can be rotated using a transform without showing it's background
- (void)sizeToFitTrackingModeFollowWithHeading;

- (void)addGoogleBadge;
- (void)addGoogleBadgeAtPoint:(CGPoint)topLeftOfGoogleBadge;

- (void)addHeadingAngleView;
- (void)showHeadingAngleView;
- (void)hideHeadingAngleView;
- (void)moveHeadingAngleViewToCoordinate:(CLLocationCoordinate2D)coordinate;

- (void)rotateToHeading:(CLHeading *)heading;
- (void)rotateToHeading:(CLHeading *)heading animated:(BOOL)animated;

- (void)resetHeadingRotation;
- (void)resetHeadingRotationAnimated:(BOOL)animated;

@end

@protocol MKMapViewDelegate <NSObject>
@optional

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated;
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated;

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView;
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView;
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error;

// mapView:viewForAnnotation: provides the view for each annotation.
// This method may be called for all or some of the added annotations.
// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;

// mapView:didAddAnnotationViews: is called after the annotation views have been added and positioned in the map.
// The delegate can implement this method to animate the adding of the annotations views.
// Use the current positions of the annotation views as the destinations of the animation.
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views;

// mapView:annotationView:calloutAccessoryControlTapped: is called when the user taps on left & right callout accessory UIControls.
//- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;

// Overlays
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay;
- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews;


// iOS 4.0 additions:
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view;
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view;
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation;
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error;
- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView;
- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView;
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState;

// MacMapKit additions
- (void)mapView:(MKMapView *)mapView userDidClickAndHoldAtCoordinate:(CLLocationCoordinate2D)coordinate;
- (NSArray *)mapView:(MKMapView *)mapView contextMenuItemsForAnnotationView:(MKAnnotationView *)view;

@end
