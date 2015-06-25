//
//  ttrBaseNavController.h
//  TexTr
//
//  Created by Mohan Kumar on 22/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ttrDefaults.h"

@interface ttrBaseNavController : UINavigationController<UINavigationControllerDelegate>

@end

@interface ttrNavControllerTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>
- (instancetype) initWithNavOperation:(UINavigationControllerOperation) p_navOperation;

@end


