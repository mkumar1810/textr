//
//  ttrBaseNavController.m
//  TexTr
//
//  Created by Mohan Kumar on 22/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrBaseNavController.h"
#import "ttrHomePullOverBtn.h"
#import "ttrHomeMyStatusView.h"
#import "ttrRESTProxy.h"

@interface ttrBaseNavController ()<UIGestureRecognizerDelegate,ttrHomeMyStatusViewDelegate>
{
    UIPanGestureRecognizer * _panGesture;
    NSMutableArray * _statusfeeds;
    UIView * _screenshotview;
    CGPoint _swipeStart;
    id<ttrCustNaviDelegates>  _showingctrlr;
}

@property (nonatomic,strong) ttrHomePullOverBtn * homePullOver;
@property (nonatomic,strong) ttrHomeMyStatusView * homeStatusFeedTV;

@end

@implementation ttrBaseNavController

- (void)awakeFromNib
{
    self.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarHidden = YES;
    [self setUpHomeStatusFeedViews];
    [self initializeMyStatusFeed];
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanSwipe:)];
    _panGesture.delegate = self;
    [self.view addGestureRecognizer:_panGesture];
    
    // Do any additional setup after loading the view.
}

- (void)initializeMyStatusFeed
{
    NSString * l_userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
    if (!l_userId)
    {
        return;
    }
    [[ttrRESTProxy alloc]
     initDatawithAPIType:@"GETMYSTATUSFEED"
     andInputParams:@{@"userId":l_userId}
     andReturnMethod:^(NSDictionary * p_groupsinfo)
     {
         if ([[p_groupsinfo valueForKey:@"error"] integerValue]==0)
         {
             NSDictionary * l_recdinfo = [NSJSONSerialization
                                          JSONObjectWithData:[p_groupsinfo valueForKey:@"resultdata"]
                                          options:NSJSONReadingMutableLeaves
                                          error:NULL];
             _statusfeeds = [NSMutableArray
                             arrayWithArray:[l_recdinfo valueForKey:@"result"]];
         }
         else
             _statusfeeds = [NSMutableArray arrayWithArray:@[]];
         [self setUpHomeStatusFeedViews];
     }];
}

- (void) setUpHomeStatusFeedViews
{
    if (self.homeStatusFeedTV) {
        [self.homeStatusFeedTV reloadAllMyStatusStreams];
        return;
    }
    self.homeStatusFeedTV = [ttrHomeMyStatusView new];
    self.homeStatusFeedTV.translatesAutoresizingMaskIntoConstraints=NO;
    self.homeStatusFeedTV.handlerDelegate = self;
    [self.view addSubview:self.homeStatusFeedTV];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.homeStatusFeedTV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-80.0)],[NSLayoutConstraint constraintWithItem:self.homeStatusFeedTV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.homeStatusFeedTV attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:(-1.0) constant:(40.0)],[NSLayoutConstraint constraintWithItem:self.homeStatusFeedTV attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]]];
    self.homePullOver = [ttrHomePullOverBtn new];
    self.homePullOver.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.homePullOver];
    [self.homePullOver addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[hp(20)]" options:0 metrics:nil views:@{@"hp":self.homePullOver}]];
    [self.homePullOver addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hp(90)]" options:0 metrics:nil views:@{@"hp":self.homePullOver}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[hp]" options:0 metrics:nil views:@{@"hp":self.homePullOver}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-190-[hp]" options:0 metrics:nil views:@{@"hp":self.homePullOver}]];
    [self.view layoutIfNeeded];
    [self.homeStatusFeedTV setHidden:YES];
    [self.homePullOver setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                         _showingctrlr.hideStatusBar = NO;
                         [self.navigationBar setHidden:NO];
                         [self.visibleViewController.view setHidden:NO];
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
            _showingctrlr.hideStatusBar = YES;
            //[self.homePullOver setHidden:YES];
            _screenshotview = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES];
            [_screenshotview setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            [self.view addSubview:_screenshotview];
            [self.navigationBar setHidden:YES];
            [self.visibleViewController.view setHidden:YES];
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
                                     _showingctrlr.hideStatusBar = NO;
                                     [self.navigationBar setHidden:NO];
                                     [self.visibleViewController.view setHidden:NO];
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.topViewController.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return self.topViewController.prefersStatusBarHidden;
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

#pragma gesture recognizer related delegates

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (_showingctrlr.showPullOver)
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
                {
                    [self cancelPullOverOfScreen];
                    return NO;
                }
            }
        }
    }
    return NO;
}

