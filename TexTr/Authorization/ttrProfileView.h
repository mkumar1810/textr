//
//  ttrProfileView.h
//  TexTr
//
//  Created by Mohan Kumar on 06/07/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ttrProfileViewDelegate <NSObject>

- (void) takeUserProfilePictureFromFrame;
- (NSDictionary*) getUserProfileData;
- (NSInteger) getNumberOfFollowersOfUser;
- (NSInteger) getnumberOfFriendsOfUser;
- (NSInteger) getNumberOfGroupsOfThisUser;
- (BOOL) checkIfUserGroupImageAvailable:(NSInteger) p_posnNo;
- (NSDictionary*) getUserStreamDataAtPosn:(NSInteger) p_posnNo;
- (void) updateNewUserStatusMessage:(NSString*) p_newStatusMsg;
- (void) showFriendsListForUser;
- (void) showFollowersListForUser;

@end

@interface ttrProfileView : UIView

@property (nonatomic,weak) id<ttrProfileViewDelegate> handlerDelegate;
@property (nonatomic) CGRect profileImageFrame;
@property (nonatomic,weak) UIView * profileImageCellRef;

- (void) reloadAllProfileDataAndGroups;
- (void) setProfileImageData:(NSData*) p_profImgData;
- (void) setProfileImage:(UIImage*) p_profileImage;
- (void) showAlertMessage:(NSString*) p_showMessage;
- (UIImage*) getProfileImage;

@end

@interface ttrProfileViewCustomCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDelegate:(id<ttrProfileViewDelegate>) p_delegate;
- (BOOL) checkIfProfileViewClicked:(CGPoint) p_touchPoint;
- (CGRect) getProfileViewFrame;
- (UIImage*) getProfileImage;
- (void) setProfileImageIntoView:(NSData*) p_profileImgData;
- (void) setProfileImage:(UIImage*) p_profileImage;
- (void) setDisplayValuesAtPosn:(NSInteger) p_posnNo andStreamDict:(NSDictionary*) p_streamDict;
//- (void) displayRecordInformation;

@end

