//
//  ttrCaptureDate.h
//  TexTr
//
//  Created by Mohan Kumar on 24/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ttrCaptureDateDelegate <NSObject>

- (void) setDateSelectedFromCaptureDate:(NSDate*) p_captureDate;
- (void) cancelDatePickerSelection;

@end

@interface ttrCaptureDate : UIView

@property (nonatomic) CGRect startingFrame;
@property (nonatomic) CGAffineTransform originalTransform;

- (instancetype) initWithFrame:(CGRect) p_frame
             andCurrentdatestr:(NSString*) p_currDateStr
            andArrowDirecttion:(int) p_arrowDirection
                  dataDelegate:(id<ttrCaptureDateDelegate>) p_dataDelegate;

@end
