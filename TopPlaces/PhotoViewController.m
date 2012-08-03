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
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation PhotoViewController

@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize photo = _photo;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolbar = _toolbar;


- (void)awakeFromNib{
    [super awakeFromNib];
    // set delegate
    self.scrollView.delegate = self;
    
}

#pragma mark delegate
- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem{
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        NSMutableArray *toolBarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolBarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolBarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolBarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}


// refresh when Model Changed
// add photo when model changed
- (void)setPhoto:(NSDictionary *)photo{
    if (![_photo isEqualToDictionary:photo]) {
        _photo = photo;
        [self refresh];
        [self addPhotoToRecent:self.photo];
    }
}


- (NSData*) fetchImage {
    // Return the image from Flickr
    return [NSData dataWithContentsOfURL:
            [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge]];
}


- (void)synchronizeViewWithImage:(NSData *) imageData {
    
    // Place the image in the image view
    self.imageView.image = [UIImage imageWithData:imageData];
    
    // Set the title of the image
    self.title = [self.photo objectForKey:PHOTO_TITLE_KEY];
    
    // Reset the zoom scale back to proper scale accroding task 8 in assignment 4
    self.scrollView.zoomScale = [self scaleRatio];
    
    // Setup the size of the scroll view
    self.scrollView.contentSize = self.imageView.image.size;
    
    // Setup the frame of the image
    self.imageView.frame =
    CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
}


- (void)refresh {
    
    //[self.spinner startAnimating];
    
    // Initialise the queue used to download from flickr
    dispatch_queue_t dispatchQueue = dispatch_queue_create("q_photo", NULL);
    
    // Load the image using the queue
    dispatch_async(dispatchQueue, ^{
        NSString *photoID = [self.photo objectForKey:PHOTO_ID_KEY];
        NSData *imageData = [self fetchImage];
        
        // Use the main queue to store the photo in NSUserDefaults and to display
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Only store and display if another photo hasn't been selected
            if ([photoID isEqualToString:[self.photo objectForKey:PHOTO_ID_KEY]]) {
               // [self storePhoto];
                [self synchronizeViewWithImage:imageData]; // Sets the zoom level to fill screen
               // [self fillView];
               // [self.spinner stopAnimating];
            }
        });
    });   
    dispatch_release(dispatchQueue); 
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
