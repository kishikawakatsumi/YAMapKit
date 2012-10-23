
//
//  MKTouchesMovedGestureRecognizer.m
//  MapKit
//
//  Created by kishikawa katsumi on 2012/10/23.
//
//

#import "MKTouchesMovedGestureRecognizer.h"

#define MKTouchesMinimumDuration  0.5

@interface MKTouchesMovedGestureRecognizer ()

@property (nonatomic, strong) NSDate *touchesBeganTimestamp;

@end

@implementation MKTouchesMovedGestureRecognizer

@synthesize touchesMovedCallback = touchesMovedCallback_;
@synthesize touchesBeganTimestamp = touchesBeganTimestamp_;

- (id)init {
	if ((self = [super init])) {
		self.cancelsTouchesInView = NO;
	}
	return self;
}

- (void)dealloc
{
    touchesMovedCallback_ = nil;
	touchesBeganTimestamp_ = nil;
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    if (touches.count >= 2) {
//        self.touchesBeganTimestamp = [NSDate date];
//    }
//}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (/*self.touchesBeganTimestamp != nil && [self.touchesBeganTimestamp timeIntervalSinceNow] < MKTouchesMinimumDuration &&*/
		touches.count == 1 && self.touchesMovedCallback) {
		self.touchesMovedCallback(touches, event);
	}
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    self.touchesBeganTimestamp = nil;
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    self.touchesBeganTimestamp = nil;
//}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
	return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
	return NO;
}

@end
