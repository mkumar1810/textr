//
//  ttrLoginView.m
//  TexTr
//
//  Created by Mohan Kumar on 25/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrLoginView.h"
#import "ttrDefaults.h"
#import "ttrCommonUtilities.h"

@interface ttrLoginView() <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSArray * _loginCellNames;
    NSArray * _loginCellDims;
}

@end

@implementation ttrLoginView

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero style:UITableViewStylePlain];
    if (self)
    {
        _loginCellNames = @[@"empty", @"username", @"password", @"empty",@"login"];
        _loginCellDims = @[@30, @40, @40, @30, @50];
        [self setBackgroundColor:[UIColor colorWithRed:0.5 green:0.7 blue:0.9 alpha:1.0]];
        self.contentInset = UIEdgeInsetsZero;
        [self setSeparatorColor:[UIColor clearColor]];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    [self setDelegate:self];
    [self setDataSource:self];
    [self reloadData];
}

- (NSDictionary*) bValidateEnteredDataandReturnLoginInfo
{
    NSMutableDictionary * l_returnDict = [[NSMutableDictionary alloc] init];
    for (ttrLoginViewCustomCell * l_tmpcell in self.visibleCells)
    {
        NSArray * l_tmpcelvalidation = [l_tmpcell bValidateCellData];
        if ([[l_tmpcelvalidation objectAtIndex:0] integerValue]!=0)
        {
            [self showAlertMessage:[l_tmpcelvalidation objectAtIndex:1]];
            return nil;
        }
        if ([l_tmpcelvalidation count]==3)
        {
            [l_returnDict setValuesForKeysWithDictionary:[l_tmpcelvalidation objectAtIndex:2]];
        }
    }
    return l_returnDict;
}

- (void) showAlertMessage:(NSString*) p_showMessage
{
    UIAlertView *l_alert = [[UIAlertView alloc] initWithTitle:@"" message:p_showMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [l_alert show];
}

#pragma table view delegates

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[_loginCellDims objectAtIndex:indexPath.row] floatValue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * l_reqdcellid = [_loginCellNames objectAtIndex:indexPath.row];
    ttrLoginViewCustomCell * l_newcell = [tableView dequeueReusableCellWithIdentifier:l_reqdcellid];
    if (!l_newcell)
        l_newcell = [[ttrLoginViewCustomCell alloc]
                     initWithStyle:UITableViewCellStyleSubtitle
                     reuseIdentifier:l_reqdcellid
                     onPosn:indexPath.row
                     withDelegate:self.handlerDelegate
                     andTxtDelegate:self];
    return l_newcell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * l_cellname = [_loginCellNames objectAtIndex:indexPath.row];
    if ([l_cellname isEqualToString:@"login"])
    {
        [self.handlerDelegate executeLoginWithInfo];
    }
}

#pragma text field delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger l_tagNo = textField.tag;
    NSInteger l_nextrowno = -1;
    switch (l_tagNo) {
        case 1:
            l_nextrowno = 2;
            break;
        default:
            break;
    }
    if (l_nextrowno!=(-1)) {
        UITableViewCell * l_nextcell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:l_nextrowno inSection:0]];
        [l_nextcell becomeFirstResponder];
    }
    else
        [textField resignFirstResponder];
    return YES;
}


@end

@interface ttrLoginViewCustomCell()
{
    UITextField * _dispTxtField;
    NSInteger _posnNo;
    id<ttrLoginViewDelegate> _handlerDelegate;
    id<UITextFieldDelegate> _txtDelegate;
}

@end

