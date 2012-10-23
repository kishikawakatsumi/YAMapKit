//
//  MKTouchesMovedGestureRecognizer.h
//  MapKit
//
//  Created by kishikawa katsumi on 2012/10/23.
//
//

#import <UIKit/UIKit.h>

typedef void (^TouchesEventBlock)(NSSet * touches, UIEvent * event);

@interface MKTouchesMovedGestureRecognizer : UIGestureRecognizer

@property(copy) TouchesEventBlock touchesMovedCallback;

@end
