//
//  MKGeometry.m
//  MapKit
//
//  Created by H. Nikolaus Schaller on 04.10.10.
//  Copyright 2009 Golden Delicious Computers GmbH&Co. KG. All rights reserved.
//

#import <MapKit/MKGeometry.h>

/* Mercator conversion
 *
 * MapPoints are on the Mercator map in some internal coordinate system
 *   we use points (1/72 inch) so that scale factor 1 makes real world map
 *   range is 0 .. 20000km on latitude and 0 .. 40000km on longitude
 *   MKMapView knows this when fetching, scaling and drawing tiles
 *
 *   since MapPoints are some internal coordinate system we defined them to
 *   start at the southwest corner (-180deg) with (0,0) and span towards north east (+180)
 *
 * CLLocationCoordinate2D are on earth surface
 *   (-90 (south) .. +90 (north) / -180 (west) .. 180 (east) degrees)
 */

MKCoordinateRegion MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D center,
													  CLLocationDistance lat,
													  CLLocationDistance lng)
{
	return MKCoordinateRegionMake(center, MKCoordinateSpanMake(lat, lng));
}

const MKMapSize MKMapSizeWorld = {268435456.0, 268435456.0};
const MKMapRect MKMapRectWorld = {{0.0, 0.0}, {268435456.0, 268435456.0}};

#define POINTS_PER_METER (72 / 0.0254)
#define EQUATOR_RADIUS	6378127.0	// WGS84 in meters
#define POLE_RADIUS 6356752.314
#define MKMapWidth (2 * M_PI * EQUATOR_RADIUS * POINTS_PER_METER)	// total width of map expressed in typographic points
#define MKMapHeight (M_PI * POLE_RADIUS * POINTS_PER_METER)		// total height of map

MKMapPoint MKMapPointForCoordinate(CLLocationCoordinate2D coord)
{ // positive coords go east (!) and north
	double l = coord.latitude * (M_PI / 180.0);		// latitude is limited to approx. +/- 85 deg
	double n = log( tan(l) + 1.0 / cos(l));
	double y = 0.5 + n / (2.0 * M_PI);
	double x = (180.0 + coord.longitude) / 360.0;
	return MKMapPointMake(x * MKMapWidth, y * MKMapHeight);
}

CLLocationCoordinate2D MKCoordinateForMapPoint(MKMapPoint mapPoint)
{
	double x = mapPoint.x / MKMapWidth;			// 0 ... MapWidth : 0 = -180 deg (west)
	double y = mapPoint.y / MKMapHeight;		// 0 ... MapHeigh : 0 = north
	CLLocationCoordinate2D loc;
	double n, l;
	x = fmod(x, 1.0);	// see http://www.gnu.org/s/hello/manual/libc/Remainder-Functions.html
	y = fmod(y, 1.0);
	n = y * (2.0 * M_PI) - M_PI;	// -PI ... +PI
	l = atan(0.5 * (exp(n) - exp(-n)));
	loc.latitude = (180.0 / M_PI) * l;
	loc.longitude = x * 360.0 - 180.0;	// -180 ... +180
	return loc;
}

CLLocationDistance MKMetersPerMapPointAtLatitude(CLLocationDegrees lat)
{
	return 1.0 / MKMapPointsPerMeterAtLatitude(lat);
}

double MKMapPointsPerMeterAtLatitude(CLLocationDegrees lat)
{
	return POINTS_PER_METER * cos((M_PI / 180.0) * lat);
}

const MKMapRect MKMapRectNull = {{INFINITY, INFINITY}, {0, 0}};

MKMapRect MKMapRectUnion(MKMapRect r1, MKMapRect r2)
{
	MKMapRect r;
	if(MKMapRectIsEmpty(r1)) return r2;
	if(MKMapRectIsEmpty(r2)) return r1;
	r.origin.x=MIN(r1.origin.x, r2.origin.x);
	r.origin.y=MIN(r1.origin.y, r2.origin.y);
	r.size.width=MAX(r1.origin.x+r1.size.width, r2.origin.x+r2.size.width)-r.origin.x;
	r.size.height=MAX(r1.origin.y+r1.size.height, r2.origin.y+r2.size.height)-r.origin.y;
	return r;
}

