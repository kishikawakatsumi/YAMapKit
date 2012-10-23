//
//  MKUserTrackingBarButtonItem.m
//  MapKit
//
//  Created by kishikawa katsumi on 2012/10/21.
//
//

#import <UIKit/UIBarButtonItem.h>
#import <MapKit/MapKit.h>

@class MKMapView;

@interface MKUserTrackingBarButtonItem : UIBarButtonItem

- (id)initWithMapView:(MKMapView *)mapView;
@property (nonatomic, strong) MKMapView *mapView;

@end
