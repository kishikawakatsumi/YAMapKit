//
//  MKLocationManager.h
//  MapKit
//
//  Created by kishikawa katsumi on 2012/10/23.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MKUserTrackingBarButtonItem.h"
#import "MKUserTrackingButton.h"

/**
 Singleton class that acts as the Location Manager and it's delegate
 Sends Notifications when CLLocationManagerDelegate-Methods are called
 */
@interface MKLocationManager : NSObject <CLLocationManagerDelegate, MKUserTrackingButtonDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastKnownLocation;
// Optional: a MapView that gets rotated according to heading updates
@property (nonatomic, strong) MKMapView *mapView;
// configure if heading calibration should be displayed
@property (nonatomic, getter=isHeadingCalibrationDisplayed) BOOL displayHeadingCalibration;

// Singleton Instance
+ (MKLocationManager *)sharedInstance;

/** Sets the specified tracking mode programatically (doesn't update button) */
- (void)setTrackingMode:(MKUserTrackingMode)trackingMode;
- (void)stopAllServices;
- (void)invalidateLastKnownLocation;

- (void)whenLocationChanged:(mk_location_changed_block)block;
- (void)removeLocationChangedBlock;

@end