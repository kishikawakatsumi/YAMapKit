//
//  MKOverlayPathView.h
//  MapKit
//
//  Created by Rick Fillion on 7/12/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKOverlayView.h>

@interface MKOverlayPathView : MKOverlayView {
    UIColor *fillColor;
    UIColor *strokeColor;
    CGFloat lineWidth;
}

@property (nonatomic, retain) UIColor *fillColor;
@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat lineWidth;

@end