MKMapRect MKMapRectIntersection(MKMapRect r1, MKMapRect r2)
{
	MKMapRect r;
	r.origin.x=MAX(r1.origin.x, r2.origin.x);
	r.origin.y=MAX(r1.origin.y, r2.origin.y);
	r.size.width=MIN(r1.origin.x+r1.size.width, r2.origin.x+r2.size.width)-r.origin.x;
	if(r.size.width < 0.0) r.size.width=0.0;	// no intersection
	r.size.height=MIN(r1.origin.y+r1.size.height, r2.origin.y+r2.size.height)-r.origin.y;
	if(r.size.height < 0.0) r.size.height=0.0;	// no intersection
	return r;
}

MKMapRect MKMapRectInset(MKMapRect rect, double dx, double dy)
{
	return MKMapRectMake(rect.origin.x+0.5*dx, rect.origin.y+0.5*dy, rect.size.width-dx, rect.size.height-dy);
}

MKMapRect MKMapRectOffset(MKMapRect rect, double dx, double dy)
{
	return MKMapRectMake(rect.origin.x+dx, rect.origin.y+dy, rect.size.width, rect.size.height);
}

BOOL MKMapRectContainsPoint(MKMapRect rect, MKMapPoint point)
{
	if(point.x < rect.origin.x || point.x > rect.origin.x+rect.size.width) return NO;
	if(point.y < rect.origin.y || point.y > rect.origin.y+rect.size.height) return NO;
	return YES;
}

BOOL MKMapRectContainsRect(MKMapRect r1, MKMapRect r2)
{ // r1 contains all corner points of r2
	if(r2.origin.x < r1.origin.x || r2.origin.x+r2.size.width > r1.origin.x+r1.size.width) return NO;
	if(r2.origin.y < r1.origin.y || r2.origin.y+r2.size.height > r1.origin.y+r1.size.height) return NO;
	return YES;
}

BOOL MKMapRectIntersectsRect(MKMapRect r1, MKMapRect r2)
{
	if(r1.origin.x+r1.size.width < r2.origin.x)	return NO;
	if(r2.origin.x+r2.size.width < r1.origin.x) return NO;
	if(r1.origin.y+r1.size.height < r2.origin.y) return NO;
	if(r2.origin.y+r2.size.height < r1.origin.y) return NO;
	return YES;
}

// FIXME: the rect becomes distorted when represented as "span"!
// FIXME: there is no reverse function for this

MKCoordinateRegion MKCoordinateRegionForMapRect(MKMapRect rect)
{
	return MKCoordinateRegionMake(MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMidX(rect), MKMapRectGetMidY(rect))),
								  MKCoordinateSpanMake( // FIXME:
													   /* lat */ 0.0, /* lng */ 0.0 )
								  );
}

BOOL MKMapRectSpans180thMeridian(MKMapRect rect)
{
	return MKMapRectGetMinX(rect) < 0 || MKMapRectGetMaxX(rect) > MKMapWidth;
}

@implementation NSValue (NSValueMapKitGeometryExtensions)

+ (NSValue *)valueWithMKCoordinate:(CLLocationCoordinate2D)coordinate
{
    return [NSValue value:&coordinate withObjCType:@encode(CLLocationCoordinate2D)];
}

+ (NSValue *)valueWithMKCoordinateSpan:(MKCoordinateSpan)span
{
    return [NSValue value:&span withObjCType:@encode(MKCoordinateSpan)];
}

- (CLLocationCoordinate2D)MKCoordinateValue
{
    CLLocationCoordinate2D coordinate;
    [self getValue:&coordinate];
    return coordinate;
}

- (MKCoordinateSpan)MKCoordinateSpanValue
{
    MKCoordinateSpan span;
    [self getValue:&span];
    return span;
}

@end
