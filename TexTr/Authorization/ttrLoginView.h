//
//  ttrLoginView.h
//  TexTr
//
//  Created by Mohan Kumar on 25/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ttrLoginViewDelegate <NSObject>

- (void) executeLoginWithInfo;

@end

@interface ttrLoginView : UITableView

@property (nonatomic,weak) id<ttrLoginViewDelegate> handlerDelegate;

- (NSDictionary*) bValidateEnteredDataandReturnLoginInfo;
- (void) showAlertMessage:(NSString*) p_showMessage;

@end

@interface ttrLoginViewCustomCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier onPosn:(NSInteger) p_posnNo withDelegate:(id<ttrLoginViewDelegate>) p_delegate andTxtDelegate:(id<UITextFieldDelegate>) p_txtDelegate;
- (NSArray*) bValidateCellData;

@end