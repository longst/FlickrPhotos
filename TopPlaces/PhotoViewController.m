//
//  PhotoViewController.m
//  TopPlaces
//
//  Created by Shitian Long on 7/27/12.
//  Copyright (c) 2012 OptiCaller Software AB. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"
#import "NSUserDefaultKey.h"

#define PHOTO_ID_KEY @"id"
#define PHOTO_TITLE_KEY @"title"

@interface PhotoViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (void)addPhotoToRecent:(NSDictionary *)photoElement;
- (NSMutableArray *)addUniquePhotoToList:(NSMutableArray *)photoList WithPhoto:(NSDictionary *)photoElement;

- (float) scaleRatio;

@end

@implementation PhotoViewController

@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize photo = _photo;


#pragma mark view life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set delegate
    self.scrollView.delegate = self;
    
    NSData *imageData = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge]];
    self.imageView.image = [UIImage imageWithData:imageData];
    // seems does not work properly for request task 8....
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    
    self.title = [self.photo objectForKey:PHOTO_TITLE_KEY];
    
    //setup size of scroll view
    self.scrollView.contentSize = self.imageView.image.size;
    
    //setup the frame of the image
    
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
	// Do any additional setup after loading the view.
}


- (float) scaleRatio{
    float scaleRatio = 1.0;
    if (self.imageView.image.size.width > self.imageView.image.size.height) {
        scaleRatio = self.imageView.image.size.height / self.view.frame.size.height;
    }
    else{
        scaleRatio = self.imageView.image.size.width / self.view.frame.size.width;
    }
    return scaleRatio;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // add photo to recent
    [self addPhotoToRecent:self.photo];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


#pragma mark scroll view delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


# pragma mark private methods
// add Add Recent Photo List, think about reference with time stamp?
- (void)addPhotoToRecent:(NSDictionary *)photoElement{
    
    // initial NSUserDefault
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // read recent photo list from user default
    NSMutableArray *recentPhotoList = [[defaults objectForKey:RECENT_PHOTOS_LIST_KEY] mutableCopy];
    
    // either initial a photo list or add current photo to list
    if (!recentPhotoList) {
        recentPhotoList = [NSMutableArray array];
    }
    
    // add photo as unique
    recentPhotoList = [self addUniquePhotoToList: recentPhotoList WithPhoto:photoElement];
    
    
    // Task 2
    // check if more than 20 element in the array
    // if so remove first element in the array
    if ([recentPhotoList count] > 20) {
        [recentPhotoList removeObjectAtIndex:0];
    }
    
    // save list to user default
    [defaults setObject:recentPhotoList forKey:RECENT_PHOTOS_LIST_KEY];
    [defaults synchronize];
}


- (NSMutableArray *)addUniquePhotoToList:(NSMutableArray *)photoList WithPhoto:(NSDictionary *)photoElement{
    
    // remove previous added photo element
    for (int i = 0; i < [photoList count]; i ++) {
        NSDictionary *photoDic = [photoList objectAtIndex:i];
        if ([[photoDic objectForKey:PHOTO_ID_KEY] isEqualToString:[photoElement objectForKey:PHOTO_ID_KEY]]) {
            [photoList removeObject:photoDic];
        }
    }
    
    // add new photo elements
    [photoList addObject:photoElement];
    return photoList;
}



@end
