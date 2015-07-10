//
//  ttrHomeCtrlr.m
//  TexTr
//
//  Created by Mohan Kumar on 25/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrHomeCtrlr.h"
#import "ttrHomeStreamsView.h"
#import "ttrRESTProxy.h"
#import "ttrHomeDropOptions.h"

@interface ttrHomeCtrlr ()<ttrHomeStreamsViewDelegate, UIGestureRecognizerDelegate,  ttrHomeDropDownOptionsDelegate>
{
    NSArray * _groupstreamsall;
    NSMutableArray * _groupstreamsfiltered;
    CGSize _keyBoardSize;
}

@property (nonatomic,strong) ttrHomeStreamsView * homestreamsTV;
@property (nonatomic,strong) ttrHomeDropOptions * homeDropMenuVw;

@end

@implementation ttrHomeCtrlr

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.transitionType = horizontalWithBounce;
    self.showPullOver = YES;
    [self.view setBackgroundColor:[UIColor colorWithRed:0.94 green:0.97 blue:1.0 alpha:1.0]];
    _groupstreamsall = @[];
    [self initializeAllHomeStreams];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDefaultItems];
    [self setupMainViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardBecomesVisible:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardBecomesHidden:) name:UIKeyboardDidHideNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void) setUpDefaultItems
{
    [self.navBar setHidden:NO];
    self.navItem.title = @"Home";
    self.navBar.items = @[self.navItem];
    self.navItem.leftBarButtonItems = @[self.bar_back_btn,self.bar_edit_btn];
    self.navItem.rightBarButtonItems = @[self.bar_list_btn, self.bar_logo_btn] ;
}

- (void) setupMainViews
{
    self.homestreamsTV = [ttrHomeStreamsView new];
    self.homestreamsTV.translatesAutoresizingMaskIntoConstraints=NO;
    self.homestreamsTV.handlerDelegate = self;
    [self.view addSubview:self.homestreamsTV];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.homestreamsTV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.homestreamsTV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-64.0)],[NSLayoutConstraint constraintWithItem:self.homestreamsTV attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.homestreamsTV attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:32.0]]];
    [self.view layoutIfNeeded];
}

- (void)initializeAllHomeStreams
{
    [self.view bringSubviewToFront:self.actView];
    [self.actView startAnimating];
    NSString * l_userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
    [[ttrRESTProxy alloc]
     initDatawithAPIType:@"GETSTREAMS"
     andInputParams:@{@"userId":l_userId}
     andReturnMethod:^(NSDictionary * p_groupsinfo)
     {
         NSDictionary * l_recdinfo = [NSJSONSerialization
                                      JSONObjectWithData:[p_groupsinfo valueForKey:@"resultdata"]
                                      options:NSJSONReadingMutableLeaves
                                      error:NULL];
         _groupstreamsall = (NSArray*) [l_recdinfo valueForKey:@"result"];
         _groupstreamsfiltered = [NSMutableArray arrayWithArray:_groupstreamsall];
         if (self.homestreamsTV)
         {
             [self.homestreamsTV reloadAllTheStreams];
         }
         [self.actView stopAnimating];
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)editOptionPressed
{
    [self.view bringSubviewToFront:self.actView];
    [self.actView startAnimating];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"createnewgroup" sender:self];
        [self.actView stopAnimating];
    });
}


