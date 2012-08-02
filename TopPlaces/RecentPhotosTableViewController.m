//
//  RecentPhotos.m
//  TopPlaces
//
//  Created by Shitian Long on 7/25/12.
//  Copyright (c) 2012 OptiCaller Software AB. All rights reserved.
//

#import "RecentPhotosTableViewController.h"
#import "NSUserDefaultKey.h"

@interface RecentPhotosTableViewController ()

@end

@implementation RecentPhotosTableViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // read from UserDefault
    self.photos = [self initialModel];
}

- (NSArray *)initialModel{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // load list and reverse object order
    NSArray *photoList = [[[defaults objectForKey:RECENT_PHOTOS_LIST_KEY] reverseObjectEnumerator] allObjects];
    return photoList;
}




@end