#pragma navigation controller delegates

- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight ;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    return [[ttrNavControllerTransitionAnimator alloc] initWithNavOperation:operation];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    _showingctrlr = (id<ttrCustNaviDelegates>) viewController;
    if (_showingctrlr.showPullOver)
    {
        [self initializeMyStatusFeed];
        [self.homePullOver setHidden:NO];
        [self.view bringSubviewToFront:self.homePullOver];
    }
    else
    {
        [self.homePullOver setHidden:YES];
    }
}

@end


@interface ttrNavControllerTransitionAnimator()
{
    UINavigationControllerOperation _navOperation;
}

@end

@implementation ttrNavControllerTransitionAnimator

- (instancetype) initWithNavOperation:(UINavigationControllerOperation) p_navOperation
{
    self = [super init];
    if (self)
    {
        _navOperation = p_navOperation;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.7;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
    id<ttrCustNaviDelegates>  l_toViewController = (id<ttrCustNaviDelegates>) [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect l_finalFrame = [transitionContext finalFrameForViewController:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]];
    id<ttrCustNaviDelegates> l_fromViewController = (id<ttrCustNaviDelegates>) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    TransitionType l_currTransitionType;
    if (_navOperation==UINavigationControllerOperationPush)
        l_currTransitionType = l_toViewController.transitionType;
    else
        l_currTransitionType = l_fromViewController.transitionType;
    NOPARAMCALLBACK l_pushCB = ^(){
        [l_fromViewController pushAnimation:l_currTransitionType];
    };
    
    NOPARAMCALLBACK l_popCB = ^(){
        [l_toViewController popAnimation:l_currTransitionType];
    };
    
    NOPARAMCALLBACK l_completionCB = ^(){
        if (_navOperation==UINavigationControllerOperationPop)
            [l_toViewController popAnimationCompleted];
        
        if (_navOperation==UINavigationControllerOperationPush)
            [l_fromViewController pushanimationCompleted];
        [transitionContext completeTransition:YES];
    };
    
    if (l_currTransitionType==noanimation)
    {
        if (_navOperation==UINavigationControllerOperationPush)
            l_pushCB();
        else
            l_popCB();
        l_completionCB();
        return;
    }
    else if (l_currTransitionType==horizontalWithoutBounce)
    {
        if (_navOperation==UINavigationControllerOperationPush)
            [self
             makeHorizontalNoBouncePushFrom:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view
             to:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view
             onContainer:[transitionContext containerView]
             duration:0.4
             finalFrame:l_finalFrame
             withCompletionCB:l_completionCB
             andPushCB:l_pushCB];
        else
            [self
             makeHorizontalNoBouncePopFrom:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view
             to:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view
             onContainer:[transitionContext containerView]
             duration:0.4
             finalFrame:l_finalFrame
             withCompletionCB:l_completionCB
             andPopCB:l_popCB];
    }
    else if (l_currTransitionType==popOutVerticalOpen)
    {
        if (_navOperation==UINavigationControllerOperationPush)
            [self
             makePopOutVerticalPushFrom:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view
             to:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view
             onContainer:[transitionContext containerView]
             duration:0.4
             finalFrame:l_finalFrame
             popOutFrame:[l_fromViewController getPopOutFrame]
             popOutImage:[l_fromViewController getPopOutImage]
             withCompletionCB:l_completionCB
             andPushCB:l_pushCB];
        else
            [self
             makePopOutVerticalPopFrom:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view
             to:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view
             onContainer:[transitionContext containerView]
             duration:0.4
             finalFrame:l_finalFrame
             popOutFrame:[l_toViewController getPopOutFrame]
             popOutImage:[l_toViewController getPopOutImage]
             withCompletionCB:l_completionCB
             andPopCB:l_popCB];
    }
    else if (l_currTransitionType==horizontalWithBounce)
    {
        if (_navOperation==UINavigationControllerOperationPush)
            [self
             makeHorizontalBouncePushFrom:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view
             to:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view
             onContainer:[transitionContext containerView]
             duration:0.7
             finalFrame:l_finalFrame
             withCompletionCB:l_completionCB
             andPushCB:l_pushCB];
        else
            [self
             makeHorizontalBouncePopFrom:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view
             to:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view
             onContainer:[transitionContext containerView]
             duration:0.7
             finalFrame:l_finalFrame
             withCompletionCB:l_completionCB
             andPopCB:l_popCB];
    }
    else if (l_currTransitionType == vertical )
    {
        if ( _navOperation == UINavigationControllerOperationPush )
            [self
             makeVerticalPushFrom:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view
             to:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view
             onContainer:[transitionContext containerView]
             duration:[self transitionDuration:transitionContext]
             finalFrame:l_finalFrame
             withCB:l_completionCB
             andPushCB:l_pushCB];
        else
            [self
             makeVerticalPopFrom:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view
             to:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view
             onContainer:[transitionContext containerView]
             duration:[self transitionDuration:transitionContext]
             finalFrame:l_finalFrame withCB:l_completionCB
             andPopCB:l_popCB];
    }
    else if (l_currTransitionType == rotatedFreeFallFromTop)
    {
        if ( _navOperation == UINavigationControllerOperationPush)
            [self
             makeRotatedFreefallPushFrom:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view
             to:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view
             onContainer:[transitionContext containerView]
             duration:[self transitionDuration:transitionContext]
             withCompletionCB:l_completionCB
             andPushCB:l_pushCB];
        else
            [self
             makeRotatedFreefallPopFrom:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view
             to:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view
             onContainer:[transitionContext containerView]
             duration:[self transitionDuration:transitionContext]
             withCompletionCB:l_completionCB
             andPopCB:l_popCB];
    }
    else if (l_currTransitionType==pageCurlRightToTop)
    {
        if ( _navOperation == UINavigationControllerOperationPush)
            [self
             makePageCurlRightPushFrom:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view
             to:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view
             onContainer:[transitionContext containerView]
             duration:[self transitionDuration:transitionContext]
             withCompletionCB:l_completionCB
             andPushCB:l_pushCB];
        else
            [self
             makePageCurlRightPopFrom:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view
             to:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view
             onContainer:[transitionContext containerView]
             duration:[self transitionDuration:transitionContext]
             withCompletionCB:l_completionCB
             andPopCB:l_popCB];
    }
    else if (l_currTransitionType==horizontalFlipFromRight)
    {
        if ( _navOperation == UINavigationControllerOperationPush)
            [self
             makeHorizontalRightFlipPushFrom:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view
             to:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view
             onContainer:[transitionContext containerView]
             duration:[self transitionDuration:transitionContext]
             withCB:l_completionCB
             andPushCB:l_pushCB];
        else
            [self
             makeHorizontalRightFlipPopFrom:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view
             to:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view
             onContainer:[transitionContext containerView]
             duration:[self transitionDuration:transitionContext]
             withCB:l_completionCB
             andPopCB:l_popCB];
    }
}

- (UIImage*) captureView:(UIView*) p_passview
{
    CGRect l_rect = p_passview.bounds;
    UIGraphicsBeginImageContext(l_rect.size);
    CGContextRef l_ctxref = UIGraphicsGetCurrentContext();
    [p_passview.layer renderInContext:l_ctxref];
    UIImage * l_reqdimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return l_reqdimage;
}

#pragma generic navigation delegate methods

- (void)makeRotatedFreefallPushFrom:(UIView *)p_fromView to:(UIView *)p_toView onContainer:(UIView *)p_containerView duration:(NSTimeInterval)p_duration withCompletionCB:(NOPARAMCALLBACK) p_completionCB andPushCB:(NOPARAMCALLBACK) p_pushCB
{
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(-1 * M_PI_2);
    CGRect fromRect = p_fromView.frame;
    CGAffineTransform translation = CGAffineTransformMakeTranslation(-1 * CGRectGetMidX(fromRect), -1 * CGRectGetMidY(fromRect));
    CGAffineTransform inverseTrans = CGAffineTransformInvert(translation);
    
    CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformConcat(inverseTrans, rotation), translation);
    
    p_toView.transform = transform;
    p_toView.alpha = 1;
    [p_containerView addSubview:p_toView];
    
    [UIView animateWithDuration:p_duration
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         p_toView.alpha = 1;
                         p_toView.transform = CGAffineTransformIdentity;
                         p_pushCB();
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [p_fromView removeFromSuperview];
                             p_completionCB(finished);
                         }
                     }];
    
}

