//
//  ttrBaseNavController.m
//  TexTr
//
//  Created by Mohan Kumar on 22/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrBaseNavController.h"

@interface ttrBaseNavController ()

@end

@implementation ttrBaseNavController

- (void)awakeFromNib
{
    self.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarHidden = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (l_currTransitionType==horizontalWithoutBounce)
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
    if (l_currTransitionType==popOutVerticalOpen)
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
    if (l_currTransitionType==horizontalWithBounce)
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

@end
