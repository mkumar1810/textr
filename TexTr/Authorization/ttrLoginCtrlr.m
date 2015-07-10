//
//  ttrLoginCtrlr.m
//  TexTr
//
//  Created by Mohan Kumar on 25/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrLoginCtrlr.h"
#import "ttrRESTProxy.h"
#import "ttrLoginView.h"

@interface ttrLoginCtrlr ()<ttrLoginViewDelegate>

@property (nonatomic,strong) ttrLoginView * loginView;

@end

@implementation ttrLoginCtrlr

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.transitionType = horizontalWithBounce;
    [self.view setBackgroundColor:[UIColor colorWithRed:0.94 green:0.97 blue:1.0 alpha:1.0]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDefaultItems];
    [self setupMainViews];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userId"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sessionToken"];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setUpDefaultItems
{
    [self.navBar setHidden:NO];
    self.navItem.title = @"Login";
    self.navBar.items = @[self.navItem];
    self.navItem.leftBarButtonItem = self.bar_back_btn;
    self.navItem.rightBarButtonItem = self.bar_logo_btn;
}

- (void) setupMainViews
{
    self.loginView = [ttrLoginView new];
    self.loginView.translatesAutoresizingMaskIntoConstraints=NO;
    self.loginView.handlerDelegate = self;
    [self.view addSubview:self.loginView];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.loginView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.loginView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-64.0)],[NSLayoutConstraint constraintWithItem:self.loginView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.loginView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:32.0]]];
    [self.view layoutIfNeeded];
}

#pragma login view delegates

- (void) executeLoginWithInfo
{
    
    NSDictionary * l_saveinfo = [self.loginView bValidateEnteredDataandReturnLoginInfo];
    if (l_saveinfo)
    {
        [self.view bringSubviewToFront:self.actView];
        [self.actView startAnimating];
         [[ttrRESTProxy alloc] initDatawithAPIType:@"UESRLOGIN" andInputParams:l_saveinfo andReturnMethod:^(NSDictionary * p_aftersignupinfo)
          {
              NSInteger l_errno = [[p_aftersignupinfo valueForKey:@"error"] integerValue];
              if (l_errno==0)
              {
                  NSDictionary * l_recdinfo = (NSDictionary*) [NSJSONSerialization
                                                               JSONObjectWithData:[p_aftersignupinfo valueForKey:@"resultdata"]
                                                               options:NSJSONReadingMutableLeaves
                                                               error:NULL];
                  NSInteger l_errorcode = [[l_recdinfo valueForKey:@"code"] integerValue];
                  if (l_errorcode!=0)
                  {
                      [self.loginView showAlertMessage:[l_recdinfo valueForKey:@"error"]];
                      return ;
                  }
                  [[NSUserDefaults standardUserDefaults] setValue:[l_recdinfo valueForKey:@"sessionToken"] forKey:@"sessionToken"];
                  [[NSUserDefaults standardUserDefaults] setValue:[l_recdinfo valueForKey:@"objectId"] forKey:@"userId"];
                  [self performSegueWithIdentifier:@"landingpage" sender:self];
              }
              else
                  [self.loginView showAlertMessage:@"Error during Logging"];
              [self.actView stopAnimating];
          }];
    }
}

@end
