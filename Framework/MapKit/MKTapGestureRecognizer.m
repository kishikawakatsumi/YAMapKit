//
//  MKTwoFingerTouchGestureRecognizer.m
//  MapKit
//
//  Created by kishikawa katsumi on 2012/10/25.
//
//

#import "MKTapGestureRecognizer.h"

@implementation MKTapGestureRecognizer

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
	return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
	return NO;
}

@end
