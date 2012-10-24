//
//  MKUserTrackingButton.h
//  MapKit
//
//  Created by kishikawa katsumi on 2012/10/23.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>

@protocol MKUserTrackingButtonDelegate;
@class MKUserTrackingBarButtonItem;

@interface MKUserTrackingButton : UIButton

// Current Location-State of the Button
@property (nonatomic, assign) MKUserTrackingMode trackingMode;
@property (nonatomic, assign) BOOL headingEnabled;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, unsafe_unretained) id<MKUserTrackingButtonDelegate> delegate;

@property (nonatomic, strong) MKUserTrackingBarButtonItem *userTrackingBarButtonItem;

/** default to white, only works on iOS 5 and up */
@property (nonatomic, strong) UIColor *activityIndicatorColor;

- (void)setTrackingMode:(MKUserTrackingMode)trackingMode animated:(BOOL)animated;
// sets the right frame when used in a UINavigationBar for portrait/landscape
- (void)setFrameForInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end

@protocol MKUserTrackingButtonDelegate <NSObject>

- (void)userTrackingButton:(MKUserTrackingButton *)userTrackingButton didChangeTrackingMode:(MKUserTrackingMode)trackingMode;

@end
