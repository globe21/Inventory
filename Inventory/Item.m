//
//  Item.m
//  Inventory
//
//  Created by Curtis Poppe on 5/24/15.
//  Copyright (c) 2015 Curtis Poppe. All rights reserved.
//

#import "Item.h"
#import "DBManager.h"

@implementation Item

NSString* const itemCountUpdated = @"CJPInventory-countUpdated";

- (NSNumber *)calculateReportValue
{
    NSNumber *firstVal;
    NSNumber *secondVal;
    NSNumber *thirdVal;
    
    if (self.firstCount.doubleValue == 0 || self.firstCount == nil || self.firstUnitTotal.intValue == 0) {
        firstVal = [NSNumber numberWithInt:0];
    } else {
        firstVal = [NSNumber numberWithDouble:[self.firstCount doubleValue] / [self.firstUnitTotal doubleValue]];
    }
    if (self.secondCount.doubleValue == 0 || self.secondCount == nil || self.secondUnitTotal.intValue == 0) {
        secondVal = [NSNumber numberWithInt:0];
    } else {
        secondVal = [NSNumber numberWithDouble:[self.secondCount doubleValue] / [self.secondUnitTotal doubleValue]];
    }
    if (self.thirdCount.doubleValue == 0 || self.thirdCount == nil || self.thirdUnitTotal.intValue == 0) {
        thirdVal = [NSNumber numberWithInt:0];
    } else {
        thirdVal = [NSNumber numberWithDouble:[self.thirdCount doubleValue] / [self.thirdUnitTotal doubleValue]];
    }
    
    NSNumber *finalVal = [NSNumber numberWithDouble:[firstVal doubleValue] + [secondVal doubleValue] + [thirdVal doubleValue]];
    return finalVal;
}


- (void)saveFirstCount
{
    DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"items.sqlite"];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE items SET first_count = %@ WHERE count_position = %@", self.firstCount, self.countPosition];
    
    [dbManager executeQuery:query];
    [[NSNotificationCenter defaultCenter] postNotificationName:itemCountUpdated object:self];
}

- (void)saveSecondCount
{
    DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"items.sqlite"];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE items SET second_count = %@ WHERE count_position = %@", self.secondCount, self.countPosition];
    
    [dbManager executeQuery:query];
    [[NSNotificationCenter defaultCenter] postNotificationName:itemCountUpdated object:self];
}

- (void)saveThirdCount
{
    DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"items.sqlite"];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE items SET third_count = %@ WHERE count_position = %@", self.thirdCount, self.countPosition];
    
    [dbManager executeQuery:query];
    [[NSNotificationCenter defaultCenter] postNotificationName:itemCountUpdated object:self];
}

- (void)saveCountPosition
{
    DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"items.sqlite"];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE items SET count_position = %@ WHERE _id = %@", self.countPosition, self.itemId];
    
    [dbManager executeQuery:query];
}

- (void)saveReportPosition
{
    DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"items.sqlite"];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE items SET report_position = %@ WHERE _id = %@", self.reportPosition, self.itemId];
    
    [dbManager executeQuery:query];
}

- (void)moveUpInReportList
{
    DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"items.sqlite"];
    NSNumber *newPos = [NSNumber numberWithInt:(int)[self.reportPosition integerValue] - 1];
    NSString *query = [NSString stringWithFormat:@"UPDATE items SET report_position = %d WHERE _id = %u", (int)[newPos integerValue], (int)[self.itemId integerValue]];
    
    [dbManager executeQuery:query];
    self.reportPosition = [newPos valueForKey:@"stringValue"];
}

- (void)moveDownInReportList
{
    DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"items.sqlite"];
    NSNumber *newPos = [NSNumber numberWithInt:(int)[self.reportPosition integerValue] + 1];
    NSString *query = [NSString stringWithFormat:@"UPDATE items SET report_position = %d WHERE _id = %u", (int)[newPos integerValue], (int)[self.itemId integerValue]];
    
    [dbManager executeQuery:query];
    self.reportPosition = [newPos valueForKey:@"stringValue"];
}

- (void)moveUpInCountList
{
    DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"items.sqlite"];
    NSNumber *newPos = [NSNumber numberWithInt:(int)[self.countPosition integerValue] - 1];
    NSString *query = [NSString stringWithFormat:@"UPDATE items SET count_position = %d WHERE _id = %u", (int)[newPos integerValue], (int)[self.itemId integerValue]];
    
    [dbManager executeQuery:query];
    self.countPosition = [newPos valueForKey:@"stringValue"];
}

