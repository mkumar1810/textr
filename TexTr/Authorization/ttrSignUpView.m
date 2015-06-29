//
//  ttrSignUpView.m
//  TexTr
//
//  Created by Mohan Kumar on 22/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrSignUpView.h"
#import "ttrDefaults.h"
#import "ttrCommonUtilities.h"

@interface ttrSignUpView()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>
{
    CGFloat _rowHeight;
    NSArray * _sgnUpCellNames;
    NSArray * _sgnUpCellDims;
    UIGestureRecognizer * _justGesture;
    CGSize _keyboardSize;
}

@property (nonatomic,strong) UITableView * signUpInfoTV;

@end

@implementation ttrSignUpView


- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        [self setBackgroundColor:[UIColor clearColor]];
        _rowHeight = 60.0f;
        _sgnUpCellNames = @[@"username", @"empty", @"password", @"confpassword", @"email",@"birthday",@"empty",@"addressbook", @"connect",@"terms"];
        _sgnUpCellDims = @[@100, @30, @38, @38, @38, @38, @30, @60, @50, @80];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (self.signUpInfoTV)
        return;
    self.signUpInfoTV = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.signUpInfoTV.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.signUpInfoTV];
    self.signUpInfoTV.dataSource = self;
    self.signUpInfoTV.delegate = self;
    [self.signUpInfoTV setSeparatorColor:[UIColor clearColor]];
    [self.signUpInfoTV setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.signUpInfoTV setBackgroundColor:[UIColor clearColor]];
    self.signUpInfoTV.contentInset = UIEdgeInsetsZero;
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.signUpInfoTV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:1.0],[NSLayoutConstraint constraintWithItem:self.signUpInfoTV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.signUpInfoTV attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.signUpInfoTV attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]]];
    [self layoutIfNeeded];
    
    _justGesture = [[UIGestureRecognizer alloc] init];
    _justGesture.delegate = self;
    [self addGestureRecognizer:_justGesture];
}

