//
//  ReportTableViewCell.h
//  Inventory
//
//  Created by Curtis Poppe on 5/29/15.
//  Copyright (c) 2015 Curtis Poppe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemCountLabel;

@end
