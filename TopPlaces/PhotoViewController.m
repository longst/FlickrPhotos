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
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorBaseView;


@end

@implementation PhotoViewController

@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize photo = _photo;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolbar = _toolbar;
@synthesize activityIndicatorBaseView = _activityIndicatorBaseView;


- (void)awakeFromNib{
    [super awakeFromNib];
    // set delegate
    self.scrollView.delegate = self;
}


- (void)viewDidLoad{
    [super viewDidLoad];
    // iPad hide activity view otherwise not
    if (self.splitViewController) {
        self.activityIndicatorBaseView.hidden = YES;
    }
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
    if (![_photo isEqualToDictionary:photo]){
        
        // make the view to be a blank to be prepare for indicator view
        [self removeCurrentPhotoOnView];
        _photo = photo;
        // add Photo to recent array
        [self addPhotoToRecent:self.photo];
        
        // load photo from Flickr
        [self refresh];
    }
}


- (void)removeCurrentPhotoOnView{
    self.imageView.image = nil;
}


// read photo either from Flickr or cache
- (NSData*) fetchImage {
    NSData *photoData = [self fetchPhotoFromCache];
    if (!photoData) {
        NSLog(@"read from Server");
        photoData = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge]];
    }
    else{
        NSLog(@"read from Cache");
    }
    return photoData;
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
    self.activityIndicatorBaseView.hidden = NO;
    
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
                [self storePhoto:imageData];
                [self synchronizeViewWithImage:imageData]; // Sets the zoom level to fill screen
               // [self fillView];
                // UI involved action have to be main thread
               self.activityIndicatorBaseView.hidden = YES;
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


#pragma mark store and fetch photo
- (void)storePhoto:(NSData *)photoData{
    NSString *photoID = [self.photo objectForKey:PHOTO_ID_KEY];
    //create instance of NSFileManager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //create an array and store result of our search for the documents directory in it
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
    
    NSString *directory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
    
    NSString *fullPath = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", photoID]]; //add our image to the path
    
    [fileManager createFileAtPath:fullPath contents:photoData attributes:nil]; //finally save the path (image)
    
    if ([self sizeOfCacheDirOverLimit]) {
        [self removeOldestPhoto];
    }
    
    NSLog(@"image saved");
}


#define SIZE_LIMIT 10 * 1024
- (BOOL)sizeOfCacheDirOverLimit{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSError *error = nil;
    NSDictionary *dic = [fileManager attributesOfItemAtPath:directory error:&error];
    
    float cachePhotoSizeInKb = ([[dic objectForKey:@"NSFileSize"] floatValue]/1024);
    NSLog(@"file info %g", cachePhotoSizeInKb);
    if (cachePhotoSizeInKb > SIZE_LIMIT) {
        return YES;
    }
    else{
        return NO;
    }
}


- (void)removeOldestPhoto{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // load list and reverse object order
    id photoList = [defaults objectForKey:RECENT_PHOTOS_LIST_KEY];
    if ([photoList isKindOfClass:[NSArray class]]) {
        NSMutableArray *photoListArray = [photoList mutableCopy];
        NSDictionary *photoDic = [photoListArray lastObject];
        NSString *photoID = [photoDic objectForKey:PHOTO_ID_KEY];
        [self removePhotoFromCache:photoID];
        
        // remove from NSUserDefault
        [photoListArray removeObject:photoDic];
        // save list to user default
        [defaults setObject:photoListArray forKey:RECENT_PHOTOS_LIST_KEY];
        [defaults synchronize];
    }
    
}


- (void)removePhotoFromCache:(NSString *)photoID{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *fullPath = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", photoID]];
    [fileManager removeItemAtPath: fullPath error:NULL];
    NSLog(@"image removed");
}


- (NSData *)fetchPhotoFromCache{
    NSString *photoID = [self.photo objectForKey:PHOTO_ID_KEY];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *fullPath = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", photoID]];
    NSData *photoData = [[NSData alloc] initWithContentsOfFile:fullPath];
    
    return photoData;
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
