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
#import "ttrHomePullOverBtn.h"
#import "ttrHomeMyStatusView.h"

@interface ttrHomeCtrlr ()<UISearchBarDelegate, ttrHomeStreamsViewDelegate, UIGestureRecognizerDelegate, ttrHomeMyStatusViewDelegate>
{
    NSMutableArray * _groupstreams;
    NSMutableArray * _statusfeeds;
    UIPanGestureRecognizer * _panGesture;
    UIView * _screenshotview;
    CGPoint _swipeStart;
}

@property (nonatomic,strong) UISearchBar * itesearchbar;
@property (nonatomic,strong) ttrHomeStreamsView * homestreamsTV;
@property (nonatomic,strong) ttrHomePullOverBtn * homePullOver;
@property (nonatomic,strong) ttrHomeMyStatusView * homeStatusFeedTV;
@property (nonatomic, assign) BOOL hideStatusBar;

@end

@implementation ttrHomeCtrlr


- (void)awakeFromNib
{
    self.transitionType = horizontalWithBounce;
    [self.view setBackgroundColor:[UIColor colorWithRed:0.94 green:0.97 blue:1.0 alpha:1.0]];
    _groupstreams = [[NSMutableArray alloc] init];
    [self initializeAllHomeStreams];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDefaultItems];
    [self setupMainViews];
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanSwipe:)];
    _panGesture.delegate = self;
    [self.view addGestureRecognizer:_panGesture];
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

- (void) setUpHomeStatusFeedViews
{
    self.homeStatusFeedTV = [ttrHomeMyStatusView new];
    self.homeStatusFeedTV.translatesAutoresizingMaskIntoConstraints=NO;
    self.homeStatusFeedTV.handlerDelegate = self;
    [self.view addSubview:self.homeStatusFeedTV];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.homeStatusFeedTV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-80.0)],[NSLayoutConstraint constraintWithItem:self.homeStatusFeedTV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.homeStatusFeedTV attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:(-1.0) constant:(40.0)],[NSLayoutConstraint constraintWithItem:self.homeStatusFeedTV attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]]];
    [self.view layoutIfNeeded];
    [self.homeStatusFeedTV setHidden:YES];
}

- (void) setupMainViews
{
    self.homestreamsTV = [ttrHomeStreamsView new];
    self.homestreamsTV.translatesAutoresizingMaskIntoConstraints=NO;
    self.homestreamsTV.handlerDelegate = self;
    [self.view addSubview:self.homestreamsTV];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.homestreamsTV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.homestreamsTV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-64.0-38.0)],[NSLayoutConstraint constraintWithItem:self.homestreamsTV attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.homestreamsTV attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:(32.0-19.0)]]];
    
    self.homePullOver = [ttrHomePullOverBtn new];
    self.homePullOver.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.homePullOver];
    [self.homePullOver addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[hp(20)]" options:0 metrics:nil views:@{@"hp":self.homePullOver}]];
    [self.homePullOver addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hp(90)]" options:0 metrics:nil views:@{@"hp":self.homePullOver}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[hp]" options:0 metrics:nil views:@{@"hp":self.homePullOver}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-190-[hp]" options:0 metrics:nil views:@{@"hp":self.homePullOver}]];
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
         _groupstreams = [NSMutableArray
                          arrayWithArray:[l_recdinfo valueForKey:@"result"]];
         if (self.homestreamsTV)
         {
             [self.homestreamsTV reloadAllTheStreams];
         }
         [self.actView stopAnimating];
     }];
    [[ttrRESTProxy alloc]
     initDatawithAPIType:@"GETMYSTATUSFEED"
     andInputParams:@{@"userId":l_userId}
     andReturnMethod:^(NSDictionary * p_groupsinfo)
     {
         NSDictionary * l_recdinfo = [NSJSONSerialization
                                      JSONObjectWithData:[p_groupsinfo valueForKey:@"resultdata"]
                                      options:NSJSONReadingMutableLeaves
                                      error:NULL];
         _statusfeeds = [NSMutableArray
                          arrayWithArray:[l_recdinfo valueForKey:@"result"]];
         [self setUpHomeStatusFeedViews];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)prefersStatusBarHidden
{
    return self.hideStatusBar;
}

#pragma gesture recognizer related delegates

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isEqual:_panGesture])
    {
        CGPoint l_touchpoint = [touch locationInView:self.view];
        BOOL l_pullovertouched = CGRectContainsPoint(self.homePullOver.frame, l_touchpoint);
        if (self.homePullOver.frame.origin.x==0)
        {
            if (l_pullovertouched)
                return YES;
        }
        else
        {
            if (l_pullovertouched)
                [self cancelPullOverOfScreen];
        }
    }
    return NO;
}

