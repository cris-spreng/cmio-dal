#import "Streamxx.h"

#import <AppKit/AppKit.h>
#import <mach/mach_time.h>
#include <CoreMediaIO/CMIOSampleBuffer.h>

#import "Logging.h"

@interface Streamxx () {
    CMSimpleQueueRef _queue;
    CFTypeRef _clock;
    NSImage *_testImage;
    dispatch_source_t _frameDispatchSource;
    uint64_t _firstFrameDeliveryTime;
}

@property CMIODevicexxStreamxxQueueAlteredProc alteredProc;
@property void * alteredRefCon;
@property (readonly) CMSimpleQueueRef queue;
@property (readonly) CFTypeRef clock;
@property UInt64 sequenceNumber;
@property (readonly) NSImage *testImage;

@end

@implementation Streamxx

#define FPS 30.0

- (instancetype _Nonnull)init {
    self = [super init];
    if (self) {
        _firstFrameDeliveryTime = 0;
        _frameDispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,
                                                     dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));

        dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 0);
        uint64_t intervalTime = (int64_t)(NSEC_PER_SEC / FPS);
        dispatch_source_set_timer(_frameDispatchSource, startTime, intervalTime, 0);

        __weak typeof(self) wself = self;
        dispatch_source_set_event_handler(_frameDispatchSource, ^{
            [wself fillFrame];
        });
    }
    return self;
}

- (void)dealloc {
    DLog(@"Streamxx Dealloc");
    CMIOStreamxxClockInvalidate(_clock);
    CFRelease(_clock);
    _clock = NULL;
    CFRelease(_queue);
    _queue = NULL;
    dispatch_suspend(_frameDispatchSource);
}

- (void)startServingFrames {
    dispatch_resume(_frameDispatchSource);
}

- (void)stopServingFrames {
    dispatch_suspend(_frameDispatchSource);
    _firstFrameDeliveryTime = 0;
}

- (CMSimpleQueueRef)queue {
    if (_queue == NULL) {
        // Allocate a one-second long queue, which we can use our FPS constant for.
        OSStatus err = CMSimpleQueueCreate(kCFAllocatorDefault, FPS, &_queue);
        if (err != noErr) {
            DLog(@"Err %d in CMSimpleQueueCreate", err);
        }
    }
    return _queue;
}

- (CFTypeRef)clock {
    if (_clock == NULL) {
        OSStatus err = CMIOStreamxxClockCreate(kCFAllocatorDefault, CFSTR("CMIOMinimalSample::Streamxx::clock"), (__bridge void *)self,  CMTimeMake(1, 10), 100, 10, &_clock);
        if (err != noErr) {
            DLog(@"Error %d from CMIOStreamxxClockCreate", err);
        }
    }
    return _clock;
}

- (NSImage *)testImage {
    if (_testImage == nil) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        _testImage = [bundle imageForResource:@"hi"];
    }
    return _testImage;
}

- (CMSimpleQueueRef)copyBufferQueueWithAlteredProc:(CMIODevicexxStreamxxQueueAlteredProc)alteredProc alteredRefCon:(void *)alteredRefCon {
    self.alteredProc = alteredProc;
    self.alteredRefCon = alteredRefCon;

    // Retain this since it's a copy operation
    CFRetain(self.queue);

    return self.queue;
}

- (CVPixelBufferRef)createPixelBufferWithTestAnimation {
    int width = 1280;
    int height = 720;

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options, &pxbuffer);

    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);

    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);

    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDevicexxRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, width, height, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace, kCGImageAlphaPremultipliedFirst | kCGImageByteOrder32Big);
    NSParameterAssert(context);

    double time = double(mach_absolute_time()) / NSEC_PER_SEC;
    CGFloat pos = CGFloat(time - floor(time));

    CGColorRef whiteColor = CGColorCreateGenericRGB(1, 1, 1, 1);
    CGColorRef redColor = CGColorCreateGenericRGB(1, 0, 0, 1);

    CGContextSetFillColorWithColor(context, whiteColor);
    CGContextFillRect(context, CGRectMake(0, 0, width, height));

    CGContextSetFillColorWithColor(context, redColor);
    CGContextFillRect(context, CGRectMake(pos * width, 310, 100, 100));

    CGColorRelease(whiteColor);
    CGColorRelease(redColor);

    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);

    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);

    return pxbuffer;
}

