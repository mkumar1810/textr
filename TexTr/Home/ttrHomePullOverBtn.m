//
//  ttrHomePullOverBtn.m
//  TexTr
//
//  Created by Mohan Kumar on 29/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrHomePullOverBtn.h"

@interface ttrHomePullOverBtn()
{
    UIImageView * _arrowImg;

}

@end

@implementation ttrHomePullOverBtn
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef l_ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef l_cmtpathRef = CGPathCreateMutable();
    CGPathMoveToPoint(l_cmtpathRef, NULL, 1.0, 0.0);
    CGPathAddLineToPoint(l_cmtpathRef, NULL, rect.size.width-1,0);
    CGPathAddArc(l_cmtpathRef, NULL, rect.size.width-1.0, 1.0 , 1.0, -M_PI_2,0,  NO);
    CGPathAddLineToPoint(l_cmtpathRef, NULL, rect.size.width, rect.size.height - 1);
    CGPathAddArc(l_cmtpathRef, NULL, rect.size.width-1, rect.size.height - 1, 1.0, 0, M_PI_2, NO);
    CGPathAddLineToPoint(l_cmtpathRef, NULL, 1, rect.size.height);
    CGPathAddArc(l_cmtpathRef, NULL, 1, rect.size.height - 1, 1.0, M_PI_2,M_PI, NO);
    CGPathAddLineToPoint(l_cmtpathRef, NULL, 0, 1.0);
    CGPathAddArc(l_cmtpathRef, NULL, 1,1, 1.0, M_PI,3.0*M_PI_2, NO);
    CGPathCloseSubpath(l_cmtpathRef);
    CGContextAddPath(l_ctx, l_cmtpathRef);
    CGContextSetFillColorWithColor(l_ctx, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7].CGColor);
    CGContextFillPath(l_ctx);
    CGContextStrokePath(l_ctx);
    CGPathRelease(l_cmtpathRef);
    
    CGContextSetStrokeColorWithColor(l_ctx, [UIColor colorWithWhite:0.8 alpha:0.9].CGColor);
    CGContextSetLineWidth(l_ctx, 1.0f);
    CGMutablePathRef l_newlinepathRef = CGPathCreateMutable();
    CGPathMoveToPoint(l_newlinepathRef, NULL, 0, 1.0);
    CGPathAddLineToPoint(l_newlinepathRef, NULL, rect.size.width-2,1.0);
    CGPathAddArc(l_newlinepathRef, NULL, rect.size.width-2.0, 2.0 , 1.0, -M_PI_2,0,  NO);
    CGPathAddLineToPoint(l_newlinepathRef, NULL, rect.size.width-1, rect.size.height - 2);
    CGPathAddArc(l_newlinepathRef, NULL, rect.size.width-2, rect.size.height - 2, 1.0, 0, M_PI_2, NO);
    CGPathAddLineToPoint(l_newlinepathRef, NULL, 0, rect.size.height-1);
    CGPathCloseSubpath(l_cmtpathRef);
    CGContextAddPath(l_ctx, l_newlinepathRef);
    CGContextStrokePath(l_ctx);
    CGPathRelease(l_newlinepathRef);
    
    _arrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(rect.size.width/2.0-10, rect.size.height/2.0-10,20.0, 20.0)];
    [self addSubview:_arrowImg];
    _arrowImg.image = [UIImage imageNamed:@"rightarr"];
}

- (void) changeTheArrowDirectionToRight
{
    _arrowImg.image = [UIImage imageNamed:@"rightarr"];
}

- (void)changeTheArrowDirectionToLeft
{
    _arrowImg.image = [UIImage imageNamed:@"leftarr"];
}

@end