- (void) setProfileImageData:(NSData*) p_profImgData
{
    ttrSignUpViewCustomCell * l_touchcell = (ttrSignUpViewCustomCell*) [self.signUpInfoTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [l_touchcell setProfileImageIntoView:p_profImgData];
}

- (void) setProfileImage:(UIImage*) p_profileImage
{
    ttrSignUpViewCustomCell * l_touchcell = (ttrSignUpViewCustomCell*) [self.signUpInfoTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [l_touchcell setProfileImage:p_profileImage];
}

- (void) setBirthDate:(NSString*) p_birthDateStr
{
    ttrSignUpViewCustomCell * l_touchcell = (ttrSignUpViewCustomCell*) [self.signUpInfoTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    [l_touchcell setTextDisplayValue:p_birthDateStr];
}


- (NSDictionary*) bValidateEnteredDataandReturnSaveInfo
{
    NSMutableDictionary * l_returnDict = [[NSMutableDictionary alloc] init];
    for (ttrSignUpViewCustomCell * l_tmpcell in self.signUpInfoTV.visibleCells)
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
    if ([[l_returnDict valueForKey:@"password"] isEqualToString:[l_returnDict valueForKey:@"confpassword"]]==NO)
    {
        [self showAlertMessage:@"password mis-match"];
        return nil;
    }
    [l_returnDict setValue:nil forKey:@"confpassword"];
    return l_returnDict;
}

- (void) showAlertMessage:(NSString*) p_showMessage
{
    UIAlertView *l_alert = [[UIAlertView alloc] initWithTitle:@"" message:p_showMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [l_alert show];
}

- (UIImage*) getProfileImage
{
    ttrSignUpViewCustomCell * l_profilecell = (ttrSignUpViewCustomCell*) [self.signUpInfoTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return [l_profilecell getProfileImage];
}

#pragma gesture recognizer delegates

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint l_touchPoint = [touch locationInView:self.signUpInfoTV];
    NSIndexPath * l_touchrow = [self.signUpInfoTV indexPathForRowAtPoint:l_touchPoint];
    if (l_touchrow)
    {
        ttrSignUpViewCustomCell * l_touchcell = (ttrSignUpViewCustomCell*) [self.signUpInfoTV cellForRowAtIndexPath:l_touchrow];
        CGPoint l_pointincell = [self.signUpInfoTV convertPoint:l_touchPoint toView:l_touchcell];
        if ([l_touchcell checkIfProfileViewClicked:l_pointincell])
        {
            self.profileImageFrame = [l_touchcell getProfileViewFrame];
            self.profileImageCellRef = l_touchcell;
            [self.handlerDelegate takeProfilePictureFromFrame];
             //:[l_touchcell getProfileViewFrame] onView:l_touchcell];
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
    return [[_sgnUpCellDims objectAtIndex:indexPath.row] floatValue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * l_reqdcellid = [_sgnUpCellNames objectAtIndex:indexPath.row];
    ttrSignUpViewCustomCell * l_newcell = [tableView dequeueReusableCellWithIdentifier:l_reqdcellid];
    if (!l_newcell)
        l_newcell = [[ttrSignUpViewCustomCell alloc]
                     initWithStyle:UITableViewCellStyleSubtitle
                     reuseIdentifier:l_reqdcellid
                     onPosn:indexPath.row
                     withDelegate:self.handlerDelegate
                     andTextDelegate:self];
    else
        [l_newcell setDisplayValuesAtPosn:indexPath.row];
    return l_newcell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * l_cellname = [_sgnUpCellNames objectAtIndex:indexPath.row];
    if ([l_cellname isEqualToString:@"connect"])
    {
        [self.handlerDelegate executeSavingOfSignUpData];
    }
}


#pragma text field related delegates handling for email and password

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag==5)
    {
        CGRect l_inputfieldbounds = [textField convertRect:textField.bounds toView:self.superview];
        [_handlerDelegate showDateCaptureFromFrame:l_inputfieldbounds withStartDateVal:textField.text];
        return NO;
    }
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect l_inputfieldbounds = [textField convertRect:textField.bounds toView:self.superview];
    CGRect l_superbounds = self.superview.bounds;
    if ([_handlerDelegate getKeyBoardSize].height==0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [textField resignFirstResponder];
        });
        return;
    }
    if ((l_inputfieldbounds.origin.y+l_inputfieldbounds.size.height+10.0)>(l_superbounds.size.height-[_handlerDelegate getKeyBoardSize].height))
    {
        CGFloat l_offsetheight = (l_inputfieldbounds.origin.y+l_inputfieldbounds.size.height) - (l_superbounds.size.height-[_handlerDelegate getKeyBoardSize].height)+10.0;
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self.signUpInfoTV setContentOffset:CGPointMake(0, l_offsetheight)];
                         }];
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
   // [self.dataDelegate resetFromScrollOffset];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger l_tagNo = textField.tag;
    NSInteger l_nextrowno = -1;
    switch (l_tagNo) {
        case 0:
            l_nextrowno = 2;
            break;
        case 2:
        case 3:
            l_nextrowno = l_tagNo+1;
            break;
        default:
            break;
    }
    if (l_nextrowno==-1)
    {
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self.signUpInfoTV setContentOffset:CGPointZero];
                         }];
        return [textField resignFirstResponder];
    }
    UITableViewCell * l_nextcell = [self.signUpInfoTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:l_nextrowno inSection:0]];
    [l_nextcell becomeFirstResponder];
    return YES;
}


@end

@interface ttrSignUpViewCustomCell()
{
    UIImageView * _profileView;
    UITextField * _dispTxtField;
    UITextView * _dispTxtView;
    UILabel * _dispLblField, * _dispLblField2;
    NSInteger _posnNo;
    UIButton * _btnAddBookCheck;
    id<ttrSignUpViewDelegate> _handlerDelegate;
    id<UITextFieldDelegate> _txtDelegate;
}

@end