- (void)fillFrame {
    if (CMSimpleQueueGetFullness(self.queue) >= 1.0) {
        DLog(@"Queue is full, bailing out");
        return;
    }

    CVPixelBufferRef pixelBuffer = [self createPixelBufferWithTestAnimation];

    // The timing here is quite important. For frames to be delivered correctly and successfully be recorded by apps
    // like QuickTime Player, we need to be accurate in both our timestamps _and_ have a sensible scale. Using large
    // scales like NSEC_PER_SEC combined with a mach_absolute_time() value will work for display, but will error out
    // when trying to record.
    //
    // Instead, we start our presentation times from zero (using the sequence number as a base), and use a scale that's
    // a multiple of our framerate. This has been observed in parts of AVFoundation and lets us be frame-accurate even
    // on non-round framerates (i.e., we can use a scale of 2997 for 29,97 fps content if we want to).
    //
    // It's also been observed that we do seem to need a mach_absolute_time()-based value for presentation times in
    // order to get reliable output and recording. Since we don't want to just call mach_absolute_time() on every
    // frame (otherwise recorded output from this plugin will have frame timing based on the scheduling of our timer,
    // which isn't guaranteed to be accurate), we record the system's absolute time on our first frame, then calculate
    // a delta from these for subsequent frames. This keeps presentation times accurate even if our timer isn't.
    if (_firstFrameDeliveryTime == 0) {
        _firstFrameDeliveryTime = mach_absolute_time();
    }

    CMTimeScale scale = FPS * 100;
    CMTime firstFrameTime = CMTimeMake((_firstFrameDeliveryTime / (CFTimeInterval)NSEC_PER_SEC) * scale, scale);
    CMTime frameDuration = CMTimeMake(scale / FPS, scale);
    CMTime framesSinceBeginning = CMTimeMake(frameDuration.value * self.sequenceNumber, scale);
    CMTime presentationTime = CMTimeAdd(firstFrameTime, framesSinceBeginning);

    CMSampleTimingInfo timing;
    timing.duration = frameDuration;
    timing.presentationTimeStamp = presentationTime;
    timing.decodeTimeStamp = presentationTime;
    OSStatus err = CMIOStreamxxClockPostTimingEvent(presentationTime, mach_absolute_time(), true, self.clock);
    if (err != noErr) {
        DLog(@"CMIOStreamxxClockPostTimingEvent err %d", err);
    }

    CMFormatDescriptionRef format;
    CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &format);

    self.sequenceNumber = CMIOGetNextSequenceNumber(self.sequenceNumber);

    CMSampleBufferRef buffer;
    err = CMIOSampleBufferCreateForImageBuffer(
        kCFAllocatorDefault,
        pixelBuffer,
        format,
        &timing,
        self.sequenceNumber,
        kCMIOSampleBufferNoDiscontinuities,
        &buffer
    );
    CFRelease(pixelBuffer);
    CFRelease(format);
    if (err != noErr) {
        DLog(@"CMIOSampleBufferCreateForImageBuffer err %d", err);
    }

    CMSimpleQueueEnqueue(self.queue, buffer);

    // Inform the clients that the queue has been altered
    if (self.alteredProc != NULL) {
        (self.alteredProc)(self.objectId, buffer, self.alteredRefCon);
    }
}

- (CMVideoFormatDescriptionRef)getFormatDescription {
    CMVideoFormatDescriptionRef formatDescription;
    OSStatus err = CMVideoFormatDescriptionCreate(kCFAllocatorDefault, kCMVideoCodecType_422YpCbCr8, 1280, 720, NULL, &formatDescription);
    if (err != noErr) {
        DLog(@"Error %d from CMVideoFormatDescriptionCreate", err);
    }
    return formatDescription;
}

