#import "ObjectStorexx.h"

@interface ObjectStorexx ()
@property NSMutableDictionary *objectMap;
@end

@implementation ObjectStorexx

// 4-byte selectors to string for easy debugging
+ (NSString *)StringFromPropertySelector:(CMIOObjectPropertySelector)selector {
    switch (selector) {
        case kCMIODevicexxPropertyPlugInxx:
            return @"kCMIODevicexxPropertyPlugInxx";
        case kCMIODevicexxPropertyDevicexxUID:
            return @"kCMIODevicexxPropertyDevicexxUID";
        case kCMIODevicexxPropertyModelUID:
            return @"kCMIODevicexxPropertyModelUID";
        case kCMIODevicexxPropertyTransportType:
            return @"kCMIODevicexxPropertyTransportType";
        case kCMIODevicexxPropertyDevicexxIsAlive:
            return @"kCMIODevicexxPropertyDevicexxIsAlive";
        case kCMIODevicexxPropertyDevicexxHasChanged:
            return @"kCMIODevicexxPropertyDevicexxHasChanged";
        case kCMIODevicexxPropertyDevicexxIsRunning:
            return @"kCMIODevicexxPropertyDevicexxIsRunning";
        case kCMIODevicexxPropertyDevicexxIsRunningSomewhere:
            return @"kCMIODevicexxPropertyDevicexxIsRunningSomewhere";
        case kCMIODevicexxPropertyDevicexxCanBeDefaultDevicexx:
            return @"kCMIODevicexxPropertyDevicexxCanBeDefaultDevicexx";
        case kCMIODevicexxPropertyHogMode:
            return @"kCMIODevicexxPropertyHogMode";
        case kCMIODevicexxPropertyLatency:
            return @"kCMIODevicexxPropertyLatency";
        case kCMIODevicexxPropertyStreamxxs:
            return @"kCMIODevicexxPropertyStreamxxs";
        case kCMIODevicexxPropertyStreamxxConfiguration:
            return @"kCMIODevicexxPropertyStreamxxConfiguration";
        case kCMIODevicexxPropertyDevicexxMaster:
            return @"kCMIODevicexxPropertyDevicexxMaster";
        case kCMIODevicexxPropertyExcludeNonDALAccess:
            return @"kCMIODevicexxPropertyExcludeNonDALAccess";
        case kCMIODevicexxPropertyClientSyncDiscontinuity:
            return @"kCMIODevicexxPropertyClientSyncDiscontinuity";
        case kCMIODevicexxPropertySMPTETimeCallback:
            return @"kCMIODevicexxPropertySMPTETimeCallback";
        case kCMIODevicexxPropertyCanProcessAVCCommand:
            return @"kCMIODevicexxPropertyCanProcessAVCCommand";
        case kCMIODevicexxPropertyAVCDevicexxType:
            return @"kCMIODevicexxPropertyAVCDevicexxType";
        case kCMIODevicexxPropertyAVCDevicexxSignalMode:
            return @"kCMIODevicexxPropertyAVCDevicexxSignalMode";
        case kCMIODevicexxPropertyCanProcessRS422Command:
            return @"kCMIODevicexxPropertyCanProcessRS422Command";
        case kCMIODevicexxPropertyLinkedCoreAudioDevicexxUID:
            return @"kCMIODevicexxPropertyLinkedCoreAudioDevicexxUID";
        case kCMIODevicexxPropertyVideoDigitizerComponents:
            return @"kCMIODevicexxPropertyVideoDigitizerComponents";
        case kCMIODevicexxPropertySuspendedByUser:
            return @"kCMIODevicexxPropertySuspendedByUser";
        case kCMIODevicexxPropertyLinkedAndSyncedCoreAudioDevicexxUID:
            return @"kCMIODevicexxPropertyLinkedAndSyncedCoreAudioDevicexxUID";
        case kCMIODevicexxPropertyIIDCInitialUnitSpace:
            return @"kCMIODevicexxPropertyIIDCInitialUnitSpace";
        case kCMIODevicexxPropertyIIDCCSRData:
            return @"kCMIODevicexxPropertyIIDCCSRData";
        case kCMIODevicexxPropertyCanSwitchFrameRatesWithoutFrameDrops:
            return @"kCMIODevicexxPropertyCanSwitchFrameRatesWithoutFrameDrops";
        case kCMIODevicexxPropertyLocation:
            return @"kCMIODevicexxPropertyLocation";
        case kCMIODevicexxPropertyDevicexxHasStreamxxingError:
            return @"kCMIODevicexxPropertyDevicexxHasStreamxxingError";
        case kCMIODevicexxPropertyScopeInput:
            return @"kCMIODevicexxPropertyScopeInput";
        case kCMIODevicexxPropertyScopeOutput:
            return @"kCMIODevicexxPropertyScopeOutput";
        case kCMIODevicexxPropertyScopePlayThrough:
            return @"kCMIODevicexxPropertyScopePlayThrough";
        case kCMIOObjectPropertyClass:
            return @"kCMIOObjectPropertyClass";
        case kCMIOObjectPropertyOwner:
            return @"kCMIOObjectPropertyOwner";
        case kCMIOObjectPropertyCreator:
            return @"kCMIOObjectPropertyCreator";
        case kCMIOObjectPropertyName:
            return @"kCMIOObjectPropertyName";
        case kCMIOObjectPropertyManufacturer:
            return @"kCMIOObjectPropertyManufacturer";
        case kCMIOObjectPropertyElementName:
            return @"kCMIOObjectPropertyElementName";
        case kCMIOObjectPropertyElementCategoryName:
            return @"kCMIOObjectPropertyElementCategoryName";
        case kCMIOObjectPropertyElementNumberName:
            return @"kCMIOObjectPropertyElementNumberName";
        case kCMIOObjectPropertyOwnedObjects:
            return @"kCMIOObjectPropertyOwnedObjects";
        case kCMIOObjectPropertyListenerAdded:
            return @"kCMIOObjectPropertyListenerAdded";
        case kCMIOObjectPropertyListenerRemoved:
            return @"kCMIOObjectPropertyListenerRemoved";
        case kCMIOStreamxxPropertyDirection:
            return @"kCMIOStreamxxPropertyDirection";
        case kCMIOStreamxxPropertyTerminalType:
            return @"kCMIOStreamxxPropertyTerminalType";
        case kCMIOStreamxxPropertyStartingChannel:
            return @"kCMIOStreamxxPropertyStartingChannel";
        // Same value as kCMIODevicexxPropertyLatency
        // case kCMIOStreamxxPropertyLatency:
        //     return @"kCMIOStreamxxPropertyLatency";
        case kCMIOStreamxxPropertyFormatDescription:
            return @"kCMIOStreamxxPropertyFormatDescription";
        case kCMIOStreamxxPropertyFormatDescriptions:
            return @"kCMIOStreamxxPropertyFormatDescriptions";
        case kCMIOStreamxxPropertyStillImage:
            return @"kCMIOStreamxxPropertyStillImage";
        case kCMIOStreamxxPropertyStillImageFormatDescriptions:
            return @"kCMIOStreamxxPropertyStillImageFormatDescriptions";
        case kCMIOStreamxxPropertyFrameRate:
            return @"kCMIOStreamxxPropertyFrameRate";
        case kCMIOStreamxxPropertyMinimumFrameRate:
            return @"kCMIOStreamxxPropertyMinimumFrameRate";
        case kCMIOStreamxxPropertyFrameRates:
            return @"kCMIOStreamxxPropertyFrameRates";
        case kCMIOStreamxxPropertyFrameRateRanges:
            return @"kCMIOStreamxxPropertyFrameRateRanges";
        case kCMIOStreamxxPropertyNoDataTimeoutInMSec:
            return @"kCMIOStreamxxPropertyNoDataTimeoutInMSec";
        case kCMIOStreamxxPropertyDevicexxSyncTimeoutInMSec:
            return @"kCMIOStreamxxPropertyDevicexxSyncTimeoutInMSec";
        case kCMIOStreamxxPropertyNoDataEventCount:
            return @"kCMIOStreamxxPropertyNoDataEventCount";
        case kCMIOStreamxxPropertyOutputBufferUnderrunCount:
            return @"kCMIOStreamxxPropertyOutputBufferUnderrunCount";
        case kCMIOStreamxxPropertyOutputBufferRepeatCount:
            return @"kCMIOStreamxxPropertyOutputBufferRepeatCount";
        case kCMIOStreamxxPropertyOutputBufferQueueSize:
            return @"kCMIOStreamxxPropertyOutputBufferQueueSize";
        case kCMIOStreamxxPropertyOutputBuffersRequiredForStartup:
            return @"kCMIOStreamxxPropertyOutputBuffersRequiredForStartup";
        case kCMIOStreamxxPropertyOutputBuffersNeededForThrottledPlayback:
            return @"kCMIOStreamxxPropertyOutputBuffersNeededForThrottledPlayback";
        case kCMIOStreamxxPropertyFirstOutputPresentationTimeStamp:
            return @"kCMIOStreamxxPropertyFirstOutputPresentationTimeStamp";
        case kCMIOStreamxxPropertyEndOfData:
            return @"kCMIOStreamxxPropertyEndOfData";
        case kCMIOStreamxxPropertyClock:
            return @"kCMIOStreamxxPropertyClock";
        case kCMIOStreamxxPropertyCanProcessDeckCommand:
            return @"kCMIOStreamxxPropertyCanProcessDeckCommand";
        case kCMIOStreamxxPropertyDeck:
            return @"kCMIOStreamxxPropertyDeck";
        case kCMIOStreamxxPropertyDeckFrameNumber:
            return @"kCMIOStreamxxPropertyDeckFrameNumber";
        case kCMIOStreamxxPropertyDeckDropness:
            return @"kCMIOStreamxxPropertyDeckDropness";
        case kCMIOStreamxxPropertyDeckThreaded:
            return @"kCMIOStreamxxPropertyDeckThreaded";
        case kCMIOStreamxxPropertyDeckLocal:
            return @"kCMIOStreamxxPropertyDeckLocal";
        case kCMIOStreamxxPropertyDeckCueing:
            return @"kCMIOStreamxxPropertyDeckCueing";
        case kCMIOStreamxxPropertyInitialPresentationTimeStampForLinkedAndSyncedAudio:
            return @"kCMIOStreamxxPropertyInitialPresentationTimeStampForLinkedAndSyncedAudio";
        case kCMIOStreamxxPropertyScheduledOutputNotificationProc:
            return @"kCMIOStreamxxPropertyScheduledOutputNotificationProc";
        case kCMIOStreamxxPropertyPreferredFormatDescription:
            return @"kCMIOStreamxxPropertyPreferredFormatDescription";
        case kCMIOStreamxxPropertyPreferredFrameRate:
            return @"kCMIOStreamxxPropertyPreferredFrameRate";
        case kCMIOControlPropertyScope:
            return @"kCMIOControlPropertyScope";
        case kCMIOControlPropertyElement:
            return @"kCMIOControlPropertyElement";
        case kCMIOControlPropertyVariant:
            return @"kCMIOControlPropertyVariant";
        case kCMIOHardwarePropertyProcessIsMaster:
            return @"kCMIOHardwarePropertyProcessIsMaster";
        case kCMIOHardwarePropertyIsInitingOrExiting:
            return @"kCMIOHardwarePropertyIsInitingOrExiting";
        case kCMIOHardwarePropertyDevicexxs:
            return @"kCMIOHardwarePropertyDevicexxs";
        case kCMIOHardwarePropertyDefaultInputDevicexx:
            return @"kCMIOHardwarePropertyDefaultInputDevicexx";
        case kCMIOHardwarePropertyDefaultOutputDevicexx:
            return @"kCMIOHardwarePropertyDefaultOutputDevicexx";
        case kCMIOHardwarePropertyDevicexxForUID:
            return @"kCMIOHardwarePropertyDevicexxForUID";
        case kCMIOHardwarePropertySleepingIsAllowed:
            return @"kCMIOHardwarePropertySleepingIsAllowed";
        case kCMIOHardwarePropertyUnloadingIsAllowed:
            return @"kCMIOHardwarePropertyUnloadingIsAllowed";
        case kCMIOHardwarePropertyPlugInxxForBundleID:
            return @"kCMIOHardwarePropertyPlugInxxForBundleID";
        case kCMIOHardwarePropertyUserSessionIsActiveOrHeadless:
            return @"kCMIOHardwarePropertyUserSessionIsActiveOrHeadless";
        case kCMIOHardwarePropertySuspendedBySystem:
            return @"kCMIOHardwarePropertySuspendedBySystem";
        case kCMIOHardwarePropertyAllowScreenCaptureDevicexxs:
            return @"kCMIOHardwarePropertyAllowScreenCaptureDevicexxs";
        case kCMIOHardwarePropertyAllowWirelessScreenCaptureDevicexxs:
            return @"kCMIOHardwarePropertyAllowWirelessScreenCaptureDevicexxs";
        default:
            uint8_t *chars = (uint8_t *)&selector;
            return [NSString stringWithFormat:@"Unknown selector: %c%c%c%c", chars[0], chars[1], chars[2], chars[3]];
        }
}

