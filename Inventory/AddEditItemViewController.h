//
//  AddEditItemViewController.h
//  Inventory
//
//  Created by Curtis Poppe on 6/20/15.
//  Copyright (c) 2015 Curtis Poppe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface AddEditItemViewController : UIViewController

typedef NS_ENUM(NSInteger, AddEditMode) {
    AddEditModeAdd,
    AddEditModeEdit
};

@property (strong, nonatomic) Item *item;
@property (nonatomic) AddEditMode addOrEditMode;

@end
