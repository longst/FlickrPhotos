//
//  MapViewController.m
//  TopPlaces
//
//  Created by Shitian Long on 8/4/12.
//  Copyright (c) 2012 OptiCaller Software AB. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;


- (void)setMapView:(MKMapView *)mapView{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations{
    _annotations = annotations;
    [self updateMapView];
}


// lecture 11 around 46:57, when I was seguing, the outlet is not set, in this case, self.mapView is not set
// therefore, we have to make view and model sync like this
- (void)updateMapView{
    if(self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateMapView];
}


- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
