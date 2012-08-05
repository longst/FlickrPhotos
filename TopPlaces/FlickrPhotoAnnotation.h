//
//  FlickrPhotoAnnotation.h
//  TopPlaces
//
//  Created by Shitian Long on 8/5/12.
//  Copyright (c) 2012 OptiCaller Software AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

// Part or controller and part of the model, bridge between the model and controller
@interface FlickrPhotoAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSDictionary *photo;

// Convenience method
+ (FlickrPhotoAnnotation *) annotationForPhoto:(NSDictionary *)photo; // Flickr photo dictonary

@end
