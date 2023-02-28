#import "PlugInxx.h"

#import <CoreMediaIO/CMIOHardwarePlugInxx.h>

#import "Logging.h"

@implementation PlugInxx

+ (PlugInxx *)SharedPlugInxx {
    static PlugInxx *sPlugInxx = nil;
    static dispatch_once_t sOnceToken;
    dispatch_once(&sOnceToken, ^{
        sPlugInxx = [[self alloc] init];
    });
    return sPlugInxx;
}

- (void)initialize {
}

- (void)teardown {
}

#pragma mark - CMIOObject

- (BOOL)hasPropertyWithAddress:(CMIOObjectPropertyAddress)address {
    switch (address.mSelector) {
        case kCMIOObjectPropertyName:
            return true;
        default:
            DLog(@"PlugInxx unhandled hasPropertyWithAddress for %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
            return false;
    };
}

- (BOOL)isPropertySettableWithAddress:(CMIOObjectPropertyAddress)address {
    switch (address.mSelector) {
        case kCMIOObjectPropertyName:
            return false;
        default:
            DLog(@"PlugInxx unhandled isPropertySettableWithAddress for %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
            return false;
    };
}

- (UInt32)getPropertyDataSizeWithAddress:(CMIOObjectPropertyAddress)address qualifierDataSize:(UInt32)qualifierDataSize qualifierData:(const void*)qualifierData {
    switch (address.mSelector) {
        case kCMIOObjectPropertyName:
            return sizeof(CFStringRef);
        default:
            DLog(@"PlugInxx unhandled getPropertyDataSizeWithAddress for %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
            return 0;
    };
}

- (void)getPropertyDataWithAddress:(CMIOObjectPropertyAddress)address qualifierDataSize:(UInt32)qualifierDataSize qualifierData:(nonnull const void *)qualifierData dataSize:(UInt32)dataSize dataUsed:(nonnull UInt32 *)dataUsed data:(nonnull void *)data {
    switch (address.mSelector) {
        case kCMIOObjectPropertyName:
            *static_cast<CFStringRef*>(data) = CFSTR("CMIOMinimalSample PlugInxx");
            *dataUsed = sizeof(CFStringRef);
            return;
        default:
            DLog(@"PlugInxx unhandled getPropertyDataWithAddress for %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
            return;
        };
}

- (void)setPropertyDataWithAddress:(CMIOObjectPropertyAddress)address qualifierDataSize:(UInt32)qualifierDataSize qualifierData:(nonnull const void *)qualifierData dataSize:(UInt32)dataSize data:(nonnull const void *)data {
    DLog(@"PlugInxx unhandled setPropertyDataWithAddress for %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
}

@end
