//
//  CountListViewController.m
//  Inventory
//
//  Created by Curtis Poppe on 5/23/15.
//  Copyright (c) 2015 Curtis Poppe. All rights reserved.
//

#import "CountListViewController.h"
#import "CountItemViewController.h"
#import "AddEditItemViewController.h"
#import "Item.h"
#import "Items.h"
#import "DBManager.h"

@interface CountListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *countTableView;

@property (nonatomic, strong) Items *items;

@end

@implementation CountListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.items = [Items sharedInstance];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.countTableView addGestureRecognizer:longPress];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.items sortArrayByCountPosition];
    [self.countTableView reloadData];
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
    
    CGPoint location = [longPress locationInView:self.countTableView];
    NSIndexPath *indexPath = [self.countTableView indexPathForRowAtPoint:location];
    
    static UIView *snapshot = nil;
    static NSIndexPath *sourceIndexPath = nil;
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.countTableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshotFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.countTableView addSubview:snapshot];
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
                    [itemToBeMoved setCountPosition:[[[self.items getItems] objectAtIndex:indexPath.row] countPosition]];
                    [itemToBeMoved saveCountPosition];
                    
                    int objectLocationToModify = (int)sourceIndexPath.row - 1;
                    for (int i = 0; i < sourceIndexPath.row - indexPath.row; i++) {
                        [[[self.items getItems] objectAtIndex:objectLocationToModify] moveDownInCountList];
                        objectLocationToModify = objectLocationToModify - 1;
                    }
                    
                    [self.items sortArrayByCountPosition];
                } else if (sourceIndexPath.row < indexPath.row) {
                    // Set the original objects position
                    Item *itemToBeMoved = [[self.items getItems] objectAtIndex:sourceIndexPath.row];
                    [itemToBeMoved setCountPosition:[[[self.items getItems] objectAtIndex:indexPath.row] countPosition]];
                    [itemToBeMoved saveCountPosition];
                    
                    int objectLocationToModify = (int)sourceIndexPath.row + 1;
                    for (int i = 0; i < indexPath.row - sourceIndexPath.row; i++) {
                        [[[self.items getItems] objectAtIndex:objectLocationToModify] moveUpInCountList];
                        objectLocationToModify = objectLocationToModify + 1;
                    }
                    
                    [self.items sortArrayByCountPosition];
                }
                
                // ... move the rows.
                [self.countTableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes
                sourceIndexPath = indexPath;
            }
            break;
        }
        default: {
            // Clean up.
            UITableViewCell *cell = [self.countTableView cellForRowAtIndexPath:sourceIndexPath];
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
    [self.countTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.items getItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.items sortArrayByCountPosition];
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    [cell.textLabel setText:[(Item *)[[self.items getItems] objectAtIndex:indexPath.row] itemName]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.countTableView deselectRowAtIndexPath:indexPath animated:NO];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CountItemViewController *vc = (CountItemViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CountItemView"];
    [vc setItem:(Item *)[[self.items getItems] objectAtIndex:indexPath.row]];
    [vc setItemPosInArray:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)peekAtIndexPath:(NSIndexPath *)indexPath AndSourceIndexPath:(NSIndexPath *)sourcePath
{
    NSLog(@"indexPath = %ld ----- sourcePath = %ld", (long)indexPath.row, (long)sourcePath.row);
}

@end
