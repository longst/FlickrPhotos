//
//  MapViewController.h
//  TopPlaces
//
//  Created by Shitian Long on 8/4/12.
//  Copyright (c) 2012 OptiCaller Software AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@class MapViewController;

@protocol MapViewControllerDelegate <NSObject>

// delegation show callout picture
- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation;

@end

@interface MapViewController : UIViewController

@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;



@end
