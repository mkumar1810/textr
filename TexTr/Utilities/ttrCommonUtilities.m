//
//  ttrCommonUtilities.m
//  TexTr
//
//  Created by Mohan Kumar on 22/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrCommonUtilities.h"

@implementation ttrCommonUtilities

+ (UIImage*) captureView:(UIView*) p_passView
{
    CGRect l_rect = p_passView.bounds;
    UIGraphicsBeginImageContext(l_rect.size);
    CGContextRef l_ctxref = UIGraphicsGetCurrentContext();
    [p_passView.layer renderInContext:l_ctxref];
    UIImage * l_reqdimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return l_reqdimage;
}

+ (UIImage *)captureView:(UIView *)p_passView ofFrame:(CGRect)p_ofFrame
{
    CGRect l_viewRect = CGRectMake(0, 0, p_passView.bounds.size.width, p_passView.bounds.size.height);
    UIGraphicsBeginImageContext(l_viewRect.size);
    CGContextRef l_ctxref = UIGraphicsGetCurrentContext();
    [p_passView.layer renderInContext:l_ctxref];
    UIImage * l_fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef l_partimgref = CGImageCreateWithImageInRect(l_fullImage.CGImage, p_ofFrame);
    UIImage * l_resultImg = [UIImage imageWithCGImage:l_partimgref];
    CGImageRelease(l_partimgref);
    return l_resultImg;
}

+ (BOOL) isTextFieldIsEmpty:(UITextField*) p_txtField
{
    if ([p_txtField.text isEqualToString:nil]==YES)
        return YES;
    
    if ([p_txtField.text isEqualToString:@""]==YES)
        return YES;
    return NO;
}

+ (BOOL)isTextFieldIsValidEMail:(UITextField *)p_txtField
{
    NSString *l_emailid = p_txtField.text;
    NSString *l_emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *l_emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", l_emailRegex];
    BOOL l_isvalidemail = [l_emailTest evaluateWithObject:l_emailid];
    return l_isvalidemail;
}

@end