- (void) makeRotatedFreefallPopFrom:(UIView*) p_fromView to:(UIView*) p_toView onContainer:(UIView*) p_containerView duration:(NSTimeInterval) p_duration withCompletionCB:(NOPARAMCALLBACK) p_completionCB andPopCB:(NOPARAMCALLBACK) p_popCB
{
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(-1 * M_PI_2);
    CGRect fromRect = p_fromView.frame;
    CGAffineTransform translation = CGAffineTransformMakeTranslation(-1 * CGRectGetMidX(fromRect), -1 * CGRectGetMidY(fromRect));
    CGAffineTransform inverseTrans = CGAffineTransformInvert(translation);
    
    CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformConcat(inverseTrans, rotation), translation);
    
    [p_containerView insertSubview:p_toView belowSubview:p_fromView];
    [UIView animateWithDuration:p_duration
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         //p_fromView.alpha = 0;
                         p_fromView.transform = transform;
                         p_popCB();
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [p_fromView removeFromSuperview];
                             p_completionCB(finished);
                         }
                     }];
}

- (void) makePageCurlRightPushFrom:(UIView*) p_fromView to:(UIView*) p_toView onContainer:(UIView*) p_containerView duration:(NSTimeInterval) p_duration withCompletionCB:(NOPARAMCALLBACK) p_completionCB andPushCB:(NOPARAMCALLBACK) p_pushCB
{
    [p_containerView insertSubview:p_toView belowSubview:p_fromView];
    [UIView transitionWithView:p_toView
                      duration:4.0
                       options: UIViewAnimationCurveEaseIn | UIViewAnimationOptionTransitionCurlUp
                    animations:^{
                        //p_fromView.frame = CGRectMake(-p_fromView.frame.size.width ,-p_fromView.frame.size.height , p_fromView.frame.size.width, p_fromView.frame.size.height);
                        p_fromView.transform = CGAffineTransformMakeTranslation((-1.0) * p_fromView.center.x , (-1.0) * p_fromView.center.y);
                        //p_fromView.alpha = 0;
                        p_pushCB();
                    }
                    completion:^(BOOL finished){
                        [p_fromView removeFromSuperview];
                        p_completionCB(finished);
                    }
     ];
}

