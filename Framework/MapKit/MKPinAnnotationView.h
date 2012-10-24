//
//  MKPinAnnotationView.h
//  MapKit
//
//  Created by kishikawa katsumi on 2012/10/23.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MKAnnotationView.h>

enum {
    MKPinAnnotationColorRed = 0,
    MKPinAnnotationColorGreen,
    MKPinAnnotationColorPurple
};
typedef NSUInteger MKPinAnnotationColor;

@interface MKPinAnnotationView : MKAnnotationView
{
    MKPinAnnotationColor pinColor;
    BOOL animatesDrop;
}

@property (nonatomic) MKPinAnnotationColor pinColor;
@property (nonatomic) BOOL animatesDrop;

@end

