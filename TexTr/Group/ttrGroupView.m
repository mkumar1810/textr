//
//  ttrGroupView.m
//  TexTr
//
//  Created by Mohan Kumar on 25/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrGroupView.h"
#import "ttrDefaults.h"
#import "ttrCommonUtilities.h"

@interface ttrGroupView()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>
{
    CGFloat _rowHeight;
    NSArray * _grpVwCellNames;
    NSArray * _grpVwCellDims;
    UIGestureRecognizer * _justGesture;
    CGSize _keyboardSize;
}

@property (nonatomic,strong) UITableView * grpViewTV;

@end


@implementation ttrGroupView

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        [self setBackgroundColor:[UIColor colorWithWhite:0.99 alpha:0.99]];
        _rowHeight = 60.0f;
        _grpVwCellNames = @[@"title", @"description", @"empty", @"friendsonly", @"viewonly",@"privategroup",@"empty",@"create", @"empty"];
        _grpVwCellDims = @[@30, @160, @25, @50, @50, @50, @35, @45, @35];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (self.grpViewTV)
        return;
    self.grpViewTV = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.grpViewTV.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.grpViewTV];
    self.grpViewTV.dataSource = self;
    self.grpViewTV.delegate = self;
    [self.grpViewTV setSeparatorColor:[UIColor clearColor]];
    [self.grpViewTV setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.grpViewTV setBackgroundColor:[UIColor clearColor]];
    self.grpViewTV.contentInset = UIEdgeInsetsZero;
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.grpViewTV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:1.0],[NSLayoutConstraint constraintWithItem:self.grpViewTV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.grpViewTV attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.grpViewTV attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]]];
    [self layoutIfNeeded];
    
    _justGesture = [[UIGestureRecognizer alloc] init];
    _justGesture.delegate = self;
    [self addGestureRecognizer:_justGesture];
}

- (void)setDescripitonImageData:(NSData *)p_descImgData
{
    ttrGroupViewCustomCell * l_touchcell = (ttrGroupViewCustomCell*) [self.grpViewTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [l_touchcell setDescriptionImageIntoView:p_descImgData];
}

- (void)setDescripitonImage:(UIImage *)p_descImage
{
    ttrGroupViewCustomCell * l_touchcell = (ttrGroupViewCustomCell*) [self.grpViewTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [l_touchcell setDescriptionImage:p_descImage];
}


- (NSDictionary*) bValidateEnteredDataandReturnSaveInfo
{
    NSMutableDictionary * l_returnDict = [[NSMutableDictionary alloc] init];
    for (ttrGroupViewCustomCell * l_tmpcell in self.grpViewTV.visibleCells)
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

- (UIImage *)getDescriptionImage
{
    ttrGroupViewCustomCell * l_desccell = (ttrGroupViewCustomCell*) [self.grpViewTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    return [l_desccell getDescriptionImage];
}

#pragma gesture recognizer delegates

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint l_touchPoint = [touch locationInView:self.grpViewTV];
    NSIndexPath * l_touchrow = [self.grpViewTV indexPathForRowAtPoint:l_touchPoint];
    if (l_touchrow)
    {
        ttrGroupViewCustomCell * l_touchcell = (ttrGroupViewCustomCell*) [self.grpViewTV cellForRowAtIndexPath:l_touchrow];
        CGPoint l_pointincell = [self.grpViewTV convertPoint:l_touchPoint toView:l_touchcell];
        if ([l_touchcell checkIfDescImageClicked:l_pointincell])
        {
            self.descImageFrame = [l_touchcell getDescriptionImgViewFrame];
            self.descImageCellRef = l_touchcell;
            [self.handlerDelegate takeDescriptionPictureFromFrame];
        }
    }
    return NO;
}

#pragma tableview delegates

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1 * _rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1 * _rowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * l_hdrvw = [UIView new];
    [l_hdrvw setBackgroundColor:[UIColor clearColor]];
    return l_hdrvw;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * l_ftrvw = [UIView new];
    [l_ftrvw setBackgroundColor:[UIColor clearColor]];
    return l_ftrvw;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[_grpVwCellDims objectAtIndex:indexPath.row] floatValue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * l_reqdcellid = [_grpVwCellNames objectAtIndex:indexPath.row];
    ttrGroupViewCustomCell * l_newcell = [tableView dequeueReusableCellWithIdentifier:l_reqdcellid];
    if (!l_newcell)
        l_newcell = [[ttrGroupViewCustomCell alloc]
                     initWithStyle:UITableViewCellStyleSubtitle
                     reuseIdentifier:l_reqdcellid
                     onPosn:indexPath.row
                     withDelegate:self.handlerDelegate
                     andTxtDelegate:self];
    else
        [l_newcell setDisplayValuesAtPosn:indexPath.row];
    return l_newcell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * l_cellname = [_grpVwCellNames objectAtIndex:indexPath.row];
    if ([l_cellname isEqualToString:@"create"])
    {
        [self.handlerDelegate executeSavingOfNewGroupEntryData];
    }
}

#pragma text field related delegates handling for email and password


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger l_tagNo = textField.tag;
    NSInteger l_nextrowno = -1;
    switch (l_tagNo) {
        case 0:
            l_nextrowno = 1;
            break;
        default:
            break;
    }
    if (l_nextrowno==-1)
    {
        return [textField resignFirstResponder];
    }
    UITableViewCell * l_nextcell = [self.grpViewTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:l_nextrowno inSection:0]];
    [l_nextcell becomeFirstResponder];
    return YES;
}

