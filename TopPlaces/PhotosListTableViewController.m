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


@end

@implementation PhotosListTableViewController

@synthesize photos = _photos;

#pragma mark getter and setter
- (void)setPhotos:(NSArray *)photos{
    if (_photos != photos) {
        _photos = photos;
    }
    if (self.tableView.window) [self.tableView reloadData];
}


#pragma mark segure section
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showAPhoto"]) {
        NSDictionary *photo = [self.photos objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        [[segue destinationViewController] setPhoto:photo];
    }
}


#pragma mark private method
- (NSString *)getPhotoTitle:(NSDictionary *)photoDic{
    NSString *photoTitle = [photoDic objectForKey:FLICKR_PHOTO_TITLE];
    
    // according to task 5 if title is nil put description as title
    if (!photoTitle) {
        photoTitle = [self getPhotoDescription:photoDic];
    }
    // in the case of "NO Photo Title" photo title can be either "nil" or @""
    if (!photoTitle || [photoTitle length] == 0){
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


- (PhotoViewController *)splitViewPhotoViewController{
    id photoViewController = [self.splitViewController.viewControllers lastObject];
    
    if (![photoViewController isKindOfClass:[PhotoViewController class]]) {
        photoViewController = nil;
    }
    return photoViewController;
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



// This function is updated, think about iPad case, which PhotoViewController is not in a segue but in the splite view
// controller. Therefore make the code clearer, we performSegueWithIdentifier in this tableview delegate function
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // if iPad there is no segue. 
    if ([self splitViewPhotoViewController]) {
        NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
        [[self splitViewPhotoViewController] setPhoto:photo];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



@end
