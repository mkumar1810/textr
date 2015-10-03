//
//  ttrCommonUtilities.h
//  TexTr
//
//  Created by Mohan Kumar on 22/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ttrCommonUtilities : NSObject

+ (UIImage*) captureView:(UIView*) p_passView;
+ (UIImage*) captureView:(UIView*) p_passView ofFrame:(CGRect) p_ofFrame;
+ (BOOL) isTextFieldIsEmpty:(UITextField*) p_txtField;
+ (BOOL) isTextFieldIsValidEMail:(UITextField*) p_txtField;
+ (UIImage *)getImageForPlusBtn:(CGSize)p_onSize withBGColor:(UIColor *)p_bgColor andStrokeColor:(UIColor *)p_strokeColor;

@end
