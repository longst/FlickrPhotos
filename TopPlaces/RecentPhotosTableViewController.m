//
//  RecentPhotos.m
//  TopPlaces
//
//  Created by Shitian Long on 7/25/12.
//  Copyright (c) 2012 OptiCaller Software AB. All rights reserved.
//

#import "RecentPhotosTableViewController.h"
#import "PhotoViewController.h"
#import "NSUserDefaultKey.h"
#import "FlickrFetcher.h"

@interface RecentPhotosTableViewController ()
//- (NSArray *)initialModel;

@end

@implementation RecentPhotosTableViewController



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // read photo list from user default
    NSArray *photosList = [self initialModel];
    
    // if photo list update, load new photo list structure to model and reload table view
    if (![photosList isEqual:self.photos]) {
        self.photos = photosList;
        [self.tableView reloadData];
    }
}


- (NSArray *)initialModel{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *photoList = [[[defaults objectForKey:RECENT_PHOTOS_LIST_KEY] reverseObjectEnumerator] allObjects];
    return photoList;
}







@end
