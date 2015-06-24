//
//  Items.h
//  Inventory
//
//  Created by Curtis Poppe on 5/24/15.
//  Copyright (c) 2015 Curtis Poppe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface Items : NSObject

+ (instancetype)sharedInstance;

- (void)addItem:(Item *)item;
- (void)addAndSaveItem:(Item *)item;
- (NSArray *)getItems;
- (void)loadItemsFromDB;
- (void)sortArrayByCountPosition;
- (void)sortArrayByReportPosition;
- (void)resetCounts;
- (void)deleteItemWithID:(NSInteger)itemID;
- (NSNumber *)findLastCountPos;
- (NSNumber *)findLastReportPos;

@end
