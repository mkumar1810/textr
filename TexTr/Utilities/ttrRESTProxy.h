//
//  ttrRESTProxy.h
//  TexTr
//
//  Created by Mohan Kumar on 24/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ttrDefaults.h"

@interface ttrRESTProxy : NSObject

- (void) initDatawithAPIType:(NSString*) p_apiType andInputParams:(NSDictionary*) p_prmDict  andReturnMethod:(GENERICCALLBACK) p_returnMethod;

@end
