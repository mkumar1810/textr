//
//  ttrUserProfileCtrlr.m
//  TexTr
//
//  Created by Mohan Kumar on 06/07/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrUserProfileCtrlr.h"
#import "ttrProfilePictureCapture.h"
#import "ttrRESTProxy.h"
#import "Base64.h"
#import "ttrProfileView.h"

@interface ttrUserProfileCtrlr ()<ttrProfileViewDelegate, ttrProfilePictureCaptureDelegates,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
{
    UIImagePickerController * _imgPicker;
    NSString * _reqdUserObjectId;
    NSDictionary * _userProfileDict;
    NSArray * _groupstreamdata;
}

@property (nonatomic,strong) ttrProfileView * profileTV;
@property (nonatomic,strong) ttrProfilePictureCapture * picturecaptureview;
@property (nonatomic,strong) UIVisualEffectView * blurEffectView;

@end

@implementation ttrUserProfileCtrlr

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.transitionType = horizontalFlipFromRight;
    //[self.view setBackgroundColor:[UIColor redColor]];
    //[self.view setBackgroundColor:[UIColor colorWithRed:0.94 green:0.97 blue:1.0 alpha:1.0]];
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.99 alpha:1.0]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDefaultItems];
    [self setupMainViews];
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)initializeDataWithParams:(NSDictionary *)p_initParams
{
    _reqdUserObjectId = [p_initParams valueForKey:@"profileid"];
    [self.view bringSubviewToFront:self.actView];
    [self.actView startAnimating];
    [[ttrRESTProxy alloc]
     initDatawithAPIType:@"GETPROFILEDATA"    //getprofiledata
     andInputParams:@{@"userobjectid":_reqdUserObjectId}
     andReturnMethod:^(NSDictionary * p_userprofiledata)
     {
         NSDictionary * l_recdinfo = [NSJSONSerialization
                                      JSONObjectWithData:[p_userprofiledata valueForKey:@"resultdata"]
                                      options:NSJSONReadingMutableLeaves
                                      error:NULL];
         _userProfileDict = (NSDictionary*) [l_recdinfo valueForKey:@"result"];
         _groupstreamdata = nil;
         if (_userProfileDict)
             _groupstreamdata = [_userProfileDict valueForKey:@"groupdata"];
         if (self.profileTV)
         {
             [self.profileTV reloadAllProfileDataAndGroups];
         }
         [self.actView stopAnimating];
     }];
}

- (void) setUpDefaultItems
{
    [self.navBar setHidden:NO];
    self.navItem.title = @"User Profile";
    self.navBar.items = @[self.navItem];
    self.navItem.leftBarButtonItem = self.bar_back_btn;
    self.navItem.rightBarButtonItem = self.bar_logo_btn;
}

- (void) setupMainViews
{
    self.profileTV = [ttrProfileView new];
    self.profileTV.translatesAutoresizingMaskIntoConstraints=NO;
    self.profileTV.handlerDelegate = self;
    [self.view addSubview:self.profileTV];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.profileTV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.profileTV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-64.0)],[NSLayoutConstraint constraintWithItem:self.profileTV attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.profileTV attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:32.0]]];
    [self.view layoutIfNeeded];
}

- (void) setScreenInteractionStatus:(BOOL) p_screenInteractStatus
{
    [self.navBar setUserInteractionEnabled:p_screenInteractStatus];
    [self.profileTV setUserInteractionEnabled:p_screenInteractStatus];
}

