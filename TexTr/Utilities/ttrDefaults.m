//
//  ttrDefaults.m
//  TexTr
//
//  Created by Mohan Kumar on 22/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrDefaults.h"

@implementation ttrDefaults

UILabel * (^__c_getStandardLabel)(NSString*) = ^(NSString * p_textVal)
{
    UILabel * l_retlbl = [UILabel new];
    l_retlbl.translatesAutoresizingMaskIntoConstraints = NO;
    l_retlbl.font = [UIFont systemFontOfSize:13.0];
    l_retlbl.textColor = [ttrDefaults getDefaultTextColor];
    l_retlbl.textAlignment = NSTextAlignmentLeft;
    l_retlbl.backgroundColor = [UIColor clearColor];
    l_retlbl.numberOfLines = 1;
    l_retlbl.text = p_textVal;
    return l_retlbl;
};

UITextField * (^__c_getStandardTextField)() = ^()
{
    UITextField * l_stdText = [UITextField new];
    l_stdText.translatesAutoresizingMaskIntoConstraints = NO;
    l_stdText.font = [UIFont systemFontOfSize:13.0f];
    l_stdText.textColor = [ttrDefaults getDefaultTextColor];
    l_stdText.textAlignment = NSTextAlignmentLeft;
    [l_stdText setBorderStyle:UITextBorderStyleNone];
    [l_stdText setBackgroundColor:[UIColor whiteColor]];
    return l_stdText;
};

UIButton * (^__c_getStandardButton)() = ^()
{
    UIButton * l_stdbutton = [UIButton new];
    l_stdbutton.translatesAutoresizingMaskIntoConstraints = NO;
    l_stdbutton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    [l_stdbutton setTitleColor:[ttrDefaults getDefaultTextColor] forState:UIControlStateNormal];
    return l_stdbutton;
};

+ (UIButton*) getStandardButton
{
    return __c_getStandardButton();
}

+ (UIButton*) getStandardButtonWithText:(NSString*) p_btnText
{
    UIButton * l_reqdbtn = __c_getStandardButton();
    [l_reqdbtn setTitle:p_btnText forState:UIControlStateNormal];
    return l_reqdbtn;
}

+ (UILabel*) getStandardLabelWithText:(NSString*) p_lblText
{
    return __c_getStandardLabel(p_lblText);
}

+ (UITextField*) getStandardTextField
{
    return __c_getStandardTextField();
}

+ (UIColor*) getDefaultTextColor
{
    //return [UIColor colorWithRed:0.0 green:0.0 blue:(128.0/255.0) alpha:1.0];
    return [UIColor blackColor];
}

@end