- (void) makePageCurlRightPopFrom:(UIView*) p_fromView to:(UIView*) p_toView onContainer:(UIView*) p_containerView duration:(NSTimeInterval) p_duration withCompletionCB:(NOPARAMCALLBACK) p_completionCB andPopCB:(NOPARAMCALLBACK) p_popCB
{
    [p_toView setFrame:CGRectMake(-p_toView.frame.size.width ,-p_toView.frame.size.height , p_toView.frame.size.width, p_toView.frame.size.height)];
    [p_containerView addSubview:p_toView];
    p_toView.alpha = 0;
    [UIView transitionWithView:p_fromView
                      duration:p_duration
                       options: UIViewAnimationOptionTransitionCurlDown
                    animations:^{
                        p_toView.alpha = 1;
                        p_toView.frame = CGRectMake(0,0, p_toView.frame.size.width, p_toView.frame.size.height);
                        p_popCB();
                    }
                    completion:^(BOOL finished){
                        [p_fromView removeFromSuperview];
                        p_completionCB(finished);
                    }
     ];
}


- (void) makeHorizontalNoBouncePushFrom:(UIView*) p_fromView to:(UIView*) p_toView onContainer:(UIView*) p_containerView duration:(NSTimeInterval) p_duration finalFrame:(CGRect) p_finalFrame withCompletionCB:(NOPARAMCALLBACK) p_completionCB andPushCB:(NOPARAMCALLBACK) p_pushCB
{
    CGRect l_finalFromFrame = CGRectMake(-p_finalFrame.size.width, 0, p_finalFrame.size.width, p_finalFrame.size.height);
    p_toView.frame = CGRectOffset(p_finalFrame, p_finalFrame.size.width, 0);
    [p_containerView addSubview:p_toView];
    [UIView animateWithDuration:p_duration
                     animations:^(){
                         p_fromView.frame = l_finalFromFrame;
                         p_toView.frame = p_finalFrame;
                         p_pushCB();
                     }
                     completion:^(BOOL p_finished){
                         p_completionCB();
                     }];
}