@implementation ttrSignUpViewCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier onPosn:(NSInteger) p_posnNo withDelegate:(id<ttrSignUpViewDelegate>) p_delegate andTextDelegate:(id<UITextFieldDelegate>) p_txtDelegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _posnNo = p_posnNo;
        _handlerDelegate = p_delegate;
        _txtDelegate = p_txtDelegate;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAccessoryType:UITableViewCellAccessoryNone];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if ([self.reuseIdentifier isEqualToString:@"username"])
    {
        [self drawUserNameCell:rect];
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
    if ([self.reuseIdentifier isEqualToString:@"confpassword"])
    {
        [self drawGenDataEntryCell:rect];
        _dispTxtField.placeholder = @"confirm password";
        _dispTxtField.secureTextEntry = YES;
    }
    if ([self.reuseIdentifier isEqualToString:@"email"])
    {
        [self drawGenDataEntryCell:rect];
        _dispTxtField.placeholder = @"email";
    }
    if ([self.reuseIdentifier isEqualToString:@"birthday"])
    {
        [self drawGenDataEntryCell:rect];
        _dispTxtField.placeholder = @"birthday";
    }
    if ([self.reuseIdentifier isEqualToString:@"addressbook"])
    {
        [self drawAddressBookCell:rect];
    }
    if ([self.reuseIdentifier isEqualToString:@"connect"])
    {
        [self drawConnectCell:rect];
    }
    if ([self.reuseIdentifier isEqualToString:@"terms"])
    {
        [self drawTermsCell:rect];
    }
    /*UIView * l_vw = [UIView new];
     [l_vw setBackgroundColor:[UIColor clearColor]];
     [self setSelectedBackgroundView:l_vw];*/
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self layoutIfNeeded];
    _dispTxtField.tag = _posnNo;
    _dispTxtField.delegate = _txtDelegate;
}

- (void) drawTermsCell:(CGRect) p_rect
{
    _dispTxtView = [UITextView new];
    _dispTxtView.translatesAutoresizingMaskIntoConstraints = NO;
    _dispTxtView.textAlignment = NSTextAlignmentLeft;
    [_dispTxtView setBackgroundColor:[UIColor clearColor]];
    _dispTxtView.font = [UIFont systemFontOfSize:11.0f];
    [_dispTxtView.layer setBorderColor:[UIColor clearColor].CGColor];
    _dispTxtView.showsVerticalScrollIndicator = YES;
    [_dispTxtView setUserInteractionEnabled:NO];
    [_dispTxtView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_dispTxtView setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    [self addSubview:_dispTxtView];
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispTxtView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-20.0)],[NSLayoutConstraint constraintWithItem:_dispTxtView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.5 constant:(-2.0)],[NSLayoutConstraint constraintWithItem:_dispTxtView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:0.5 constant:0.0],[NSLayoutConstraint constraintWithItem:_dispTxtView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]]];
    
    NSMutableAttributedString *l_termstxt = [[NSMutableAttributedString alloc] initWithString:@"By tapping 'Connect' you agree to the terms of service and privacy policy."];
    
    NSRange l_tosrange = [[l_termstxt string] rangeOfString:@"terms of service"];
    [l_termstxt addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:11.0f] range:l_tosrange];
    [l_termstxt addAttribute:NSForegroundColorAttributeName value:[UIColor magentaColor] range:l_tosrange];
    
    NSRange l_pprange = [[l_termstxt string] rangeOfString:@"privacy policy"];
    [l_termstxt addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:11.0f] range:l_pprange];
    [l_termstxt addAttribute:NSForegroundColorAttributeName value:[UIColor magentaColor] range:l_pprange];
    
    _dispTxtView.attributedText = l_termstxt;
    
    _dispLblField2 = [ttrDefaults getStandardLabelWithText:@"Note:Your personal information is kept private"];
    [self addSubview:_dispLblField2];
    _dispLblField2.font = [UIFont systemFontOfSize:10.0f];
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-10.0)],[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.5 constant:(-2.0)],[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.5 constant:0.0],[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:5.0]]];
    [_dispLblField2 sizeToFit];
}

