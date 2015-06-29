//
//  ttrGroupController.m
//  TexTr
//
//  Created by Mohan Kumar on 25/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrGroupController.h"
#import "ttrGroupView.h"
#import "ttrProfilePictureCapture.h"
#import "Base64.h"
#import "ttrRESTProxy.h"

@interface ttrGroupController ()<ttrGroupViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, ttrProfilePictureCaptureDelegates>
{
    UIImagePickerController * _imgPicker;
}

@property (nonatomic,strong) ttrGroupView * grpUpView;
@property (nonatomic,strong) ttrProfilePictureCapture * picturecaptureview;
@property (nonatomic,strong) UIVisualEffectView * blurEffectView;

@end

@implementation ttrGroupController

- (void)awakeFromNib
{
    self.transitionType = vertical;
    [self.view setBackgroundColor:[UIColor colorWithRed:0.94 green:0.97 blue:1.0 alpha:1.0]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDefaultItems];
    [self setupMainViews];
    // Do any additional setup after loading the view.
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.delegate = self;
}

- (void) setUpDefaultItems
{
    [self.navBar setHidden:NO];
    self.navItem.title = @"New Group";
    self.navBar.items = @[self.navItem];
    self.navItem.leftBarButtonItem = self.bar_back_btn;
    self.navItem.rightBarButtonItem = self.bar_logo_btn ;
}

- (void) setupMainViews
{
    self.grpUpView = [ttrGroupView new];
    self.grpUpView.translatesAutoresizingMaskIntoConstraints=NO;
    self.grpUpView.handlerDelegate = self;
    [self.view addSubview:self.grpUpView];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.grpUpView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.grpUpView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-64.0)],[NSLayoutConstraint constraintWithItem:self.grpUpView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.grpUpView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:32.0]]];
    [self.view layoutIfNeeded];
}

- (void) setScreenInteractionStatus:(BOOL) p_screenInteractStatus
{
    [self.navBar setUserInteractionEnabled:p_screenInteractStatus];
    [self.grpUpView setUserInteractionEnabled:p_screenInteractStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showDescriptionPictureTakingScreen
{
    CGRect l_fromRect = [self.grpUpView.descImageCellRef convertRect:self.grpUpView.descImageFrame toView:self.view];
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


#pragma image view controller delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * l_image = (UIImage*) [info valueForKey:UIImagePickerControllerOriginalImage];
    if (l_image != nil)
    {
        [self.grpUpView setDescripitonImage:l_image];
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
        [self showDescriptionPictureTakingScreen];
    }
    else if (buttonIndex==1)
    {
        _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:_imgPicker animated:YES completion:NULL];
    }
}


#pragma delegate of sign up view

- (void)takeDescriptionPictureFromFrame
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

- (void)executeSavingOfNewGroupEntryData
{
    NSMutableDictionary * l_saveinfo = [NSMutableDictionary dictionaryWithDictionary:[self.grpUpView bValidateEnteredDataandReturnSaveInfo]];
    if ([[l_saveinfo allKeys] count]>0)
    {
        [self setScreenInteractionStatus:NO];
        [self.view bringSubviewToFront:self.actView];
        [self.actView startAnimating];
        DICTIONARYCALLBACK l_createindbCB = ^(NSDictionary * p_aftersaveimageinfo)
        {
            if (p_aftersaveimageinfo)
            {
                NSDictionary * l_recdinfo = (NSDictionary*) [NSJSONSerialization
                                                             JSONObjectWithData:[p_aftersaveimageinfo valueForKey:@"resultdata"]
                                                             options:NSJSONReadingMutableLeaves
                                                             error:NULL];
                if ([l_recdinfo valueForKey:@"url"])
                    [l_saveinfo setValue:[l_recdinfo valueForKey:@"url"] forKey:@"groupimg"];
            }
            NSString * l_userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
            [l_saveinfo setValue:l_userId forKey:@"userId"];
            [[ttrRESTProxy alloc] initDatawithAPIType:@"CREATEGROUP" andInputParams:l_saveinfo andReturnMethod:^(NSDictionary * p_aftergroupcrinfo)
             {
                 NSDictionary * l_groupinfo = (NSDictionary*) [NSJSONSerialization
                                                              JSONObjectWithData:[p_aftergroupcrinfo valueForKey:@"resultdata"]
                                                              options:NSJSONReadingMutableLeaves
                                                              error:NULL];
                 NSInteger l_errorcode = [[l_groupinfo valueForKey:@"code"] integerValue];
                 [self.actView stopAnimating];
                 [self setScreenInteractionStatus:YES];
                 if (l_errorcode!=0)
                 {
                     [self.grpUpView showAlertMessage:[l_groupinfo valueForKey:@"error"]];
                     return ;
                 }
                 [self.navigationController popViewControllerAnimated:YES];
             }];
        };
        UIImage * l_descimage = [self.grpUpView getDescriptionImage];
        if (l_descimage)
        {
            NSData * l_descimgdata = UIImageJPEGRepresentation(l_descimage,0.7);
            Base64 * l_b64converter = [[Base64 alloc] init];
            NSString * l_pdfdatastr = [l_b64converter encode:l_descimgdata];
            [[ttrRESTProxy alloc] initDatawithAPIType:@"GROUPIMAGE" andInputParams:@{@"base64":l_pdfdatastr,@"__ContentType":@"image/jpeg"} andReturnMethod:l_createindbCB];
        }
        else
            l_createindbCB(nil);
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
    [self.grpUpView setDescripitonImageData:p_snapshotImageData];
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

@end
