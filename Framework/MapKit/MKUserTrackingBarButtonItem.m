//
//  MKUserTrackingBarButtonItem.m
//  MapKit
//
//  Created by kishikawa katsumi on 2012/10/21.
//
//

#import <MapKit/MKUserTrackingBarButtonItem.h>
#import <MapKit/MKUserTrackingButton.h>
#import <MapKit/MKLocationManager.h>

@interface MKUserTrackingBarButtonItem ()

//+ (int)_activityIndicatorStyle;
//+ (Class)_activityIndicatorClass;
//@property(retain, nonatomic) UIView *_associatedView;
//@property(retain, nonatomic) UINavigationBar *_navigationBar;
//@property(retain, nonatomic) UIToolbar *_toolbar;
//@property(nonatomic) MKUserTrackingMode _state;
//@property(retain, nonatomic) UIImageView *_imageView;
//@property(retain, nonatomic) UIActivityIndicatorView *_progressIndicator;
//- (void)_goToNextMode:(id)arg1;
//- (void)_updateState;
//- (void)setState:(int)arg1;
//- (BOOL)_shouldAnimateFromState:(int)arg1 toState:(int)arg2;
//- (id)_imageForState:(int)arg1;
//- (int)_styleForState:(int)arg1;
//- (float)_verticalOffsetForState:(int)arg1;
//- (void)animationDidStop:(id)arg1 finished:(BOOL)arg2;
//- (id)_contentAnimation;
//- (id)_expandAnimation;
//- (id)_shrinkAnimation;
//- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
//- (id)createViewForNavigationItem:(id)arg1;
//- (id)createViewForToolbar:(id)arg1;
//- (void)setEnabled:(BOOL)arg1;
//- (void)_repositionViews;
//- (BOOL)_isInMiniBar;
@property(retain, nonatomic) MKUserTrackingButton *_userTrackingButton;

@end

@implementation MKUserTrackingBarButtonItem

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithMapView:(MKMapView *)mapView {
    if ((self = [self initWithTrackingMode:MKUserTrackingModeNone startListening:YES])) {
        self.mapView = mapView;
        self.delegate = [MKLocationManager sharedInstance];
        
        [[MKLocationManager sharedInstance] setMapView:mapView];
        
//        [mapView sizeToFitTrackingModeFollowWithHeading];
//        [mapView addGoogleBadge];
//        [mapView addHeadingAngleView];
    }
    
    return self;
}

- (id)initWithTrackingMode:(MKUserTrackingMode)trackingMode startListening:(BOOL)startListening
{
    self = [super initWithImage:nil style:UIBarButtonItemStyleBordered target:nil action:nil];
    if (self) {
        self.width = 32.0f;
        
        self._userTrackingButton = [[MKUserTrackingButton alloc] init];
        __userTrackingButton.userTrackingBarButtonItem = self;
        __userTrackingButton.trackingMode = trackingMode;
        
        if (startListening) {
            [self startListeningToLocationUpdates];
        }
    }
	return self;
}

- (id)initWithTrackingMode:(MKUserTrackingMode)trackingMode
{
	return [self initWithTrackingMode:trackingMode startListening:YES];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MKLocationManagerDidUpdateToLocationFromLocation object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKLocationManagerDidUpdateHeading object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKLocationManagerDidFailWithError object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKLocationManagerDidStopUpdatingServices object:nil];
}

- (id)createViewForToolbar:(id)arg1
{
    IMP f = [UIBarButtonItem instanceMethodForSelector:_cmd];
    UIView *view = f(self, _cmd, arg1);
    [view addSubview:__userTrackingButton];
    return view;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MKLocateMeBarButtonItem
////////////////////////////////////////////////////////////////////////

- (void)setTrackingMode:(MKUserTrackingMode)trackingMode
{
	[self setTrackingMode:trackingMode animated:NO];
}

- (void)setTrackingMode:(MKUserTrackingMode)trackingMode animated:(BOOL)animated
{
	[self._userTrackingButton setTrackingMode:trackingMode animated:YES];
}

- (MKUserTrackingMode)trackingMode
{
	return self._userTrackingButton.trackingMode;
}

- (void)setHeadingEnabled:(BOOL)headingEnabled
{
	self._userTrackingButton.headingEnabled = headingEnabled;
}

- (BOOL)headingEnabled
{
	return self._userTrackingButton.headingEnabled;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
	[self._userTrackingButton addTarget:target action:action forControlEvents:controlEvents];
}

- (void)setDelegate:(id<MKUserTrackingButtonDelegate>)delegate
{
    self._userTrackingButton.delegate = delegate;
}

- (id<MKUserTrackingButtonDelegate>)delegate
{
    return self._userTrackingButton.delegate;
}

- (void)setFrameForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    [self._userTrackingButton setFrameForInterfaceOrientation:orientation];
}

- (void)startListeningToLocationUpdates
{
    // begin listening to location update notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationManagerDidUpdateToLocationFromLocation:)
                                                 name:MKLocationManagerDidUpdateToLocationFromLocation
                                               object:nil];
    // begin listening to heading update notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationManagerDidUpdateHeading:)
                                                 name:MKLocationManagerDidUpdateHeading
                                               object:nil];
    // begin listening to location errors
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationManagerDidFail:)
                                                 name:MKLocationManagerDidFailWithError
                                               object:nil];
    // begin listening to end of updating of all services
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationManagerDidStopUpdatingServices:)
                                                 name:MKLocationManagerDidStopUpdatingServices
                                               object:nil];
}

- (void)stopListeningToLocationUpdates
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)locationManagerDidUpdateToLocationFromLocation:(NSNotification *)notification
{
    // only set new location status if we are currently not receiving heading updates
	if (self.trackingMode != MKUserTrackingModeFollowWithHeading) {
        [self setTrackingMode:MKUserTrackingModeFollow animated:YES];
	}
}

- (void)locationManagerDidUpdateHeading:(NSNotification *)notification
{
	CLHeading *newHeading = MKLocationGetNewHeading(notification);
    
    if (newHeading.headingAccuracy > 0) {
        [self setTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    } else {
        [self setTrackingMode:MKUserTrackingModeFollow animated:YES];
    }
}

- (void)locationManagerDidFail:(NSNotification *)notification
{
    [self setTrackingMode:MKUserTrackingModeNone animated:YES];
}

- (void)locationManagerDidStopUpdatingServices:(NSNotification *)notification
{
	// update locationStatus
	[self setTrackingMode:MKUserTrackingModeNone animated:YES];
}

@end
