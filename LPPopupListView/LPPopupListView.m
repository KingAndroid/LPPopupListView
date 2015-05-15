//
//  LPPopupListView.m
//
//  Created by Luka Penger on 27/03/14.
//  Copyright (c) 2014 Luka Penger. All rights reserved.
//

// This code is distributed under the terms and conditions of the MIT license.
//
// Copyright (c) 2014 Luka Penger
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "LPPopupListView.h"


#define navigationBarHeight 44.0f
#define separatorLineHeight 1.0f
#define closeButtonWidth 44.0f
#define navigationBarTitlePadding 12.0f
#define animationsDuration 0.25f


#define LPP_CELL_ID @"LPPopupListViewCell"
@interface LPPopupListView ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *arrayList;
@property (nonatomic, strong) NSString *navigationBarTitle;
@property (nonatomic, assign) BOOL isMultipleSelection;

@end


@implementation LPPopupListView
{
  //Content View
  UIView *contentView;
}

static BOOL isShown = false;

#pragma mark - Lifecycle

- (id)initWithTitle:(NSString *)title list:(NSArray *)list selectedIndexes:(NSIndexSet *)selectedList point:(CGPoint)point size:(CGSize)size multipleSelection:(BOOL)multipleSelection disableBackgroundInteraction:(BOOL)diableInteraction
{
  CGRect contentFrame = CGRectMake(point.x, point.y,size.width,size.height);
  
  //Disable background Interaction
  if (diableInteraction) {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
  } else {
    self = [super initWithFrame:contentFrame];
    contentFrame = CGRectMake(0, 0, size.width, size.height);
  }
  
  
  if (self) {
    _useCellLeftImage = YES;
    
    //Content View
    contentView = [[UIView alloc] initWithFrame:contentFrame];
    
    contentView.backgroundColor = [UIColor colorWithRed:(0.0/255.0) green:(108.0/255.0) blue:(192.0/255.0) alpha:0.7];
    
    self.cellHighlightColor = [UIColor colorWithRed:(0.0/255.0) green:(60.0/255.0) blue:(127.0/255.0) alpha:0.5f];
    
    self.navigationBarTitle = title;
    self.arrayList = [NSArray arrayWithArray:list];
    self.selectedIndexes = [[NSMutableIndexSet alloc] initWithIndexSet:selectedList];
    self.isMultipleSelection = multipleSelection;
    
    self.navigationBarView = [[UIView alloc] init];
    self.navigationBarView.backgroundColor = [UIColor colorWithRed:(0.0/255.0) green:(108.0/255.0) blue:(192.0/255.0) alpha:0.7];
    [contentView addSubview:self.navigationBarView];
    
    self.separatorLineView = [[UIView alloc] init];
    self.separatorLineView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:self.separatorLineView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = self.navigationBarTitle;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.navigationBarView addSubview:self.titleLabel];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setImage:[UIImage imageNamed:@"closeButton"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:self.closeButton];
    
    self.btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnLeft setTitle:@"All" forState:UIControlStateNormal];
    [self.btnLeft addTarget:self action:@selector(onAllClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:self.btnLeft];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerNib:[UINib nibWithNibName:LPP_CELL_ID bundle:nil]
         forCellReuseIdentifier:LPP_CELL_ID];
    [contentView addSubview:self.tableView];
    [self addSubview:contentView];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:contentView.bounds];
  contentView.layer.masksToBounds = NO;
  contentView.layer.shadowColor = [UIColor blackColor].CGColor;
  contentView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
  contentView.layer.shadowOpacity = 0.5f;
  contentView.layer.shadowPath = shadowPath.CGPath;
  
  self.navigationBarView.frame = CGRectMake(0.0f, 0.0f, contentView.frame.size.width, navigationBarHeight);
  self.separatorLineView.frame = CGRectMake(0.0f, self.navigationBarView.frame.size.height, contentView.frame.size.width, separatorLineHeight);
  [self.closeButton sizeToFit];
  self.closeButton.frame = CGRectMake((self.navigationBarView.frame.size.width-closeButtonWidth - 5),
                                      0.0f, self.closeButton.frame.size.width, self.navigationBarView.frame.size.height);
  [self.btnLeft sizeToFit];
  self.btnLeft.frame = CGRectMake(5, 0.0f, self.btnLeft.frame.size.width, self.navigationBarView.frame.size.height);
  
  [self.titleLabel sizeToFit];
  self.titleLabel.frame = CGRectMake(
    (self.navigationBarView.frame.size.width - self.titleLabel.frame.size.width) / 2,
    0.0f, self.titleLabel.frame.size.width, navigationBarHeight);
  
  self.tableView.frame = CGRectMake(0.0f, (navigationBarHeight + separatorLineHeight), contentView.frame.size.width, (contentView.frame.size.height-(navigationBarHeight + separatorLineHeight)));
}

