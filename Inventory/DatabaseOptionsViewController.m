//
//  DatabaseOptionsViewController.m
//  Inventory
//
//  Created by Curtis Poppe on 5/24/15.
//  Copyright (c) 2015 Curtis Poppe. All rights reserved.
//

#import "DatabaseOptionsViewController.h"
#import "Items.h"
#import "DBManager.h"

@interface DatabaseOptionsViewController ()

@property (strong, nonatomic) NSArray *pickerOptions;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@end

@implementation DatabaseOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pickerOptions = @[@"New Week", @"Clear Database", @"Restore Default Database"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)performActionFromPicker:(UIButton *)sender
{
    if ([self.pickerView selectedRowInComponent:0] == 0) {
        [[Items sharedInstance] resetCounts];
    } else if ([self.pickerView selectedRowInComponent:0] == 1) {
        DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"items.sqlite"];
        [dbManager emptyDB];
        [[Items sharedInstance] loadItemsFromDB];
    } else if ([self.pickerView selectedRowInComponent:0] == 2) {
        DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"items.sqlite"];
        [dbManager restoreDefaultDB];
        [[Items sharedInstance] loadItemsFromDB];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[self pickerOptions] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[self pickerOptions] objectAtIndex:row];
}

@end