@end


@interface ttrGroupViewCustomCell()
{
    UIImageView * _descImgView;
    UITextField * _dispTxtField;
    UILabel * _dispLblField, * _dispLblField2;
    NSInteger _posnNo;
    UIButton * _btnCheckBox, * _btncamera;
    id<ttrGroupViewDelegate> _handlerDelegate;
    id<UITextFieldDelegate> _txtDelegate;
}

@end

@implementation ttrGroupViewCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier onPosn:(NSInteger) p_posnNo withDelegate:(id<ttrGroupViewDelegate>) p_delegate andTxtDelegate:(id<UITextFieldDelegate>) p_txtDelegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _posnNo = p_posnNo;
        _handlerDelegate = p_delegate;
        _txtDelegate = p_txtDelegate;
        if ([self.reuseIdentifier isEqualToString:@"empty"])
            [self setBackgroundColor:[UIColor clearColor]];
        else
            [self setBackgroundColor:[UIColor whiteColor]];
        [self setAccessoryType:UITableViewCellAccessoryNone];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if ([self.reuseIdentifier isEqualToString:@"title"])
    {
        [self drawTitleCell:rect];
        _dispTxtField.tag = 0;
    }
    else if ([self.reuseIdentifier isEqualToString:@"description"])
    {
        [self drawDescImageCell:rect];
        _dispTxtField.tag = 1;
    }
    else if ([self.reuseIdentifier isEqualToString:@"empty"])
    {
        [self drawEmptyCell:rect];
    }
    else if ([self.reuseIdentifier isEqualToString:@"friendsonly"])
    {
        [self draw2Lbl1BtnCheckCell:rect];
        _dispLblField.text = @"Friends Only";
        _dispLblField2.text = @"Only friends will be able to see your group";
    }
    else if ([self.reuseIdentifier isEqualToString:@"viewonly"])
    {
        [self draw2Lbl1BtnCheckCell:rect];
        _dispLblField.text = @"View Only";
        _dispLblField2.text = @"People can view your conversion but not enter it";
    }
    else if ([self.reuseIdentifier isEqualToString:@"privategroup"])
    {
        [self draw2Lbl1BtnCheckCell:rect];
        _dispLblField.text = @"Private Group";
        _dispLblField2.text = @"Makes your group invisible to other users";
    }
    else if ([self.reuseIdentifier isEqualToString:@"create"])
    {
        [self drawCreateCell:rect];
    }
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self layoutIfNeeded];
}

- (void) drawCreateCell:(CGRect) p_rect
{
    
    UILabel * l_lblcreate = [ttrDefaults getStandardLabelWithText:@"Create"];
    [l_lblcreate setBackgroundColor:[UIColor whiteColor]];
    l_lblcreate.textAlignment = NSTextAlignmentCenter;
    l_lblcreate.font = [UIFont boldSystemFontOfSize:24.0f];
    l_lblcreate.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:l_lblcreate];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:l_lblcreate attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-10.0)],[NSLayoutConstraint constraintWithItem:l_lblcreate attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:l_lblcreate attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:l_lblcreate attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:(5.0)]]];
}

