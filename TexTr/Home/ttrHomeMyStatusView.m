//
//  ttrHomeMyStatusView.m
//  TexTr
//
//  Created by Mohan Kumar on 30/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrHomeMyStatusView.h"
#import "ttrDefaults.h"
#import "ttrRESTProxy.h"

@interface ttrHomeMyStatusView()<UITableViewDataSource, UITableViewDelegate>
{
    CGFloat _rowHeight;
}

@property (nonatomic,strong) UITableView * myStatusViewTV;

@end

@implementation ttrHomeMyStatusView

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        [self setBackgroundColor:[UIColor colorWithRed:0.5 green:0.7 blue:0.9 alpha:1.0]];
        _rowHeight = 80.0f;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (self.myStatusViewTV)
        return;
    self.myStatusViewTV = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.myStatusViewTV.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.myStatusViewTV];
    self.myStatusViewTV.dataSource = self;
    self.myStatusViewTV.delegate = self;
    [self.myStatusViewTV setSeparatorColor:[UIColor clearColor]];
    [self.myStatusViewTV setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.myStatusViewTV setBackgroundColor:[UIColor clearColor]];
    self.myStatusViewTV.contentInset = UIEdgeInsetsZero;
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.myStatusViewTV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:1.0],[NSLayoutConstraint constraintWithItem:self.myStatusViewTV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.myStatusViewTV attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.myStatusViewTV attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]]];
    [self layoutIfNeeded];
}

- (void) showAlertMessage:(NSString*) p_showMessage
{
    UIAlertView *l_alert = [[UIAlertView alloc] initWithTitle:@"" message:p_showMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [l_alert show];
}

- (void) reloadAllMyStatusStreams
{
    [self.myStatusViewTV reloadData];
}

#pragma tableview delegates

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0; //.1 * _rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0)
        return 0; //.1 * _rowHeight;
    else
        return 40.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * l_hdrvw = [UIView new];
    [l_hdrvw setBackgroundColor:[UIColor clearColor]];
    return l_hdrvw;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.handlerDelegate getNumberOfMyStatusStream];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * l_followcellid = @"follow_cell";
    NSDictionary * l_mystatfeeddict = [self.handlerDelegate getMyStatusStreamDataAtPosn:indexPath.row];
    ttrHomeStatFeedViewCustomCell * l_newcell = [tableView dequeueReusableCellWithIdentifier:l_followcellid];
    if (!l_newcell)
        l_newcell = [[ttrHomeStatFeedViewCustomCell alloc]
                     initWithStyle:UITableViewCellStyleSubtitle
                     reuseIdentifier:l_followcellid
                     onPosn:indexPath.row];
    [l_newcell setDisplayValuesAtPosn:indexPath.row andMyStatusDict:l_mystatfeeddict];
    return l_newcell;
}

@end


@interface ttrHomeStatFeedViewCustomCell()
{
    UIImageView * _profileView;
    UILabel * _lblusername, * _lblgrptitle, * _lbldescription;
    NSInteger _posnNo;
    UIButton * _btncomments, * _btnpin, * _btnshare;
    UILabel * _lblcomments, * _lblpin, * lblshare, * _lbltimediff;
    NSDictionary * _statfeedDict;
}

@end

@implementation ttrHomeStatFeedViewCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier onPosn:(NSInteger) p_posnNo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _posnNo = p_posnNo;
        [self setBackgroundColor:[UIColor colorWithRed:0.94 green:0.97 blue:1.0 alpha:1.0]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self drawPlainCell:rect];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self layoutIfNeeded];
    [self displayValues];
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
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_lblusername attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-90.0)]]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[pv]-10-[name]" options:0 metrics:nil views:@{@"name":_lblusername,@"pv":_profileView}]];
    [_lblusername sizeToFit];
    
    _lblgrptitle = [ttrDefaults getStandardLabelWithText:@"group title"];
    [self addSubview:_lblgrptitle];
    _lblgrptitle.font = [UIFont boldSystemFontOfSize:12.0f];
    [_lblgrptitle addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[title(15)]" options:0 metrics:nil views:@{@"title":_lblgrptitle}]];
    //[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[name][title]" options:0 metrics:nil views:@{@"title":_lblgrptitle,@"name":_lblusername}]];
    _lblgrptitle.textColor = [UIColor blackColor];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_lblgrptitle attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-100.0)],[NSLayoutConstraint constraintWithItem:_lblgrptitle attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_lblusername attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]]];
    [_lblgrptitle sizeToFit];
    
    _lbldescription = [ttrDefaults getStandardLabelWithText:@"description"];
    [self addSubview:_lbldescription];
    _lbldescription.font = [UIFont systemFontOfSize:10.0f];
    
    [_lbldescription addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[desc(13)]" options:0 metrics:nil views:@{@"desc":_lbldescription}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[name][title][desc]" options:0 metrics:nil views:@{@"title":_lblgrptitle,@"name":_lblusername,@"desc":_lbldescription}]];
    _lbldescription.textColor = [UIColor grayColor];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_lbldescription attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-100.0)],[NSLayoutConstraint constraintWithItem:_lbldescription attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_lblusername attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]]];
    [_lbldescription sizeToFit];
    
    _btncomments = [ttrDefaults getStandardButton];
    [_btncomments setBackgroundColor:[UIColor clearColor]];
    _btncomments.translatesAutoresizingMaskIntoConstraints = NO;
    [_btncomments setUserInteractionEnabled:NO];
    [_btncomments setTitle:@"0" forState:UIControlStateNormal];
    [_btncomments setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _btncomments.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [_btncomments.titleLabel sizeToFit];
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

- (void) setDisplayValuesAtPosn:(NSInteger) p_posnNo andMyStatusDict:(NSDictionary*) p_myStatusDict
{
    _posnNo = p_posnNo;
    _statfeedDict = p_myStatusDict;
    if (_profileView) {
        [self displayValues];
    }
}

- (void) displayValues
{
    _lblusername.text = [_statfeedDict valueForKey:@"username"];
    _lblgrptitle.text = [_statfeedDict valueForKey:@"title"];
    _lbldescription.text = [_statfeedDict valueForKey:@"description"];
    _profileView.image = [UIImage imageNamed:@"nophoto"];
    if ([_statfeedDict valueForKey:@"userprofile"])
    {
        [[ttrRESTProxy alloc]
         initDatawithAPIType:@"GETFILE"
         andInputParams:@{@"filename":[_statfeedDict valueForKey:@"userprofile"]}
         andReturnMethod:^(NSDictionary * p_imgfileinfo)
         {
             _profileView.image = [UIImage imageWithData:[p_imgfileinfo valueForKey:@"resultdata"]];
         }];
    }
}

@end
