//
//  ttrFollowersList.h
//  TexTr
//
//  Created by Mohan Kumar on 10/07/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ttrFollowersListViewDelegate <NSObject>

- (NSInteger) getNumberOfFollowersForUser;
- (NSDictionary*) getFollowerDictOfUserAtPosn:(NSInteger) p_posnNo;
- (void) lookUpFollowersForSearchStr:(NSString*) p_searchStr;

@end

@interface ttrFollowersList : UIScrollView

@property (nonatomic,weak) id<ttrFollowersListViewDelegate> handlerDelegate;

- (void) reloadAllTheFollowersList;
- (void) setDataKeyBoardSize:(CGSize) p_keyboardSize;

@end

@interface ttrFollowersListVwCustomCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andDataDelegate:(id<ttrFollowersListViewDelegate>) p_dataDelegate;
- (void) setDisplayValuesAtPosn:(NSInteger) p_posnNo;

@end