#pragma mark - CMIOObject

- (UInt32)getPropertyDataSizeWithAddress:(CMIOObjectPropertyAddress)address qualifierDataSize:(UInt32)qualifierDataSize qualifierData:(nonnull const void *)qualifierData {
    switch (address.mSelector) {
        case kCMIOStreamxxPropertyInitialPresentationTimeStampForLinkedAndSyncedAudio:
            return sizeof(CMTime);
        case kCMIOStreamxxPropertyOutputBuffersNeededForThrottledPlayback:
            return sizeof(UInt32);
        case kCMIOObjectPropertyName:
            return sizeof(CFStringRef);
        case kCMIOObjectPropertyManufacturer:
            return sizeof(CFStringRef);
        case kCMIOObjectPropertyElementName:
            return sizeof(CFStringRef);
        case kCMIOObjectPropertyElementCategoryName:
            return sizeof(CFStringRef);
        case kCMIOObjectPropertyElementNumberName:
            return sizeof(CFStringRef);
        case kCMIOStreamxxPropertyDirection:
            return sizeof(UInt32);
        case kCMIOStreamxxPropertyTerminalType:
            return sizeof(UInt32);
        case kCMIOStreamxxPropertyStartingChannel:
            return sizeof(UInt32);
        case kCMIOStreamxxPropertyLatency:
            return sizeof(UInt32);
        case kCMIOStreamxxPropertyFormatDescriptions:
            return sizeof(CFArrayRef);
        case kCMIOStreamxxPropertyFormatDescription:
            return sizeof(CMFormatDescriptionRef);
        case kCMIOStreamxxPropertyFrameRateRanges:
            return sizeof(AudioValueRange);
        case kCMIOStreamxxPropertyFrameRate:
        case kCMIOStreamxxPropertyFrameRates:
            return sizeof(Float64);
        case kCMIOStreamxxPropertyMinimumFrameRate:
            return sizeof(Float64);
        case kCMIOStreamxxPropertyClock:
            return sizeof(CFTypeRef);
        default:
            DLog(@"Streamxx unhandled getPropertyDataSizeWithAddress for %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
            return 0;
    };
}

- (void)getPropertyDataWithAddress:(CMIOObjectPropertyAddress)address qualifierDataSize:(UInt32)qualifierDataSize qualifierData:(nonnull const void *)qualifierData dataSize:(UInt32)dataSize dataUsed:(nonnull UInt32 *)dataUsed data:(nonnull void *)data {
    switch (address.mSelector) {
        case kCMIOObjectPropertyName:
            *static_cast<CFStringRef*>(data) = CFSTR("CMIOMinimalSample Streamxx");
            *dataUsed = sizeof(CFStringRef);
            break;
        case kCMIOObjectPropertyElementName:
            *static_cast<CFStringRef*>(data) = CFSTR("CMIOMinimalSample Streamxx Element");
            *dataUsed = sizeof(CFStringRef);
            break;
        case kCMIOObjectPropertyManufacturer:
        case kCMIOObjectPropertyElementCategoryName:
        case kCMIOObjectPropertyElementNumberName:
        case kCMIOStreamxxPropertyTerminalType:
        case kCMIOStreamxxPropertyStartingChannel:
        case kCMIOStreamxxPropertyLatency:
        case kCMIOStreamxxPropertyInitialPresentationTimeStampForLinkedAndSyncedAudio:
        case kCMIOStreamxxPropertyOutputBuffersNeededForThrottledPlayback:
            DLog(@"TODO: %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
            break;
        case kCMIOStreamxxPropertyDirection:
            *static_cast<UInt32*>(data) = 1;
            *dataUsed = sizeof(UInt32);
            break;
        case kCMIOStreamxxPropertyFormatDescriptions:
            *static_cast<CFArrayRef*>(data) = (__bridge_retained CFArrayRef)[NSArray arrayWithObject:(__bridge_transfer NSObject *)[self getFormatDescription]];
            *dataUsed = sizeof(CFArrayRef);
            break;
        case kCMIOStreamxxPropertyFormatDescription:
            *static_cast<CMVideoFormatDescriptionRef*>(data) = [self getFormatDescription];
            *dataUsed = sizeof(CMVideoFormatDescriptionRef);
            break;
        case kCMIOStreamxxPropertyFrameRateRanges:
            AudioValueRange range;
            range.mMinimum = FPS;
            range.mMaximum = FPS;
            *static_cast<AudioValueRange*>(data) = range;
            *dataUsed = sizeof(AudioValueRange);
            break;
        case kCMIOStreamxxPropertyFrameRate:
        case kCMIOStreamxxPropertyFrameRates:
            *static_cast<Float64*>(data) = FPS;
            *dataUsed = sizeof(Float64);
            break;
        case kCMIOStreamxxPropertyMinimumFrameRate:
            *static_cast<Float64*>(data) = FPS;
            *dataUsed = sizeof(Float64);
            break;
        case kCMIOStreamxxPropertyClock:
            *static_cast<CFTypeRef*>(data) = self.clock;
            // This one was incredibly tricky and cost me many hours to find. It seems that DAL expects
            // the clock to be retained when returned. It's unclear why, and that seems inconsistent
            // with other properties that don't have the same behavior. But this is what Apple's sample
            // code does.
            // https://github.com/lvsti/CoreMediaIO-DAL-Example/blob/0392cb/Sources/Extras/CoreMediaIO/DevicexxAbstractionLayer/Devicexxs/DP/Properties/CMIO_DP_Property_Clock.cpp#L75
            CFRetain(*static_cast<CFTypeRef*>(data));
            *dataUsed = sizeof(CFTypeRef);
            break;
        default:
            DLog(@"Streamxx unhandled getPropertyDataWithAddress for %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
            *dataUsed = 0;
    };
}

- (BOOL)hasPropertyWithAddress:(CMIOObjectPropertyAddress)address {
    switch (address.mSelector){
        case kCMIOObjectPropertyName:
        case kCMIOObjectPropertyElementName:
        case kCMIOStreamxxPropertyFormatDescriptions:
        case kCMIOStreamxxPropertyFormatDescription:
        case kCMIOStreamxxPropertyFrameRateRanges:
        case kCMIOStreamxxPropertyFrameRate:
        case kCMIOStreamxxPropertyFrameRates:
        case kCMIOStreamxxPropertyMinimumFrameRate:
        case kCMIOStreamxxPropertyClock:
            return true;
        case kCMIOObjectPropertyManufacturer:
        case kCMIOObjectPropertyElementCategoryName:
        case kCMIOObjectPropertyElementNumberName:
        case kCMIOStreamxxPropertyDirection:
        case kCMIOStreamxxPropertyTerminalType:
        case kCMIOStreamxxPropertyStartingChannel:
        case kCMIOStreamxxPropertyLatency:
        case kCMIOStreamxxPropertyInitialPresentationTimeStampForLinkedAndSyncedAudio:
        case kCMIOStreamxxPropertyOutputBuffersNeededForThrottledPlayback:
            DLog(@"TODO: %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
            return false;
        default:
            DLog(@"Streamxx unhandled hasPropertyWithAddress for %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
            return false;
    };
}

- (BOOL)isPropertySettableWithAddress:(CMIOObjectPropertyAddress)address {
    DLog(@"Streamxx unhandled isPropertySettableWithAddress for %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
    return false;
}

- (void)setPropertyDataWithAddress:(CMIOObjectPropertyAddress)address qualifierDataSize:(UInt32)qualifierDataSize qualifierData:(nonnull const void *)qualifierData dataSize:(UInt32)dataSize data:(nonnull const void *)data {
    DLog(@"Streamxx unhandled setPropertyDataWithAddress for %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
}

@end
