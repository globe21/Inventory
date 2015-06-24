//
//  CountItemViewController.h
//  Inventory
//
//  Created by Curtis Poppe on 5/29/15.
//  Copyright (c) 2015 Curtis Poppe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface CountItemViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) Item *item;
@property (nonatomic) NSInteger itemPosInArray;

- (instancetype)initWithItem:(Item *)item;
- (void)updateForItem;

@end
