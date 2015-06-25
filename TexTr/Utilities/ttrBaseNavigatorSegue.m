//
//  ttrBaseNavigatorSegue.m
//  TexTr
//
//  Created by Mohan Kumar on 22/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrBaseNavigatorSegue.h"
#import "ttrBaseController.h"

@implementation ttrBaseNavigatorSegue


- (instancetype) initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    self = [super initWithIdentifier:identifier source:source destination:destination];
    if (self) {
        //
    }
    return self;
}

- (void) perform
{
    UIViewController * l_src = (UIViewController*) self.sourceViewController;
    UIViewController * l_dest = (UIViewController*) self.destinationViewController;
    if ([l_dest respondsToSelector:@selector(initializeDataWithParams:)])
    {
        id<ttrCustNaviDelegates>  l_srcdlg = (id<ttrCustNaviDelegates>) l_src;
        id<ttrCustNaviDelegates>  l_destdlg = (id<ttrCustNaviDelegates>) l_dest;
        [l_destdlg initializeDataWithParams:l_srcdlg.navigateParams];
    }
    [l_src.navigationController pushViewController:l_dest animated:YES];
}

@end
