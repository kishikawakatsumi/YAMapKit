//
//  MKViewController.m
//  YAMapKit
//
//  Created by katsumi-kishikawa on 2012/09/21.
//  Copyright (c) 2012年 kishikawa katsumi. All rights reserved.
//

#import "MKViewController.h"
#import "MKMapView.h"
#import "MKUserLocation.h"
#import "MKPointAnnotation.h"
#import "MKPinAnnotationView.h"

@interface MKViewController () <MKMapViewDelegate> {
    MKMapView *mapView;
}

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *currentButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@end

@implementation MKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 504)];
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    
    [self. view addSubview:mapView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)moveToCurrent:(id)sender {
    MKUserLocation *userLocation = mapView.userLocation;
    
    CLLocationCoordinate2D coordinate = userLocation.location.coordinate;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    [mapView setRegion:region animated:YES];
    [mapView setCenterCoordinate:coordinate animated:YES];
}

- (IBAction)addPin:(id)sender {
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = [mapView centerCoordinate];
    pin.title = @"Title";
    [mapView addAnnotation:pin];
}

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"blah"];
    view.draggable = YES;
    return view;
}

- (void)viewDidUnload {
    [self setAddButton:nil];
    [self setToolbar:nil];
    [self setCurrentButton:nil];
    [super viewDidUnload];
}
@end