- (void) drawConnectCell:(CGRect) p_rect
{
    
    UILabel * l_lblconnect = [ttrDefaults getStandardLabelWithText:@"Connect"];
    [l_lblconnect setBackgroundColor:[UIColor grayColor]];
    l_lblconnect.textAlignment = NSTextAlignmentCenter;
    l_lblconnect.font = [UIFont boldSystemFontOfSize:24.0f];
    l_lblconnect.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:l_lblconnect];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:l_lblconnect attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-10.0)],[NSLayoutConstraint constraintWithItem:l_lblconnect attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:l_lblconnect attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:l_lblconnect attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:(5.0)]]];
}

- (void) drawAddressBookCell:(CGRect) p_rect
{
    NOPARAMCALLBACK l_drawLines =
    ^{
        CGContextRef l_ctxref = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(l_ctxref, 0.5);
        CGContextSetStrokeColorWithColor(l_ctxref, [UIColor lightGrayColor].CGColor);
        CGContextMoveToPoint(l_ctxref, 10  , p_rect.size.height*0.7);
        CGContextAddLineToPoint(l_ctxref, p_rect.size.width-1.0, p_rect.size.height*0.7);
        CGContextStrokePath(l_ctxref);
    };
    
    _dispLblField = [ttrDefaults getStandardLabelWithText:@"Address book Matching"];
    [self addSubview:_dispLblField];
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispLblField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-p_rect.size.height/2.0-20.0)],[NSLayoutConstraint constraintWithItem:_dispLblField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.7 constant:(-2.0)],[NSLayoutConstraint constraintWithItem:_dispLblField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:0.7 constant:0.0],[NSLayoutConstraint constraintWithItem:_dispLblField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:(-p_rect.size.height/4.0)]]];
    
    _btnAddBookCheck = [ttrDefaults getStandardButton];
    
    [_btnAddBookCheck setBackgroundImage:[UIImage imageNamed:@"chkbox_uncheck"] forState:UIControlStateNormal];
    [_btnAddBookCheck setBackgroundImage:[UIImage imageNamed:@"chkbox_check"] forState:UIControlStateSelected];
    [_btnAddBookCheck setBackgroundColor:[UIColor clearColor]];
    _btnAddBookCheck.translatesAutoresizingMaskIntoConstraints = NO;
    [_btnAddBookCheck setUserInteractionEnabled:NO];
    [self addSubview:_btnAddBookCheck];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_btnAddBookCheck attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.7 constant:(-20.0)],[NSLayoutConstraint constraintWithItem:_btnAddBookCheck attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.7 constant:(-20.0)],[NSLayoutConstraint constraintWithItem:_btnAddBookCheck attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:0.7 constant:0.0],[NSLayoutConstraint constraintWithItem:_btnAddBookCheck attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:(-10.0)]]];

    _dispLblField2 = [ttrDefaults getStandardLabelWithText:@"Allow address book matching to find friends already using TexTr"];
    [self addSubview:_dispLblField2];
    _dispLblField2.font = [UIFont systemFontOfSize:10.0f];
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-10.0)],[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.3 constant:(-2.0)],[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.7 constant:0.0],[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:5.0]]];
    [_dispLblField2 sizeToFit];
    l_drawLines();
}

