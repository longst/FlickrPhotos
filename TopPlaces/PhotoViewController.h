//
//  PhotoViewController.h
//  TopPlaces
//
//  Created by Shitian Long on 7/27/12.
//  Copyright (c) 2012 OptiCaller Software AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface PhotoViewController : UIViewController <SplitViewBarButtonItemPresenter>

// photo view controller model
@property (nonatomic, strong) NSDictionary *photo;

@end
