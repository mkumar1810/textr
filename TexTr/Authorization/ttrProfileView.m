//
//  ttrProfileView.m
//  TexTr
//
//  Created by Mohan Kumar on 06/07/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrProfileView.h"
#import "ttrDefaults.h"
#import "ttrCommonUtilities.h"
#import "ttrRESTProxy.h"

@interface ttrProfileView()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>
{
    CGFloat _rowHeight;
    CGFloat _groupCellheight;
    NSArray * _profileCellNames;
    NSArray * _profileCellDims;
    UIGestureRecognizer * _justGesture;
    CGSize _keyboardSize;
}

@property (nonatomic,strong) UITableView * profileDataTV;

@end

@implementation ttrProfileView

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        [self setBackgroundColor:[UIColor clearColor]];
        _rowHeight = 60.0f;
        _groupCellheight = 80.0f;
        _profileCellNames = @[@"usernameimage",@"friendsfollowers",@"followers",@"friends"];
        _profileCellDims = @[@130,@25,@35,@35];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (self.profileDataTV)
        return;
    self.profileDataTV = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.profileDataTV.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.profileDataTV];
    self.profileDataTV.dataSource = self;
    self.profileDataTV.delegate = self;
    [self.profileDataTV setSeparatorColor:[UIColor clearColor]];
    [self.profileDataTV setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.profileDataTV setBackgroundColor:[UIColor clearColor]];
    self.profileDataTV.contentInset = UIEdgeInsetsZero;
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.profileDataTV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:1.0],[NSLayoutConstraint constraintWithItem:self.profileDataTV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.profileDataTV attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.profileDataTV attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]]];
    [self layoutIfNeeded];
    
    _justGesture = [[UIGestureRecognizer alloc] init];
    _justGesture.delegate = self;
    [self addGestureRecognizer:_justGesture];
}

- (void)reloadAllProfileDataAndGroups
{
    [self.profileDataTV reloadData];
}