- (void) drawGenDataEntryCell:(CGRect) p_rect
{
    NOPARAMCALLBACK l_drawLines =
    ^{
        if ([self.reuseIdentifier isEqualToString:@"birthday"])
        {
            return;
        }
        CGContextRef l_ctxref = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(l_ctxref, 0.5);
        CGContextSetStrokeColorWithColor(l_ctxref, [UIColor lightGrayColor].CGColor);
        CGContextMoveToPoint(l_ctxref, 10  , p_rect.size.height-1.0);
        CGContextAddLineToPoint(l_ctxref, p_rect.size.width-1.0, p_rect.size.height-1.0);
        CGContextStrokePath(l_ctxref);
    };

    _dispTxtField = [ttrDefaults getStandardTextField];
    [self addSubview:_dispTxtField];
    [_dispTxtField setBackgroundColor:[UIColor clearColor]];
    [_dispTxtField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_dispTxtField setAutocorrectionType:UITextAutocorrectionTypeNo];
    
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

- (void) drawUserNameCell:(CGRect) p_rect
{
    NOPARAMCALLBACK l_drawLines =
    ^{
        CGContextRef l_ctxref = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(l_ctxref, 0.5);
        CGContextSetStrokeColorWithColor(l_ctxref, [UIColor lightGrayColor].CGColor);
        CGContextMoveToPoint(l_ctxref, p_rect.size.height+20.0  , p_rect.size.height-35.0);
        CGContextAddLineToPoint(l_ctxref, p_rect.size.width-1.0, p_rect.size.height-35.0);
        CGContextStrokePath(l_ctxref);
    };
    
    if (_profileView)
    {
        l_drawLines();
        return;
    }
    
    _profileView = [UIImageView new];
    _profileView.image = [UIImage imageNamed:@"nophoto"];
    _profileView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_profileView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[pv]" options:0 metrics:nil views:@{@"pv":_profileView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[pv]" options:0 metrics:nil views:@{@"pv":_profileView}]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_profileView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-20.0)],[NSLayoutConstraint constraintWithItem:_profileView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-20.0)]]];
    
    _dispTxtField = [ttrDefaults getStandardTextField];
    _dispTxtField.placeholder = @"user name";
    [self addSubview:_dispTxtField];
    [_dispTxtField setBackgroundColor:[UIColor clearColor]];
    [_dispTxtField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_dispTxtField setAutocorrectionType:UITextAutocorrectionTypeNo];
    CGFloat l_tf_left = p_rect.size.height + 20.0;
    CGFloat l_tf_top = p_rect.size.height-34.0;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-tf_l-[tf]" options:0 metrics:@{@"tf_l":@(l_tf_left)} views:@{@"tf":_dispTxtField}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-tf_t-[tf]" options:0 metrics:@{@"tf_t":@(l_tf_top)} views:@{@"tf":_dispTxtField}]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispTxtField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-l_tf_left)],[NSLayoutConstraint constraintWithItem:_dispTxtField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-l_tf_top-1)]]];
    
    l_drawLines();
}

- (void) setDisplayValuesAtPosn:(NSInteger) p_posnNo
{
    _dispTxtField.tag = _posnNo;
    
}

- (BOOL) checkIfProfileViewClicked:(CGPoint) p_touchPoint
{
    if (_profileView)
    {
        if (CGRectContainsPoint(_profileView.frame, p_touchPoint)==YES)
        {
            return YES;
        }
    }
    return NO;
}

- (CGRect) getProfileViewFrame
{
    return _profileView.frame;
}

- (void) setProfileImageIntoView:(NSData*) p_profileImgData
{
    _profileView.image = [UIImage imageWithData:p_profileImgData];
}

- (void) setProfileImage:(UIImage*) p_profileImage
{
    _profileView.image = p_profileImage;
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
    if ([self.reuseIdentifier isEqualToString:@"confpassword"])
    {
        l_valuecheck = [ttrCommonUtilities isTextFieldIsEmpty:_dispTxtField];
        return @[@(l_valuecheck?1:0),@"Invalid conf password!",@{@"confpassword":_dispTxtField.text}];
    }
    if ([self.reuseIdentifier isEqualToString:@"email"])
    {
        l_valuecheck = [ttrCommonUtilities isTextFieldIsValidEMail:_dispTxtField];
        return @[@(l_valuecheck?0:1),@"Invalid e-mail!",@{@"email":_dispTxtField.text}];
    }
    if ([self.reuseIdentifier isEqualToString:@"birthday"])
    {
        l_valuecheck = [ttrCommonUtilities isTextFieldIsEmpty:_dispTxtField];
        return @[@(l_valuecheck?1:0),@"Invalid birthday",@{@"birthday":_dispTxtField.text}];
    }
    return @[@(0)];
}

- (UIImage*) getProfileImage
{
    return _profileView.image;
}

@end
