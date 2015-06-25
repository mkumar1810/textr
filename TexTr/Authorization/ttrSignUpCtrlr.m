//
//  ttrSignUpCtrlr.m
//  TexTr
//
//  Created by Mohan Kumar on 22/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrSignUpCtrlr.h"
#import "ttrSignUpView.h"
#import "ttrProfilePictureCapture.h"
#import "ttrCaptureDate.h"
#import "ttrRESTProxy.h"
#import "Base64.h"

@interface ttrSignUpCtrlr () <ttrSignUpViewDelegate, ttrProfilePictureCaptureDelegates,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, ttrCaptureDateDelegate>
{
    UIImagePickerController * _imgPicker;
    CGSize _keyboardSize;
    ttrCaptureDate * _ttrDateCapture;
}

@property (nonatomic,strong) ttrSignUpView * signUpView;
@property (nonatomic,strong) ttrProfilePictureCapture * picturecaptureview;
@property (nonatomic,strong) UIVisualEffectView * blurEffectView;

@end

@implementation ttrSignUpCtrlr

- (void)awakeFromNib
{
    self.transitionType = horizontalWithBounce;
    [self.view setBackgroundColor:[UIColor colorWithRed:0.94 green:0.97 blue:1.0 alpha:1.0]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDefaultItems];
    [self setupMainViews];
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardBecomesVisible:) name:UIKeyboardDidShowNotification object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setUpDefaultItems
{
    [self.navBar setHidden:NO];
    self.navItem.title = @"Sign Up";
    self.navBar.items = @[self.navItem];
    self.navItem.leftBarButtonItem = self.bar_back_btn;
    self.navItem.rightBarButtonItem = self.bar_logo_btn;
}

- (void) setupMainViews
{
    self.signUpView = [ttrSignUpView new];
    self.signUpView.translatesAutoresizingMaskIntoConstraints=NO;
    self.signUpView.handlerDelegate = self;
    [self.view addSubview:self.signUpView];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.signUpView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.signUpView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-64.0)],[NSLayoutConstraint constraintWithItem:self.signUpView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.signUpView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:32.0]]];
    [self.view layoutIfNeeded];
}

- (void) setScreenInteractionStatus:(BOOL) p_screenInteractStatus
{
    [self.navBar setUserInteractionEnabled:p_screenInteractStatus];
    [self.signUpView setUserInteractionEnabled:p_screenInteractStatus];
}

- (void) showProfilePictureTakingScreen
{
    CGRect l_fromRect = [self.signUpView.profileImageCellRef convertRect:self.signUpView.profileImageFrame toView:self.view];
    CGRect l_torect = CGRectMake(0, (self.view.bounds.size.height - self.view.bounds.size.width - 38.0)/2.0 , self.view.bounds.size.width, (self.view.bounds.size.width+38.0));
    self.picturecaptureview = [ttrProfilePictureCapture new];
    self.picturecaptureview.alpha = 0;
    self.picturecaptureview.imageDataDelegate = self;
    [self.view addSubview:self.picturecaptureview];
    [self.picturecaptureview setFrame:l_torect];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [self.blurEffectView setFrame:self.view.frame];
    self.blurEffectView.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 0);
    [self.view addSubview:self.blurEffectView];
    
    CGFloat l_shrinkfactor_x = l_fromRect.size.width/l_torect.size.width;
    CGFloat l_shrinkfactor_y = l_fromRect.size.height/l_torect.size.height;
    CGPoint l_fromrectcenter = CGPointMake(l_fromRect.origin.x+l_fromRect.size.width/2.0, l_fromRect.origin.y+l_fromRect.size.height/2.0);
    CGPoint l_torectcenter = CGPointMake(l_torect.origin.x+l_torect.size.width/2.0, l_torect.origin.y+l_torect.size.height/2.0);
    CGAffineTransform l_originalTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(l_shrinkfactor_x, l_shrinkfactor_y), CGAffineTransformMakeTranslation((l_fromrectcenter.x - l_torectcenter.x), (l_fromrectcenter.y-l_torectcenter.y)));
    self.picturecaptureview.transform = l_originalTransform ;
    [self.view bringSubviewToFront:self.picturecaptureview];
    
    [UIView animateWithDuration:0.4
                     animations:^(){
                         self.picturecaptureview.transform = CGAffineTransformIdentity;
                         self.picturecaptureview.alpha = 1;
                     }
                     completion:^(BOOL p_finished){
                         [UIView animateWithDuration:0.2
                                          animations:^{
                                              self.blurEffectView.transform = CGAffineTransformIdentity;
                                          }];
                         [self setScreenInteractionStatus:NO];
                         self.picturecaptureview.originalTransform = l_originalTransform;
                         [self setScreenInteractionStatus:NO];
                     }];
}

