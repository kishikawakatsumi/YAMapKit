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
    NSMutableArray *_overlays;
    NSMutableArray *_annotations;
    NSMutableArray *_selectedAnnotations;
@private
//    MKWebView *webView;
    CLLocationManager *locationManager;
    BOOL hasSetCenterCoordinate;
    // Overlays
    NSMutableDictionary *_overlayViews;
    NSMutableDictionary *_overlayScriptObjects;
    // Annotations
    NSMutableDictionary *_annotationViews;
    NSMutableDictionary *_annotationScriptObjects;
}

@property (assign, nonatomic) id <MKMapViewDelegate> delegate;

// Changing the map type or region can cause the map to start loading map content.
// The loading delegate methods will be called as map content is loaded.
@property (nonatomic) MKMapType mapType;

// Region is the coordinate and span of the map.
// Region may be modified to fit the aspect ratio of the view using regionThatFits:.
@property (nonatomic) MKCoordinateRegion region;
- (void)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated;

// centerCoordinate allows the coordinate of the region to be changed without changing the zoom level.
@property (nonatomic) CLLocationCoordinate2D centerCoordinate;
- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;

// Returns a region of the aspect ratio of the map view that contains the given region, with the same center point.
- (MKCoordinateRegion)regionThatFits:(MKCoordinateRegion)region;

// Access the visible region of the map in projected coordinates.
@property (nonatomic) MKMapRect visibleMapRect;
- (void)setVisibleMapRect:(MKMapRect)mapRect animated:(BOOL)animate;

// Returns an MKMapRect modified to fit the aspect ratio of the map.
- (MKMapRect)mapRectThatFits:(MKMapRect)mapRect;

// Edge padding is the minumum padding on each side around the specified MKMapRect.
- (void)setVisibleMapRect:(MKMapRect)mapRect edgePadding:(UIEdgeInsets)insets animated:(BOOL)animate;
- (MKMapRect)mapRectThatFits:(MKMapRect)mapRect edgePadding:(UIEdgeInsets)insets;

- (CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate toPointToView:(UIView *)view;
- (CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(UIView *)view;
- (CGRect)convertRegion:(MKCoordinateRegion)region toRectToView:(UIView *)view;
- (MKCoordinateRegion)convertRect:(CGRect)rect toRegionFromView:(UIView *)view;

// Disable user interaction from zooming or scrolling the map, or both.
@property(nonatomic, getter=isZoomEnabled) BOOL zoomEnabled;
@property(nonatomic, getter=isScrollEnabled) BOOL scrollEnabled;

// Set to YES to add the user location annotation to the map and start updating its location
@property (nonatomic) BOOL showsUserLocation;

// The annotation representing the user's location
@property (nonatomic, readonly) MKUserLocation *userLocation;

@property (nonatomic) MKUserTrackingMode userTrackingMode NS_AVAILABLE(NA, 5_0);
- (void)setUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated NS_AVAILABLE(NA, 5_0);

// Returns YES if the user's location is displayed within the currently visible map region.
@property (nonatomic, readonly, getter=isUserLocationVisible) BOOL userLocationVisible;

// Annotations are models used to annotate coordinates on the map.
// Implement mapView:viewForAnnotation: on MKMapViewDelegate to return the annotation view for each annotation.
- (void)addAnnotation:(id <MKAnnotation>)annotation;
- (void)addAnnotations:(NSArray *)annotations;

- (void)removeAnnotation:(id <MKAnnotation>)annotation;
- (void)removeAnnotations:(NSArray *)annotations;

@property (nonatomic, readonly) NSArray *annotations;
- (NSSet *)annotationsInMapRect:(MKMapRect)mapRect NS_AVAILABLE(NA, 4_2);

// Currently displayed view for an annotation; returns nil if the view for the annotation isn't being displayed.
- (MKAnnotationView *)viewForAnnotation:(id <MKAnnotation>)annotation;

// Used by the delegate to acquire an already allocated annotation view, in lieu of allocating a new one.
- (MKAnnotationView *)dequeueReusableAnnotationViewWithIdentifier:(NSString *)identifier;

// Select or deselect a given annotation.  Asks the delegate for the corresponding annotation view if necessary.
- (void)selectAnnotation:(id <MKAnnotation>)annotation animated:(BOOL)animated;
- (void)deselectAnnotation:(id <MKAnnotation>)annotation animated:(BOOL)animated;
@property (nonatomic, copy) NSArray *selectedAnnotations;

// annotationVisibleRect is the visible rect where the annotations views are currently displayed.
// The delegate can use annotationVisibleRect when animating the adding of the annotations views in mapView:didAddAnnotationViews:
@property (nonatomic, readonly) CGRect annotationVisibleRect;

// Overlays are models used to represent areas to be drawn on top of the map.
// This is in contrast to annotations, which represent points on the map.
// Implement -mapView:viewForOverlay: on MKMapViewDelegate to return the view for each overlay.
- (void)addOverlay:(id <MKOverlay>)overlay NS_AVAILABLE(NA, 4_0);
- (void)addOverlays:(NSArray *)overlays NS_AVAILABLE(NA, 4_0);

- (void)removeOverlay:(id <MKOverlay>)overlay NS_AVAILABLE(NA, 4_0);
- (void)removeOverlays:(NSArray *)overlays NS_AVAILABLE(NA, 4_0);

- (void)insertOverlay:(id <MKOverlay>)overlay atIndex:(NSUInteger)index NS_AVAILABLE(NA, 4_0);
- (void)exchangeOverlayAtIndex:(NSUInteger)index1 withOverlayAtIndex:(NSUInteger)index2 NS_AVAILABLE(NA, 4_0);

- (void)insertOverlay:(id <MKOverlay>)overlay aboveOverlay:(id <MKOverlay>)sibling NS_AVAILABLE(NA, 4_0);
- (void)insertOverlay:(id <MKOverlay>)overlay belowOverlay:(id <MKOverlay>)sibling NS_AVAILABLE(NA, 4_0);

@property (nonatomic, readonly) NSArray *overlays NS_AVAILABLE(NA, 4_0);

// Currently displayed view for overlay; returns nil if the view has not been created yet.
- (MKOverlayView *)viewForOverlay:(id <MKOverlay>)overlay NS_AVAILABLE(NA, 4_0);

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
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view NS_AVAILABLE(NA, 4_0);
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view NS_AVAILABLE(NA, 4_0);

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView NS_AVAILABLE(NA, 4_0);
- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView NS_AVAILABLE(NA, 4_0);
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation NS_AVAILABLE(NA, 4_0);
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error NS_AVAILABLE(NA, 4_0);

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
fromOldState:(MKAnnotationViewDragState)oldState NS_AVAILABLE(NA, 4_0);

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay NS_AVAILABLE(NA, 4_0);

// Called after the provided overlay views have been added and positioned in the map.
- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews NS_AVAILABLE(NA, 4_0);

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated NS_AVAILABLE(NA, 5_0);

// MacMapKit additions
- (void)mapView:(MKMapView *)mapView userDidClickAndHoldAtCoordinate:(CLLocationCoordinate2D)coordinate;
- (NSArray *)mapView:(MKMapView *)mapView contextMenuItemsForAnnotationView:(MKAnnotationView *)view;

@end