- (void) makeHorizontalNoBouncePopFrom:(UIView*) p_fromView to:(UIView*) p_toView onContainer:(UIView*) p_containerView duration:(NSTimeInterval) p_duration finalFrame:(CGRect) p_finalFrame withCompletionCB:(NOPARAMCALLBACK) p_completionCB andPopCB:(NOPARAMCALLBACK) p_popCB
{
    CGRect l_finalFromFrame = CGRectMake(p_finalFrame.size.width, 0, p_finalFrame.size.width, p_finalFrame.size.height);
    p_toView.frame = CGRectOffset(l_finalFromFrame, -p_finalFrame.size.width, 0);
    [p_containerView addSubview:p_toView];
    [p_containerView sendSubviewToBack:p_toView];
    [UIView animateWithDuration:p_duration
                     animations:^(){
                         [p_fromView setFrame:l_finalFromFrame];
                         [p_toView setFrame:p_finalFrame];
                         p_popCB();
                     }
                     completion:^(BOOL p_finished){
                         p_completionCB();
                     }];
}

- (void) makePopOutVerticalPushFrom:(UIView*) p_fromView to:(UIView*) p_toView onContainer:(UIView*) p_containerView duration:(NSTimeInterval) p_duration finalFrame:(CGRect) p_finalFrame popOutFrame:(CGRect) p_popOutFrame popOutImage:(UIImage*) p_popOutImage withCompletionCB:(NOPARAMCALLBACK) p_completionCB andPushCB:(NOPARAMCALLBACK) p_pushCB
{
    UIImageView * l_cellimgvw = [[UIImageView alloc] initWithImage:p_popOutImage];
    [l_cellimgvw setFrame:p_popOutFrame];
    CGFloat l_shrink_x = p_popOutFrame.size.width / p_finalFrame.size.width;
    CGFloat l_shrink_y = p_popOutFrame.size.height / p_finalFrame.size.height;
    CGFloat l_expand_x = p_finalFrame.size.width / p_popOutFrame.size.width;
    CGFloat l_expand_y = p_finalFrame.size.height / p_popOutFrame.size.height;
    [p_containerView addSubview:p_toView];
    p_toView.alpha = 0;
    [p_containerView addSubview:l_cellimgvw];
    [p_containerView bringSubviewToFront:p_toView];
    p_toView.transform = CGAffineTransformMakeScale(l_shrink_x, l_shrink_y);
    p_toView.center = CGPointMake(p_popOutFrame.origin.x + p_popOutFrame.size.width/2.0, p_popOutFrame.origin.y+p_popOutFrame.size.height/2.0);
    CGPoint l_finalcenter = CGPointMake(p_finalFrame.origin.x + p_finalFrame.size.width/2.0, p_finalFrame.origin.y+p_finalFrame.size.height/2.0);
    [UIView animateWithDuration:p_duration
                     animations:^(){
                         l_cellimgvw.alpha = 0;
                         p_toView.alpha = 1;
                         p_toView.transform = CGAffineTransformIdentity;
                         l_cellimgvw.transform = CGAffineTransformMakeScale(l_expand_x, l_expand_y);
                         p_toView.center = l_finalcenter;
                         l_cellimgvw.center = l_finalcenter;
                         p_pushCB();
                     }
                     completion:^(BOOL p_finished){
                         [l_cellimgvw removeFromSuperview];
                         p_completionCB();
                     }];
}

