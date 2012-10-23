//
//  MKAnnotationView.m
//  MapKit
//
//  Created by Rick Fillion on 7/18/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import "MKAnnotationView.h"
#import "MKAnnotation.h"
#import "MKMapView.h"
#import "WebScriptEngine.h"
#import "WebScriptObject.h"

@implementation MKAnnotationView

@synthesize reuseIdentifier;
@synthesize annotation;
@synthesize imageUrl;
@synthesize centerOffset;
@synthesize calloutOffset;
@synthesize enabled;
@synthesize highlighted;
@synthesize selected;
@synthesize canShowCallout;
@synthesize draggable;
@synthesize dragState;

- (id)initWithAnnotation:(id <MKAnnotation>)anAnnotation reuseIdentifier:(NSString *)aReuseIdentifier
{
    if (self = [super init])
    {
        reuseIdentifier = aReuseIdentifier;
        self.annotation = anAnnotation;
    }
    return self;
}

- (void)prepareForReuse
{
    // Unsupported so far.
}

- (void)setSelected:(BOOL)_selected animated:(BOOL)animated
{
    self.selected = _selected;
}

- (NSString *)viewPrototypeName
{
    return @"AnnotationOverlay";
}

- (CGSize)imageSize
{
    return CGSizeZero;
}

- (NSDictionary *)options
{
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:[super options]];
    
    if (self.imageUrl) {
        [options setObject:self.imageUrl forKey:@"imageUrl"];
    }
    if (!CGSizeEqualToSize(self.imageSize, CGSizeZero)) {
        [options setObject:[NSNumber numberWithInteger:(NSInteger)self.imageSize.width] forKey:@"imageWidth"];
        [options setObject:[NSNumber numberWithInteger:(NSInteger)self.imageSize.height] forKey:@"imageHeight"];
    }
    
    if (latlngCenter) {
        [options setObject:latlngCenter forKey:@"position"];
    }
    
    if ([self.annotation title]) {
        [options setObject:[self.annotation title] forKey:@"title"];
    }
    
    [options setObject:[NSNumber numberWithBool:draggable] forKey:@"draggable"];
    
    return [options copy];
}

- (void)draw:(WebScriptObject *)overlayScriptObject
{
    NSString *script = [NSString stringWithFormat:@"new google.maps.LatLng(%f, %f);", self.annotation.coordinate.latitude, self.annotation.coordinate.longitude];
    latlngCenter = [overlayScriptObject.scriptEngine evaluateWebScript:script];
    
    [super draw:overlayScriptObject];
}

- (void)setTransformAccordingToMapView:(MKMapView *)mapView {
    [self setTransform:CGAffineTransformInvert(mapView.transform)];
}

@end
