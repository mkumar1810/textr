//
//  ttrProfilePictureCapture.m
//  TexTr
//
//  Created by Mohan Kumar on 23/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrProfilePictureCapture.h"
#import "ttrDefaults.h"
#import "ttrCommonUtilities.h"

@interface ttrProfilePictureCapture()
{
    UIImagePickerController * _imagePicker;
}

@property (nonatomic,strong) UIToolbar * toolBar;
@property (nonatomic,strong) UIImageView * cameraStreamIV;
@property (nonatomic,retain) AVCaptureSession * snapshotCaptureSession;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer * snapshotPreviewLayer;
@property (nonatomic,retain) AVCaptureStillImageOutput * snapshotImage;

@end

@implementation ttrProfilePictureCapture

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    //[self setBackgroundColor:_bgColor];
    // Drawing code
    UIBarButtonItem * l_bar_cancel_btn, * l_bar_capture_btn;
    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, rect.size.width-1, 38.0)];
    self.toolBar.translucent = NO;
    self.toolBar.barTintColor = [UIColor colorWithWhite:0.98 alpha:1];
    self.toolBar.tintColor = [UIColor colorWithWhite:0.98 alpha:1];
    //[UIColor colorWithRed:74.0/255.0f green:74.0/255.0f blue:74.0/255.0f alpha:1];
    UILabel *l_titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 38)];
    l_titlelabel.text = [NSString stringWithFormat:@"Make Snapshot"];
    l_titlelabel.font = [UIFont boldSystemFontOfSize:18.0f];
    l_titlelabel.textAlignment = NSTextAlignmentCenter;
    l_titlelabel.textColor = [ttrDefaults getDefaultTextColor];
    UIBarButtonItem *l_titlebutton = [[UIBarButtonItem alloc] initWithCustomView:l_titlelabel];
    UIBarButtonItem *l_flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *l_flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIButton * l_captureButton = [[UIButton alloc] initWithFrame:CGRectMake(2, 2, 56, 26)];
    [l_captureButton setTitle:@"Capture" forState:UIControlStateNormal];
    [l_captureButton setTitleColor:[ttrDefaults getDefaultTextColor] forState:UIControlStateNormal];
    l_captureButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [l_captureButton addTarget:self action:@selector(captureImage) forControlEvents:UIControlEventTouchUpInside];
    l_bar_capture_btn = [[UIBarButtonItem alloc] initWithCustomView:l_captureButton];
    
    UIButton * l_cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(2, 2, 56, 26)];
    [l_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [l_cancelButton setTitleColor:[ttrDefaults getDefaultTextColor] forState:UIControlStateNormal];
    [l_cancelButton addTarget:self action:@selector(cancelImageCapture) forControlEvents:UIControlEventTouchUpInside];
    l_cancelButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    l_bar_cancel_btn = [[UIBarButtonItem alloc] initWithCustomView:l_cancelButton];
    
    self.toolBar.items = @[l_bar_cancel_btn, l_flex1, l_titlebutton, l_flex2, l_bar_capture_btn];
    [self addSubview:self.toolBar];
    self.cameraStreamIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 38.0, rect.size.width, rect.size.height-38.0)];
    [self.cameraStreamIV setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.cameraStreamIV];
    
    CGContextRef l_newctxt = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(l_newctxt, 1.0);
    CGContextSetStrokeColorWithColor(l_newctxt, [UIColor grayColor].CGColor);
    
    CGContextMoveToPoint(l_newctxt, 0, 38);
    CGContextAddLineToPoint(l_newctxt, rect.size.width-1, 38);
    CGContextStrokePath(l_newctxt);
    
    [self openCamera];
}


- (void) captureImage
{
    AVCaptureConnection *l_videoConnection = nil;
    for (AVCaptureConnection *l_connection in self.snapshotImage.connections)
    {
        for (AVCaptureInputPort *l_port in [l_connection inputPorts])
        {
            if ([[l_port mediaType] isEqual:AVMediaTypeVideo] )
            {
                l_videoConnection = l_connection;
                break;
            }
        }
        if (l_videoConnection)
        {
            break;
        }
    }
    
    [self.snapshotImage captureStillImageAsynchronouslyFromConnection:l_videoConnection completionHandler: ^(CMSampleBufferRef p_imageSampleBuffer, NSError *p_error)
     {
         CFDictionaryRef l_exifAttachments = CMGetAttachment( p_imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (l_exifAttachments)
         {
             // Do something with the attachments.
             //NSLog(@"attachements: %@", l_exifAttachments);
         } else {
             [self showAlertMessage:@"Please take snap again"];
             [self.imageDataDelegate cancelSnapShotSelection];
             return ;
         }
         
         NSData * l_imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:p_imageSampleBuffer];
         //UIImage *l_image = [[UIImage alloc] initWithData:l_imageData];
         
         //self.cameraStreamIV.image = [UIImage imageWithData:l_imageData];
         [self.imageDataDelegate snapShotCaptured:l_imageData];
         
         //UIImageWriteToSavedPhotosAlbum(l_image, nil, nil, nil);
     }];
    [self.snapshotCaptureSession stopRunning];
}




- (void) showAlertMessage:(NSString*) p_showMessage
{
    UIAlertView *l_alert = [[UIAlertView alloc] initWithTitle:@"" message:p_showMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [l_alert show];
}

- (void) cancelImageCapture
{
    [self.imageDataDelegate cancelSnapShotSelection];
}

- (void) openCamera
{
    NSError * l_error;
    NSArray * l_mediadevices = [AVCaptureDevice devices];
    AVCaptureDevice * l_capturedevice;
    for (AVCaptureDevice * l_mediadevice in l_mediadevices)
    {
        if ([l_mediadevice hasMediaType:AVMediaTypeVideo]) {
            
            if ([l_mediadevice position] == AVCaptureDevicePositionFront)
            {
                l_capturedevice = l_mediadevice;
                break;
            }
        }
    }
    

    //AVCaptureDevice * l_capturedevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //l_capturedevice.position = AVCaptureDevicePositionFront;
    AVCaptureDeviceInput * l_captureinput = [AVCaptureDeviceInput deviceInputWithDevice:l_capturedevice error:&l_error];
    if (!l_captureinput) {
        NSLog(@"the error is %@", [l_error localizedDescription]);
        return;
    }
    
    self.snapshotCaptureSession = [[AVCaptureSession alloc] init];
    [self.snapshotCaptureSession addInput:l_captureinput];
    AVCaptureMetadataOutput * l_barcodedataoutput = [[AVCaptureMetadataOutput alloc] init];
    [self.snapshotCaptureSession addOutput:l_barcodedataoutput];
    self.snapshotPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.snapshotCaptureSession];
    [self.snapshotPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    //CGRect l_originalframe = self.cameraStreamIV.frame;
    //self.cameraStreamIV.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
    //self.cameraStreamIV.frame = l_originalframe;
    self.cameraStreamIV.backgroundColor = [UIColor redColor];
    [self.snapshotPreviewLayer setFrame:self.cameraStreamIV.bounds];
    [self.cameraStreamIV.layer addSublayer:self.snapshotPreviewLayer];
    self.snapshotImage = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *l_outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.snapshotImage setOutputSettings:l_outputSettings];
    [self.snapshotCaptureSession addOutput:self.snapshotImage];
    [self.snapshotCaptureSession startRunning];
}


@end