- (void) keyboardBecomesVisible:(NSNotification*) p_visibeNotification
{
    NSDictionary * l_userInfo = [p_visibeNotification userInfo];
    _keyboardSize = [[l_userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma image view controller delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * l_image = (UIImage*) [info valueForKey:UIImagePickerControllerOriginalImage];
    if (l_image != nil)
    {
        [self.signUpView setProfileImage:l_image];
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma alert view related delegates

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // 0 - camera, 1 - library
    if (buttonIndex==0)
    {
        [self showProfilePictureTakingScreen];
    }
    else if (buttonIndex==1)
    {
        _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:_imgPicker animated:YES completion:NULL];
    }
}

#pragma delegate of sign up view

- (void) takeProfilePictureFromFrame
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView * l_alertview = [[UIAlertView alloc] initWithTitle:@"TexTr" message:@"Select source Option" delegate:self cancelButtonTitle:@"Camera" otherButtonTitles:@"Library", nil];
        l_alertview.tag = 101;
        l_alertview.delegate = self;
        [l_alertview show];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:_imgPicker animated:YES completion:NULL];
    }
}

- (CGSize) getKeyBoardSize
{
    return _keyboardSize;
}

- (void) showDateCaptureFromFrame:(CGRect) p_fromRect withStartDateVal:(NSString*) p_dateStr
{
    if (_ttrDateCapture)
    {
        return;
    }
    CGRect l_toFrame = CGRectMake((self.view.frame.size.width-300.0)/2.0 , (p_fromRect.origin.y - 230), 300, 230);
    _ttrDateCapture = [[ttrCaptureDate alloc]
                    initWithFrame:l_toFrame
                       andCurrentdatestr:(p_dateStr?p_dateStr:@"")
                    andArrowDirecttion:1
                    dataDelegate:self];
    _ttrDateCapture.alpha = 0.1;
    [self.view addSubview:_ttrDateCapture];
    CGPoint l_fromrectcenter = CGPointMake(p_fromRect.origin.x+p_fromRect.size.width/2.0, p_fromRect.origin.y+p_fromRect.size.height/2.0);
    CGPoint l_torectcenter = CGPointMake(l_toFrame.origin.x+l_toFrame.size.width/2.0, l_toFrame.origin.y+l_toFrame.size.height/2.0);
    CGFloat l_srink_x = p_fromRect.size.width / l_toFrame.size.width;
    CGFloat l_srink_y = p_fromRect.size.height / l_toFrame.size.height;
    CGAffineTransform l_fromtransform = CGAffineTransformConcat(CGAffineTransformMakeScale(l_srink_x, l_srink_y), CGAffineTransformMakeTranslation( 0 , l_fromrectcenter.y-l_torectcenter.y ));
    _ttrDateCapture.transform = l_fromtransform;
    [self.view layoutIfNeeded];
    //_ttrDateCapture.center = l_fromrectcenter;
    [UIView animateWithDuration:0.4
                     animations:^(){
                         _ttrDateCapture.transform = CGAffineTransformIdentity;
                         _ttrDateCapture.alpha = 1;
                     }
                     completion:^(BOOL p_finished){
                         _ttrDateCapture.originalTransform = l_fromtransform;
                         [self setScreenInteractionStatus:NO];
                     }];
}

