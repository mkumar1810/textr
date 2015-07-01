//
//  ttrHomeMyStatusView.h
//  TexTr
//
//  Created by Mohan Kumar on 30/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ttrHomeMyStatusViewDelegate <NSObject>

- (NSInteger) getNumberOfMyStatusStream;
- (NSDictionary*) getMyStatusStreamDataAtPosn:(NSInteger) p_posnNo;

@end


@interface ttrHomeMyStatusView : UIView

@property (nonatomic,weak) id<ttrHomeMyStatusViewDelegate> handlerDelegate;

- (void) reloadAllMyStatusStreams;

@end

@interface ttrHomeStatFeedViewCustomCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier onPosn:(NSInteger) p_posnNo;
- (void) setDisplayValuesAtPosn:(NSInteger) p_posnNo andMyStatusDict:(NSDictionary*) p_myStatusDict;

@end