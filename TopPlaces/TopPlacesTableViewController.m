//
//  TopPlacesTableViewController.m
//  TopPlaces
//
//  Created by Shitian Long on 7/25/12.
//  Copyright (c) 2012 OptiCaller Software AB. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "FlickrFetcher.h"

@interface TopPlacesTableViewController ()

// extra task, photo by countries data structure
@property (nonatomic, strong) NSDictionary *photosByCountries;

// new property for maintain countries list in alphabetical order
// avoid mulitple times sort
@property (nonatomic, strong) NSArray *countriesInAlpha;

@end

typedef enum{
    SORT_BY_STRING,
    SROT_BY_DIC,
    SROT_BY_UNKNOW,
}SORT_REF;


@implementation TopPlacesTableViewController


@synthesize photos = _photos;
@synthesize photosByCountries = _photosByCountries;
@synthesize countriesInAlpha = _countriesInAlpha;


- (void)setPhotos:(NSArray *)photos{
    if (_photos != photos) {
        _photos = photos;
        // update countries list each time photos dictionary updated
        [self updatePhotosByCountrise];
        
        // obly tableView reload when tableview is active
        if (self.tableView.window) {
            [self.tableView reloadData];
        }
    }
}


#pragma mark - Segue handleing
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // TODO.think about how it works
    /**
     UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
     [spinner startAnimating];
     [self.view addSubview:spinner];
     */
    
    if ([segue.identifier isEqualToString:@"showPhotoList"]){
        // get select section
        NSString *photoByCountry = [self photosByCountriesForSection: self.tableView.indexPathForSelectedRow.section];
        
        // get country array
        NSArray *photoByCountryList = [self.photosByCountries objectForKey:photoByCountry];
        
        // get photo index dic
        NSDictionary *photoDic = [photoByCountryList objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        
        //multi-thread
        dispatch_queue_t downloadQueue = dispatch_queue_create("top place download", NULL);
        dispatch_async(downloadQueue, ^{
            NSArray *photosListFromLocation = [self getLocationPhotosList:photoDic];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[segue destinationViewController] setPhotos:photosListFromLocation];
            });
        });
    }
    [[self.view.subviews mutableCopy] removeLastObject];
    
    
}

#pragma mark - view life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    
    // automatic load the list when application start
    if (!self.photos) {
        [self downloadFlickrFetcher:nil];
    }
    
}

#pragma mark - IBAction
- (IBAction)refresh:(UIBarButtonItem *)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [self downloadFlickrFetcher:sender];
}


#pragma mark - download process
- (void)downloadFlickrFetcher:(id)sender{
    dispatch_queue_t downloadQueue = dispatch_queue_create("top place download", NULL);
    
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([sender isKindOfClass:[UIBarButtonItem class]]) {
                self.navigationItem.rightBarButtonItem = sender;
            }
            self.photos = photos;
        });
    });
    dispatch_release(downloadQueue);
    
}


#pragma mark - private methods
// Task 4 fetch photo list from Flickr
- (NSArray *)getLocationPhotosList:(NSDictionary *)photoDic{
    return [FlickrFetcher photosInPlace:photoDic maxResults:50];
}


// Task 3 get photo city name
- (NSString *)getPhotoCityName:(NSDictionary *)photoDic{
    NSString * content = [photoDic objectForKey:FLICKR_PLACE_NAME];
    NSRange range = [content rangeOfString:@","];
    NSString *cityName = [content substringToIndex:range.location];
    
    // if string end with space, remove space
    if ([cityName hasSuffix:@" "]) cityName = [cityName substringToIndex:([cityName length]-1)];
    
    //NSLog(@"city Name is %@", cityName);
    return cityName;
}


// Task 3 get rest of photo information
- (NSString *)getPhotoRest:(NSDictionary *)photoDic{
    NSString * content = [photoDic objectForKey:FLICKR_PLACE_NAME];
    NSRange range = [content rangeOfString:@","];
    // remove ", " two characters
    NSString *restName = [content substringFromIndex:(range.location+2)];
    //NSLog(@"city Name is %@", restName);
    return restName;
}



