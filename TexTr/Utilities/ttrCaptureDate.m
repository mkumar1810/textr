//
//  ttrCaptureDate.m
//  TexTr
//
//  Created by Mohan Kumar on 24/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrCaptureDate.h"

@interface ttrCaptureDate()
{
    UIDatePicker * _timePicker;
    UIButton * _doneBtn;
    UIButton * _cancelBtn;
    id<ttrCaptureDateDelegate> _dataDelegate;
    NSString * _currDateStr;
    int _arrowDirection;
}

@end

@implementation ttrCaptureDate

- (instancetype) initWithFrame:(CGRect) p_frame
             andCurrentdatestr:(NSString*) p_currDateStr
            andArrowDirecttion:(int) p_arrowDirection
                  dataDelegate:(id<ttrCaptureDateDelegate>) p_dataDelegate
{
    self = [super initWithFrame:p_frame];
    if (self) {
        _arrowDirection = p_arrowDirection;
        _dataDelegate = p_dataDelegate;
        _currDateStr = p_currDateStr;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect l_cancelbtnframe, l_donebtnframe;
    UIBezierPath * l_polygonpath = [UIBezierPath bezierPath];
    [l_polygonpath moveToPoint:CGPointMake(0.0, 0.0f)];
    [l_polygonpath addLineToPoint:CGPointMake(rect.size.width, 0.0)];
    [l_polygonpath addLineToPoint:CGPointMake(rect.size.width, rect.size.height-15.0)];
    [l_polygonpath addLineToPoint:CGPointMake(rect.size.width/2.0+10.0, rect.size.height-15.0)];
    [l_polygonpath addLineToPoint:CGPointMake(rect.size.width/2.0, rect.size.height)];
    [l_polygonpath addLineToPoint:CGPointMake(rect.size.width/2.0-10.0, rect.size.height-15.0)];
    [l_polygonpath addLineToPoint:CGPointMake(0.0f, rect.size.height-15.0)];
    l_cancelbtnframe = CGRectMake(5, 0, 63, 30);
    l_donebtnframe = CGRectMake(rect.size.width-68, 0, 63, 30);
    [l_polygonpath closePath];
    [[UIColor whiteColor] setFill];
    [l_polygonpath fill];
    
    _timePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 5, rect.size.width-40, rect.size.height-45)];
    [_timePicker setDatePickerMode:UIDatePickerModeDate];
    [self addSubview:_timePicker];
    _cancelBtn = [[UIButton alloc] initWithFrame:l_cancelbtnframe];
    [_cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [_cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(pickerTimeChanged:) forControlEvents:UIControlEventTouchDown];
    _cancelBtn.tag = 1000;
    [self addSubview:_cancelBtn];
    _doneBtn = [[UIButton alloc] initWithFrame:l_donebtnframe];
    [_doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    _doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [_doneBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_doneBtn addTarget:self action:@selector(pickerTimeChanged:) forControlEvents:UIControlEventTouchDown];
    _doneBtn.tag = 1001;
    [self addSubview:_doneBtn];
    [self showDateSelectionValues];
}

- (void) showDateSelectionValues
{
    NSDateFormatter * l_df = [[NSDateFormatter alloc] init];
    [l_df setDateFormat:@"dd-MMM-yyyy"];
    if (_currDateStr)
    {
        if ([_currDateStr length]>0)
            [_timePicker setDate:[l_df dateFromString:_currDateStr]];
        else
            [_timePicker setDate:[NSDate date]];
    }
    else
        [_timePicker setDate:[NSDate date]];
}


- (IBAction) pickerTimeChanged :(id) sender
{
    UIButton * l_btn = (UIButton *) sender;
    if (l_btn.tag == 1001)
        [_dataDelegate setDateSelectedFromCaptureDate:_timePicker.date];
    else
        [_dataDelegate cancelDatePickerSelection];
}

@end