- (void) makePopOutVerticalPopFrom:(UIView*) p_fromView to:(UIView*) p_toView onContainer:(UIView*) p_containerView duration:(NSTimeInterval) p_duration finalFrame:(CGRect) p_finalFrame popOutFrame:(CGRect) p_popOutFrame popOutImage:(UIImage*) p_popOutImage withCompletionCB:(NOPARAMCALLBACK) p_completionCB andPopCB:(NOPARAMCALLBACK) p_popCB
{
    [p_containerView addSubview:p_toView];
    [p_toView setFrame:p_finalFrame];
    UIImageView * l_cellimgvw = [[UIImageView alloc] initWithImage:p_popOutImage];
    [l_cellimgvw setFrame:p_finalFrame];
    l_cellimgvw.alpha = 0;
    CGFloat l_shrink_x = p_popOutFrame.size.width / p_finalFrame.size.width;
    CGFloat l_shrink_y = p_popOutFrame.size.height / p_finalFrame.size.height;
    [p_containerView addSubview:p_fromView];
    p_fromView.alpha = 1;
    [p_containerView addSubview:l_cellimgvw];
    [p_containerView bringSubviewToFront:p_fromView];
    CGPoint l_finalcenter = CGPointMake(p_popOutFrame.origin.x + p_popOutFrame.size.width/2.0, p_popOutFrame.origin.y+p_popOutFrame.size.height/2.0);
    [UIView animateWithDuration:p_duration
                     animations:^(){
                         l_cellimgvw.alpha = 1;
                         p_fromView.alpha = 0;
                         p_fromView.transform = CGAffineTransformMakeScale(l_shrink_x, l_shrink_y);
                         l_cellimgvw.transform = CGAffineTransformMakeScale(l_shrink_x, l_shrink_y);
                         p_fromView.center = l_finalcenter;
                         l_cellimgvw.center = l_finalcenter;
                         p_popCB();
                     }
                     completion:^(BOOL p_finished){
                         [l_cellimgvw removeFromSuperview];
                         p_completionCB();
                     }];
    
}

- (void) makeHorizontalBouncePushFrom:(UIView*) p_fromView to:(UIView*) p_toView onContainer:(UIView*) p_containerView duration:(NSTimeInterval) p_duration finalFrame:(CGRect) p_finalFrame withCompletionCB:(NOPARAMCALLBACK) p_completionCB andPushCB:(NOPARAMCALLBACK) p_pushCB
{
    CGRect l_finalFromFrame = CGRectMake(-p_finalFrame.size.width, 0, p_finalFrame.size.width, p_finalFrame.size.height);
    p_toView.frame = CGRectOffset(p_finalFrame, p_finalFrame.size.width, 0);
    [p_containerView addSubview:p_toView];
    //return;
    [UIView animateWithDuration:p_duration
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(){
                         p_fromView.frame = l_finalFromFrame;
                         p_toView.frame = p_finalFrame;
                         p_pushCB();
                     }
                     completion:^(BOOL p_finished){
                         p_completionCB();
                     }];
}

- (void) makeHorizontalBouncePopFrom:(UIView*) p_fromView to:(UIView*) p_toView onContainer:(UIView*) p_containerView duration:(NSTimeInterval) p_duration finalFrame:(CGRect) p_finalFrame withCompletionCB:(NOPARAMCALLBACK) p_completionCB andPopCB:(NOPARAMCALLBACK) p_popCB
{
    CGRect l_finalFromFrame = CGRectMake(p_finalFrame.size.width, 0, p_finalFrame.size.width, p_finalFrame.size.height);
    p_toView.frame = CGRectOffset(l_finalFromFrame, -p_finalFrame.size.width, 0);
    [p_containerView addSubview:p_toView];
    [p_containerView sendSubviewToBack:p_toView];
    [UIView animateWithDuration:p_duration
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(){
                         [p_fromView setFrame:l_finalFromFrame];
                         [p_toView setFrame:p_finalFrame];
                         p_popCB();
                     }
                     completion:^(BOOL p_finished){
                         p_completionCB();
                     }];
}

