//
//  ttrHomeStreamsView.h
//  TexTr
//
//  Created by Mohan Kumar on 26/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ttrHomeStreamsViewDelegate <NSObject>

- (NSInteger) getNumberOfStreams;
- (BOOL) checkIfGroupImageAvailable:(NSInteger) p_posnNo;
- (NSDictionary*) getStreamDataAtPosn:(NSInteger) p_posnNo;

@end

@interface ttrHomeStreamsView : UIView

@property (nonatomic,weak) id<ttrHomeStreamsViewDelegate> handlerDelegate;
- (void) reloadAllTheStreams;

@end

@interface ttrHomeStreamsViewCustomCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier onPosn:(NSInteger) p_posnNo andDataDelegate:(id<ttrHomeStreamsViewDelegate>) p_dataDelegate;
- (void) setDisplayValuesAtPosn:(NSInteger) p_posnNo andStreamDict:(NSDictionary*) p_streamDict;

@end