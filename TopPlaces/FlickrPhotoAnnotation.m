//
//  FlickrPhotoAnnotation.m
//  TopPlaces
//
//  Created by Shitian Long on 8/5/12.
//  Copyright (c) 2012 OptiCaller Software AB. All rights reserved.
//

#import "FlickrPhotoAnnotation.h"
#import "FlickrFetcher.h"

@implementation FlickrPhotoAnnotation

@synthesize photo = _photo;

+ (FlickrPhotoAnnotation *) annotationForPhoto:(NSDictionary *)photo{
    FlickrPhotoAnnotation *annotation = [[FlickrPhotoAnnotation alloc] init];
    annotation.photo = photo;
    return annotation;
}


#pragma mark implement annoation
- (NSString *)title{
    return [self.photo objectForKey:FLICKR_PHOTO_TITLE];
}


- (NSString *)subtitle{
    // another way of fetch value from Dic
    return [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
}


- (CLLocationCoordinate2D)coordinate{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.photo objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.photo objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}


@end
