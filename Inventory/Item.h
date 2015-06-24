//
//  Item.h
//  Inventory
//
//  Created by Curtis Poppe on 5/24/15.
//  Copyright (c) 2015 Curtis Poppe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (nonatomic, strong) NSNumber *itemId;
@property (nonatomic, strong) NSNumber *firstCount;
@property (nonatomic, strong) NSNumber *secondCount;
@property (nonatomic, strong) NSNumber *thirdCount;
@property (nonatomic, strong) NSNumber *firstUnitTotal;
@property (nonatomic, strong) NSNumber *secondUnitTotal;
@property (nonatomic, strong) NSNumber *thirdUnitTotal;
@property (nonatomic, strong) NSNumber *reportPosition;
@property (nonatomic, strong) NSNumber *countPosition;
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, strong) NSString *firstUnitName;
@property (nonatomic, strong) NSString *secondUnitName;
@property (nonatomic, strong) NSString *thirdUnitName;

extern NSString* const itemCountUpdated;

- (NSNumber *)calculateReportValue;
- (void)saveFirstCount;
- (void)saveSecondCount;
- (void)saveThirdCount;
- (void)moveUpInReportList;
- (void)moveDownInReportList;
- (void)moveUpInCountList;
- (void)moveDownInCountList;
- (void)saveReportPosition;
- (void)saveCountPosition;
- (void)updateItemName:(NSString *)itemName;
- (void)updateUnitNamesUsing:(NSString *)firstUnitName secondUnitName:(NSString *)secondUnitName thirdUnitName:(NSString *)thirdUnitName;
- (void)updateUnitTotalsUsing:(NSNumber *)firstUnitTotal secondUnitTotal:(NSNumber *)secondUnitTotal secondUnitTotal:(NSNumber *)thirdUnitTotal;

@end
