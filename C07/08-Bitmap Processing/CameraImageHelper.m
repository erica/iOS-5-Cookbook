/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
#import "CameraImageHelper.h"
#import "Orientation.h"
#import "UIImage-Utilities.h"

#pragma mark Camera Image Helper

@implementation CameraImageHelper
@synthesize ciImage, session, isUsingFrontCamera;

#pragma mark Available Cameras
+ (int) numberOfCameras
{
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
}

+ (BOOL) backCameraAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices)
        if (device.position == AVCaptureDevicePositionBack) return YES;
    return NO;
}

+ (BOOL) frontCameraAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices)
        if (device.position == AVCaptureDevicePositionFront) return YES;
    return NO;
}

+ (AVCaptureDevice *)backCamera
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices)
        if (device.position == AVCaptureDevicePositionBack) return device;
    
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

+ (AVCaptureDevice *)frontCamera
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices)
        if (device.position == AVCaptureDevicePositionFront) return device;
    
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

#pragma mark Orientation: UIImage
- (UIImageOrientation) currentImageOrientation
{
    return currentImageOrientation(isUsingFrontCamera, NO);
}

#pragma mark image
- (UIImage *) currentImage
{
    UIImageOrientation orientation = currentImageOrientation(isUsingFrontCamera, NO);
    return [UIImage imageWithCIImage:self.ciImage orientation:orientation];
}

#pragma mark Preview Handling
- (void) embedPreviewInView: (UIView *) aView
{
    if (!session) return;
    
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession: session];
    preview.frame = aView.bounds;
    preview.videoGravity = AVLayerVideoGravityResizeAspect; // hmmm.
    [aView.layer addSublayer: preview];
}

- (UIView *) previewWithFrame: (CGRect) aFrame
{
    if (!session) return nil;    
    
    UIView *view = [[UIView alloc] initWithFrame:aFrame];
    [self embedPreviewInView:view];
    
    return view;
}

- (AVCaptureVideoPreviewLayer *) previewInView: (UIView *) view
{
    for (CALayer *layer in view.layer.sublayers)
        if ([layer isKindOfClass:[AVCaptureVideoPreviewLayer class]])
            return (AVCaptureVideoPreviewLayer *)layer;
    
    return nil;
}

- (void) layoutPreviewInView: (UIView *) aView
{
    AVCaptureVideoPreviewLayer *layer = [self previewInView:aView];
    if (!layer) return;

    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CATransform3D transform = CATransform3DIdentity;
    if (orientation == UIDeviceOrientationPortrait) ;
    else if (orientation == UIDeviceOrientationLandscapeLeft)
        transform = CATransform3DMakeRotation(-M_PI_2, 0.0f, 0.0f, 1.0f);
    else if (orientation == UIDeviceOrientationLandscapeRight)
        transform = CATransform3DMakeRotation(M_PI_2, 0.0f, 0.0f, 1.0f);
    else if (orientation == UIDeviceOrientationPortraitUpsideDown)
        transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
    
    layer.transform = transform;
    layer.frame = aView.frame;
}

#pragma mark Capture

- (void) switchCameras
{
    if (![CameraImageHelper numberOfCameras] > 1) return;
    
    isUsingFrontCamera = !isUsingFrontCamera;
    AVCaptureDevice *newDevice = isUsingFrontCamera ? [CameraImageHelper frontCamera] : [CameraImageHelper backCamera];
    
    [session beginConfiguration];
    
    // Remove existing inputs
    for (AVCaptureInput *input in [session inputs])
        [session removeInput:input];
    
    // Change the input
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:nil];
    [session addInput:captureInput];
    
    [session commitConfiguration];
}

// Autorelease pool added thanks to suggestion by Josh Snyder -- May not be
// needed any more under ARC but retained in code for now
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool 
    {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
        self.ciImage = [[CIImage alloc] initWithCVPixelBuffer:imageBuffer options:(__bridge_transfer NSDictionary *)attachments];
    }
}

#pragma mark Setup

- (void) startRunningSession
{
    if (session.running) return;
    [session startRunning];
}

- (void) stopRunningSession
{
    [session stopRunning];
}

- (void) establishCamera: (uint) whichCamera
{
    NSError *error;
    
    // Is a camera available
    if (![CameraImageHelper numberOfCameras]) return;

    // Choose camera
    isUsingFrontCamera = NO;
    if ((whichCamera == kCameraFront) && [CameraImageHelper frontCameraAvailable])
        isUsingFrontCamera = YES;

    // Retrieve the selected camera
    AVCaptureDevice *device = isUsingFrontCamera ? [CameraImageHelper frontCamera] : [CameraImageHelper backCamera];
    
    // Create the capture input
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!captureInput)
    {    
        NSLog(@"Error establishing device input: %@", error); 
        return;
    }
    
    // Create capture output
    // Update thanks to Jake Marsh who points out not to use the main queue
    char *queueName = "com.sadun.tasks.grabFrames";
    dispatch_queue_t queue = dispatch_queue_create(queueName, NULL);  
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES; 
    [captureOutput setSampleBufferDelegate:self queue:queue];
    
    // Establish settings
    NSDictionary *settings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
    [captureOutput setVideoSettings:settings];
    
    // Create a session
    self.session = [[AVCaptureSession alloc] init];
    [session addInput:captureInput];
    [session addOutput:captureOutput];
}

#pragma mark Creation

- (id) init
{
    if (!(self = [super init])) return self;
    [self establishCamera: kCameraBack];
    return self;
}    

- (id) initWithCamera: (uint) whichCamera
{
    if (!(self = [super init])) return self;    
    [self establishCamera: whichCamera];
    return self;
}

+ (id) helperWithCamera: (uint) whichCamera
{
    CameraImageHelper *helper = [[CameraImageHelper alloc] initWithCamera:(uint) whichCamera];
    return helper;
}

@end
