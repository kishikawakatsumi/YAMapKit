//
//  MKOverlayView.h
//  MapKit
//
//  Created by Rick Fillion on 7/12/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKOverlay.h"
#import "MKView.h"

@interface MKOverlayView : MKView {
    id <MKOverlay> overlay;
}

@property (nonatomic, readonly) id <MKOverlay> overlay;

- (id)initWithOverlay:(id <MKOverlay>)anOverlay;

@end