- (void) makeVerticalPushFrom:(UIView*) p_fromView to:(UIView*) p_toView onContainer:(UIView*) p_containerView duration:(NSTimeInterval) p_duration finalFrame:(CGRect) p_finalFrame withCB:(NOPARAMCALLBACK) p_completionCB andPushCB:(NOPARAMCALLBACK) p_pushCB
{
    CGRect finalFromFrame = CGRectOffset(p_fromView.frame, 0, -p_finalFrame.size.height);
    p_toView.frame = CGRectOffset(p_finalFrame, 0, [[UIScreen mainScreen] bounds].size.height);
    [p_containerView addSubview:p_toView];
    
    [UIView animateWithDuration:p_duration
                          delay:0
         usingSpringWithDamping:.75
          initialSpringVelocity:.1
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         p_fromView.frame = finalFromFrame;
                         p_toView.frame = p_finalFrame;
                         p_pushCB();
                     } completion:^(BOOL finished) {
                         p_completionCB();
                     }];
}

- (void) makeVerticalPopFrom:(UIView*) p_fromView to:(UIView*) p_toView onContainer:(UIView*) p_containerView duration:(NSTimeInterval) p_duration finalFrame:(CGRect) p_finalFrame withCB:(NOPARAMCALLBACK) p_completionCB andPopCB:(NOPARAMCALLBACK) p_popCB
{
    CGRect finalFromFrame = CGRectOffset(p_fromView.frame, 0, p_finalFrame.size.height);
    p_toView.frame = CGRectOffset(p_finalFrame, 0, -[[UIScreen mainScreen] bounds].size.height);
    [p_containerView addSubview:p_toView];
    
    [UIView animateWithDuration:p_duration
                          delay:0
         usingSpringWithDamping:.75
          initialSpringVelocity:.1
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         p_fromView.frame = finalFromFrame;
                         p_toView.frame = p_finalFrame;
                         p_popCB();
                     } completion:^(BOOL finished) {
                         p_completionCB();
                     }];
}


- (void) makeHorizontalRightFlipPushFrom:(UIView*) p_fromView to:(UIView*) p_toView onContainer:(UIView*) p_containerView duration:(NSTimeInterval) p_duration withCB:(NOPARAMCALLBACK) p_completionCB andPushCB:(NOPARAMCALLBACK) p_pushCB
{
    
    [p_containerView insertSubview:p_toView belowSubview:p_fromView];
    [UIView animateWithDuration:p_duration animations:^(){
        p_pushCB();
    }];
    [UIView transitionFromView:p_fromView
                        toView:p_toView
                      duration:p_duration
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:^(BOOL p_finished)
     {
         if (p_finished)
         {
             [p_fromView removeFromSuperview];
             p_completionCB(p_finished);
         }
     }];
    
}

- (void) makeHorizontalRightFlipPopFrom:(UIView*) p_fromView to:(UIView*) p_toView onContainer:(UIView*) p_containerView duration:(NSTimeInterval) p_duration withCB:(NOPARAMCALLBACK) p_completionCB andPopCB:(NOPARAMCALLBACK) p_popCB
{
    [p_containerView insertSubview:p_toView belowSubview:p_fromView];
    [UIView animateWithDuration:p_duration animations:^(){
        p_popCB();
    }];
    [UIView transitionFromView:p_fromView
                        toView:p_toView
                      duration:p_duration
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:^(BOOL p_finished)
     {
         if (p_finished)
         {
             [p_fromView removeFromSuperview];
             p_completionCB(p_finished);
         }
     }];
}

@end