- (void) showProfilePictureTakingScreen
{
    CGRect l_fromRect = [self.profileTV.profileImageCellRef convertRect:self.profileTV.profileImageFrame toView:self.view];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateNewImageToTheUser:(UIImage*) p_newImage
{
    NSData * l_profiledata = UIImageJPEGRepresentation(p_newImage,0.4);
    Base64 * l_b64converter = [[Base64 alloc] init];
    NSString * l_pdfdatastr = [l_b64converter encode:l_profiledata];
    [[ttrRESTProxy alloc] initDatawithAPIType:@"USERPROFILE" andInputParams:@{@"base64":l_pdfdatastr,@"__ContentType":@"image/jpeg"} andReturnMethod:^(NSDictionary * p_aftersaveinfo)
     {
         NSDictionary * l_recdinfo = (NSDictionary*) [NSJSONSerialization
                                                      JSONObjectWithData:[p_aftersaveinfo valueForKey:@"resultdata"]
                                                      options:NSJSONReadingMutableLeaves
                                                      error:NULL];
         NSDictionary * l_saveinfo = @{@"profileimg":[l_recdinfo valueForKey:@"url"]};
         [[ttrRESTProxy alloc]
          initDatawithAPIType:@"USERINFOUPDATE"
          andInputParams:@{@"saveinfo":l_saveinfo,@"userid":_reqdUserObjectId}
          andReturnMethod:NULL];
     }];
}

#pragma navigation delegates custom

- (void)pushAnimation:(TransitionType)p_pushAnimationType
{
    [self.profileTV resignFirstResponder];
}

- (void)popAnimation:(TransitionType)p_popAnimationType
{

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma image view controller delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * l_image = (UIImage*) [info valueForKey:UIImagePickerControllerOriginalImage];
    if (l_image != nil)
    {
        [self updateNewImageToTheUser:l_image];
        [self.profileTV setProfileImage:l_image];
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma snapshot image capturing view delegates

- (void)cancelSnapShotSelection
{
    [self unLoadPictureCaptureViewToFrame:CGRectZero];
}

- (void) snapShotCaptured:(NSData*) p_snapshotImageData
{
    [self unLoadPictureCaptureViewToFrame:CGRectZero];
    [self updateNewImageToTheUser:[UIImage imageWithData:p_snapshotImageData]];
    [self.profileTV setProfileImageData:p_snapshotImageData];
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

#pragma delegate of profile picture controller

- (void) takeUserProfilePictureFromFrame
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

- (NSDictionary *)getUserProfileData
{
    if (_userProfileDict)
        return [_userProfileDict valueForKey:@"profiledata"];
    else
        return nil;
}

- (NSInteger) getNumberOfFollowersOfUser
{
    return [[_userProfileDict valueForKey:@"nooffollowers"] integerValue];
}

- (NSInteger) getnumberOfFriendsOfUser
{
    return [[_userProfileDict valueForKey:@"nooffriends"] integerValue];
}

- (BOOL) checkIfUserGroupImageAvailable:(NSInteger) p_posnNo
{
    if ([[_groupstreamdata objectAtIndex:p_posnNo] valueForKey:@"groupimg"])
        return YES;
    else
        return NO;
}

- (NSDictionary*) getUserStreamDataAtPosn:(NSInteger) p_posnNo
{
    return [_groupstreamdata objectAtIndex:p_posnNo];
}

- (NSInteger)getNumberOfGroupsOfThisUser
{
    if (_groupstreamdata)
        return [_groupstreamdata count];
    else
        return 0;
}

- (void) updateNewUserStatusMessage:(NSString*) p_newStatusMsg
{
    [[ttrRESTProxy alloc]
     initDatawithAPIType:@"USERINFOUPDATE"
     andInputParams:@{@"saveinfo":@{@"statusmsg":p_newStatusMsg},
                      @"userid":_reqdUserObjectId}
     andReturnMethod:NULL];
}

- (void) showFriendsListForUser
{
    [self.view bringSubviewToFront:self.actView];
    [self.actView startAnimating];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigateParams = @{@"profileid":[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"],@"usertype":@"friends"};
        [self performSegueWithIdentifier:@"showfriendsforuser" sender:self];
        [self.actView stopAnimating];
    });
}

- (void) showFollowersListForUser
{
    
    [self.view bringSubviewToFront:self.actView];
    [self.actView startAnimating];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigateParams = @{@"profileid":[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"],@"usertype":@"followers"};
        [self performSegueWithIdentifier:@"showfollowersforuser" sender:self];
        [self.actView stopAnimating];
    });
}

@end
