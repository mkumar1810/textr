//
//  ttrGroupMessageBoard.m
//  TexTr
//
//  Created by Mohan Kumar on 10/07/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrGroupMessageBoard.h"
#import "ttrMsgBoardView.h"
#import "ttrRESTProxy.h"
#define kMaxIdleTimeSeconds 30.0

@interface ttrGroupMessageBoard ()<ttrMsgBoardViewDelegate>
{
    NSDictionary * _groupInfoDict;
    NSMutableArray * _chatMessagesData;
    NSDateFormatter * _utcDateFormatter;
    BOOL _allOldMsgsRetrieved;
}

@property (nonatomic,strong) ttrMsgBoardView * msgBoardView;
@property (nonatomic) BOOL stopChatMsgFetching;

@end

@implementation ttrGroupMessageBoard
static NSTimer * _idleTimer;

- (void)awakeFromNib
{
    self.transitionType = popOutVerticalOpen;
    [self.view setBackgroundColor:[UIColor colorWithRed:0.94 green:0.97 blue:1.0 alpha:1.0]];
    _utcDateFormatter = [[NSDateFormatter alloc] init];
    [_utcDateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss 'GMT'"];
    [_utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDefaultItems];
    [self setupMainViewWithTextMessage];
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
    self.navItem.rightBarButtonItems = @[self.bar_list_btn, self.bar_logo_btn] ;
}

- (void) setupMainViewWithTextMessage
{
    self.msgBoardView = [ttrMsgBoardView new];
    self.msgBoardView.translatesAutoresizingMaskIntoConstraints=NO;
    self.msgBoardView.handlerDelegate = self;
    [self.view addSubview:self.msgBoardView];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.msgBoardView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.msgBoardView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-64.0)],[NSLayoutConstraint constraintWithItem:self.msgBoardView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.msgBoardView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:32.0]]];
    [self.view layoutIfNeeded];
}

