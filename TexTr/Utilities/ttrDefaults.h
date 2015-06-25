//
//  ttrDefaults.h
//  TexTr
//
//  Created by Mohan Kumar on 22/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define MAIN_API_HOST_URL  @"https://api.parse.com/1"
#define PARSE_APPLICATION_ID @"4pbyM3kZr8JaYxAnwd4UNQIZ6WsGqPy98p14QaEk"
#define PARSE_REST_API_KEY @"geCJgJVna8l0N3wTQ4yC8BFE9CdJG02Urgg66hHM"

typedef enum {
    noanimation,
    //horizontal,
    horizontalWithoutBounce,
    //vertical,
    popOutVerticalOpen,
    horizontalWithBounce,
    //pageCurlFromright
} TransitionType;

typedef void (^NOPARAMCALLBACK) ();
typedef void (^DICTIONARYCALLBACK) (NSDictionary*);
typedef void (^ARRAYCALLBACK) (NSArray*);
typedef void (^GENERICCALLBACK) (id);
typedef void (^STRINGCALLBACK) (NSString *);

@protocol ttrCustNaviDelegates <NSObject>

@property (nonatomic) TransitionType transitionType;
@property (nonatomic,retain) NSDictionary * navigateParams;

@optional

- (void) pushAnimation:(TransitionType) p_pushAnimationType;
- (void) popAnimation:(TransitionType) p_popAnimationType;
- (void) popAnimationCompleted;
- (void) pushanimationCompleted;
- (CGRect) getPopOutFrame;
- (UIImage*) getPopOutTopImage;
- (UIImage*) getPopOutBottomImage;
- (UIImage*) getPopOutImage;
- (void) initializeDataWithParams:(NSDictionary*) p_initParams;

@end

@interface ttrDefaults : NSObject

+ (UILabel*) getStandardLabelWithText:(NSString*) p_lblText;
+ (UITextField*) getStandardTextField;
+ (UIButton*) getStandardButton;
+ (UIButton*) getStandardButtonWithText:(NSString*) p_btnText;
+ (UIColor*) getDefaultTextColor;

@end