- (void) setProfileImageData:(NSData*) p_profImgData
{
    ttrProfileViewCustomCell * l_touchcell = (ttrProfileViewCustomCell*) [self.profileDataTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [l_touchcell setProfileImageIntoView:p_profImgData];
}

- (void) setProfileImage:(UIImage*) p_profileImage
{
    ttrProfileViewCustomCell * l_touchcell = (ttrProfileViewCustomCell*) [self.profileDataTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [l_touchcell setProfileImage:p_profileImage];
}


- (void) showAlertMessage:(NSString*) p_showMessage
{
    UIAlertView *l_alert = [[UIAlertView alloc] initWithTitle:@"" message:p_showMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [l_alert show];
}

- (UIImage*) getProfileImage
{
    ttrProfileViewCustomCell * l_profilecell = (ttrProfileViewCustomCell*) [self.profileDataTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return [l_profilecell getProfileImage];
}

- (BOOL)resignFirstResponder
{
    for (ttrProfileViewCustomCell * l_tmpcell in self.profileDataTV.visibleCells)
    {
        [l_tmpcell resignFirstResponder];
    }
    return YES;
}

#pragma gesture recognizer delegates

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint l_touchPoint = [touch locationInView:self.profileDataTV];
    NSIndexPath * l_touchrow = [self.profileDataTV indexPathForRowAtPoint:l_touchPoint];
    if (l_touchrow)
    {
        ttrProfileViewCustomCell * l_touchcell = (ttrProfileViewCustomCell*) [self.profileDataTV cellForRowAtIndexPath:l_touchrow];
        CGPoint l_pointincell = [self.profileDataTV convertPoint:l_touchPoint toView:l_touchcell];
        if ([l_touchcell checkIfProfileViewClicked:l_pointincell])
        {
            self.profileImageFrame = [l_touchcell getProfileViewFrame];
            self.profileImageCellRef = l_touchcell;
            [self.handlerDelegate takeUserProfilePictureFromFrame];
            //:[l_touchcell getProfileViewFrame] onView:l_touchcell];
        }
        else
            [self resignFirstResponder];
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
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0)
        return 0.1 * _rowHeight;
    else
        return 0;
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
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
        return [[_profileCellDims objectAtIndex:indexPath.row] floatValue];
    else
    {
        if ([self.handlerDelegate checkIfUserGroupImageAvailable:indexPath.row])
            return _groupCellheight*2.0;
        else
            return _groupCellheight;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
        return [_profileCellNames count];
    else
        return [_handlerDelegate getNumberOfGroupsOfThisUser];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * l_plainstreamcell = @"grp_plain_cell";
    static NSString * l_imgstreamcell = @"grp_image_cell";
    NSString * l_reqdcellid = l_plainstreamcell;
    NSDictionary * l_streamdict;
    if (indexPath.section==1)
    {
        l_streamdict = [self.handlerDelegate getUserStreamDataAtPosn:indexPath.row];
        if ([l_streamdict valueForKey:@"groupimg"])
            l_reqdcellid = l_imgstreamcell;
    }
    else
        l_reqdcellid = [_profileCellNames objectAtIndex:indexPath.row];
    
    ttrProfileViewCustomCell * l_newcell = [tableView dequeueReusableCellWithIdentifier:l_reqdcellid];
    if (!l_newcell)
        l_newcell = [[ttrProfileViewCustomCell alloc]
                     initWithStyle:UITableViewCellStyleDefault
                     reuseIdentifier:l_reqdcellid
                     withDelegate:self.handlerDelegate];
    [l_newcell setDisplayValuesAtPosn:indexPath.row andStreamDict:l_streamdict];
    return l_newcell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
    {
        if ([[_profileCellNames objectAtIndex:indexPath.row] isEqualToString:@"friends"])
        {
            [self.handlerDelegate showFriendsListForUser];
        }
        else if ([[_profileCellNames objectAtIndex:indexPath.row] isEqualToString:@"followers"])
        {
            [self.handlerDelegate showFollowersListForUser];
        }
    }
}

@end

@interface ttrProfileViewCustomCell()<UITextViewDelegate>
{
    UIImageView * _profileView, * _grpImgView;
    UILabel * _dispLblField1, * _dispLblField2;
    UITextField * _dispTxtField1;
    UITextView * _dispTxtView1;
    NSInteger _posnNo;
    UIButton * _btnAddBookCheck;
    id<ttrProfileViewDelegate> _handlerDelegate;
    NSDictionary * _streamDict;
    UILabel * _lblusername, * _lblgrptitle, * _lbldescription, * _lbltimebefore;
    UIButton * _btncomments, * _btnpin, * _btnshare;
    UILabel * _lblcomments, * _lblpin, * lblshare; //, * _lbltimediff;
    NSDateFormatter * _utcDateFormatter;
}

@end

@implementation ttrProfileViewCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDelegate:(id<ttrProfileViewDelegate>) p_delegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _handlerDelegate = p_delegate;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAccessoryType:UITableViewCellAccessoryNone];
        _utcDateFormatter = [[NSDateFormatter alloc] init];
        [_utcDateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss 'GMT'"];
        [_utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if ([self.reuseIdentifier isEqualToString:@"usernameimage"])
    {
        [self drawUserNameImageCell:rect];
    }
    else if ([self.reuseIdentifier isEqualToString:@"friendsfollowers"])
    {
        [self drawFriendsFollowersCell:rect];
        [self displayRecordInformation];
    }
    else if ([self.reuseIdentifier isEqualToString:@"followers"])
    {
        [self drawBottomLine:rect];
        [self drawFollowFriendsCell:@"Followers" onRect:rect];
    }
    else if ([self.reuseIdentifier isEqualToString:@"friends"])
    {
        [self drawFollowFriendsCell:@"Friends" onRect:rect];
    }
    else if ([self.reuseIdentifier rangeOfString:@"plain"].location!=NSNotFound)  // plain cell
    {
        [self drawPlainCell:rect];
        [self displayStreamDictValues];
    }
    else if ([self.reuseIdentifier rangeOfString:@"image"].location!=NSNotFound) // image cell
    {
        [self drawPlainCell:rect];
        [self drawGroupImage:rect];
        [self displayStreamDictValues];
    }
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self layoutIfNeeded];
    [self displayRecordInformation];
}


- (void) drawGroupImage:(CGRect) p_rect
{
    _grpImgView = [UIImageView new];
    _grpImgView.translatesAutoresizingMaskIntoConstraints = NO;
    [_grpImgView setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:0.97]];
    [self addSubview:_grpImgView];
    
    CGFloat l_descimgheight = p_rect.size.height / 2;
    
    [_grpImgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[gi(gi_h)]" options:0 metrics:@{@"gi_h":@(l_descimgheight)} views:@{@"gi":_grpImgView}]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_grpImgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-20.0)],[NSLayoutConstraint constraintWithItem:_grpImgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:(0.0)],[NSLayoutConstraint constraintWithItem:_grpImgView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:2.0 constant:(-l_descimgheight/2-20.0)]]];
}

- (void) drawPlainCell:(CGRect) p_rect
{
    NOPARAMCALLBACK l_drawLines =
    ^{
        CGContextRef l_ctx = UIGraphicsGetCurrentContext();
        CGMutablePathRef l_pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(l_pathRef, NULL, 0, 0);
        CGPathAddLineToPoint(l_pathRef, NULL, p_rect.size.width,  0);
        CGPathAddLineToPoint(l_pathRef, NULL, p_rect.size.width,  5);
        CGPathAddLineToPoint(l_pathRef, NULL, 0,  5);
        CGPathCloseSubpath(l_pathRef);
        CGContextAddPath(l_ctx, l_pathRef);
        CGContextSetFillColorWithColor(l_ctx, [UIColor colorWithRed:0.5 green:0.7 blue:0.9 alpha:1.0].CGColor);
        CGContextFillPath(l_ctx);
        CGPathRelease(l_pathRef);
        
        CGContextSetLineWidth(l_ctx, 2.0);
        CGContextSetStrokeColorWithColor(l_ctx, [UIColor lightGrayColor].CGColor);
        CGContextMoveToPoint(l_ctx, 0  , p_rect.size.height-20.0);
        CGContextAddLineToPoint(l_ctx, p_rect.size.width, p_rect.size.height-20.0);
        CGContextStrokePath(l_ctx);
        
        // drawing comments
        CGMutablePathRef l_cmtpathRef = CGPathCreateMutable();
        CGPathMoveToPoint(l_cmtpathRef, NULL, 10.0, p_rect.size.height - 7.0);
        CGPathAddLineToPoint(l_cmtpathRef, NULL, 10.0, p_rect.size.height - 13.0);
        CGPathAddArc(l_cmtpathRef, NULL, 12.0, p_rect.size.height - 13.0, 2.0, M_PI, 3.0 * M_PI_2, NO);
        CGPathAddLineToPoint(l_cmtpathRef, NULL, 20.0, p_rect.size.height - 15.0);
        CGPathAddArc(l_cmtpathRef, NULL, 20.0, p_rect.size.height - 13.0, 2.0, 3.0 * M_PI_2, 2.0 * M_PI, NO);
        CGPathAddLineToPoint(l_cmtpathRef, NULL, 22.0, p_rect.size.height - 12.0);
        CGPathAddLineToPoint(l_cmtpathRef, NULL, 25.0, p_rect.size.height - 10.0);
        CGPathAddLineToPoint(l_cmtpathRef, NULL, 22.0, p_rect.size.height - 8.0);
        CGPathAddLineToPoint(l_cmtpathRef, NULL, 22.0, p_rect.size.height - 7.0);
        CGPathAddArc(l_cmtpathRef, NULL, 20.0, p_rect.size.height - 7.0, 2.0, 0, M_PI_2, NO);
        CGPathAddLineToPoint(l_cmtpathRef, NULL, 12.0, p_rect.size.height - 5.0);
        CGPathAddArc(l_cmtpathRef, NULL, 12.0, p_rect.size.height - 7.0, 2.0, M_PI_2, M_PI, NO);
        CGPathCloseSubpath(l_cmtpathRef);
        CGContextAddPath(l_ctx, l_cmtpathRef);
        CGContextSetFillColorWithColor(l_ctx, [UIColor lightGrayColor].CGColor);
        CGContextFillPath(l_ctx);
        CGPathRelease(l_cmtpathRef);
        
        //drawing pin
        CGMutablePathRef l_pinpathRef = CGPathCreateMutable();
        CGPathMoveToPoint(l_pinpathRef, NULL, p_rect.size.width / 2.0 - 12.0, p_rect.size.height - 12.5);
        CGPathAddArc(l_pinpathRef, NULL, p_rect.size.width / 2.0 - 9.5 , p_rect.size.height - 12.5, 2.5, M_PI, 3.0 * M_PI, NO);
        CGPathCloseSubpath(l_pinpathRef);
        CGContextAddPath(l_ctx, l_pinpathRef);
        CGContextSetFillColorWithColor(l_ctx, [UIColor lightGrayColor].CGColor);
        CGContextFillPath(l_ctx);
        CGPathRelease(l_pinpathRef);
        
        CGContextSetLineWidth(l_ctx, 1.0);
        CGContextMoveToPoint(l_ctx, p_rect.size.width/2.0 - 9.5, p_rect.size.height-12.5);
        CGContextAddLineToPoint(l_ctx, p_rect.size.width/2.0 - 9.5, p_rect.size.height-5.0);
        CGContextStrokePath(l_ctx);
        
        UIImage * l_shareimg = [UIImage imageNamed:@"share"];
        [l_shareimg drawInRect:CGRectMake(p_rect.size.width-58, p_rect.size.height-15,10.0, 10.0)];
    };
    
    if (_profileView) {
        l_drawLines();
        return;
    }
    
    _profileView = [UIImageView new];
    _profileView.image = [UIImage imageNamed:@"nophoto"];
    _profileView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_profileView];
    [_profileView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[pv(40)]" options:0 metrics:nil views:@{@"pv":_profileView}]];
    [_profileView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pv(40)]" options:0 metrics:nil views:@{@"pv":_profileView}]];
    //[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[pv]" options:0 metrics:nil views:@{@"pv":_profileView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[pv]" options:0 metrics:nil views:@{@"pv":_profileView}]];
    
    _lblusername = [ttrDefaults getStandardLabelWithText:@"user name"];
    [self addSubview:_lblusername];
    _lblusername.font = [UIFont systemFontOfSize:10.0f];
    
    [_lblusername addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[name(12)]" options:0 metrics:nil views:@{@"name":_lblusername}]];
    //[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[name]" options:0 metrics:nil views:@{@"name":_lblusername}]];
    _lblusername.textColor = [UIColor grayColor];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_lblusername attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-110.0)]]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[pv]-10-[name]" options:0 metrics:nil views:@{@"name":_lblusername,@"pv":_profileView}]];
    [_lblusername sizeToFit];
    
    _lbltimebefore = [ttrDefaults getStandardLabelWithText:@""];
    [self addSubview:_lbltimebefore];
    _lbltimebefore.font = [UIFont systemFontOfSize:10.0f];
    //_lbltimebefore.backgroundColor = [UIColor redColor];
    [_lbltimebefore addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[time(12)]" options:0 metrics:nil views:@{@"time":_lbltimebefore}]];
    [_lbltimebefore addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[time(40)]" options:0 metrics:nil views:@{@"time":_lbltimebefore}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[time]" options:0 metrics:nil views:@{@"time":_lbltimebefore}]];
    _lbltimebefore.textColor = [UIColor grayColor];
    _lbltimebefore.textAlignment = NSTextAlignmentRight;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[pv]-10-[name][time]" options:0 metrics:nil views:@{@"name":_lblusername,@"pv":_profileView,@"time":_lbltimebefore}]];
    [_lblusername sizeToFit];
    
    _lblgrptitle = [ttrDefaults getStandardLabelWithText:@"group title"];
    [self addSubview:_lblgrptitle];
    _lblgrptitle.font = [UIFont boldSystemFontOfSize:10.0f];
    [_lblgrptitle addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[title(15)]" options:0 metrics:nil views:@{@"title":_lblgrptitle}]];
    //[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[name][title]" options:0 metrics:nil views:@{@"title":_lblgrptitle,@"name":_lblusername}]];
    _lblgrptitle.textColor = [UIColor blackColor];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_lblgrptitle attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-70.0)],[NSLayoutConstraint constraintWithItem:_lblgrptitle attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_lblusername attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]]];
    [_lblgrptitle sizeToFit];
    
    _lbldescription = [ttrDefaults getStandardLabelWithText:@"description"];
    [self addSubview:_lbldescription];
    _lbldescription.font = [UIFont systemFontOfSize:10.0f];
    
    [_lbldescription addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[desc(13)]" options:0 metrics:nil views:@{@"desc":_lbldescription}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[name][title][desc]" options:0 metrics:nil views:@{@"title":_lblgrptitle,@"name":_lblusername,@"desc":_lbldescription}]];
    _lbldescription.textColor = [UIColor grayColor];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_lbldescription attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-70.0)],[NSLayoutConstraint constraintWithItem:_lbldescription attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_lblusername attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]]];
    [_lbldescription sizeToFit];
    
    _btncomments = [ttrDefaults getStandardButton];
    [_btncomments setBackgroundColor:[UIColor clearColor]];
    _btncomments.translatesAutoresizingMaskIntoConstraints = NO;
    //[_btncomments setUserInteractionEnabled:NO];
    [_btncomments setTitle:@"0" forState:UIControlStateNormal];
    [_btncomments setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _btncomments.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [_btncomments.titleLabel sizeToFit];
    //[_btncomments addTarget:self action:@selector(addCommentToGroup) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btncomments];
    [_btncomments addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bc(10)]" options:0 metrics:nil views:@{@"bc":_btncomments}]];
    [_btncomments addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[bc(10)]" options:0 metrics:nil views:@{@"bc":_btncomments}]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_btncomments attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_profileView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:15.0],[NSLayoutConstraint constraintWithItem:_btncomments attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:2.0 constant:(-10.0)]]];
    
    _btnpin = [ttrDefaults getStandardButton];
    [_btnpin setBackgroundColor:[UIColor clearColor]];
    _btnpin.translatesAutoresizingMaskIntoConstraints = NO;
    [_btnpin setUserInteractionEnabled:NO];
    [_btnpin setTitle:@"Pin" forState:UIControlStateNormal];
    [_btnpin setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _btnpin.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [_btnpin.titleLabel sizeToFit];
    [self addSubview:_btnpin];
    [_btnpin addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bp(10)]" options:0 metrics:nil views:@{@"bp":_btnpin}]];
    [_btnpin addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[bp(20)]" options:0 metrics:nil views:@{@"bp":_btnpin}]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_btnpin attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:3.5],[NSLayoutConstraint constraintWithItem:_btnpin attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:2.0 constant:(-10.0)]]];
    
    _btnshare = [ttrDefaults getStandardButton];
    [_btnshare setBackgroundColor:[UIColor clearColor]];
    _btnshare.translatesAutoresizingMaskIntoConstraints = NO;
    [_btnshare setUserInteractionEnabled:NO];
    [_btnshare setTitle:@"Share" forState:UIControlStateNormal];
    [_btnshare setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _btnshare.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [_btnshare.titleLabel sizeToFit];
    [self addSubview:_btnshare];
    [_btnshare addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bs(10)]" options:0 metrics:nil views:@{@"bs":_btnshare}]];
    [_btnshare addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[bs(35)]" options:0 metrics:nil views:@{@"bs":_btnshare}]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_btnshare attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:2.0 constant:(-30.0)],[NSLayoutConstraint constraintWithItem:_btnshare attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:2.0 constant:(-10.0)]]];
    
    l_drawLines();
}

- (void) drawBottomLine:(CGRect) p_rect
{
    CGContextRef l_ctxref = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(l_ctxref, 0.5);
    CGContextSetStrokeColorWithColor(l_ctxref, [UIColor lightGrayColor].CGColor);
    CGContextMoveToPoint(l_ctxref, 0  , p_rect.size.height-1.0);
    CGContextAddLineToPoint(l_ctxref, p_rect.size.width, p_rect.size.height-1.0);
    CGContextStrokePath(l_ctxref);
    
}

- (void) drawFriendsFollowersCell:(CGRect) p_rect
{
    [self drawBottomLine:p_rect];
    CGContextRef l_ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef l_pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(l_pathRef, NULL, p_rect.size.width/2.0-3.0, p_rect.size.height/2.0);
    CGPathAddLineToPoint(l_pathRef, NULL, p_rect.size.width/2.0, p_rect.size.height/2.0-3.0);
    CGPathAddLineToPoint(l_pathRef, NULL, p_rect.size.width/2.0+3.0, p_rect.size.height/2.0);
    CGPathAddLineToPoint(l_pathRef, NULL, p_rect.size.width/2.0, p_rect.size.height/2.0+3.0);
    //CGPathAddArc(l_pathRef, NULL, p_rect.size.width/2.0, p_rect.size.height/2.0, 2.0, -M_PI, M_PI, false);
    CGPathCloseSubpath(l_pathRef);
    CGContextAddPath(l_ctx, l_pathRef);
    CGContextSetFillColorWithColor(l_ctx, [UIColor grayColor].CGColor);
    CGContextFillPath(l_ctx);
    CGPathRelease(l_pathRef);
    
    if (_dispLblField1) {
        return;
    }

    _dispLblField1 = [ttrDefaults getStandardLabelWithText:@"0 Followers"];
    [self addSubview:_dispLblField1];
    _dispLblField1.textAlignment = NSTextAlignmentRight;
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispLblField1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.5 constant:(-10.0)],[NSLayoutConstraint constraintWithItem:_dispLblField1 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:0.5 constant:(-5.0)],[NSLayoutConstraint constraintWithItem:_dispLblField1 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:_dispLblField1 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-2.0)]]];

    _dispLblField2 = [ttrDefaults getStandardLabelWithText:@"0 Friends"];
    [self addSubview:_dispLblField2];
    _dispLblField2.textAlignment = NSTextAlignmentLeft;
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.5 constant:(-10.0)],[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.5 constant:5.0],[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0],[NSLayoutConstraint constraintWithItem:_dispLblField2 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-2.0)]]];
}

