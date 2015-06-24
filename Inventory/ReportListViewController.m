//
//  ReportListViewController.m
//  Inventory
//
//  Created by Curtis Poppe on 5/23/15.
//  Copyright (c) 2015 Curtis Poppe. All rights reserved.
//

#import "ReportListViewController.h"
#import "ReportTableViewCell.h"
#import "AddEditItemViewController.h"
#import "Items.h"
#import "Item.h"

@interface ReportListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *reportTableView;

@property (nonatomic, strong) Items *items;

@end

@implementation ReportListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.items = [Items sharedInstance];
    [self.reportTableView registerNib:[UINib nibWithNibName:@"ReportCell" bundle:nil] forCellReuseIdentifier:@"ReportCell"];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.reportTableView addGestureRecognizer:longPress];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countsChanged) name:itemCountUpdated object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.items sortArrayByReportPosition];
    [self.reportTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)countsChanged
{
    [self.reportTableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)addItemButtonTapped:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddEditItemViewController *vc = (AddEditItemViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AddEditItemView"];
    [vc setAddOrEditMode:AddEditModeAdd];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)longPressGestureRecognized:(id)sender
{
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.reportTableView];
    NSIndexPath *indexPath = [self.reportTableView indexPathForRowAtPoint:location];
    
    static UIView *snapshot = nil;
    static NSIndexPath *sourceIndexPath = nil;
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.reportTableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshotFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.reportTableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                   
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    
                    // Fade out.
                    cell.alpha = 0.0;
                } completion:^(BOOL finished) {
                    
                    cell.hidden = YES;
                }];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                if (sourceIndexPath.row > indexPath.row) {
                    
                    // Set the original objects position
                    Item *itemToBeMoved = [[self.items getItems] objectAtIndex:sourceIndexPath.row];
                    [itemToBeMoved setReportPosition:[[[self.items getItems] objectAtIndex:indexPath.row] reportPosition]];
                    [itemToBeMoved saveReportPosition];
                    
                    int objectLocationToModify = (int)sourceIndexPath.row - 1;
                    for (int i = 0; i < sourceIndexPath.row - indexPath.row; i++) {
                        [[[self.items getItems] objectAtIndex:objectLocationToModify] moveDownInReportList];
                        objectLocationToModify = objectLocationToModify - 1;
                    }
                    
                    [self.items sortArrayByReportPosition];
                } else if (sourceIndexPath.row < indexPath.row) {
                    // Set the original objects position
                    Item *itemToBeMoved = [[self.items getItems] objectAtIndex:sourceIndexPath.row];
                    [itemToBeMoved setReportPosition:[[[self.items getItems] objectAtIndex:indexPath.row] reportPosition]];
                    [itemToBeMoved saveReportPosition];
                    
                    int objectLocationToModify = (int)sourceIndexPath.row + 1;
                    for (int i = 0; i < indexPath.row - sourceIndexPath.row; i++) {
                        [[[self.items getItems] objectAtIndex:objectLocationToModify] moveUpInReportList];
                        objectLocationToModify = objectLocationToModify + 1;
                    }
                    
                    [self.items sortArrayByReportPosition];
                }
                
                // ... move the rows.
                [self.reportTableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes
                sourceIndexPath = indexPath;
            }
            break;
        }
        default: {
            // Clean up.
            UITableViewCell *cell = [self.reportTableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                
                // Undo fade out.
                cell.alpha = 1.0;
            } completion:^(BOOL finished) {
                
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
            }];
            
            break;
        }
    }
}

- (UIView *)customSnapshotFromView:(UIView *)inputView
{
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

- (void)deleteItemWithID:(NSInteger)itemID
{
    [[Items sharedInstance] deleteItemWithID:itemID];
    [self.reportTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.items getItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.items sortArrayByReportPosition];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:2];
    
    ReportTableViewCell *cell = (ReportTableViewCell *)[self.reportTableView dequeueReusableCellWithIdentifier:@"ReportCell"];
    cell.showsReorderControl = YES;
    [cell.itemNameLabel setText:[(Item *)[[self.items getItems] objectAtIndex:indexPath.row] itemName]];
    [cell.itemCountLabel setText:[NSString stringWithFormat:@"%@", [formatter stringFromNumber:[(Item *)[[self.items getItems] objectAtIndex:indexPath.row] calculateReportValue]]]];
    return cell;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Edit" handler:^void (UITableViewRowAction *action, NSIndexPath *indexPath) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AddEditItemViewController *vc = (AddEditItemViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AddEditItemView"];
        [vc setItem:(Item *)[[self.items getItems] objectAtIndex:indexPath.row]];
        [vc setAddOrEditMode:AddEditModeEdit];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    editAction.backgroundColor = [UIColor blueColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^void (UITableViewRowAction *action, NSIndexPath *indexPath) {
        Item *item = (Item *)[[self.items getItems] objectAtIndex:indexPath.row];
        [self deleteItemWithID:[item.itemId intValue]];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    return [NSArray arrayWithObjects:editAction, deleteAction, nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
