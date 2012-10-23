//
//  MKCircleView.h
//  MapKit
//
//  Created by Rick Fillion on 7/12/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKOverlayPathView.h"

@class WebScriptObject;
@class MKCircle;

@interface MKCircleView : MKOverlayPathView {
    WebScriptObject *latlngCenter;
}

@property (nonatomic, readonly) MKCircle *circle;

- (id)initWithCircle:(MKCircle *)circle;



@end