// Task 2 sort in alphabet order
- (NSArray *)sortAlphabeticalOrder:(NSArray *)source{
    
    SORT_REF sort_reference;
    
    // in this case, we assume that array carray same type of element
    id element = [source objectAtIndex:0];
    
    if ([element respondsToSelector:@selector(caseInsensitiveCompare:)]) {
        sort_reference = SORT_BY_STRING;
    }
    else if ([element isKindOfClass:[NSDictionary class]]){
        sort_reference = SROT_BY_DIC;
    }
    else{
        sort_reference = SROT_BY_UNKNOW;
    }
    
    NSArray *sortedArray = nil;
    
    switch (sort_reference) {
        case SORT_BY_STRING:{
            sortedArray = [source sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
            break;
        }
            
        case SROT_BY_DIC:{
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_NAME ascending:YES];
            
            sortedArray = [[source mutableCopy] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
            break;
        }
            
        case SROT_BY_UNKNOW:{
            sortedArray = source;
            break;
        }
            
        default:
            break;
    }
    
    return sortedArray;
}


// Extra task, update photo countries data structure according to photo dictories
- (void)updatePhotosByCountrise{
    NSMutableDictionary *photosByCountries = [NSMutableDictionary dictionary];
    
    for (NSDictionary *photo in self.photos) {
        
        // get countries name
        NSString *countryOfPhoto = [self getPhotoCountry:photo];
        
        // build counties photos array
        NSMutableArray *countryOfPhotoArray = [photosByCountries objectForKey:countryOfPhoto];
        
        //either initial countries photos array or add an element in to countries photo array
        if (!countryOfPhotoArray) {
            countryOfPhotoArray = [NSMutableArray array];
            [photosByCountries setObject:countryOfPhotoArray forKey:countryOfPhoto];
        }
        
        [countryOfPhotoArray addObject:photo];
    }
    
    // sort cities photos according alphabetucal in array
    NSArray *countryList = [photosByCountries allKeys];
    for (int i = 0; i < [countryList count]; i ++) {
        NSArray *sortArray = [self sortAlphabeticalOrder:(NSArray *)[photosByCountries objectForKey:[countryList objectAtIndex:i]]];
        [photosByCountries setObject:sortArray forKey:[countryList objectAtIndex:i]];
    }
    
    // sort countries according alphabetical
    self.countriesInAlpha = [self sortAlphabeticalOrder:countryList];
    
    self.photosByCountries = photosByCountries;
}


// extra task, get photo country name
#define FLICKR_PHOTO_POSITION 2
- (NSString *)getPhotoCountry:(NSDictionary *)photoDic{
    NSString * content = [photoDic objectForKey:FLICKR_PLACE_NAME];
    
    // meta data from Fickr: Ivins, Utah, United States
    
    NSArray *photoContentElement = [content componentsSeparatedByString:@","];

    // arrary will be {Ivins, Utah, United States}
    NSString *photoCountry = nil;
    if ([photoContentElement count] == 3){
        photoCountry = [photoContentElement objectAtIndex:FLICKR_PHOTO_POSITION];
        // remove space in front of element
        if ([photoCountry hasPrefix:@" "]) photoCountry = [photoCountry substringFromIndex:1];
    }
    else {
        photoCountry = @"Unknow country";
    }
    
    return photoCountry;
}


# pragma mark table view index and section handling
- (NSString *)getCountryNameByPhotos:(NSInteger)section{
    return [[self.photosByCountries allKeys] objectAtIndex:section];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.photosByCountries count];
}


- (NSString *)photosByCountriesForSection:(NSInteger)section{
    NSArray *sortCountriesList = self.countriesInAlpha;
    return [sortCountriesList objectAtIndex:section];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self photosByCountriesForSection:section];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *photoByCountry = [self photosByCountriesForSection:section];
    NSArray *photoByCountryList = [self.photosByCountries objectForKey:photoByCountry];
    return [photoByCountryList count];
}


# pragma mark table view delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"FlickrPhoto";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // get country name
    NSString *photoByCountry = [self photosByCountriesForSection:indexPath.section];
    
    // get country array
    NSArray *photoByCountryList = [self.photosByCountries objectForKey:photoByCountry];

    
    // get photo index dic
    NSDictionary *photo = [photoByCountryList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [self getPhotoCityName:photo];
    cell.detailTextLabel.text = [self getPhotoRest:photo];
    return cell;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