- (void)initializeDataWithParams:(NSDictionary *)p_initParams
{
    [self.view bringSubviewToFront:self.actView];
    [self.actView startAnimating];
    _groupInfoDict = [p_initParams copy];
    self.navItem.title = [_groupInfoDict valueForKey:@"title"];
    [self fetchOldMessages];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Handling idle timeout

- (void) resetIdleTimer
{
    if (!_idleTimer)
    {
        _idleTimer = [NSTimer
                      scheduledTimerWithTimeInterval:kMaxIdleTimeSeconds
                      target:self
                      selector:@selector(idleTimerExceeded)
                      userInfo:nil
                      repeats:YES];
    }
    /*else
    {
        if (fabs([_idleTimer.fireDate timeIntervalSinceNow])< (kMaxIdleTimeSeconds-1.0))
        {
            [_idleTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:kMaxIdleTimeSeconds]];
        }
    }*/
}


- (void) idleTimerExceeded
{
    if (!self.stopChatMsgFetching)
    {
        //NSLog(@"messages fetching starts");
        [self generateAndHandleNewMessages];
    }
    //[self resetIdleTimer];
}


- (void) generateAndHandleNewMessages
{
    self.stopChatMsgFetching = YES;
    NSDictionary * l_lastdict;
    if (_chatMessagesData) {
        if ([_chatMessagesData count]>0)
        {
            l_lastdict = [_chatMessagesData objectAtIndex:0];
        }
    }
    NSDate * l_latestdatetime = [NSDate date];
    if (l_lastdict)
    {
        l_latestdatetime = [_utcDateFormatter dateFromString:[l_lastdict valueForKey:@"createdAt"]];
    }
    [[ttrRESTProxy alloc]
     initDatawithAPIType:@"GETNEWMESSAGES"
     andInputParams:@{@"groupid":[_groupInfoDict valueForKey:@"objectId"],
                      @"lastmsgtime":[_utcDateFormatter stringFromDate:l_latestdatetime]}
     andReturnMethod:^(NSDictionary * p_messagesinfo)
     {
         NSDictionary * l_recdinfo = (NSDictionary*) [NSJSONSerialization
                                                      JSONObjectWithData:[p_messagesinfo valueForKey:@"resultdata"]
                                                      options:NSJSONReadingMutableLeaves
                                                      error:NULL];
         for (NSDictionary * l_tmpdict in [l_recdinfo valueForKey:@"result"])
         {
             [self addValueToArrayFromDict:l_tmpdict andTopPosn:YES];
         }
         if (self.msgBoardView)
         {
             [self.msgBoardView reloadAllChatMessages];
         }
         [self resetIdleTimer];
         self.stopChatMsgFetching = NO;
     }];
}

- (void) addValueToArrayFromDict:(NSDictionary*) p_reqdDict andTopPosn:(BOOL) p_topPosn
{
    if (!_chatMessagesData)
    {
        _chatMessagesData = [[NSMutableArray alloc] init];
    }
    NSPredicate * l_chkcondition = [NSPredicate predicateWithFormat:@"objectId CONTAINS[c] %@",[p_reqdDict valueForKey:@"objectId"]];
    NSArray * l_chkresult = [_chatMessagesData filteredArrayUsingPredicate:l_chkcondition];
    if ([l_chkresult count]==0)
    {
        if (p_topPosn)
            [_chatMessagesData insertObject:[p_reqdDict copy] atIndex:0];
        else
            [_chatMessagesData addObject:[p_reqdDict copy]];
    }
}

#pragma keyboard related notificaiton handlers

- (void) keyboardBecomesVisible:(NSNotification*) p_visibeNotification
{
    NSDictionary * l_userInfo = [p_visibeNotification userInfo];
    CGSize l_keyBoardSize = [[l_userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.msgBoardView setDataKeyBoardSize:l_keyBoardSize];
}

- (void) keyboardBecomesHidden:(NSNotification*) p_hidingNotification
{
    [self.msgBoardView setDataKeyBoardSize:CGSizeZero];
}

#pragma ttr message board delegate

- (void) sendTextMessage:(NSString*) p_txtMessage
{
    self.stopChatMsgFetching = YES;
    NSString * l_userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
    NSDictionary * l_lastdict;
    if (_chatMessagesData) {
        if ([_chatMessagesData count]>0)
        {
            l_lastdict = [_chatMessagesData objectAtIndex:0];
        }
    }
    NSDate * l_latestdatetime = [NSDate date];
    if (l_lastdict)
    {
        l_latestdatetime = [_utcDateFormatter dateFromString:[l_lastdict valueForKey:@"createdAt"]];
    }
    [[ttrRESTProxy alloc]
     initDatawithAPIType:@"POSTTOMESSAGEBOARD" //posttomessageboard
     andInputParams:@{@"groupid":[_groupInfoDict valueForKey:@"objectId"],
                      @"lastmsgtime":[_utcDateFormatter stringFromDate:l_latestdatetime],
                      @"userid":l_userId,
                      @"message":p_txtMessage}
     andReturnMethod:^(NSDictionary * p_messagesinfo)
     {
         NSDictionary * l_recdinfo = (NSDictionary*) [NSJSONSerialization
                                                      JSONObjectWithData:[p_messagesinfo valueForKey:@"resultdata"]
                                                      options:NSJSONReadingMutableLeaves
                                                      error:NULL];
         for (NSDictionary * l_tmpdict in [l_recdinfo valueForKey:@"result"])
         {
             [self addValueToArrayFromDict:l_tmpdict andTopPosn:YES];
         }
         if (self.msgBoardView)
         {
             [self.msgBoardView reloadAllChatMessages];
         }
         [self resetIdleTimer];
         self.stopChatMsgFetching = NO;
     }];
}

- (NSInteger) getNumberOfBoardMessages
{
    if (_allOldMsgsRetrieved)
        return [_chatMessagesData count];
    else
        return [_chatMessagesData count]+1;
}

- (NSDictionary*) getBoardMessageDictAtPosn:(NSInteger) p_posnNo
{
    if (p_posnNo<[_chatMessagesData count])
        if (_chatMessagesData)
            return [_chatMessagesData objectAtIndex:p_posnNo];
    return nil;
}

- (void) fetchOldMessages
{
    self.stopChatMsgFetching = YES;
    NSDictionary * l_lastdict;
    if (_chatMessagesData) {
        if ([_chatMessagesData count]>0)
        {
            l_lastdict = [_chatMessagesData objectAtIndex:([_chatMessagesData count]-1)];
        }
    }
    NSDate * l_latestdatetime = [NSDate date];
    if (l_lastdict)
    {
        l_latestdatetime = [_utcDateFormatter dateFromString:[l_lastdict valueForKey:@"createdAt"]];
    }
    [[ttrRESTProxy alloc]
     initDatawithAPIType:@"GETMESSAGEBOARD"
     andInputParams:@{@"groupid":[_groupInfoDict valueForKey:@"objectId"],
                      @"lastmsgtime":[_utcDateFormatter stringFromDate:l_latestdatetime]}
     andReturnMethod:^(NSDictionary * p_messagesinfo)
     {
         NSDictionary * l_recdinfo = (NSDictionary*) [NSJSONSerialization
                                                      JSONObjectWithData:[p_messagesinfo valueForKey:@"resultdata"]
                                                      options:NSJSONReadingMutableLeaves
                                                      error:NULL];
         if ([[l_recdinfo valueForKey:@"result"] count]==0)
         {
             _allOldMsgsRetrieved = YES;
         }
         else
         {
             if (!_chatMessagesData)
             {
                 _chatMessagesData = [NSMutableArray arrayWithArray:[l_recdinfo valueForKey:@"result"]];
             }
             else
             {
                 for (NSDictionary * l_tmpdict in [l_recdinfo valueForKey:@"result"])
                 {
                     [self addValueToArrayFromDict:l_tmpdict andTopPosn:NO];
                 }
             }
         }
         if (self.msgBoardView)
         {
             [self.msgBoardView reloadAllChatMessages];
         }
         [self.actView stopAnimating];
         [self resetIdleTimer];
         self.stopChatMsgFetching = NO;
     }];
}

@end
