//
//  ttrGroupView.h
//  TexTr
//
//  Created by Mohan Kumar on 25/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ttrGroupViewDelegate <NSObject>

- (void) takeDescriptionPictureFromFrame;
- (void) executeSavingOfNewGroupEntryData;

@end

@interface ttrGroupView : UIView

@property (nonatomic,weak) id<ttrGroupViewDelegate> handlerDelegate;
@property (nonatomic) CGRect descImageFrame;
@property (nonatomic,weak) UIView * descImageCellRef;

- (void) setDescripitonImageData:(NSData*) p_descImgData;
- (void) setDescripitonImage:(UIImage*) p_descImage;
- (NSDictionary*) bValidateEnteredDataandReturnSaveInfo;
- (void) showAlertMessage:(NSString*) p_showMessage;
- (UIImage*) getDescriptionImage;

@end


@interface ttrGroupViewCustomCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier onPosn:(NSInteger) p_posnNo withDelegate:(id<ttrGroupViewDelegate>) p_delegate andTxtDelegate:(id<UITextFieldDelegate>) p_txtDelegate;
- (void) setDisplayValuesAtPosn:(NSInteger) p_posnNo;
- (BOOL) checkIfDescImageClicked:(CGPoint) p_touchPoint;
- (CGRect) getDescriptionImgViewFrame;
- (UIImage*) getDescriptionImage;
- (void) setDescriptionImageIntoView:(NSData*) p_descImgData;
- (void) setDescriptionImage:(UIImage*) p_descImage;
- (void) setTextDisplayValue:(NSString*) p_txtdisplayValue;
- (NSArray*) bValidateCellData;

@end