- (void)moveDownInCountList
{
    DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"items.sqlite"];
    NSNumber *newPos = [NSNumber numberWithInt:(int)[self.countPosition integerValue] + 1];
    NSString *query = [NSString stringWithFormat:@"UPDATE items SET count_position = %d WHERE _id = %u", (int)[newPos integerValue], (int)[self.itemId integerValue]];
    
    [dbManager executeQuery:query];
    self.countPosition = [newPos valueForKey:@"stringValue"];
}

- (void)updateItemName:(NSString *)itemName
{
    // FIXME: Escape characters in passed strings
    if (itemName != nil && ![itemName isEqual: @""]) {
        DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"items.sqlite"];
        NSString *query = [NSString stringWithFormat:@"UPDATE items SET item_name = '%@' WHERE _id = %u", itemName, (int)[self.itemId integerValue]];
        
        [dbManager executeQuery:query];
        self.itemName = itemName;
    }
}

- (void)updateUnitNamesUsing:(NSString *)firstUnitName secondUnitName:(NSString *)secondUnitName thirdUnitName:(NSString *)thirdUnitName
{
    // FIXME: Escape characters in passed strings
    DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"items.sqlite"];
    NSString *query;
    
    // Update first unit name
    if (firstUnitName != nil && ![firstUnitName isEqual: @""]) {
        query = [NSString stringWithFormat:@"UPDATE items SET first_unit_name = '%@' WHERE _id = %u", firstUnitName, (int)[self.itemId integerValue]];
        self.firstUnitName = firstUnitName;
    } else {
        query = [NSString stringWithFormat:@"UPDATE items SET first_unit_name = None WHERE _id = %u", (int)[self.itemId integerValue]];
        self.firstUnitName = @"None";
    }
    
    [dbManager executeQuery:query];
    
    // Update second unit name
    if (secondUnitName != nil && ![secondUnitName isEqual: @""]) {
        query = [NSString stringWithFormat:@"UPDATE items SET second_unit_name = '%@' WHERE _id = %u", secondUnitName, (int)[self.itemId integerValue]];
        self.secondUnitName = secondUnitName;
    } else {
        query = [NSString stringWithFormat:@"UPDATE items SET second_unit_name = None WHERE _id = %u", (int)[self.itemId integerValue]];
        self.secondUnitName = @"None";
    }
    
    [dbManager executeQuery:query];
    
    // Update third unit name
    if (thirdUnitName != nil && ![thirdUnitName isEqual: @""]) {
        query = [NSString stringWithFormat:@"UPDATE items SET third_unit_name = '%@' WHERE _id = %u", thirdUnitName, (int)[self.itemId integerValue]];
        self.thirdUnitName = thirdUnitName;
    } else {
        query = [NSString stringWithFormat:@"UPDATE items SET third_unit_name = None WHERE _id = %u", (int)[self.itemId integerValue]];
        self.thirdUnitName = @"None";
    }
    
    [dbManager executeQuery:query];
}

- (void)updateUnitTotalsUsing:(NSNumber *)firstUnitTotal secondUnitTotal:(NSNumber *)secondUnitTotal secondUnitTotal:(NSNumber *)thirdUnitTotal
{
    DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"items.sqlite"];
    NSString *query;
    
    // Update first unit total
    if (firstUnitTotal != nil) {
        query = [NSString stringWithFormat:@"UPDATE items SET first_unit_total = %@ WHERE _id = %u", firstUnitTotal, (int)[self.itemId integerValue]];
        self.firstUnitTotal = firstUnitTotal;
    } else {
        query = [NSString stringWithFormat:@"UPDATE items SET first_unit_total = None WHERE _id = %u", (int)[self.itemId integerValue]];
        self.firstUnitTotal = 0;
    }
    
    [dbManager executeQuery:query];
    
    // Update second unit total
    if (secondUnitTotal != nil) {
        query = [NSString stringWithFormat:@"UPDATE items SET second_unit_total = %@ WHERE _id = %u", secondUnitTotal, (int)[self.itemId integerValue]];
        self.secondUnitTotal = secondUnitTotal;
    } else {
        query = [NSString stringWithFormat:@"UPDATE items SET second_unit_total = None WHERE _id = %u", (int)[self.itemId integerValue]];
        self.secondUnitTotal = 0;
    }
    
    [dbManager executeQuery:query];
    
    // Update third unit total
    if (thirdUnitTotal != nil) {
        query = [NSString stringWithFormat:@"UPDATE items SET third_unit_total = %@ WHERE _id = %u", thirdUnitTotal, (int)[self.itemId integerValue]];
        self.thirdUnitTotal = thirdUnitTotal;
    } else {
        query = [NSString stringWithFormat:@"UPDATE items SET third_unit_total = None WHERE _id = %u", (int)[self.itemId integerValue]];
        self.thirdUnitTotal = 0;
    }
    
    [dbManager executeQuery:query];
    
}

@end
