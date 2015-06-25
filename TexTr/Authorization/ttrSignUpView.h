//
//  ttrSignUpView.h
//  TexTr
//
//  Created by Mohan Kumar on 22/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ttrSignUpViewDelegate <NSObject>

- (void) takeProfilePictureFromFrame;
- (CGSize) getKeyBoardSize;
- (void) showDateCaptureFromFrame:(CGRect) p_fromRect withStartDateVal:(NSString*) p_dateStr;
- (void) executeSavingOfSignUpData;

@end

@interface ttrSignUpView : UIView

@property (nonatomic,weak) id<ttrSignUpViewDelegate> handlerDelegate;
@property (nonatomic) CGRect profileImageFrame;
@property (nonatomic,weak) UIView * profileImageCellRef;

- (void) setProfileImageData:(NSData*) p_profImgData;
- (void) setProfileImage:(UIImage*) p_profileImage;
- (void) setBirthDate:(NSString*) p_birthDateStr;
- (NSDictionary*) bValidateEnteredDataandReturnSaveInfo;
- (void) showAlertMessage:(NSString*) p_showMessage;
- (UIImage*) getProfileImage;

@end

@interface ttrSignUpViewCustomCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier onPosn:(NSInteger) p_posnNo withDelegate:(id<ttrSignUpViewDelegate>) p_delegate andTextDelegate:(id<UITextFieldDelegate>) p_txtDelegate;
- (void) setDisplayValuesAtPosn:(NSInteger) p_posnNo;
- (BOOL) checkIfProfileViewClicked:(CGPoint) p_touchPoint;
- (CGRect) getProfileViewFrame;
- (UIImage*) getProfileImage;
- (void) setProfileImageIntoView:(NSData*) p_profileImgData;
- (void) setProfileImage:(UIImage*) p_profileImage;
- (void) setTextDisplayValue:(NSString*) p_txtdisplayValue;
- (NSArray*) bValidateCellData;

@end