- (void) cancelPullOverOfScreen
{
    [self.homePullOver setHidden:YES];
    [self.homePullOver changeTheArrowDirectionToRight];
    [UIView animateWithDuration:0.6
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(){
                         self.homeStatusFeedTV.transform = CGAffineTransformIdentity;
                         _screenshotview.transform = CGAffineTransformIdentity;
                         self.homePullOver.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL p_finished){
                         [self.homePullOver setHidden:NO];
                         [self.view bringSubviewToFront:self.homePullOver];
                         self.hideStatusBar = NO;
                         [self.navBar setHidden:NO];
                         [self.homestreamsTV setHidden:NO];
                         [self setNeedsStatusBarAppearanceUpdate];
                         [_screenshotview removeFromSuperview];
                         _screenshotview = nil;
                         [self.homeStatusFeedTV setHidden:YES];
                     }];
}

- (void) handlePanSwipe:(UIPanGestureRecognizer*) p_recognizer
{
    CGPoint l_touchPoint = [p_recognizer translationInView:self.view];
    switch (p_recognizer.state){
        case UIGestureRecognizerStateBegan:
        {
            self.hideStatusBar = YES;
            [self.homePullOver setHidden:YES];
            _screenshotview = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES];
            [_screenshotview setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            [self.view addSubview:_screenshotview];
            [self.navBar setHidden:YES];
            [self.homestreamsTV setHidden:YES];
            [self setNeedsStatusBarAppearanceUpdate];
            _swipeStart = l_touchPoint;
            [self.homeStatusFeedTV setHidden:NO];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGFloat l_shiftoffset = l_touchPoint.x - _swipeStart.x;
            if (l_shiftoffset>self.homeStatusFeedTV.frame.size.width)
            {
                l_shiftoffset = self.homeStatusFeedTV.frame.size.width;
            }
            self.homeStatusFeedTV.transform = CGAffineTransformMakeTranslation(l_shiftoffset, 0);
            _screenshotview.transform = CGAffineTransformMakeTranslation(l_shiftoffset, 0);
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            CGFloat l_shiftoffset = l_touchPoint.x - _swipeStart.x;
            if (l_shiftoffset>(self.homeStatusFeedTV.frame.size.width/3.0))
                l_shiftoffset = self.homeStatusFeedTV.frame.size.width;
            else
                l_shiftoffset = 0;
            [UIView animateWithDuration:0.6
                                  delay:0
                 usingSpringWithDamping:0.6
                  initialSpringVelocity:0.1
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:^(){
                                 self.homeStatusFeedTV.transform = CGAffineTransformMakeTranslation(l_shiftoffset, 0);
                                 _screenshotview.transform = CGAffineTransformMakeTranslation(l_shiftoffset, 0);
                                 self.homePullOver.transform = CGAffineTransformMakeTranslation(l_shiftoffset, 0);
                             }
                             completion:^(BOOL p_finished){
                                 [self.homePullOver setHidden:NO];
                                 [self.view bringSubviewToFront:self.homePullOver];
                                 if (l_shiftoffset==0)
                                 {
                                     self.hideStatusBar = NO;
                                     [self.navBar setHidden:NO];
                                     [self.homestreamsTV setHidden:NO];
                                     [self setNeedsStatusBarAppearanceUpdate];
                                     [_screenshotview removeFromSuperview];
                                     _screenshotview = nil;
                                     [self.homeStatusFeedTV setHidden:YES];
                                 }
                                 else
                                 {
                                     [self.homePullOver changeTheArrowDirectionToLeft];
                                 }
                             }];
            break;
        }
        default:
            break;
    }
}

#pragma  search bar customer search string related delegates

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = nil;
}

// called when Search (in our case “Done”) button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma home controller search view delegates

- (NSInteger) getNumberOfStreams
{
    return [_groupstreams count];
}

- (BOOL) checkIfGroupImageAvailable:(NSInteger) p_posnNo
{
    if ([[_groupstreams objectAtIndex:p_posnNo] valueForKey:@"groupimg"])
        return YES;
    else
        return NO;
}

- (NSDictionary*) getStreamDataAtPosn:(NSInteger) p_posnNo
{
    return [_groupstreams objectAtIndex:p_posnNo];
}

#pragma home status feed delegate

- (NSInteger) getNumberOfMyStatusStream
{
    return [_statusfeeds count];
}

- (NSDictionary*) getMyStatusStreamDataAtPosn:(NSInteger) p_posnNo
{
    return [_statusfeeds objectAtIndex:p_posnNo];
}

@end
