//
//  ttrSgnLgnOptionScreen.m
//  TexTr
//
//  Created by Mohan Kumar on 22/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrSgnLgnOptionScreen.h"

@interface ttrSgnLgnOptionScreen ()

@property (nonatomic,strong) UIImageView * imgLogoVw;
@property (nonatomic,strong) UIButton * btnLogin;
@property (nonatomic,strong) UIButton * btnSignUp;

@end

@implementation ttrSgnLgnOptionScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitialObjects];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupInitialObjects
{
    [self.view setBackgroundColor:[UIColor colorWithRed:0.5 green:0.7 blue:0.9 alpha:1.0]];
    self.btnLogin = [ttrDefaults getStandardButton];
    [self.btnLogin setTitle:@"Log In" forState:UIControlStateNormal];
    [self.view addSubview:self.btnLogin];
    self.btnLogin.backgroundColor = [UIColor whiteColor];
    self.btnLogin.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.btnLogin setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnLogin addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnSignUp = [ttrDefaults getStandardButton];
    [self.btnSignUp setTitle:@"Sign Up" forState:UIControlStateNormal];
    self.btnSignUp.backgroundColor = [UIColor whiteColor];
    self.btnSignUp.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.btnSignUp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnSignUp addTarget:self action:@selector(signUpClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnSignUp];
    
    self.imgLogoVw = [UIImageView new];
    self.imgLogoVw.translatesAutoresizingMaskIntoConstraints = NO;
    [self.imgLogoVw setBackgroundColor:[UIColor clearColor]];
    self.imgLogoVw.image = [UIImage imageNamed:@"Logo"];
    [self.view addSubview:self.imgLogoVw];
    [self.imgLogoVw addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lg(100)]" options:0 metrics:nil views:@{@"lg":self.imgLogoVw}]];
    [self.imgLogoVw addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[lg(200)]" options:0 metrics:nil views:@{@"lg":self.imgLogoVw}]];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.imgLogoVw attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.imgLogoVw attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:0.75 constant:0.0]]];
    
    [self.btnLogin addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bl(40)]" options:0 metrics:nil views:@{@"bl":self.btnLogin}]];
    [self.btnSignUp addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bs(40)]" options:0 metrics:nil views:@{@"bs":self.btnSignUp}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bl]" options:0 metrics:nil views:@{@"bl":self.btnLogin}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bs]" options:0 metrics:nil views:@{@"bs":self.btnSignUp}]];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.btnLogin attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.btnSignUp attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]]];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.btnSignUp attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:2.0 constant:(-120.0)]]];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.btnLogin attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.btnSignUp attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:(60.0)]]];
    [self.view layoutIfNeeded];
}

- (void) signUpClicked
{
    [self performSegueWithIdentifier:@"signup" sender:self];
}

- (void) loginButtonClicked
{
    [self performSegueWithIdentifier:@"login" sender:self];
}

@end
