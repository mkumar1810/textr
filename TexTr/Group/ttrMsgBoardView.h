//
//  ttrMsgBoardView.h
//  TexTr
//
//  Created by Mohan Kumar on 10/07/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol ttrMsgBoardViewDelegate <NSObject>

- (NSInteger) getNumberOfBoardMessages;
- (NSDictionary*) getBoardMessageDictAtPosn:(NSInteger) p_posnNo;
- (void) sendTextMessage:(NSString*) p_txtMessage;
- (void) fetchOldMessages;

@end

@interface ttrMsgBoardView : UIScrollView


@property (nonatomic,weak) id<ttrMsgBoardViewDelegate> handlerDelegate;

- (void)setDataKeyBoardSize:(CGSize)p_keyboardSize;
- (void) reloadAllChatMessages;

@end

@interface ttrMsgBoardViewCell : UITableViewCell

- (void) setDisplayDict:(NSDictionary*) p_displayDict itemPosnNo:(NSInteger) p_itemNo;

@end

@interface ttrMsgBoardViewCellMsgView: UILabel

- (instancetype) initWithArrowDirn:(NSString*) p_arrowDirn;
- (void) setdisplayText:(NSString*) p_dispText;
@end