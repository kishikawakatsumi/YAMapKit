//
//  ConfigurationViewController.m
//  Demo
//
//  Created by kishikawa katsumi on 2012/10/21.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "MapViewController.h"

@interface ConfigurationViewController () {
    UIButton *dropPinButton;
    UIButton *printButton;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeControl;

@end

@implementation ConfigurationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat y = _mapTypeControl.frame.origin.y - 18.0f - 46.0f;
    dropPinButton = [UIButton buttonWithType:110];
    dropPinButton.frame = CGRectMake(20.0f, y, 136.0f, 46.0f);
    dropPinButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [dropPinButton setTitle:NSLocalizedString(@"Drop Pin", nil) forState:UIControlStateNormal];
    [dropPinButton addTarget:self action:@selector(dropPin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dropPinButton];
    
    printButton = [UIButton buttonWithType:110];
    printButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    printButton.frame = CGRectMake(164.0f, y, 136.0f, 46.0f);
    [printButton setTitle:NSLocalizedString(@"Print", nil) forState:UIControlStateNormal];
    [printButton addTarget:self action:@selector(print:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:printButton];
    
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    if (!controller) {
        printButton.enabled = NO;
    }
    
    CGRect segmentFrame = self.mapTypeControl.frame;
    CGSize segmentSize = segmentFrame.size;
    segmentSize.height = 46.0f;
    segmentFrame.size = segmentSize;
    _mapTypeControl.frame = segmentFrame;
    [_mapTypeControl setTitle:NSLocalizedString(@"Map", nil) forSegmentAtIndex:0];
    [_mapTypeControl setTitle:NSLocalizedString(@"Satellite", nil) forSegmentAtIndex:1];
    [_mapTypeControl setTitle:NSLocalizedString(@"Hybrid", nil) forSegmentAtIndex:2];
    _mapTypeControl.segmentedControlStyle = 6;
    _mapTypeControl.selectedSegmentIndex = _mapType;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dropPin:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^
     {
         if ([_delegate respondsToSelector:@selector(configurationViewControllerWillAddPin:)]) {
             [_delegate configurationViewControllerWillAddPin:self];
         }
     }];
}

- (void)print:(id)sender
{
    if ([_delegate respondsToSelector:@selector(configurationViewControllerWillPrintMap:)]) {
        [_delegate configurationViewControllerWillPrintMap:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)mapTypeChanged:(id)sender
{
    if ([_delegate respondsToSelector:@selector(configurationViewController:mapTypeChanged:)]) {
        [_delegate configurationViewController:self mapTypeChanged:_mapTypeControl.selectedSegmentIndex];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