- (void) draw2Lbl1BtnCheckCell:(CGRect) p_rect
{
    NOPARAMCALLBACK l_drawLines =
    ^{
        CGContextRef l_ctx = UIGraphicsGetCurrentContext();
        CGMutablePathRef l_pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(l_pathRef, NULL, 0, p_rect.size.height - 20.0);
        CGPathAddLineToPoint(l_pathRef, NULL, p_rect.size.width,  p_rect.size.height-20.0);
        CGPathAddLineToPoint(l_pathRef, NULL, p_rect.size.width,  p_rect.size.height);
        CGPathAddLineToPoint(l_pathRef, NULL, 0,  p_rect.size.height);
        CGPathCloseSubpath(l_pathRef);
        CGContextAddPath(l_ctx, l_pathRef);
        CGContextSetFillColorWithColor(l_ctx, [UIColor colorWithRed:0.94 green:0.97 blue:1.0 alpha:1.0].CGColor);
        CGContextFillPath(l_ctx);
        CGPathRelease(l_pathRef);
        
    };
    
    _dispLblField = [ttrDefaults getStandardLabelWithText:@""];
    [self addSubview:_dispLblField];
    _dispLblField.font = [UIFont boldSystemFontOfSize:16.0f];
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispLblField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-40.0)],[NSLayoutConstraint constraintWithItem:_dispLblField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.6 constant:(-2.0)],[NSLayoutConstraint constraintWithItem:_dispLblField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:0.6 constant:0.0],[NSLayoutConstraint constraintWithItem:_dispLblField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:(-10.0)]]];
    
    _btnCheckBox = [ttrDefaults getStandardButton];
    
    [_btnCheckBox setBackgroundImage:[UIImage imageNamed:@"chkbox_uncheck"] forState:UIControlStateNormal];
    [_btnCheckBox setBackgroundImage:[UIImage imageNamed:@"chkbox_check"] forState:UIControlStateSelected];
    [_btnCheckBox setBackgroundColor:[UIColor clearColor]];
    _btnCheckBox.translatesAutoresizingMaskIntoConstraints = NO;
    [_btnCheckBox addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnCheckBox];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_btnCheckBox attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.6 constant:(-10.0)],[NSLayoutConstraint constraintWithItem:_btnCheckBox attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.6 constant:(-10.0)],[NSLayoutConstraint constraintWithItem:_btnCheckBox attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:0.6 constant:0.0],[NSLayoutConstraint constraintWithItem:_btnCheckBox attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:(-15.0)]]];
    
    _dispLblField2 = [ttrDefaults getStandardLabelWithText:@""];
    [self addSubview:_dispLblField2];
    _dispLblField2.font = [UIFont systemFontOfSize:10.0f];
    [_dispLblField2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[df2(20)]" options:0 metrics:nil views:@{@"df2":_dispLblField2}]];
    _dispLblField2.textColor = [UIColor grayColor];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-10.0)],[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:5.0]]];
    [_dispLblField2 sizeToFit];
    l_drawLines();
    [self layoutIfNeeded];
}

- (void) drawTitleCell:(CGRect) p_rect
{
    NOPARAMCALLBACK l_drawLines =
    ^{
        CGContextRef l_ctxref = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(l_ctxref, 0.5);
        CGContextSetStrokeColorWithColor(l_ctxref, [UIColor lightGrayColor].CGColor);
        CGContextMoveToPoint(l_ctxref, 10  , p_rect.size.height-1.0);
        CGContextAddLineToPoint(l_ctxref, p_rect.size.width-1.0, p_rect.size.height-1.0);
        CGContextStrokePath(l_ctxref);
    };
    
    _dispTxtField = [ttrDefaults getStandardTextField];
    [self addSubview:_dispTxtField];
    _dispTxtField.placeholder = @"Title";
    [_dispTxtField setBackgroundColor:[UIColor whiteColor]];
    [_dispTxtField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_dispTxtField setAutocorrectionType:UITextAutocorrectionTypeNo];
    _dispTxtField.delegate = _txtDelegate;
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispTxtField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-10.0)],[NSLayoutConstraint constraintWithItem:_dispTxtField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-2.0)],[NSLayoutConstraint constraintWithItem:_dispTxtField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:_dispTxtField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:5.0]]];
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