- (void) executeSavingOfSignUpData
{
    NSMutableDictionary * l_saveinfo = [NSMutableDictionary dictionaryWithDictionary:[self.signUpView bValidateEnteredDataandReturnSaveInfo]];
    if ([[l_saveinfo allKeys] count]>0)
    {
        [self.view bringSubviewToFront:self.actView];
        [self.actView startAnimating];
        UIImage * l_profileimage = [self.signUpView getProfileImage];
        if (l_profileimage)
        {
            NSData * l_profiledata = UIImageJPEGRepresentation(l_profileimage,0.7);
            Base64 * l_b64converter = [[Base64 alloc] init];
            NSString * l_pdfdatastr = [l_b64converter encode:l_profiledata];
            [[ttrRESTProxy alloc] initDatawithAPIType:@"USERPROFILE" andInputParams:@{@"base64":l_pdfdatastr,@"__ContentType":@"image/jpeg"} andReturnMethod:^(NSDictionary * p_aftersaveinfo)
             {
                 NSDictionary * l_recdinfo = (NSDictionary*) [NSJSONSerialization
                                                              JSONObjectWithData:[p_aftersaveinfo valueForKey:@"resultdata"]
                                                              options:NSJSONReadingMutableLeaves
                                                              error:NULL];
                 if ([l_recdinfo valueForKey:@"url"])
                     [l_saveinfo setValue:[l_recdinfo valueForKey:@"url"] forKey:@"profileimg"];
                 [[ttrRESTProxy alloc] initDatawithAPIType:@"USERSIGNUP" andInputParams:l_saveinfo andReturnMethod:^(NSDictionary * p_aftersignupinfo)
                  {
                      NSDictionary * l_recdinfo = (NSDictionary*) [NSJSONSerialization
                                                                   JSONObjectWithData:[p_aftersignupinfo valueForKey:@"resultdata"]
                                                                   options:NSJSONReadingMutableLeaves
                                                                   error:NULL];
                      NSInteger l_errorcode = [[l_recdinfo valueForKey:@"code"] integerValue];
                      [self.actView stopAnimating];
                      if (l_errorcode!=0)
                      {
                          [self.signUpView showAlertMessage:[l_recdinfo valueForKey:@"error"]];
                          return ;
                      }
                      [self.navigationController popViewControllerAnimated:YES];
                  }];
             }];
        }
    }
}

#pragma snapshot image capturing view delegates

- (void)cancelSnapShotSelection
{
    [self unLoadPictureCaptureViewToFrame:CGRectZero];
}

- (void) snapShotCaptured:(NSData*) p_snapshotImageData
{
    [self unLoadPictureCaptureViewToFrame:CGRectZero];
    [self.signUpView setProfileImageData:p_snapshotImageData];
}


- (void) unLoadPictureCaptureViewToFrame:(CGRect) p_toFrame
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.blurEffectView.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 0);
                     } completion:^(BOOL p_finished){
                         [self.blurEffectView removeFromSuperview];
                         self.blurEffectView = nil;
                         [UIView animateWithDuration:0.4
                                          animations:^(){
                                              self.picturecaptureview.transform = self.picturecaptureview.originalTransform;
                                              self.picturecaptureview.alpha = 0;
                                          }
                                          completion:^(BOOL p_finished){
                                              [self setScreenInteractionStatus:YES];
                                              [self.picturecaptureview removeFromSuperview];
                                              self.picturecaptureview = nil;
                                              [self setScreenInteractionStatus:YES];
                                          }];
                     }];
}

#pragma capturing delivered date related delegates

- (void) setDateSelectedFromCaptureDate:(NSDate*) p_captureDate
{
    NSDateFormatter * l_df = [[NSDateFormatter alloc] init];
    [l_df setDateFormat:@"dd-MMM-yyyy"];
    [self.signUpView setBirthDate:[l_df stringFromDate:p_captureDate]];
    [self cancelDatePickerSelection];
}

- (void) cancelDatePickerSelection
{
    [UIView animateWithDuration:0.4
                     animations:^(){
                         _ttrDateCapture.transform = _ttrDateCapture.originalTransform;
                         _ttrDateCapture.alpha = 0;
                     }
                     completion:^(BOOL p_finished){
                         [_ttrDateCapture removeFromSuperview];
                         _ttrDateCapture = nil;
                         [self setScreenInteractionStatus:YES];
                     }];
}

@end
