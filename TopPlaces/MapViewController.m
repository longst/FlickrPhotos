//
//  MapViewController.m
//  TopPlaces
//
//  Created by Shitian Long on 8/4/12.
//  Copyright (c) 2012 OptiCaller Software AB. All rights reserved.
//

#import "MapViewController.h"
#import "PhotoViewController.h"
#import "FlickrPhotoAnnotation.h"

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;


#pragma mark setter and getter
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


#pragma mark MK MapViewDelegate
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVc"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVc"];
        aView.canShowCallout = YES;
        // 30 30 from lecture 11
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    return aView;
}


- (PhotoViewController *)splitViewPhotoViewController{
    id photoViewController = [self.splitViewController.viewControllers lastObject];
    
    if (![photoViewController isKindOfClass:[PhotoViewController class]]) {
        photoViewController = nil;
    }
    return photoViewController;
}


// TODO add a button show detail image
// Think about if it possible first show callout, next chick show detail
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    UIImage *image = [self.delegate mapViewController:self imageForAnnotation:view.annotation];
    // implement show detal view
    [(UIImageView *)view.leftCalloutAccessoryView setImage:image];
    
    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)view.annotation;
    if ([self splitViewPhotoViewController]) {
        [[self splitViewPhotoViewController] setPhoto:fpa.photo];
    }
    else{
        [self performSegueWithIdentifier:@"show photo detail" sender:fpa.photo];
    }

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"show photo detail"]) {
        [[segue destinationViewController] setPhoto:sender];
    }
}


#pragma mark view life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    self.mapView.delegate = self;
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