- (void)popAnimationCompleted
{
    [self initializeAllHomeStreams];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) executeListButtonClicked
{
    UIView * l_barprintvw = [self.bar_list_btn valueForKey:@"view"];
    CGRect l_pointrect = [l_barprintvw convertRect:l_barprintvw.bounds toView:self.view];
    CGPoint l_stPoint = CGPointMake(l_pointrect.origin.x-160.0, l_pointrect.origin.y+l_pointrect.size.height);
    self.homeDropMenuVw = [[ttrHomeDropOptions alloc] initWithFrame:CGRectZero andSuperPoint:CGPointZero dataDelegate:self];
    self.homeDropMenuVw.translatesAutoresizingMaskIntoConstraints = NO;
    //_rptselector.startingFrame = l_pointrect;
    [self.view addSubview:self.homeDropMenuVw];
    self.homeDropMenuVw.alpha =0.05;
    CGFloat l_shrink_x = l_pointrect.size.width / 160.0f;
    CGFloat l_shrink_y = l_pointrect.size.height / 120.0f;
    [self.homeDropMenuVw addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[popup(160)]" options:0 metrics:nil views:@{@"popup":self.homeDropMenuVw}]];
    [self.homeDropMenuVw addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[popup(120)]" options:0 metrics:nil views:@{@"popup":self.homeDropMenuVw}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-xval-[popup]" options:0 metrics:@{@"xval":@(l_stPoint.x)} views:@{@"popup":self.homeDropMenuVw}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-yval-[popup]" options:0 metrics:@{@"yval":@(l_stPoint.y)} views:@{@"popup":self.homeDropMenuVw}]];
    [self.view layoutIfNeeded];
    CGAffineTransform l_totransform = CGAffineTransformConcat(CGAffineTransformMakeScale(l_shrink_x, l_shrink_y),CGAffineTransformMakeTranslation((+160.0/2.0), (-120.0/2.0)));
    self.homeDropMenuVw.transform =l_totransform; // CGAffineTransformMakeScale(l_shrink_x, l_shrink_y);
    self.homeDropMenuVw.alpha = 0.5;
    self.homeDropMenuVw.originalTransform = l_totransform;
    [UIView animateWithDuration:0.3
                     animations:^(){
                         self.homeDropMenuVw.transform = CGAffineTransformIdentity;
                         self.homeDropMenuVw.alpha = 1.0;
                     } completion:^(BOOL p_finished){
                         [self.navBar setUserInteractionEnabled:NO];
                         [self.homestreamsTV setUserInteractionEnabled:NO];
                     }];
}

- (void) unloadPopUpDropdownSelection
{
    if (self.homeDropMenuVw.tag==1) return;
    self.homeDropMenuVw.tag = 1;
    [UIView animateWithDuration:0.3
                     animations:^(){
                         self.homeDropMenuVw.transform = self.homeDropMenuVw.originalTransform;
                         self.homeDropMenuVw.alpha = 0.5;
                     } completion:^(BOOL p_finished){
                         self.homeDropMenuVw.tag = 0;
                         [self.view layoutIfNeeded];
                         [self.navBar setUserInteractionEnabled:YES];
                         [self.homestreamsTV setUserInteractionEnabled:YES];
                         [self.homeDropMenuVw removeFromSuperview];
                         self.homeDropMenuVw = nil;
                     }];
}

#pragma keyboard related notificaiton handlers

- (void) keyboardBecomesVisible:(NSNotification*) p_visibeNotification
{
    NSDictionary * l_userInfo = [p_visibeNotification userInfo];
    CGSize l_keyBoardSize = [[l_userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.homestreamsTV setDataKeyBoardSize:l_keyBoardSize];
}

- (void) keyboardBecomesHidden:(NSNotification*) p_hidingNotification
{
    [self.homestreamsTV setDataKeyBoardSize:CGSizeZero];
}

#pragma gesture recognizer related delegates

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.homeDropMenuVw)
    {
        [self unloadPopUpDropdownSelection];
        return NO;
    }
    return NO;
}


#pragma home controller search view delegates

- (NSInteger) getNumberOfStreams
{
    return [_groupstreamsfiltered count];
}

- (BOOL) checkIfGroupImageAvailable:(NSInteger) p_posnNo
{
    if ([[_groupstreamsfiltered objectAtIndex:p_posnNo] valueForKey:@"groupimg"])
        return YES;
    else
        return NO;
}

- (NSDictionary*) getStreamDataAtPosn:(NSInteger) p_posnNo
{
    return [_groupstreamsfiltered objectAtIndex:p_posnNo];
}

- (void) generateStreamsForSearchStr:(NSString*) p_searchStr
{
    if (p_searchStr!=nil && [p_searchStr length]>0)
    {
        NSPredicate * l_streamsearch =
        [NSPredicate predicateWithFormat:@"title CONTAINS[c] %@ || description CONTAINS[c] %@ ", p_searchStr, p_searchStr];
        _groupstreamsfiltered = [NSMutableArray arrayWithArray:[_groupstreamsall filteredArrayUsingPredicate:l_streamsearch]];
    }
    else
    {
        _groupstreamsfiltered = [NSMutableArray arrayWithArray:_groupstreamsall];
    }
    [self.homestreamsTV reloadAllTheStreams];
}

- (void)showGroupForViewingFromStreamAtPosn:(NSInteger)p_posnNo
{
    
}

#pragma drop down options popup delegates

- (void) optionCellSelected:(NSInteger) p_cellRowNo andFrame:(CGRect) p_cellFrame
{
    switch (p_cellRowNo) {
        case 0: // self user profile
        {
            [self.view bringSubviewToFront:self.actView];
            [self.actView startAnimating];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigateParams = @{@"profileid":[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"]};
                [self performSegueWithIdentifier:@"showselfprofile" sender:self];
                [self.actView stopAnimating];
            });
            break;
        }
        default:
            break;
    }
    [self unloadPopUpDropdownSelection];
}

@end
