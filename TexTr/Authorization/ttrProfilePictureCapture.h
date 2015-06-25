//
//  ttrProfilePictureCapture.h
//  TexTr
//
//  Created by Mohan Kumar on 23/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/CGImageProperties.h>


@protocol ttrProfilePictureCaptureDelegates <NSObject>

- (void) cancelSnapShotSelection;
- (void) snapShotCaptured:(NSData*) p_snapshotImageData;

@end

@interface ttrProfilePictureCapture : UIView <AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate>

@property (nonatomic) CGAffineTransform originalTransform;
@property (nonatomic, weak) id<ttrProfilePictureCaptureDelegates> imageDataDelegate;

@end