@implementation ttrLoginViewCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier onPosn:(NSInteger) p_posnNo withDelegate:(id<ttrLoginViewDelegate>) p_delegate andTxtDelegate:(id<UITextFieldDelegate>) p_txtDelegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _posnNo = p_posnNo;
        _handlerDelegate = p_delegate;
        _txtDelegate = p_txtDelegate;
        if ([self.reuseIdentifier isEqualToString:@"username"] | [self.reuseIdentifier isEqualToString:@"password"])
            [self setBackgroundColor:[UIColor whiteColor]];
        else
            [self setBackgroundColor:[UIColor clearColor]];
        [self setAccessoryType:UITableViewCellAccessoryNone];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if ([self.reuseIdentifier isEqualToString:@"username"])
    {
        [self drawGenDataEntryCell:rect];
        _dispTxtField.placeholder = @"username";
    }
    if ([self.reuseIdentifier isEqualToString:@"empty"])
    {
        [self drawEmptyCell:rect];
    }
    if ([self.reuseIdentifier isEqualToString:@"password"])
    {
        [self drawGenDataEntryCell:rect];
        _dispTxtField.placeholder = @"password";
        _dispTxtField.secureTextEntry = YES;
    }
    if ([self.reuseIdentifier isEqualToString:@"login"])
    {
        [self drawLoginCell:rect];
    }
    UIView * l_vw = [UIView new];
    [l_vw setBackgroundColor:[UIColor clearColor]];
    [self setSelectedBackgroundView:l_vw];
    [self layoutIfNeeded];
}

- (void) drawLoginCell:(CGRect) p_rect
{
    UILabel * l_lblconnect = [ttrDefaults getStandardLabelWithText:@"Login"];
    [l_lblconnect setBackgroundColor:[UIColor whiteColor]];
    l_lblconnect.textAlignment = NSTextAlignmentCenter;
    l_lblconnect.font = [UIFont boldSystemFontOfSize:24.0f];
    l_lblconnect.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:l_lblconnect];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:l_lblconnect attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-10.0)],[NSLayoutConstraint constraintWithItem:l_lblconnect attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:l_lblconnect attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:l_lblconnect attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:(5.0)]]];
}

- (void) drawGenDataEntryCell:(CGRect) p_rect
{
    NOPARAMCALLBACK l_drawLines =
    ^{
        if ([self.reuseIdentifier isEqualToString:@"password"])
        {
            return;
        }
        CGContextRef l_ctxref = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(l_ctxref, 0.5);
        CGContextSetStrokeColorWithColor(l_ctxref, [UIColor grayColor].CGColor);
        CGContextMoveToPoint(l_ctxref, 10  , p_rect.size.height-1.0);
        CGContextAddLineToPoint(l_ctxref, p_rect.size.width-1.0, p_rect.size.height-1.0);
        CGContextStrokePath(l_ctxref);
    };
    
    _dispTxtField = [ttrDefaults getStandardTextField];
    [self addSubview:_dispTxtField];
    //[_dispTxtField setBackgroundColor:[UIColor clearColor]];
    [_dispTxtField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_dispTxtField setAutocorrectionType:UITextAutocorrectionTypeNo];
    _dispTxtField.delegate = _txtDelegate;
    _dispTxtField.tag = _posnNo;
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispTxtField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-12.0)],[NSLayoutConstraint constraintWithItem:_dispTxtField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-2.0)],[NSLayoutConstraint constraintWithItem:_dispTxtField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:_dispTxtField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:5.0]]];
    l_drawLines();
}

- (void) drawEmptyCell:(CGRect) p_rect
{
    UIView * l_vw = [UIView new];
    [l_vw setBackgroundColor:[UIColor colorWithRed:0.5 green:0.7 blue:0.9 alpha:1.0]];
    l_vw.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:l_vw];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:l_vw attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:l_vw attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:l_vw attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:l_vw attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]]];
}

- (void) setDisplayValuesAtPosn:(NSInteger) p_posnNo
{
    _dispTxtField.tag = _posnNo;
    
}

- (BOOL)becomeFirstResponder
{
    if (_dispTxtField) {
        [_dispTxtField becomeFirstResponder];
    }
    return YES;
}

- (void) setTextDisplayValue:(NSString*) p_txtdisplayValue
{
    _dispTxtField.text = p_txtdisplayValue;
}

- (NSArray*) bValidateCellData;
{
    BOOL l_valuecheck;
    if ([self.reuseIdentifier isEqualToString:@"username"])
    {
        l_valuecheck = [ttrCommonUtilities isTextFieldIsEmpty:_dispTxtField];
        return @[@(l_valuecheck?1:0),@"Invalid User name!", @{@"username":_dispTxtField.text}];
    }
    if ([self.reuseIdentifier isEqualToString:@"password"])
    {
        l_valuecheck = [ttrCommonUtilities isTextFieldIsEmpty:_dispTxtField];
        return @[@(l_valuecheck?1:0),@"Invalid password!",@{@"password":_dispTxtField.text}];
    }
    return @[@(0)];
}

@end
