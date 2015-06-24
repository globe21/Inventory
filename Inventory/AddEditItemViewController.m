//
//  AddEditItemViewController.m
//  Inventory
//
//  Created by Curtis Poppe on 6/20/15.
//  Copyright (c) 2015 Curtis Poppe. All rights reserved.
//

#import "AddEditItemViewController.h"
#import "Items.h"

@interface AddEditItemViewController ()

@property (weak, nonatomic) IBOutlet UITextField *itemNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstUnitNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondUnitNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *thirdUnitNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstUnitTotalTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondUnitTotalTextField;
@property (weak, nonatomic) IBOutlet UITextField *thirdUnitTotalTextField;

@end

@implementation AddEditItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.addOrEditMode == AddEditModeEdit) {
        // If editing an existing item
        // Set up the text fields
        self.itemNameTextField.text = self.item.itemName;
        self.firstUnitNameTextField.text = self.item.firstUnitName;
        self.secondUnitNameTextField.text = self.item.secondUnitName;
        self.thirdUnitNameTextField.text = self.item.thirdUnitName;
        self.firstUnitTotalTextField.text = [NSString stringWithFormat:@"%@", self.item.firstUnitTotal];
        self.secondUnitTotalTextField.text = [NSString stringWithFormat:@"%@", self.item.secondUnitTotal];
        self.thirdUnitTotalTextField.text = [NSString stringWithFormat:@"%@", self.item.thirdUnitTotal];
        self.title = @"Edit Item";
    } else if (self.addOrEditMode == AddEditModeAdd) {
        self.title = @"Add Item";
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapOnView:(id)sender
{
    [self.itemNameTextField resignFirstResponder];
    [self.firstUnitTotalTextField resignFirstResponder];
    [self.secondUnitTotalTextField resignFirstResponder];
    [self.thirdUnitTotalTextField resignFirstResponder];
    [self.firstUnitNameTextField resignFirstResponder];
    [self.secondUnitNameTextField resignFirstResponder];
    [self.thirdUnitNameTextField resignFirstResponder];
    [self.firstUnitTotalTextField resignFirstResponder];
    [self.secondUnitTotalTextField resignFirstResponder];
    [self.thirdUnitTotalTextField resignFirstResponder];
}

- (IBAction)saveButtonTapped:(id)sender
{
    if (self.addOrEditMode == AddEditModeEdit) {
        // If editing an existing item
        // Update the current items info and save
        [self.item updateItemName:self.itemNameTextField.text];
        [self.item updateUnitNamesUsing:self.firstUnitNameTextField.text secondUnitName:self.secondUnitNameTextField.text thirdUnitName:self.thirdUnitNameTextField.text];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *firstNum = [f numberFromString:self.firstUnitTotalTextField.text];
        NSNumber *secondNum = [f numberFromString:self.secondUnitTotalTextField.text];
        NSNumber *thirdNum = [f numberFromString:self.thirdUnitTotalTextField.text];
        [self.item updateUnitTotalsUsing:firstNum secondUnitTotal:secondNum secondUnitTotal:thirdNum];
    } else if (self.addOrEditMode == AddEditModeAdd) {
        // If adding a new item
        // Create the item and add it to the Items singleton which will save it as well
        Item *item = [[Item alloc] init];
        item.countPosition = [NSNumber numberWithInt:[[[Items sharedInstance] findLastCountPos] intValue] + 1];
        item.reportPosition = [NSNumber numberWithInt:[[[Items sharedInstance] findLastReportPos] intValue] + 1];
        item.firstCount = [NSNumber numberWithInt:0];
        item.secondCount = [NSNumber numberWithInt:0];
        item.thirdCount = [NSNumber numberWithInt:0];
        if (self.itemNameTextField.text != nil && ![self.itemNameTextField.text isEqualToString:@""]) {
            item.itemName = self.itemNameTextField.text;
        } else {
            item.itemName = @"No Name";
        }
        
        if (self.firstUnitNameTextField.text != nil && ![self.firstUnitNameTextField.text isEqualToString:@""]) {
            item.firstUnitName = self.firstUnitNameTextField.text;
        } else {
            item.firstUnitName = @"None";
        }
        
        if (self.secondUnitNameTextField.text != nil && ![self.secondUnitNameTextField.text isEqualToString:@""]) {
            item.secondUnitName = self.secondUnitNameTextField.text;
        } else {
            item.secondUnitName = @"None";
        }
        
        if (self.thirdUnitNameTextField.text != nil && ![self.thirdUnitNameTextField.text isEqualToString:@""]) {
            item.thirdUnitName = self.thirdUnitNameTextField.text;
        } else {
            item.thirdUnitName = @"None";
        }
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        
        if (self.firstUnitTotalTextField.text != nil && ![self.firstUnitTotalTextField.text isEqualToString:@""]) {
            item.firstUnitTotal = [f numberFromString:self.firstUnitTotalTextField.text];
        } else {
            item.firstUnitTotal = [NSNumber numberWithInt:0];
        }
        
        if (self.secondUnitTotalTextField.text != nil && ![self.secondUnitTotalTextField.text isEqualToString:@""]) {
            item.secondUnitTotal = [f numberFromString:self.secondUnitTotalTextField.text];
        } else {
            item.secondUnitTotal = [NSNumber numberWithInt:0];
        }
        
        if (self.thirdUnitTotalTextField.text != nil && ![self.thirdUnitTotalTextField.text isEqualToString:@""]) {
            item.thirdUnitTotal = [f numberFromString:self.thirdUnitTotalTextField.text];
        } else {
            item.thirdUnitTotal = [NSNumber numberWithInt:0];
        }
        
        [[Items sharedInstance] addAndSaveItem:item];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
