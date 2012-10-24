//
//  MKLocationManager.m
//  MapKit
//
//  Created by kishikawa katsumi on 2012/10/23.
//
//

#import <MapKit/MKLocationManager.h>
#import <MapKit/MKTouchesMovedGestureRecognizer.h>
#import <MapKit/MKMapView.h>

@interface MKLocationManager ()

@property (nonatomic, copy) mk_location_changed_block locationChangedBlock;

@end

@implementation MKLocationManager

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)init {
    if ((self = [super init])) {
        _locationManager = [[CLLocationManager alloc] init];
		_locationManager.delegate = self;
        _displayHeadingCalibration = YES;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MKLocationManager
////////////////////////////////////////////////////////////////////////

- (void)setTrackingMode:(MKUserTrackingMode)trackingMode {
    [self setActiveServicesForTrackingMode:trackingMode];
}

- (void)stopAllServices {
	// Reset transform on map
    [self.mapView resetHeadingRotationAnimated:YES];
    [self.mapView hideHeadingAngleView];
    
    self.mapView.userTrackingMode = MKUserTrackingModeNone;
    
	// stop location-services
	[self.locationManager stopUpdatingLocation];
	[self.locationManager stopUpdatingHeading];
    
	// post notification
	[[NSNotificationCenter defaultCenter] postNotificationName:MKLocationManagerDidStopUpdatingHeading object:self userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:MKLocationManagerDidStopUpdatingServices object:self userInfo:nil];
}

- (void)invalidateLastKnownLocation
{
    self.lastKnownLocation = nil;
}

- (void)whenLocationChanged:(mk_location_changed_block)block
{
    self.locationChangedBlock = block;
}

- (void)removeLocationChangedBlock {
    self.locationChangedBlock = nil;
}

- (void)setMapView:(MKMapView *)mapView {
	if(mapView != _mapView) {
		_mapView = mapView;
        
        // detect taps on the map-view
        MKTouchesMovedGestureRecognizer * tapInterceptor = [[MKTouchesMovedGestureRecognizer alloc] init];
        // safe self for block
        __unsafe_unretained MKLocationManager *blockSelf = self;
        
        tapInterceptor.touchesMovedCallback = ^(NSSet * touches, UIEvent * event) {
            // Reset transform on map
            [blockSelf.mapView resetHeadingRotationAnimated:YES];
            // hide heading angle overlay
            [blockSelf.mapView hideHeadingAngleView];
            
            // stop location-services
            [[MKLocationManager sharedInstance].locationManager stopUpdatingLocation];
            [[MKLocationManager sharedInstance].locationManager stopUpdatingHeading];
            
            // Tell LocateMeBarButtonItem to update it's state
            [[NSNotificationCenter defaultCenter] postNotificationName:MKLocationManagerDidStopUpdatingHeading object:blockSelf userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:MKLocationManagerDidStopUpdatingServices object:blockSelf userInfo:nil];
        };
        
        [self.mapView addGestureRecognizer:tapInterceptor];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - CLLocationManagerDelegate
////////////////////////////////////////////////////////////////////////

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, MKLocationLocationManagerKey,
							  newLocation, MKLocationNewLocationKey,
							  oldLocation, MKLocationOldLocationKey, nil];
    
    // move heading angle overlay to new coordinate
    [self.mapView setCenterCoordinate:newLocation.coordinate animated:YES];
    [self.mapView moveHeadingAngleViewToCoordinate:newLocation.coordinate];
    
    // save last known global location
    self.lastKnownLocation = newLocation;
    
    // call delegate-block if there is one
    if (self.locationChangedBlock != nil) {
        self.locationChangedBlock(newLocation);
    }
    
	[[NSNotificationCenter defaultCenter] postNotificationName:MKLocationManagerDidUpdateToLocationFromLocation object:self userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, MKLocationLocationManagerKey,
							  error, MKLocationErrorKey, nil];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:MKLocationManagerDidFailWithError object:self userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, MKLocationLocationManagerKey,
							  newHeading, MKLocationNewHeadingKey, nil];
    
    if (newHeading.headingAccuracy > 0) {
        // show heading angle overlay
        [self.mapView showHeadingAngleView];
        // move heading angle overlay to new coordinate
        [self.mapView moveHeadingAngleViewToCoordinate:self.mapView.userLocation.coordinate];
        // rotate map according to heading
        [self.mapView rotateToHeading:newHeading animated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MKLocationManagerDidUpdateHeading object:self userInfo:userInfo];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return self.displayHeadingCalibration;
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, MKLocationLocationManagerKey,
							  region, MKLocationRegionKey, nil];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:MKLocationManagerDidEnterRegion object:self userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, MKLocationLocationManagerKey,
							  region, MKLocationRegionKey, nil];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:MKLocationManagerDidExitRegion object:self userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, MKLocationLocationManagerKey,
							  region, MKLocationRegionKey,
							  error, MKLocationErrorKey, nil];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:MKLocationManagerMonitoringDidFailForRegion object:self userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, MKLocationLocationManagerKey,
							  [NSNumber numberWithInt:status], MKLocationAuthorizationStatusKey, nil];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:MKLocationManagerDidChangeAuthorizationStatus object:self userInfo:userInfo];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MKUserTrackingButtonDelegate
////////////////////////////////////////////////////////////////////////

- (void)userTrackingButton:(MKUserTrackingButton *)userTrackingButton didChangeTrackingMode:(MKUserTrackingMode)trackingMode
{
    [self setActiveServicesForTrackingMode:trackingMode];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)setActiveServicesForTrackingMode:(MKUserTrackingMode)trackingMode
{
    self.mapView.userTrackingMode = (MKUserTrackingMode)trackingMode;
    
    // check new status after status-toggle and update locationManager accordingly
    switch(trackingMode) {
            // if we are currently idle, stop updates
        case MKUserTrackingModeNone:
            [self stopAllServices];
            break;
            
            // if we are currently searching, start updating location
        case MKUserTrackingModeSearching:
            [self.locationManager startUpdatingLocation];
            [self.locationManager stopUpdatingHeading];
            break;
            
            // if we are already receiving updates
        case MKUserTrackingModeFollow:
            [self.locationManager startUpdatingLocation];
            [self.locationManager stopUpdatingHeading];
            break;
            
            // if we are currently receiving heading updates, start updating heading
        case MKUserTrackingModeFollowWithHeading:
            [self.locationManager startUpdatingLocation];
            [self.locationManager startUpdatingHeading];
            break;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Singleton
////////////////////////////////////////////////////////////////////////

static MKLocationManager *sharedMKLocationManager = nil;

+ (MKLocationManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMKLocationManager = [[self alloc] init];
    });
    
	return sharedMKLocationManager;
}

@end
