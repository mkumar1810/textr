//
//  ttrHomeDropOptions.h
//  TexTr
//
//  Created by Mohan Kumar on 01/07/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ttrHomeDropDownOptionsDelegate <NSObject>

- (void) optionCellSelected:(NSInteger) p_cellRowNo andFrame:(CGRect) p_cellFrame;

@end


@interface ttrHomeDropOptions : UIView

@property (nonatomic,retain) NSArray * heightConstraints;
@property (nonatomic) CGAffineTransform originalTransform;

- (instancetype) initWithFrame:(CGRect) p_frame andSuperPoint:(CGPoint) p_superPoint dataDelegate:(id<ttrHomeDropDownOptionsDelegate>) p_dataDelegate;

@end