- (void) drawDescImageCell:(CGRect) p_rect
{
    NOPARAMCALLBACK l_drawLines =
    ^{
        CGContextRef l_ctx = UIGraphicsGetCurrentContext();
        CGMutablePathRef l_pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(l_pathRef, NULL, 0, p_rect.size.height - 20.0);
        CGPathAddLineToPoint(l_pathRef, NULL, p_rect.size.width,  p_rect.size.height-20.0);
        CGPathAddLineToPoint(l_pathRef, NULL, p_rect.size.width,  p_rect.size.height);
        CGPathAddLineToPoint(l_pathRef, NULL, 0,  p_rect.size.height);
        CGPathCloseSubpath(l_pathRef);
        CGContextAddPath(l_ctx, l_pathRef);
        CGContextSetFillColorWithColor(l_ctx, [UIColor colorWithRed:0.94 green:0.97 blue:1.0 alpha:1.0].CGColor);
        CGContextFillPath(l_ctx);
        CGPathRelease(l_pathRef);
        
    };
    
    if (_descImgView)
    {
        l_drawLines();
        return;
    }
    
    _descImgView = [UIImageView new];
    _descImgView.translatesAutoresizingMaskIntoConstraints = NO;
    [_descImgView setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:0.97]];
    [self addSubview:_descImgView];
    
    _dispTxtField = [ttrDefaults getStandardTextField];
    _dispTxtField.placeholder = @"description";
    [self addSubview:_dispTxtField];
    [_dispTxtField setBackgroundColor:[UIColor clearColor]];
    [_dispTxtField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_dispTxtField setAutocorrectionType:UITextAutocorrectionTypeNo];
    _dispTxtField.delegate = _txtDelegate;
    
    [_dispTxtField addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tf(25)]" options:0 metrics:nil views:@{@"tf":_dispTxtField}]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispTxtField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-10.0)],[NSLayoutConstraint constraintWithItem:_dispTxtField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:5.0]]];
    
    CGFloat l_descimgheight = p_rect.size.height - 29.0 - 20;

    [_descImgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[di(di_h)]" options:0 metrics:@{@"di_h":@(l_descimgheight)} views:@{@"di":_descImgView}]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_descImgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-10.0)],[NSLayoutConstraint constraintWithItem:_descImgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:(5.0)]]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[tf]-2-[di]" options:0 metrics:nil views:@{@"tf":_dispTxtField, @"di":_descImgView}]];

    
    _btncamera = [ttrDefaults getStandardButton];
    [_btncamera setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [_btncamera setBackgroundColor:[UIColor clearColor]];
    _btncamera.translatesAutoresizingMaskIntoConstraints = NO;
    [_btncamera setUserInteractionEnabled:NO];
    _btncamera.alpha = 0.6;
    [self addSubview:_btncamera];
    [_btncamera addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bc(20)]" options:0 metrics:nil views:@{@"bc":_btncamera}]];
    [_btncamera addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[bc(35)]" options:0 metrics:nil views:@{@"bc":_btncamera}]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_btncamera attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_descImgView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:_btncamera attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_descImgView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:(-5.0)]]];
    [self bringSubviewToFront:_btncamera];
    
    _dispLblField2 = [ttrDefaults getStandardLabelWithText:@"Add relevant hashtags to help people find your group"];
    [self addSubview:_dispLblField2];
    _dispLblField2.font = [UIFont systemFontOfSize:10.0f];
    
    [_dispLblField2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[df2(20)]" options:0 metrics:nil views:@{@"df2":_dispLblField2}]];
    _dispLblField2.textColor = [UIColor grayColor];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-10.0)],[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:5.0]]];
    [_dispLblField2 sizeToFit];
    
    l_drawLines();
    [self layoutIfNeeded];
}

- (void) setDisplayValuesAtPosn:(NSInteger) p_posnNo
{
    _dispTxtField.tag = _posnNo;
}

- (BOOL)checkIfDescImageClicked:(CGPoint)p_touchPoint
{
    if (_btncamera)
    {
        if (CGRectContainsPoint(_btncamera.frame, p_touchPoint)==YES)
        {
            return YES;
        }
    }
    return NO;
}

- (CGRect)getDescriptionImgViewFrame
{
    return _btncamera.frame;
}

- (void)setDescriptionImageIntoView:(NSData *)p_descImgData
{
    _descImgView.image = [UIImage imageWithData:p_descImgData];
}

- (void)setDescriptionImage:(UIImage *)p_descImage
{
    _descImgView.image = p_descImage;
}

- (BOOL)becomeFirstResponder
{
    if (_dispTxtField)
    {
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
    if ([self.reuseIdentifier isEqualToString:@"title"])
    {
        l_valuecheck = [ttrCommonUtilities isTextFieldIsEmpty:_dispTxtField];
        return @[@(l_valuecheck?1:0),@"Invalid title!", @{@"title":_dispTxtField.text}];
    }
    if ([self.reuseIdentifier isEqualToString:@"description"])
    {
        l_valuecheck = [ttrCommonUtilities isTextFieldIsEmpty:_dispTxtField];
        return @[@(l_valuecheck?1:0),@"Invalid Description!",@{@"description":_dispTxtField.text}];
    }
    if ([self.reuseIdentifier isEqualToString:@"friendsonly"] |
        [self.reuseIdentifier isEqualToString:@"viewonly"] |
        [self.reuseIdentifier isEqualToString:@"privategroup"])
    {
        return @[@(0),@"",@{ self.reuseIdentifier: @(_btnCheckBox.selected)}];
    }
    return @[@(0)];
}

- (UIImage *)getDescriptionImage
{
    return _descImgView.image;
}

- (void) buttonClicked
{
    _btnCheckBox.selected = !_btnCheckBox.selected;
}

@end