- (void)closeButtonClicked:(id)sender {
  [self hideAnimated:self.closeAnimated];
}

- (void) onAllClick:(id)sender {
  if (self.selectedIndexes.count == self.arrayList.count) {
    [self.selectedIndexes removeAllIndexes];
  } else {
    [self.selectedIndexes addIndexesInRange:NSMakeRange(0, self.arrayList.count)];
  }
  [self.tableView reloadData];
}

- (void) setUseCellLeftImage:(BOOL)useCellLeftImage {
  _useCellLeftImage = useCellLeftImage;
  [self.tableView reloadData];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.arrayList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  LPPopupListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LPP_CELL_ID];
  cell.highlightColor = self.cellHighlightColor;
  cell.useleftImg = self.useCellLeftImage;
  
  BOOL isSelected = NO;
  if (self.isMultipleSelection) {
    if ([self.selectedIndexes containsIndex:indexPath.row]) {
      cell.imgRight.image = [UIImage imageNamed:@"checkMark"];
      isSelected = YES;
    } else {
      cell.imgRight.image = nil;
    }
  }
  
  [self.delegate popupListView:self cell:cell object:self.arrayList[indexPath.row] isSelected:isSelected];
  return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  if (self.isMultipleSelection) {
    if ([self.selectedIndexes containsIndex:indexPath.row]) {
      [self.selectedIndexes removeIndex:indexPath.row];
    } else {
      [self.selectedIndexes addIndex:indexPath.row];
    }
    
    [self.tableView reloadData];
  } else {
    isShown = false;
    
    if ([self.delegate respondsToSelector:@selector(popupListView:didSelectIndex:)]) {
      [self.delegate popupListView:self didSelectIndex:indexPath.row];
    }
    [self hideAnimated:self.closeAnimated];
  }
}

#pragma mark - Instance methods

- (void)showInView:(UIView *)view animated:(BOOL)animated {
  if(!isShown) {
    isShown = true;
    self.closeAnimated = animated;
    
    if(animated) {
      contentView.alpha = 0.0f;
      [view addSubview:self];
      
      [UIView animateWithDuration:animationsDuration animations:^{
        contentView.alpha = 1.0f;
      }];
    } else {
      [view addSubview:self];
    }
  }
}

- (void)hideAnimated:(BOOL)animated {
  if (animated) {
    [UIView animateWithDuration:animationsDuration animations:^{
      contentView.alpha = 0.0f;
    } completion:^(BOOL finished) {
      isShown = false;
      
      if (self.isMultipleSelection) {
        if ([self.delegate respondsToSelector:@selector(popupListViewDidHide:selectedIndexes:)]) {
          [self.delegate popupListViewDidHide:self selectedIndexes:self.selectedIndexes];
        }
      }
      
      [self removeFromSuperview];
    }];
  } else {
    isShown = false;
    
    if (self.isMultipleSelection) {
      if ([self.delegate respondsToSelector:@selector(popupListViewDidHide:selectedIndexes:)]) {
        [self.delegate popupListViewDidHide:self selectedIndexes:self.selectedIndexes];
      }
    }
    
    [self removeFromSuperview];
  }
}

@end
