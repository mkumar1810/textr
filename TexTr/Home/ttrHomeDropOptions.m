//
//  ttrHomeDropOptions.m
//  TexTr
//
//  Created by Mohan Kumar on 01/07/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrHomeDropOptions.h"

@interface ttrHomeDropOptions()<UITableViewDataSource, UITableViewDelegate>
{
    id<ttrHomeDropDownOptionsDelegate> _dataDelegate;
    UITableView * _optionsView;
    CGFloat _rowHeight;
    CGRect _originalFrame;
    CGPoint _superPoint;
    NSArray * _optionsList;
}

@end

@implementation ttrHomeDropOptions

- (instancetype) initWithFrame:(CGRect) p_frame andSuperPoint:(CGPoint) p_superPoint dataDelegate:(id<ttrHomeDropDownOptionsDelegate>) p_dataDelegate
{
    self = [super init];
    if (self)
    {
        _dataDelegate = p_dataDelegate;
        _rowHeight = 50.0f;
        _originalFrame = p_frame;
        _superPoint = p_superPoint;
        [self setBackgroundColor:[UIColor clearColor]];
        _optionsList = @[@"My Profile", @"Settings"];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath * l_polygonpath = [UIBezierPath bezierPath];
    [l_polygonpath moveToPoint:CGPointMake(20.0f, 20.0f)];
    [l_polygonpath addLineToPoint:CGPointMake(rect.size.width - 40.0f, 20.0f)];
    [l_polygonpath addLineToPoint:CGPointMake(rect.size.width, 0.0f)];
    [l_polygonpath addLineToPoint:CGPointMake(rect.size.width-20.0, 40.0f)];
    [l_polygonpath addLineToPoint:CGPointMake(rect.size.width-20.0, rect.size.height - 20.0f)];
    [l_polygonpath addArcWithCenter:CGPointMake(rect.size.width-40.0, rect.size.height - 20.0) radius:20.0f startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [l_polygonpath addLineToPoint:CGPointMake(20.0f, rect.size.height)];
    [l_polygonpath addArcWithCenter:CGPointMake(20.0f, rect.size.height - 20.0) radius:20.0f startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [l_polygonpath addLineToPoint:CGPointMake(0.0f, 40.0f)];
    [l_polygonpath addArcWithCenter:CGPointMake(20.0f, 40.0f) radius:20.0f startAngle:M_PI endAngle:3.0*M_PI_2 clockwise:YES];
    [l_polygonpath closePath];
    [[UIColor colorWithRed:0.3 green:0.5 blue:0.7 alpha:1.0] setFill];
    [l_polygonpath fill];
    [self createOptionListTableView:rect];
}

- (void) createOptionListTableView:(CGRect) p_reqdRect
{
    if (_optionsView) {
        return;
    }
    _optionsView = [[UITableView alloc] initWithFrame:CGRectZero
                                                style:UITableViewStylePlain];
    if ([_optionsView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_optionsView setSeparatorInset:UIEdgeInsetsZero];
    }
    _optionsView.translatesAutoresizingMaskIntoConstraints = NO;
    _optionsView.showsVerticalScrollIndicator = YES;
    _optionsView.showsHorizontalScrollIndicator = NO;
    _optionsView.backgroundColor = [UIColor clearColor];
    _optionsView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _optionsView.separatorColor = [UIColor clearColor];
    [_optionsView setDelegate:self];
    [_optionsView setDataSource:self];
    [self addSubview:_optionsView];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_optionsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-20.0)],[NSLayoutConstraint constraintWithItem:_optionsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-20.0)],[NSLayoutConstraint constraintWithItem:_optionsView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:(-10.0)],[NSLayoutConstraint constraintWithItem:_optionsView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:(10.0)]]];
}

#pragma delegates for table view  option and branches table view delegates

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * l_optioncellid = @"option_cell";
    UILabel * l_lbloption;
    UITableViewCell * l_newcell = [tableView dequeueReusableCellWithIdentifier:l_optioncellid];
    if (!l_newcell)
    {
        l_newcell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:l_optioncellid];
        l_lbloption = [[UILabel alloc] initWithFrame:CGRectMake(5, 1, _optionsView.frame.size.width-10.0, _rowHeight - 2.0f)];
        [l_lbloption setBackgroundColor:[UIColor clearColor]];
        [l_lbloption setTextColor:[UIColor whiteColor]];
        [l_lbloption setTextAlignment:NSTextAlignmentCenter];
        l_lbloption.font = [UIFont boldSystemFontOfSize:20.0f];
        l_lbloption.numberOfLines= 0;
        l_lbloption.tag = 101;
        [l_newcell setBackgroundColor:[UIColor clearColor]];
        [l_newcell.contentView addSubview:l_lbloption];
        [l_newcell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    else
        l_lbloption = (UILabel*) [l_newcell.contentView viewWithTag:101];
    l_lbloption.text = [_optionsList objectAtIndex:indexPath.row];
    return l_newcell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_optionsList count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * l_selectedcell = [tableView cellForRowAtIndexPath:indexPath];
    [_dataDelegate optionCellSelected:indexPath.row andFrame:l_selectedcell.frame];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end