- (void) drawFollowFriendsCell:(NSString*) p_dispText onRect:(CGRect) p_rect
{
    if (_dispLblField1) {
        return;
    }
    
    _dispLblField1 = [ttrDefaults getStandardLabelWithText:p_dispText];
    [self addSubview:_dispLblField1];
    _dispLblField1.textAlignment = NSTextAlignmentLeft;
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispLblField1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-20.0)],[NSLayoutConstraint constraintWithItem:_dispLblField1 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0],[NSLayoutConstraint constraintWithItem:_dispLblField1 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0],[NSLayoutConstraint constraintWithItem:_dispLblField1 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-2.0)]]];
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
}

- (void) drawUserNameImageCell:(CGRect) p_rect
{
    NOPARAMCALLBACK l_drawLines =
    ^{
        CGContextRef l_ctxref = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(l_ctxref, 0.5);
        CGContextSetStrokeColorWithColor(l_ctxref, [UIColor lightGrayColor].CGColor);
        CGContextMoveToPoint(l_ctxref, 0  , p_rect.size.height-1.0);
        CGContextAddLineToPoint(l_ctxref, p_rect.size.width, p_rect.size.height-1.0);
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
    [_profileView.layer setBorderWidth:1.0f];
    _profileView.layer.cornerRadius = 5.0f;
    [_profileView.layer setBorderColor:[UIColor clearColor].CGColor];
    _profileView.layer.masksToBounds=YES;
    
    [_profileView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[pv(50)]" options:0 metrics:nil views:@{@"pv":_profileView}]];
    [_profileView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pv(50)]" options:0 metrics:nil views:@{@"pv":_profileView}]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_profileView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]]];
    
    _dispLblField1 = [ttrDefaults getStandardLabelWithText:@"user name"];
    [self addSubview:_dispLblField1];
    _dispLblField1.font = [UIFont boldSystemFontOfSize:16.0f];
    _dispLblField1.textAlignment = NSTextAlignmentCenter;
    [_dispLblField1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[df1(25)]" options:0 metrics:nil views:@{@"df1":_dispLblField1}]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispLblField1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-40.0)],[NSLayoutConstraint constraintWithItem:_dispLblField1 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]]];

    _dispTxtView1 = [UITextView new];
    _dispTxtView1.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_dispTxtView1];
    _dispTxtView1.text = @"Enter Status message here....";
    _dispTxtView1.textAlignment = NSTextAlignmentCenter;
    [_dispTxtView1 setBackgroundColor:[UIColor clearColor]];
    _dispTxtView1.delegate = self;
    _dispTxtView1.font = [UIFont systemFontOfSize:11.0f];
    [_dispTxtView1.layer setBorderColor:[UIColor clearColor].CGColor];
    _dispTxtView1.showsVerticalScrollIndicator = NO;
    //[_dispTxtView1 setUserInteractionEnabled:NO];
    [_dispTxtView1 setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_dispTxtView1 setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    [_dispTxtView1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[dtv1(30)]" options:0 metrics:nil views:@{@"dtv1":_dispTxtView1}]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispTxtView1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-10.0)],[NSLayoutConstraint constraintWithItem:_dispTxtView1 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]]];
    
    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:|-5-[pv]-5-[df1]-5-[dtv1]"
      options:0
      metrics:nil
      views:@{@"pv":_profileView,
              @"df1":_dispLblField1,
              @"dtv1":_dispTxtView1}]];
    l_drawLines();
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

- (void) setDisplayValuesAtPosn:(NSInteger) p_posnNo andStreamDict:(NSDictionary*) p_streamDict
{
    _posnNo = p_posnNo;
    _streamDict = p_streamDict;
    if (_streamDict)
    {
        if (_profileView) {
            [self displayStreamDictValues];
        }
    }
    else
        [self displayRecordInformation];
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

- (UIImage*) getProfileImage
{
    return _profileView.image;
}

- (void) displayStreamDictValues
{
    _lblusername.text = [_streamDict valueForKey:@"username"];
    _lblgrptitle.text = [_streamDict valueForKey:@"title"];
    _lbldescription.text = [_streamDict valueForKey:@"description"];
    _profileView.image = [UIImage imageNamed:@"nophoto"];
    _grpImgView.image = nil;
    NSDate * l_utcdate = [_utcDateFormatter dateFromString:[_streamDict valueForKey:@"updatedAt"]];
    NSTimeInterval l_timeseconds = [[NSDate date] timeIntervalSinceDate:l_utcdate];
    NSInteger l_mindiff =l_timeseconds / 60.0;
    NSInteger l_hrsdiff = l_timeseconds / (60.0*60.0);
    NSInteger l_daydiff = l_timeseconds / (24.0*60.0*60.0);
    if (l_daydiff>0)
        _lbltimebefore.text = [NSString stringWithFormat:@"%dd", (int) l_daydiff];
    else if (l_hrsdiff>0)
        _lbltimebefore.text =[NSString stringWithFormat:@"%dh", (int) l_hrsdiff];
    else
        _lbltimebefore.text =[NSString stringWithFormat:@"%dm", (int) l_mindiff];
    
    if ([_streamDict valueForKey:@"userprofile"])
    {
        [[ttrRESTProxy alloc]
         initDatawithAPIType:@"GETFILE"
         andInputParams:@{@"filename":[_streamDict valueForKey:@"userprofile"]}
         andReturnMethod:^(NSDictionary * p_imgfileinfo)
         {
             _profileView.image = [UIImage imageWithData:[p_imgfileinfo valueForKey:@"resultdata"]];
         }];
    }
    if ([_streamDict valueForKey:@"groupimg"])
    {
        [[ttrRESTProxy alloc]
         initDatawithAPIType:@"GETFILE"
         andInputParams:@{@"filename":[_streamDict valueForKey:@"groupimg"]}
         andReturnMethod:^(NSDictionary * p_imgfileinfo)
         {
             _grpImgView.image = [UIImage imageWithData:[p_imgfileinfo valueForKey:@"resultdata"]];
         }];
    }
}


- (void) displayRecordInformation
{
    if ([self.reuseIdentifier isEqualToString:@"usernameimage"])
    {
        if (_dispLblField1)
        {
            NSDictionary * l_getprofileimgdata = [_handlerDelegate getUserProfileData];
            if (l_getprofileimgdata)
            {
                _dispLblField1.text = [l_getprofileimgdata valueForKey:@"username"];
                if ([l_getprofileimgdata valueForKey:@"statusmsg"])
                    _dispTxtView1.text = [l_getprofileimgdata valueForKey:@"statusmsg"];
                else
                    _dispTxtView1.text = @"Enter Status message here....";
                _profileView.image = [UIImage imageNamed:@"nophoto"];
                if ([l_getprofileimgdata valueForKey:@"userprofile"])
                {
                    [[ttrRESTProxy alloc]
                     initDatawithAPIType:@"GETFILE"
                     andInputParams:@{@"filename":[l_getprofileimgdata valueForKey:@"userprofile"]}
                     andReturnMethod:^(NSDictionary * p_imgfileinfo)
                     {
                         _profileView.image = [UIImage imageWithData:[p_imgfileinfo valueForKey:@"resultdata"]];
                     }];
                }
            }
        }
    }
    else if ([self.reuseIdentifier isEqualToString:@"friendsfollowers"])
    {
        if (_dispLblField1)
        {
            _dispLblField1.text = [NSString stringWithFormat:@"%d Followers", (int) [_handlerDelegate getNumberOfFollowersOfUser]];
            _dispLblField2.text = [NSString stringWithFormat:@"%d Friends", (int) [_handlerDelegate getnumberOfFriendsOfUser]];
        }
    }
}

- (BOOL)resignFirstResponder
{
    if (_dispTxtView1)
        return [_dispTxtView1 resignFirstResponder];
    else
        return YES;
}

#pragma textview delegates to enable disable keyboard notifications

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Enter Status message here...."])
    {
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSString * l_enteredText = textView.text;
    l_enteredText = [l_enteredText stringByReplacingOccurrencesOfString:@"Enter Status message here...." withString:@""];
    l_enteredText = [l_enteredText stringByReplacingOccurrencesOfString:@" " withString:@""];
    l_enteredText = [l_enteredText stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if ([l_enteredText length]==0)
    {
        textView.text = @"Enter Status message here....";
    }
    else
        [_handlerDelegate updateNewUserStatusMessage:l_enteredText];
}

@end