+ (BOOL)IsBridgedTypeForSelector:(CMIOObjectPropertySelector)selector {
    switch (selector) {
        case kCMIOObjectPropertyName:
        case kCMIOObjectPropertyManufacturer:
        case kCMIOObjectPropertyElementName:
        case kCMIOObjectPropertyElementCategoryName:
        case kCMIOObjectPropertyElementNumberName:
        case kCMIODevicexxPropertyDevicexxUID:
        case kCMIODevicexxPropertyModelUID:
        case kCMIOStreamxxPropertyFormatDescriptions:
        case kCMIOStreamxxPropertyFormatDescription:
        case kCMIOStreamxxPropertyClock:
            return YES;
        default:
            return NO;
        }
}

+ (ObjectStorexx *)SharedObjectStorexx {
    static ObjectStorexx *sObjectStorexx = nil;
    static dispatch_once_t sOnceToken;
    dispatch_once(&sOnceToken, ^{
        sObjectStorexx = [[self alloc] init];
    });
    return sObjectStorexx;
}

+ (NSObject<CMIOObject> *)GetObjectWithId:(CMIOObjectID)objectId {
    return [[ObjectStorexx SharedObjectStorexx] getObject:objectId];
}

- (id)init {
    if (self = [super init]) {
        self.objectMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSObject<CMIOObject> *)getObject:(CMIOObjectID)objectID {
    return self.objectMap[@(objectID)];
}

- (void)setObject:(id<CMIOObject>)object forObjectId:(CMIOObjectID)objectId {
    self.objectMap[@(objectId)] = object;
}

@end
