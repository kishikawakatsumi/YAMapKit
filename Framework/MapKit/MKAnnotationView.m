//
//  MKAnnotationView.m
//  MapKit
//
//  Created by Rick Fillion on 7/18/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import <MapKit/MKAnnotationView.h>
#import <MapKit/MKAnnotation.h>
#import <MapKit/MKMapView.h>
#import <MapKit/MKWebScriptEngine.h>
#import <MapKit/MKWebScriptObject.h>
#import <QuartzCore/QuartzCore.h>

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

- (id)init
{
    self = [super init];
    if (self) {
        _imageSize = CGSizeZero;
    }
    return self;
}

- (id)initWithAnnotation:(id <MKAnnotation>)anAnnotation reuseIdentifier:(NSString *)aReuseIdentifier
{
    if (self = [super init])
    {
        _imageSize = CGSizeZero;
        
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

- (void)setImage:(UIImage *)image
{
    static NSUInteger number = 0;
    _image = image;
    NSString *tmp = NSTemporaryDirectory();
    NSString *file = [NSString stringWithFormat:@"MKAnnotationView-custom-image%d", number++];
    NSString *path = [tmp stringByAppendingPathComponent:file];
    imageUrl = path;
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:imageUrl atomically:YES];
}

- (NSDictionary *)options
{
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:[super options]];
    
    if (self.imageUrl) {
        [options setObject:self.imageUrl forKey:@"imageUrl"];
    } else {
        self.imageSize = self.bounds.size;
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.image = image;
        [options setObject:self.imageUrl forKey:@"imageUrl"];
    }
    if (!CGSizeEqualToSize(self.imageSize, CGSizeZero)) {
        [options setObject:[NSNumber numberWithInteger:(NSInteger)self.imageSize.width] forKey:@"imageWidth"];
        [options setObject:[NSNumber numberWithInteger:(NSInteger)self.imageSize.height] forKey:@"imageHeight"];
    }
    
    if (latlngCenter) {
        [options setObject:latlngCenter forKey:@"position"];
    }
    
    if ([self.annotation respondsToSelector:@selector(title)] && self.annotation.title) {
        [options setObject:[self.annotation title] forKey:@"title"];
    }
    
    [options setObject:[NSNumber numberWithBool:draggable] forKey:@"draggable"];
    
    return [options copy];
}

- (void)draw:(MKWebScriptObject *)overlayScriptObject
{
    NSString *script = [NSString stringWithFormat:@"new google.maps.LatLng(%f, %f);", self.annotation.coordinate.latitude, self.annotation.coordinate.longitude];
    latlngCenter = [overlayScriptObject.scriptEngine evaluateWebScript:script];
    
    [super draw:overlayScriptObject];
}

- (void)setTransformAccordingToMapView:(MKMapView *)mapView {
    [self setTransform:CGAffineTransformInvert(mapView.transform)];
}

@end
