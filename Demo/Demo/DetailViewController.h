//
//  DetailViewController.h
//  Demo
//
//  Created by kishikawa katsumi on 2012/10/21.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
//#import <AddressBookUI/AddressBookUI.h>
//#import <iAd/iAd.h>

@interface DetailViewController : UITableViewController

@property (weak, nonatomic) MKMapView *mapView;
@property (weak, nonatomic) MKPlacemark *placemark;

@end
