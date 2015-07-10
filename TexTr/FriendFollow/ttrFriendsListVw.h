//
//  ttrFriendsListVw.h
//  TexTr
//
//  Created by Mohan Kumar on 10/07/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ttrFriendsListViewDelegate <NSObject>

- (NSInteger) getNumberOfFriendsForUser;
- (NSDictionary*) getFriendDictOfUserAtPosn:(NSInteger) p_posnNo;
- (void) lookUpFriendsForSearchStr:(NSString*) p_searchStr;

@end

@interface ttrFriendsListVw : UIScrollView

@property (nonatomic,weak) id<ttrFriendsListViewDelegate> handlerDelegate;

- (void) reloadAllTheFriendsList;
- (void) setDataKeyBoardSize:(CGSize) p_keyboardSize;

@end

@interface ttrFriendsListVwCustomCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andDataDelegate:(id<ttrFriendsListViewDelegate>) p_dataDelegate;
- (void) setDisplayValuesAtPosn:(NSInteger) p_posnNo;

@end