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

+ (UIColor*) getColorRandomly:(int) p_colorNo withAlpha:(CGFloat) p_alpha
{
    UIColor * l_returnColor;
    switch (p_colorNo % 15) {
        case 0:
            l_returnColor = [UIColor colorWithRed:0.91 green:0.72 blue:0.88 alpha:p_alpha];
            break;
        case 1:
            l_returnColor = [UIColor colorWithRed:0.93 green:0.74 blue:0.74 alpha:p_alpha];
            break;
        case 2:
            l_returnColor = [UIColor colorWithRed:0.76 green:0.83 blue:0.89 alpha:p_alpha];
            break;
        case 3:
            l_returnColor = [UIColor colorWithRed:0.72 green:0.85 blue:0.72 alpha:p_alpha];
            break;
        case 4:
            l_returnColor = [UIColor colorWithRed:0.69 green:0.69 blue:0.91 alpha:p_alpha];
            break;
        case 5:
            l_returnColor = [UIColor colorWithRed:0.98 green:0.93 blue:0.79 alpha:p_alpha];
            break;
        case 6:
            l_returnColor = [UIColor colorWithRed:0.71 green:0.83 blue:0.82 alpha:p_alpha];
            break;
        case 7:
            l_returnColor = [UIColor colorWithRed:0.81 green:0.89 blue:0.95 alpha:p_alpha];
            break;
        case 8:
            l_returnColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:p_alpha];
            break;
        case 9:
            l_returnColor = [UIColor colorWithRed:0.93 green:0.97 blue:0.78 alpha:p_alpha];
            break;
        case 10:
            l_returnColor = [UIColor colorWithRed:0.97 green:0.78 blue:0.78 alpha:p_alpha];
            break;
        case 11:
            l_returnColor = [UIColor colorWithRed:0.78 green:0.69 blue:0.83 alpha:p_alpha];
            break;
        case 12:
            l_returnColor = [UIColor colorWithRed:0.97 green:0.85 blue:0.82 alpha:p_alpha];
            break;
        case 13:
            l_returnColor = [UIColor colorWithRed:0.88 green:0.95 blue:1.00 alpha:p_alpha];
            break;
        case 14:
            l_returnColor = [UIColor colorWithRed:0.99 green:0.95 blue:0.83 alpha:p_alpha];
            break;
        default:
            l_returnColor = [UIColor whiteColor];
            break;
    }
    return l_returnColor;
}


@end
