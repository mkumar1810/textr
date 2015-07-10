//
//  ttrFriendFollowController.m
//  TexTr
//
//  Created by Mohan Kumar on 10/07/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrFriendFollowController.h"
#import "ttrRESTProxy.h"
#import "ttrFriendsListVw.h"
#import "ttrFollowersList.h"

@interface ttrFriendFollowController ()<ttrFriendsListViewDelegate, ttrFollowersListViewDelegate>
{
    NSArray * _friendsDataList;
    NSMutableArray * _friendsDatListFiltered;
    NSArray * _followersDataList;
    NSMutableArray * _followersDatListFiltered;
    NSString * _reqdUserObjectId;
    NSString * _currDispUser;
}

@property (nonatomic,strong) ttrFriendsListVw * friendsTV;
@property (nonatomic,strong) ttrFollowersList * followersTV;

@end

@implementation ttrFriendFollowController

- (void)awakeFromNib
{
    self.transitionType = horizontalWithBounce;
    //[self.view setBackgroundColor:[UIColor colorWithRed:0.94 green:0.97 blue:1.0 alpha:1.0]];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.5 green:0.7 blue:0.9 alpha:1.0]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDefaultItems];
    //[self setupMainViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardBecomesVisible:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardBecomesHidden:) name:UIKeyboardDidHideNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setUpDefaultItems
{
    [self.navBar setHidden:NO];
    self.navBar.items = @[self.navItem];
    self.navItem.leftBarButtonItem = self.bar_back_btn;
    self.navItem.rightBarButtonItem = self.bar_logo_btn ;
}

- (void) setupMainViewPosition:(UIView*) p_onView
{
    [self.view addSubview:p_onView];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:p_onView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:p_onView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-64.0)],[NSLayoutConstraint constraintWithItem:p_onView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:p_onView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:32.0]]];
    [self.view layoutIfNeeded];
}

- (void)initializeDataWithParams:(NSDictionary *)p_initParams
{
    NSString * l_apiname = nil;
    [self.view bringSubviewToFront:self.actView];
    [self.actView startAnimating];
    _reqdUserObjectId = [p_initParams valueForKey:@"profileid"];
    _currDispUser = [p_initParams valueForKey:@"usertype"];
    if ([_currDispUser isEqualToString:@"friends"])
    {
        self.friendsTV = [ttrFriendsListVw new];
        self.friendsTV.translatesAutoresizingMaskIntoConstraints=NO;
        self.friendsTV.handlerDelegate = self;
        [self setupMainViewPosition:self.friendsTV];
        self.navItem.title = @"Friends";
        l_apiname = @"GETFRIENDS";
    }
    else if ([_currDispUser isEqualToString:@"followers"])
    {
        self.followersTV = [ttrFollowersList new];
        self.followersTV.translatesAutoresizingMaskIntoConstraints=NO;
        self.followersTV.handlerDelegate = self;
        [self setupMainViewPosition:self.followersTV];
        self.navItem.title = @"Followers";
        l_apiname = @"GETFOLLOWERS";
    }
    
    
    [[ttrRESTProxy alloc]
     initDatawithAPIType:l_apiname
     andInputParams:@{@"userobjectid":_reqdUserObjectId}
     andReturnMethod:^(NSDictionary * p_userprofiledata)
     {
         NSDictionary * l_recdinfo = [NSJSONSerialization
                                      JSONObjectWithData:[p_userprofiledata valueForKey:@"resultdata"]
                                      options:NSJSONReadingMutableLeaves
                                      error:NULL];
         if ([_currDispUser isEqualToString:@"friends"])
         {
             _friendsDataList = (NSArray*) [l_recdinfo valueForKey:@"result"];
             _friendsDatListFiltered = [NSMutableArray arrayWithArray:_friendsDataList];
             if (self.friendsTV)
             {
                 [self.friendsTV reloadAllTheFriendsList];
             }
         }
         else if ([_currDispUser isEqualToString:@"followers"])
         {
             _followersDataList = (NSArray*) [l_recdinfo valueForKey:@"result"];
             _followersDatListFiltered = [NSMutableArray arrayWithArray:_followersDataList];
             if (self.followersTV)
             {
                 [self.followersTV reloadAllTheFollowersList];
             }
         }
         [self.actView stopAnimating];
     }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma keyboard related notificaiton handlers

- (void) keyboardBecomesVisible:(NSNotification*) p_visibeNotification
{
    NSDictionary * l_userInfo = [p_visibeNotification userInfo];
    CGSize l_keyBoardSize = [[l_userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if ([_currDispUser isEqualToString:@"friends"])
        [self.friendsTV setDataKeyBoardSize:l_keyBoardSize];
    else if ([_currDispUser isEqualToString:@"followers"])
        [self.followersTV setDataKeyBoardSize:l_keyBoardSize];
}

- (void) keyboardBecomesHidden:(NSNotification*) p_hidingNotification
{
    if ([_currDispUser isEqualToString:@"friends"])
        [self.friendsTV setDataKeyBoardSize:CGSizeZero];
    else if ([_currDispUser isEqualToString:@"followers"])
        [self.followersTV setDataKeyBoardSize:CGSizeZero];
}

#pragma friends list displaying delegates

- (NSInteger) getNumberOfFriendsForUser
{
    return [_friendsDatListFiltered count];
}

- (NSDictionary*) getFriendDictOfUserAtPosn:(NSInteger) p_posnNo
{
    return [_friendsDatListFiltered objectAtIndex:p_posnNo];
}

- (void) lookUpFriendsForSearchStr:(NSString*) p_searchStr
{
    if (p_searchStr!=nil && [p_searchStr length]>0)
    {
        NSPredicate * l_friendsearchfetch =
        [NSPredicate predicateWithFormat:@"username CONTAINS[c] %@ || statusmsg CONTAINS[c] %@ ", p_searchStr, p_searchStr];
        _friendsDatListFiltered = [NSMutableArray arrayWithArray:[_friendsDataList filteredArrayUsingPredicate:l_friendsearchfetch]];
    }
    else
    {
        _friendsDatListFiltered = [NSMutableArray arrayWithArray:_friendsDataList];
    }
    [self.friendsTV reloadAllTheFriendsList];
}

#pragma followers list displaying delegates

- (NSInteger) getNumberOfFollowersForUser
{
    return [_followersDatListFiltered count];
}

- (NSDictionary*) getFollowerDictOfUserAtPosn:(NSInteger) p_posnNo
{
    return [_followersDatListFiltered objectAtIndex:p_posnNo];
}

- (void) lookUpFollowersForSearchStr:(NSString*) p_searchStr
{
    if (p_searchStr!=nil && [p_searchStr length]>0)
    {
        NSPredicate * l_followersearchfetch =
        [NSPredicate predicateWithFormat:@"username CONTAINS[c] %@ || statusmsg CONTAINS[c] %@ ", p_searchStr, p_searchStr];
        _followersDatListFiltered = [NSMutableArray arrayWithArray:[_followersDataList filteredArrayUsingPredicate:l_followersearchfetch]];
    }
    else
    {
        _followersDatListFiltered = [NSMutableArray arrayWithArray:_followersDataList];
    }
    [self.followersTV reloadAllTheFollowersList];
}

@end
