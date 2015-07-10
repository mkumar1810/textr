//
//  ttrHomeStreamsView.m
//  TexTr
//
//  Created by Mohan Kumar on 26/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrHomeStreamsView.h"
#import "ttrDefaults.h"
#import "ttrRESTProxy.h"

@interface ttrHomeStreamsView()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate>
{
    CGFloat _rowHeight;
    CGSize _keyBoardSize;
}

@property (nonatomic,strong) UITableView * streamViewTV;
@property (nonatomic,strong) UISearchBar * streamSearchBar;

@end

@implementation ttrHomeStreamsView

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
    if (self.streamViewTV)
        return;
    self.streamViewTV = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.streamViewTV.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.streamViewTV];
    self.streamViewTV.dataSource = self;
    self.streamViewTV.delegate = self;
    [self.streamViewTV setSeparatorColor:[UIColor clearColor]];
    [self.streamViewTV setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.streamViewTV setBackgroundColor:[UIColor clearColor]];
    self.streamViewTV.contentInset = UIEdgeInsetsZero;
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.streamViewTV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:1.0],[NSLayoutConstraint constraintWithItem:self.streamViewTV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-44.0)],[NSLayoutConstraint constraintWithItem:self.streamViewTV attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.streamViewTV attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:(-22.0)]]];
    self.streamSearchBar = [UISearchBar new];
    self.streamSearchBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.streamSearchBar];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sb]" options:0 metrics:nil views:@{@"sb":self.streamSearchBar}]];
    [self.streamSearchBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sb(44)]" options:0 metrics:nil views:@{@"sb":self.streamSearchBar}]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.streamSearchBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.streamSearchBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.streamViewTV attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]]];
    self.streamSearchBar.placeholder = @"Search groups, followers and friends";
    self.streamSearchBar.delegate = self;
    self.streamSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.streamSearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.scrollEnabled = NO;
    [self layoutIfNeeded];
}

- (void) showAlertMessage:(NSString*) p_showMessage
{
    UIAlertView *l_alert = [[UIAlertView alloc] initWithTitle:@"" message:p_showMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [l_alert show];
}

- (void) reloadAllTheStreams
{
    [self.streamViewTV reloadData];
}

- (void)setDataKeyBoardSize:(CGSize)p_keyboardSize
{
    if (CGSizeEqualToSize(p_keyboardSize, _keyBoardSize)==NO)
    {
        _keyBoardSize = p_keyboardSize;
    }
    if (CGSizeEqualToSize(p_keyboardSize, CGSizeZero))
    {
        [UIView animateWithDuration:0.4
                         animations:^{
                             [self setContentOffset:CGPointMake(0, 0)];
                         }];
        return;
    }
    CGRect l_inputfieldbounds = [self.streamSearchBar convertRect:self.streamSearchBar.bounds toView:self];
    CGRect l_superbounds = self.bounds;
    if ((l_inputfieldbounds.origin.y+l_inputfieldbounds.size.height+10.0)>(l_superbounds.size.height-_keyBoardSize.height))
    {
        CGFloat l_offsetheight = (l_inputfieldbounds.origin.y+l_inputfieldbounds.size.height) - (l_superbounds.size.height-_keyBoardSize.height)+10.0;
        if (l_offsetheight!=self.contentOffset.y)
        {
            [UIView animateWithDuration:0.4
                             animations:^{
                                 [self setContentOffset:CGPointMake(0, l_offsetheight)];
                             }];
        }
    }
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
    return 0; //.1 * _rowHeight;
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
    if ([self.handlerDelegate checkIfGroupImageAvailable:indexPath.row])
        return _rowHeight*2.0;
    else
        return _rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.handlerDelegate getNumberOfStreams];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * l_plainstreamcell = @"grp_plain_cell";
    static NSString * l_imgstreamcell = @"grp_image_cell";
    NSString * l_reqdcellid = l_plainstreamcell;
    NSDictionary * l_streamdict = [self.handlerDelegate getStreamDataAtPosn:indexPath.row];
    if ([l_streamdict valueForKey:@"groupimg"])
        l_reqdcellid = l_imgstreamcell;
    
    ttrHomeStreamsViewCustomCell * l_newcell = [tableView dequeueReusableCellWithIdentifier:l_reqdcellid];
    if (!l_newcell)
        l_newcell = [[ttrHomeStreamsViewCustomCell alloc]
                     initWithStyle:UITableViewCellStyleSubtitle
                     reuseIdentifier:l_reqdcellid
                     onPosn:indexPath.row
                     andDataDelegate:self.handlerDelegate];
    [l_newcell setDisplayValuesAtPosn:indexPath.row andStreamDict:l_streamdict];
    return l_newcell;
}

#pragma  search bar customer search string related delegates

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
    searchBar.text = nil;
    [self.handlerDelegate generateStreamsForSearchStr:@""];
}

// called when Search (in our case “Done”) button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    NSString * l_searchstr = searchBar.text;
    if (!l_searchstr)
        l_searchstr = @"";
    [searchBar resignFirstResponder];
    [self.handlerDelegate generateStreamsForSearchStr:l_searchstr];
}

@end

@interface ttrHomeStreamsViewCustomCell()
{
    UIImageView * _profileView, * _grpImgView;
    UILabel * _lblusername, * _lblgrptitle, * _lbldescription, * _lbltimebefore;
    NSInteger _posnNo;
    UIButton * _btncomments, * _btnpin, * _btnshare;
    UILabel * _lblcomments, * _lblpin, * lblshare; //, * _lbltimediff;
    id<ttrHomeStreamsViewDelegate> _dataDelegate;
    NSDictionary * _streamDict;
    NSDateFormatter * _utcDateFormatter;
}

@end

@implementation ttrHomeStreamsViewCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier onPosn:(NSInteger) p_posnNo andDataDelegate:(id<ttrHomeStreamsViewDelegate>) p_dataDelegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _posnNo = p_posnNo;
        _dataDelegate = p_dataDelegate;
        [self setBackgroundColor:[UIColor colorWithRed:0.94 green:0.97 blue:1.0 alpha:1.0]];
        _utcDateFormatter = [[NSDateFormatter alloc] init];
        [_utcDateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss 'GMT'"];
        [_utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if ([self.reuseIdentifier rangeOfString:@"plain"].location!=NSNotFound)  // plain cell
    {
        [self drawPlainCell:rect];
    }
    else if ([self.reuseIdentifier rangeOfString:@"image"].location!=NSNotFound) // image cell
    {
        [self drawPlainCell:rect];
        [self drawGroupImage:rect];
    }
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self layoutIfNeeded];
    [self displayValues];
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
    [_profileView.layer setBorderWidth:1.0f];
    _profileView.layer.cornerRadius = 5.0f;
    [_profileView.layer setBorderColor:[UIColor clearColor].CGColor];
    _profileView.layer.masksToBounds=YES;

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

- (void) setDisplayValuesAtPosn:(NSInteger) p_posnNo andStreamDict:(NSDictionary*) p_streamDict
{
    _posnNo = p_posnNo;
    _streamDict = p_streamDict;
    if (_profileView) {
        [self displayValues];
    }
}

- (void) displayValues
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

@end
