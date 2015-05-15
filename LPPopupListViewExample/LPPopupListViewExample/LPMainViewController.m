//
//  LPMainViewController.m
//  LPPopupListViewExample
//
//  Created by Luka Penger on 27/03/14.
//  Copyright (c) 2014 Luka Penger. All rights reserved.
//

#import "LPMainViewController.h"


@interface LPMainViewController ()

@property (nonatomic, strong) NSMutableIndexSet *selectedIndexes;

@end


@implementation LPMainViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
  NSString *bundleName = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleDisplayName"]];
  self.title = bundleName;
}

#pragma mark - Button

- (IBAction)buttonClicked:(id)selector
{
  float paddingTopBottom = 20.0f;
  float paddingLeftRight = 20.0f;
  
  CGPoint point = CGPointMake(paddingLeftRight, (self.navigationController.navigationBar.frame.size.height + paddingTopBottom) + paddingTopBottom);
  CGSize size = CGSizeMake((self.view.frame.size.width - (paddingLeftRight * 2)), self.view.frame.size.height - ((self.navigationController.navigationBar.frame.size.height + paddingTopBottom) + (paddingTopBottom * 2)));
  
  LPPopupListView *listView = [[LPPopupListView alloc] initWithTitle:@"List View"
                                                                list:[self list]
                                                     selectedIndexes:self.selectedIndexes
                                                               point:point
                                                                size:size
                                                   multipleSelection:YES
                                        disableBackgroundInteraction:YES];
  [listView.closeButton setTitle:@"Done" forState:UIControlStateNormal];
  [listView.closeButton setImage:nil forState:UIControlStateNormal];
  listView.useCellLeftImage = NO;
  listView.delegate = self;
  
  [listView showInView:self.navigationController.view animated:YES];
}

#pragma mark - LPPopupListViewDelegate
-(void) popupListView:(LPPopupListView *)popupListView cell:(LPPopupListViewCell *)cell object:(id)obj isSelected:(BOOL)isSelected {
  cell.lblTitle.text = obj;
}

- (void)popupListView:(LPPopupListView *)popUpListView didSelectIndex:(NSInteger)index
{
  NSLog(@"popUpListView - didSelectIndex: %d", index);
}

- (void)popupListViewDidHide:(LPPopupListView *)popUpListView selectedIndexes:(NSIndexSet *)selectedIndexes
{
  NSLog(@"popupListViewDidHide - selectedIndexes: %@", selectedIndexes.description);
  
  self.selectedIndexes = [[NSMutableIndexSet alloc] initWithIndexSet:selectedIndexes];
  
  self.textView.text = @"";
  [selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    self.textView.text = [self.textView.text stringByAppendingFormat:@"%@\n", [[self list] objectAtIndex:idx]];
  }];
}

#pragma mark - Array List

- (NSArray *)list
{
  return [NSArray arrayWithObjects:@"Car", @"Motor", @"Airplane", @"Boat", @"Bike", nil];
}

@end