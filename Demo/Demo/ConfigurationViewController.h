//
//  ConfigurationViewController.h
//  Demo
//
//  Created by kishikawa katsumi on 2012/10/21.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapViewController.h"

@interface ConfigurationViewController : UIViewController

@property (weak, nonatomic) id delegate;
@property (assign, nonatomic) MKMapType mapType;

@end

@protocol ConfigurationViewControllerDelegate <NSObject>

- (void)configurationViewController:(ConfigurationViewController *)controller mapTypeChanged:(MKMapType)mapType;
- (void)configurationViewControllerWillAddPin:(ConfigurationViewController *)controller;
- (void)configurationViewControllerWillPrintMap:(ConfigurationViewController *)controller;

@end