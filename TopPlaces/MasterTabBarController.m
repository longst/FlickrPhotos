//
//  MasterTabBarController.m
//  TopPlaces
//
//  Created by Shitian Long on 8/3/12.
//  Copyright (c) 2012 OptiCaller Software AB. All rights reserved.
//

#import "MasterTabBarController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface MasterTabBarController () <UISplitViewControllerDelegate>

@end

@implementation MasterTabBarController


- (void)awakeFromNib{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


// Only want to display button in portrait
- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    // in portrait mode, show master view otherwise, hide master view
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Menu";
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}


- (void)splitViewController:(UISplitViewController *)svc
          popoverController:(UIPopoverController *)pc
  willPresentViewController:(UIViewController *)aViewController
{
    // We save this so as we can dismiss it when we select a picture

}


- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
    // remove button from detail view controller
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}


// Get the detail view, since it will be presenting the button. Only if it implements the button
- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}


@end
