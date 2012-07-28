//
//  PhotosListViewController.m
//  TopPlaces
//
//  Created by Shitian Long on 7/26/12.
//  Copyright (c) 2012 OptiCaller Software AB. All rights reserved.
//

#import "PhotosListTableViewController.h"
#import "PhotoViewController.h"
#import "FlickrFetcher.h"

@interface PhotosListTableViewController ()

- (NSString *)getPhotoTitle:(NSDictionary *)photoDic;
- (NSString *)getPhotoDescription:(NSDictionary *)photoDic;

@end

@implementation PhotosListTableViewController

@synthesize photos = _photos;

#pragma mark getter and setter
- (void)setPhotos:(NSArray *)photos{
    NSLog(@"photos %@", photos);
    if (_photos != photos) {
        _photos = photos;
    }
    if (self.tableView.window) [self.tableView reloadData];
}


#pragma mark segure section
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"segue called");
    
    NSDictionary *photo = [self.photos objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    [[segue destinationViewController] setPhoto:photo];
}


#pragma mark private method
- (NSString *)getPhotoTitle:(NSDictionary *)photoDic{
    NSString *photoTitle = [photoDic objectForKey:FLICKR_PHOTO_TITLE];
    
    // according to task 5 if title is nil put description as title
    if (!photoTitle) {
        photoTitle = [[photoDic objectForKey:@"description"] objectForKey:@"_content"];
    }
    if (!photoTitle){
        photoTitle = @"unknow";
    }
    
    return photoTitle;
}


- (NSString *)getPhotoDescription:(NSDictionary *)photoDic{
    //if title is nill, description set to nil
    
    NSString *description = nil;
    
    if (![photoDic objectForKey:FLICKR_PHOTO_TITLE]) {
        return description;
    }
    else{
        return [[photoDic objectForKey:@"description"] objectForKey:@"_content"];
    }
}


#pragma mark table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"photoElement";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // get photo index dic
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [self getPhotoTitle:photo];
    cell.detailTextLabel.text = [self getPhotoDescription:photo];
    return cell;
}



@end
