//
//  CountItemViewController.m
//  Inventory
//
//  Created by Curtis Poppe on 5/29/15.
//  Copyright (c) 2015 Curtis Poppe. All rights reserved.
//

#import "CountItemViewController.h"
#import "Items.h"

@interface CountItemViewController ()

@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdUnitLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstUnitTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondUnitTextField;
@property (weak, nonatomic) IBOutlet UITextField *thirdUnitTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;

@end

@implementation CountItemViewController

- (instancetype)initWithItem:(Item *)item
{
    self = [super init];
    
    if (self) {
        self.itemNameLabel.text = item.itemName;
        self.firstUnitLabel.text = item.firstUnitName;
        self.secondUnitLabel.text = item.secondUnitName;
        self.thirdUnitLabel.text = item.thirdUnitName;
        self.firstUnitTextField.text = [NSString stringWithFormat:@"%@", self.item.firstCount];
        self.secondUnitTextField.text = [NSString stringWithFormat:@"%@", self.item.secondCount];
        self.thirdUnitTextField.text = [NSString stringWithFormat:@"%@", self.item.thirdCount];
        [self showOrHideNextButton];
        [self showOrHidePreviousButton];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.firstUnitTextField addTarget:self
                  action:@selector(textFieldDidChange)
        forControlEvents:UIControlEventEditingChanged];
    
    [self.secondUnitTextField addTarget:self
                                action:@selector(textFieldDidChange)
                      forControlEvents:UIControlEventEditingChanged];
    
    [self.thirdUnitTextField addTarget:self
                                action:@selector(textFieldDidChange)
                      forControlEvents:UIControlEventEditingChanged];
    
    [self updateForItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateForItem
{
    self.itemNameLabel.text = self.item.itemName;
    self.firstUnitLabel.text = self.item.firstUnitName;
    self.secondUnitLabel.text = self.item.secondUnitName;
    self.thirdUnitLabel.text = self.item.thirdUnitName;
    self.firstUnitTextField.text = [NSString stringWithFormat:@"%@", self.item.firstCount];
    self.secondUnitTextField.text = [NSString stringWithFormat:@"%@", self.item.secondCount];
    self.thirdUnitTextField.text = [NSString stringWithFormat:@"%@", self.item.thirdCount];
    [self showOrHideNextButton];
    [self showOrHidePreviousButton];
    [self showOrHideTextBoxesAndLabels];
}

- (void)showOrHidePreviousButton
{
    if (self.itemPosInArray == 0) {
        self.previousButton.hidden = YES;
    } else {
        self.previousButton.hidden = NO;
    }
}

- (void)showOrHideNextButton
{
    if (self.itemPosInArray == [[Items sharedInstance] getItems].count - 1) {
        self.nextButton.hidden = YES;
    } else {
        self.nextButton.hidden = NO;
    }
}

- (void)showOrHideTextBoxesAndLabels
{
    if (self.item.firstUnitTotal == nil || self.item.firstUnitTotal.intValue == 0) {
        self.firstUnitTextField.hidden = YES;
        self.firstUnitLabel.hidden = YES;
    } else {
        self.firstUnitTextField.hidden = NO;
        self.firstUnitLabel.hidden = NO;
    }
    
    if (self.item.secondUnitTotal == nil || self.item.secondUnitTotal.intValue == 0) {
        self.secondUnitTextField.hidden = YES;
        self.secondUnitLabel.hidden = YES;
    } else {
        self.secondUnitTextField.hidden = NO;
        self.secondUnitLabel.hidden = NO;
    }
    
    if (self.item.thirdUnitTotal == nil || self.item.thirdUnitTotal.intValue == 0) {
        self.thirdUnitTextField.hidden = YES;
        self.thirdUnitLabel.hidden = YES;
    } else {
        self.thirdUnitTextField.hidden = NO;
        self.thirdUnitLabel.hidden = NO;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)previousItem:(UIButton *)sender
{
    if (self.itemPosInArray > 0) {
        [self saveCounts];
        self.itemPosInArray = self.itemPosInArray - 1;
        [[Items sharedInstance] sortArrayByCountPosition];
        Item *item = [[[Items sharedInstance] getItems] objectAtIndex:self.itemPosInArray];
        self.item = item;
        [self updateForItem];
    }
}

- (IBAction)nextItem:(UIButton *)sender
{
    if (self.itemPosInArray < [[Items sharedInstance] getItems].count - 1) {
        [self saveCounts];
        self.itemPosInArray = self.itemPosInArray + 1;
        [[Items sharedInstance] sortArrayByCountPosition];
        Item *item = [[[Items sharedInstance] getItems] objectAtIndex:self.itemPosInArray];
        self.item = item;
        [self updateForItem];
    }
}

- (IBAction)tapOnView:(id)sender
{
    [self.firstUnitTextField resignFirstResponder];
    [self.secondUnitTextField resignFirstResponder];
    [self.thirdUnitTextField resignFirstResponder];
}

- (IBAction)swipeScreen:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        [self previousItem:self.previousButton];
    } else if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self nextItem:self.nextButton];
    }
}

- (void)saveCounts
{
    NSNumberFormatter *count = [[NSNumberFormatter alloc] init];
    count.numberStyle = NSNumberFormatterDecimalStyle;
    self.item.firstCount = [count numberFromString:self.firstUnitTextField.text];
    self.item.secondCount = [count numberFromString:self.secondUnitTextField.text];
    self.item.thirdCount = [count numberFromString:self.thirdUnitTextField.text];
    [self.item saveFirstCount];
    [self.item saveSecondCount];
    [self.item saveThirdCount];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField setSelectedTextRange:[textField textRangeFromPosition:textField.beginningOfDocument
                                                          toPosition:textField.endOfDocument]];
}

- (void)textFieldDidChange
{
    [self saveCounts];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self saveCounts];
}

@end
