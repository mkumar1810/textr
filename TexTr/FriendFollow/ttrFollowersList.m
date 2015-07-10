//
//  ttrFollowersList.m
//  TexTr
//
//  Created by Mohan Kumar on 10/07/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrFollowersList.h"
#import "ttrDefaults.h"
#import "ttrCommonUtilities.h"
#import "ttrRESTProxy.h"

@interface ttrFollowersList()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    CGFloat _rowHeight;
    CGSize _keyBoardSize;
}

@property (nonatomic,strong) UITableView * followersTV;
@property (nonatomic,strong) UISearchBar * streamSearchBar;

@end

@implementation ttrFollowersList

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        [self setBackgroundColor:[UIColor clearColor]];
        _rowHeight = 60.0f;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Drawing code
    if (self.followersTV)
        return;
    self.followersTV = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.followersTV.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.followersTV];
    self.followersTV.dataSource = self;
    self.followersTV.delegate = self;
    [self.followersTV setSeparatorColor:[UIColor clearColor]];
    [self.followersTV setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.followersTV setBackgroundColor:[UIColor clearColor]];
    self.followersTV.contentInset = UIEdgeInsetsZero;
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.followersTV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:1.0],[NSLayoutConstraint constraintWithItem:self.followersTV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-44.0)],[NSLayoutConstraint constraintWithItem:self.followersTV attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.followersTV attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:(-22.0)]]];
    self.streamSearchBar = [UISearchBar new];
    self.streamSearchBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.streamSearchBar];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sb]" options:0 metrics:nil views:@{@"sb":self.streamSearchBar}]];
    [self.streamSearchBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sb(44)]" options:0 metrics:nil views:@{@"sb":self.streamSearchBar}]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.streamSearchBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.streamSearchBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.followersTV attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]]];
    self.streamSearchBar.placeholder = @"Search followers";
    self.streamSearchBar.delegate = self;
    self.streamSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.streamSearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self layoutIfNeeded];
    [self setScrollEnabled:NO];
}

- (void) reloadAllTheFollowersList
{
    [self.followersTV reloadData];
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
    return _rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.handlerDelegate getNumberOfFollowersForUser];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * l_reqdcellid = @"follower_cell";
    ttrFollowersListVwCustomCell * l_newcell = [tableView dequeueReusableCellWithIdentifier:l_reqdcellid];
    if (!l_newcell)
        l_newcell = [[ttrFollowersListVwCustomCell alloc]
                     initWithStyle:UITableViewCellStyleSubtitle
                     reuseIdentifier:l_reqdcellid
                     andDataDelegate:self.handlerDelegate];
    [l_newcell setDisplayValuesAtPosn:indexPath.row];
    return l_newcell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     
     */
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
    [self.handlerDelegate lookUpFollowersForSearchStr:@""];
}

// called when Search (in our case “Done”) button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    NSString * l_searchstr = searchBar.text;
    if (!l_searchstr)
        l_searchstr = @"";
    [searchBar resignFirstResponder];
    [self.handlerDelegate lookUpFollowersForSearchStr:l_searchstr];
}

@end

@interface ttrFollowersListVwCustomCell()
{
    NSInteger _posnNo;
    id<ttrFollowersListViewDelegate> _handlerDelegate;
    UIImageView * _profileView;
    UILabel * _lblusername,* _lblstatusmsg;
}

@end

@implementation ttrFollowersListVwCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andDataDelegate:(id<ttrFollowersListViewDelegate>)p_dataDelegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _handlerDelegate = p_dataDelegate;
        [self setBackgroundColor:[UIColor colorWithRed:0.94 green:0.97 blue:1.0 alpha:1.0]];
        [self setAccessoryType:UITableViewCellAccessoryNone];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    NOPARAMCALLBACK l_drawLines =
    ^{
        CGContextRef l_ctx = UIGraphicsGetCurrentContext();
        CGMutablePathRef l_pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(l_pathRef, NULL, 0, 0);
        CGPathAddLineToPoint(l_pathRef, NULL, rect.size.width,  0);
        CGPathAddLineToPoint(l_pathRef, NULL, rect.size.width,  5);
        CGPathAddLineToPoint(l_pathRef, NULL, 0,  5);
        CGPathCloseSubpath(l_pathRef);
        CGContextAddPath(l_ctx, l_pathRef);
        CGContextSetFillColorWithColor(l_ctx, [UIColor colorWithRed:0.5 green:0.7 blue:0.9 alpha:1.0].CGColor);
        CGContextFillPath(l_ctx);
        CGPathRelease(l_pathRef);
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
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[pv]" options:0 metrics:nil views:@{@"pv":_profileView}]];
    
    _lblusername = [ttrDefaults getStandardLabelWithText:@"user name"];
    [self addSubview:_lblusername];
    _lblusername.font = [UIFont boldSystemFontOfSize:15.0f];
    
    [_lblusername addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[name(20)]" options:0 metrics:nil views:@{@"name":_lblusername}]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_lblusername attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-60.0)]]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[pv]-10-[name]" options:0 metrics:nil views:@{@"name":_lblusername,@"pv":_profileView}]];
    [_lblusername sizeToFit];
    
    _lblstatusmsg = [ttrDefaults getStandardLabelWithText:@"status message"];
    [self addSubview:_lblstatusmsg];
    _lblstatusmsg.font = [UIFont systemFontOfSize:10.0f];
    
    [_lblstatusmsg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sm(20)]" options:0 metrics:nil views:@{@"sm":_lblstatusmsg}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[name][sm]" options:0 metrics:nil views:@{@"name":_lblusername,@"sm":_lblstatusmsg}]];
    _lblstatusmsg.textColor = [UIColor grayColor];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_lblstatusmsg attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-60.0)],[NSLayoutConstraint constraintWithItem:_lblstatusmsg attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_lblusername attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]]];
    [_lblstatusmsg sizeToFit];
    
    l_drawLines();
    [self layoutIfNeeded];
    UIView * l_vw = [UIView new];
    [l_vw setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundView:l_vw];
    [self displayValues];
}

- (void) setDisplayValuesAtPosn:(NSInteger) p_posnNo
{
    _posnNo = p_posnNo;
    if (_profileView) {
        [self displayValues];
    }
    
}

- (void) displayValues
{
    if (_profileView)
    {
        NSDictionary * l_frienddict = [_handlerDelegate getFollowerDictOfUserAtPosn:_posnNo];
        _lblusername.text = [l_frienddict valueForKey:@"username"];
        _lblstatusmsg.text = [l_frienddict valueForKey:@"statusmsg"];
        _profileView.image = [UIImage imageNamed:@"nophoto"];
        if ([l_frienddict valueForKey:@"userprofile"])
        {
            [[ttrRESTProxy alloc]
             initDatawithAPIType:@"GETFILE"
             andInputParams:@{@"filename":[l_frienddict valueForKey:@"userprofile"]}
             andReturnMethod:^(NSDictionary * p_imgfileinfo)
             {
                 _profileView.image = [UIImage imageWithData:[p_imgfileinfo valueForKey:@"resultdata"]];
             }];
        }
        
    }
}

@end

