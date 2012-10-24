//
//  MKView.h
//  MapKit
//
//  Created by Rick Fillion on 7/19/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKWebScriptObject;

@interface MKView : UIView

// TODO : might want to rename this one.
@property (nonatomic, readonly) NSString *viewPrototypeName;
@property (nonatomic, readonly) NSDictionary *options;

- (void)draw:(MKWebScriptObject *)overlayScriptObject;
- (MKWebScriptObject *)overlayScriptObjectFromMapScriptObject:(MKWebScriptObject *)mapScriptObject;

@end
