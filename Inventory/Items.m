//
//  Items.m
//  Inventory
//
//  Created by Curtis Poppe on 5/24/15.
//  Copyright (c) 2015 Curtis Poppe. All rights reserved.
//

#import "Items.h"
#import "DBManager.h"

@interface Items()

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) DBManager *dbManager;

@end

@implementation Items

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.items = [[NSMutableArray alloc] init];
        self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"items.sqlite"];
        [self loadItemsFromDB];
    }
    
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)addItem:(Item *)item
{
    [self.items addObject:item];
}

- (void)addAndSaveItem:(Item *)item
{
    NSString *query = [NSString stringWithFormat:@"INSERT INTO items (first_count, second_count, third_count, first_unit_total, second_unit_total, third_unit_total, report_position, count_position, item_name, first_unit_name, second_unit_name, third_unit_name) VALUES (%F, %F, %F, %F, %F, %F, %lu, %lu, '%@', '%@', '%@', '%@')", [item.firstCount doubleValue], [item.secondCount doubleValue], [item.thirdCount doubleValue], [item.firstUnitTotal doubleValue], [item.secondUnitTotal doubleValue], [item.thirdUnitTotal doubleValue], [item.reportPosition integerValue], [item.countPosition integerValue], item.itemName, item.firstUnitName, item.secondUnitName, item.thirdUnitName];
    
    DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"items.sqlite"];
    [dbManager executeQuery:query];
    
    [self loadItemsFromDB];
}

- (NSArray *)getItems
{
    return [NSArray arrayWithArray:self.items];
}

- (void)loadItemsFromDB
{
    self.items = [[NSMutableArray alloc] init];
    
    // Form the query
    NSString *query = @"SELECT * from items";
    
    // Get the results
    NSArray *itemInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSInteger indexOfId = [self.dbManager.arrColumnNames indexOfObject:@"_id"];
    NSInteger indexOfFirstCount = [self.dbManager.arrColumnNames indexOfObject:@"first_count"];
    NSInteger indexOfSecondCount = [self.dbManager.arrColumnNames indexOfObject:@"second_count"];
    NSInteger indexOfThirdCount = [self.dbManager.arrColumnNames indexOfObject:@"third_count"];
    NSInteger indexOfFirstUnitTotal = [self.dbManager.arrColumnNames indexOfObject:@"first_unit_total"];
    NSInteger indexOfSecondUnitTotal = [self.dbManager.arrColumnNames indexOfObject:@"second_unit_total"];
    NSInteger indexOfThirdUnitTotal = [self.dbManager.arrColumnNames indexOfObject:@"third_unit_total"];
    NSInteger indexOfReportPosition = [self.dbManager.arrColumnNames indexOfObject:@"report_position"];
    NSInteger indexOfCountPosition = [self.dbManager.arrColumnNames indexOfObject:@"count_position"];
    NSInteger indexOfItemName = [self.dbManager.arrColumnNames indexOfObject:@"item_name"];
    NSInteger indexOfFirstUnitName = [self.dbManager.arrColumnNames indexOfObject:@"first_unit_name"];
    NSInteger indexOfSecondUnitName = [self.dbManager.arrColumnNames indexOfObject:@"second_unit_name"];
    NSInteger indexOfThirdUnitName = [self.dbManager.arrColumnNames indexOfObject:@"third_unit_name"];
    
    for (int i = 0; i < itemInfo.count; i++) {
        Item *item = [[Item alloc] init];
        
        item.itemId = [[itemInfo objectAtIndex: i] objectAtIndex:indexOfId];
        item.firstCount = [[itemInfo objectAtIndex: i] objectAtIndex:indexOfFirstCount];
        item.secondCount = [[itemInfo objectAtIndex: i] objectAtIndex:indexOfSecondCount];
        item.thirdCount = [[itemInfo objectAtIndex: i] objectAtIndex:indexOfThirdCount];
        item.firstUnitTotal = [[itemInfo objectAtIndex: i] objectAtIndex:indexOfFirstUnitTotal];
        item.secondUnitTotal = [[itemInfo objectAtIndex: i] objectAtIndex:indexOfSecondUnitTotal];
        item.thirdUnitTotal = [[itemInfo objectAtIndex: i] objectAtIndex:indexOfThirdUnitTotal];
        item.reportPosition = [[itemInfo objectAtIndex: i] objectAtIndex:indexOfReportPosition];
        item.countPosition = [[itemInfo objectAtIndex: i] objectAtIndex:indexOfCountPosition];
        item.itemName = [[itemInfo objectAtIndex: i] objectAtIndex:indexOfItemName];
        item.firstUnitName = [[itemInfo objectAtIndex: i] objectAtIndex:indexOfFirstUnitName];
        item.secondUnitName = [[itemInfo objectAtIndex: i] objectAtIndex:indexOfSecondUnitName];
        item.thirdUnitName = [[itemInfo objectAtIndex: i] objectAtIndex:indexOfThirdUnitName];
        
        [self addItem:item];
    }
}

- (void)sortArrayByCountPosition
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"countPosition"
                                                 ascending:YES
                                                  selector:@selector(localizedStandardCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [self.items sortedArrayUsingDescriptors:sortDescriptors];
    self.items = [NSMutableArray arrayWithArray:sortedArray];
}

- (void)sortArrayByReportPosition
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"reportPosition"
                                                 ascending:YES
                                                  selector:@selector(localizedStandardCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [self.items sortedArrayUsingDescriptors:sortDescriptors];
    self.items = [NSMutableArray arrayWithArray:sortedArray];
}

- (void)resetCounts
{
    NSString *query = @"UPDATE items SET first_count = 0, second_count = 0, third_count = 0";
    [self.dbManager executeQuery:query];
    [self loadItemsFromDB];
    [[NSNotificationCenter defaultCenter] postNotificationName:itemCountUpdated object:self];
}

- (void)deleteItemWithID:(NSInteger)itemID
{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM items WHERE _id = %lu", (long)itemID];
    [self.dbManager executeQuery:query];
    [self loadItemsFromDB];
}

- (NSNumber *)findLastCountPos
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"countPosition"
                                                 ascending:YES
                                                  selector:@selector(localizedStandardCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [self.items sortedArrayUsingDescriptors:sortDescriptors];
    NSMutableArray *itemsToCheck = [NSMutableArray arrayWithArray:sortedArray];
    return [[itemsToCheck objectAtIndex:itemsToCheck.count - 1] countPosition];
}

- (NSNumber *)findLastReportPos
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"reportPosition"
                                                 ascending:YES
                                                  selector:@selector(localizedStandardCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [self.items sortedArrayUsingDescriptors:sortDescriptors];
    NSMutableArray *itemsToCheck = [NSMutableArray arrayWithArray:sortedArray];
    return [[itemsToCheck objectAtIndex:itemsToCheck.count - 1] reportPosition];
}

@end
