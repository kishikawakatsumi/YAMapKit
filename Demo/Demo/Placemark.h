//
//  Placemark.h
//  Demo
//
//  Created by kishikawa katsumi on 2012/10/21.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface Placemark : MKPlacemark

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
//@property (nonatomic, readwrite, copy) NSDictionary *addressDictionary;

@end
