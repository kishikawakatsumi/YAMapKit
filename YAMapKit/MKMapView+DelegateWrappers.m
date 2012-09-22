//
//  MKMapView+DelegateWrappers.m
//  MapKit
//
//  Created by Rick Fillion on 7/22/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import "MKMapView+DelegateWrappers.h"

@implementation MKMapView (DelegateWrappers)

- (void)delegateRegionWillChangeAnimated:(BOOL)animated
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:)]) {
        [self.delegate mapView:self regionWillChangeAnimated:animated];
    }
}

- (void)delegateRegionDidChangeAnimated:(BOOL)animated
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)]) {
        [self.delegate mapView:self regionDidChangeAnimated:animated];
    }
}

- (void)delegateDidUpdateUserLocation
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:didUpdateUserLocation:)]) {
        [self.delegate mapView:self didUpdateUserLocation:self.userLocation];
    }
}

- (void)delegateDidFailToLocateUserWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:didFailToLocateUserWithError:)]) {
        [self.delegate mapView:self didFailToLocateUserWithError:error];
    }
}

- (void)delegateWillStartLocatingUser
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapViewWillStartLocatingUser:)]) {
        [self.delegate mapViewWillStartLocatingUser:self];
    }
}

- (void)delegateDidStopLocatingUser
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapViewDidStopLocatingUser:)]) {
        [self.delegate mapViewDidStopLocatingUser:self];
    }
}

- (void)delegateDidAddOverlayViews:(NSArray *)someOverlayViews
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:didAddOverlayViews:)]) {
        [self.delegate mapView:self didAddOverlayViews:someOverlayViews];
    }
}

- (void)delegateDidAddAnnotationViews:(NSArray *)someAnnotationViews
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:didAddAnnotationViews:)]) {
        [self.delegate mapView:self didAddAnnotationViews:someAnnotationViews];
    }
}

- (void)delegateDidSelectAnnotationView:(MKAnnotationView *)view
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]) {
        [self.delegate mapView:self didSelectAnnotationView:view];
    }
}

- (void)delegateDidDeselectAnnotationView:(MKAnnotationView *)view
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:didDeselectAnnotationView:)]) {
        [self.delegate mapView:self didDeselectAnnotationView:view];
    }
}

- (void)delegateAnnotationView:(MKAnnotationView *)annotationView
            didChangeDragState:(MKAnnotationViewDragState)newState
                  fromOldState:(MKAnnotationViewDragState)oldState
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:annotationView:didChangeDragState:fromOldState:)]) {
        [self.delegate mapView:self annotationView:annotationView didChangeDragState:newState fromOldState:oldState];
    }
}

- (void)delegateWillStartLoadingMap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapViewWillStartLoadingMap:)]) {
        [self.delegate mapViewWillStartLoadingMap:self];
    }
}

- (void)delegateDidFinishLoadingMap;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapViewDidFinishLoadingMap:)]) {
        [self.delegate mapViewDidFinishLoadingMap:self];
    }
}

- (void)delegateDidFailLoadingMapWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapViewDidFailLoadingMap:withError:)]) {
        [self.delegate mapViewDidFailLoadingMap:self withError:error];
    }
}

// MacMapKit additions
- (void)delegateUserDidClickAndHoldAtCoordinate:(CLLocationCoordinate2D)coordinate;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:userDidClickAndHoldAtCoordinate:)]) {
        [self.delegate mapView:self userDidClickAndHoldAtCoordinate:coordinate];
    }
    
}

- (NSArray *)delegateContextMenuItemsForAnnotationView:(MKAnnotationView *)view
{
    NSArray *items = [NSArray array];
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:contextMenuItemsForAnnotationView:)]) {
        items = [self.delegate mapView:self contextMenuItemsForAnnotationView:view];
    }
    return items;
}


@end
