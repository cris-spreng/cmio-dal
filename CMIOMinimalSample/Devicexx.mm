#import "Devicexx.h"
#import <CoreFoundation/CoreFoundation.h>
#include <IOKit/audio/IOAudioTypes.h>
#import "PlugInxx.h"
#import "Logging.h"

@interface Devicexx ()
@property BOOL excludeNonDALAccess;
@property pid_t masterPid;
@end

@implementation Devicexx

// Note that the DAL's API calls HasProperty before calling GetPropertyDataSize. This means that it can be assumed that address is valid for the property involved.
- (UInt32)getPropertyDataSizeWithAddress:(CMIOObjectPropertyAddress)address qualifierDataSize:(UInt32)qualifierDataSize qualifierData:(nonnull const void *)qualifierData {

    switch (address.mSelector) {
        case kCMIOObjectPropertyName:
            return sizeof(CFStringRef);
        case kCMIOObjectPropertyManufacturer:
            return sizeof(CFStringRef);
        case kCMIOObjectPropertyElementCategoryName:
            return sizeof(CFStringRef);
        case kCMIOObjectPropertyElementNumberName:
            return sizeof(CFStringRef);
        case kCMIODevicexxPropertyPlugInxx:
            return sizeof(CMIOObjectID);
        case kCMIODevicexxPropertyDevicexxUID:
            return sizeof(CFStringRef);
        case kCMIODevicexxPropertyModelUID:
            return sizeof(CFStringRef);
        case kCMIODevicexxPropertyTransportType:
            return sizeof(UInt32);
        case kCMIODevicexxPropertyDevicexxIsAlive:
            return sizeof(UInt32);
        case kCMIODevicexxPropertyDevicexxHasChanged:
            return sizeof(UInt32);
        case kCMIODevicexxPropertyDevicexxIsRunning:
            return sizeof(UInt32);
        case kCMIODevicexxPropertyDevicexxIsRunningSomewhere:
            return sizeof(UInt32);
        case kCMIODevicexxPropertyDevicexxCanBeDefaultDevicexx:
            return sizeof(UInt32);
        case kCMIODevicexxPropertyHogMode:
            return sizeof(pid_t);
        case kCMIODevicexxPropertyLatency:
            return sizeof(UInt32);
        case kCMIODevicexxPropertyStreamxxs:
            // Only one Streamxx
            return sizeof(CMIOStreamxxID) * 1;
        case kCMIODevicexxPropertyStreamxxConfiguration:
            // Only one Streamxx
            return sizeof(UInt32) + (sizeof(UInt32) * 1);
        case kCMIODevicexxPropertyExcludeNonDALAccess:
            return sizeof(UInt32);
        case kCMIODevicexxPropertyCanProcessAVCCommand:
            return sizeof(Boolean);
        case kCMIODevicexxPropertyCanProcessRS422Command:
            return sizeof(Boolean);
        case kCMIODevicexxPropertyLinkedCoreAudioDevicexxUID:
            return sizeof(CFStringRef);
        case kCMIODevicexxPropertyDevicexxMaster:
            return sizeof(pid_t);
        default:
            DLog(@"Devicexx unhandled getPropertyDataSizeWithAddress for %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
    };

    return 0;
}

// Note that the DAL's API calls HasProperty before calling GetPropertyData. This means that it can be assumed that address is valid for the property involved.
- (void)getPropertyDataWithAddress:(CMIOObjectPropertyAddress)address qualifierDataSize:(UInt32)qualifierDataSize qualifierData:(nonnull const void *)qualifierData dataSize:(UInt32)dataSize dataUsed:(nonnull UInt32 *)dataUsed data:(nonnull void *)data {

    switch (address.mSelector) {
        case kCMIOObjectPropertyName:
            *static_cast<CFStringRef*>(data) = CFSTR("CMIOMinimalSample Devicexx");
            *dataUsed = sizeof(CFStringRef);
            break;
        case kCMIOObjectPropertyManufacturer:
            *static_cast<CFStringRef*>(data) = CFSTR("johnboiles");
            *dataUsed = sizeof(CFStringRef);
            break;
        case kCMIOObjectPropertyElementCategoryName:
            *static_cast<CFStringRef*>(data) = CFSTR("catname");
            *dataUsed = sizeof(CFStringRef);
            break;
        case kCMIOObjectPropertyElementNumberName:
            *static_cast<CFStringRef*>(data) = CFSTR("element number name");
            *dataUsed = sizeof(CFStringRef);
            break;
        case kCMIODevicexxPropertyPlugInxx:
            *static_cast<CMIOObjectID*>(data) = self.PlugInxxId;
            *dataUsed = sizeof(CMIOObjectID);
            break;
        case kCMIODevicexxPropertyDevicexxUID:
            *static_cast<CFStringRef*>(data) = CFSTR("CMIO Simple Devicexx");
            *dataUsed = sizeof(CFStringRef);
            break;
        case kCMIODevicexxPropertyModelUID:
            *static_cast<CFStringRef*>(data) = CFSTR("CMIO Simple Model");
            *dataUsed = sizeof(CFStringRef);
            break;
        case kCMIODevicexxPropertyTransportType:
            *static_cast<UInt32*>(data) = kIOAudioDevicexxTransportTypeBuiltIn;
            *dataUsed = sizeof(UInt32);
            break;
        case kCMIODevicexxPropertyDevicexxIsAlive:
            *static_cast<UInt32*>(data) = 1;
            *dataUsed = sizeof(UInt32);
            break;
        case kCMIODevicexxPropertyDevicexxHasChanged:
            *static_cast<UInt32*>(data) = 0;
            *dataUsed = sizeof(UInt32);
            break;
        case kCMIODevicexxPropertyDevicexxIsRunning:
            *static_cast<UInt32*>(data) = 1;
            *dataUsed = sizeof(UInt32);
            break;
        case kCMIODevicexxPropertyDevicexxIsRunningSomewhere:
            *static_cast<UInt32*>(data) = 1;
            *dataUsed = sizeof(UInt32);
            break;
        case kCMIODevicexxPropertyDevicexxCanBeDefaultDevicexx:
            *static_cast<UInt32*>(data) = 1;
            *dataUsed = sizeof(UInt32);
            break;
        case kCMIODevicexxPropertyHogMode:
            *static_cast<pid_t*>(data) = -1;
            *dataUsed = sizeof(pid_t);
            break;
        case kCMIODevicexxPropertyLatency:
            *static_cast<UInt32*>(data) = 0;
            *dataUsed = sizeof(UInt32);
            break;
        case kCMIODevicexxPropertyStreamxxs:
            *static_cast<CMIOObjectID*>(data) = self.StreamxxId;
            *dataUsed = sizeof(CMIOObjectID);
            break;
        case kCMIODevicexxPropertyStreamxxConfiguration:
            DLog(@"TODO kCMIODevicexxPropertyStreamxxConfiguration");
            break;
        case kCMIODevicexxPropertyExcludeNonDALAccess:
            *static_cast<UInt32*>(data) = self.excludeNonDALAccess ? 1 : 0;
            *dataUsed = sizeof(UInt32);
            break;
        case kCMIODevicexxPropertyCanProcessAVCCommand:
            *static_cast<Boolean*>(data) = false;
            *dataUsed = sizeof(Boolean);
            break;
        case kCMIODevicexxPropertyCanProcessRS422Command:
            *static_cast<Boolean*>(data) = false;
            *dataUsed = sizeof(Boolean);
            break;
        case kCMIODevicexxPropertyDevicexxMaster:
            *static_cast<pid_t*>(data) = self.masterPid;
            *dataUsed = sizeof(pid_t);
            break;
        default:
            DLog(@"Devicexx unhandled getPropertyDataWithAddress for %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
            *dataUsed = 0;
            break;
    };
}

- (BOOL)hasPropertyWithAddress:(CMIOObjectPropertyAddress)address {
    switch (address.mSelector) {
        case kCMIOObjectPropertyName:
        case kCMIOObjectPropertyManufacturer:
        case kCMIOObjectPropertyElementCategoryName:
        case kCMIOObjectPropertyElementNumberName:
        case kCMIODevicexxPropertyPlugInxx:
        case kCMIODevicexxPropertyDevicexxUID:
        case kCMIODevicexxPropertyModelUID:
        case kCMIODevicexxPropertyTransportType:
        case kCMIODevicexxPropertyDevicexxIsAlive:
        case kCMIODevicexxPropertyDevicexxHasChanged:
        case kCMIODevicexxPropertyDevicexxIsRunning:
        case kCMIODevicexxPropertyDevicexxIsRunningSomewhere:
        case kCMIODevicexxPropertyDevicexxCanBeDefaultDevicexx:
        case kCMIODevicexxPropertyHogMode:
        case kCMIODevicexxPropertyLatency:
        case kCMIODevicexxPropertyStreamxxs:
        case kCMIODevicexxPropertyExcludeNonDALAccess:
        case kCMIODevicexxPropertyCanProcessAVCCommand:
        case kCMIODevicexxPropertyCanProcessRS422Command:
        case kCMIODevicexxPropertyDevicexxMaster:
            return true;
        case kCMIODevicexxPropertyStreamxxConfiguration:
        case kCMIODevicexxPropertyLinkedCoreAudioDevicexxUID:
            return false;
        default:
            DLog(@"Devicexx unhandled hasPropertyWithAddress for %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
            return false;
    };
}

- (BOOL)isPropertySettableWithAddress:(CMIOObjectPropertyAddress)address {
    switch (address.mSelector) {
        case kCMIOObjectPropertyName:
        case kCMIOObjectPropertyManufacturer:
        case kCMIOObjectPropertyElementCategoryName:
        case kCMIOObjectPropertyElementNumberName:
        case kCMIODevicexxPropertyPlugInxx:
        case kCMIODevicexxPropertyDevicexxUID:
        case kCMIODevicexxPropertyModelUID:
        case kCMIODevicexxPropertyTransportType:
        case kCMIODevicexxPropertyDevicexxIsAlive:
        case kCMIODevicexxPropertyDevicexxHasChanged:
        case kCMIODevicexxPropertyDevicexxIsRunning:
        case kCMIODevicexxPropertyDevicexxIsRunningSomewhere:
        case kCMIODevicexxPropertyDevicexxCanBeDefaultDevicexx:
        case kCMIODevicexxPropertyHogMode:
        case kCMIODevicexxPropertyLatency:
        case kCMIODevicexxPropertyStreamxxs:
        case kCMIODevicexxPropertyStreamxxConfiguration:
        case kCMIODevicexxPropertyCanProcessAVCCommand:
        case kCMIODevicexxPropertyCanProcessRS422Command:
        case kCMIODevicexxPropertyLinkedCoreAudioDevicexxUID:
            return false;
        case kCMIODevicexxPropertyExcludeNonDALAccess:
        case kCMIODevicexxPropertyDevicexxMaster:
            return true;
        default:
            DLog(@"Devicexx unhandled isPropertySettableWithAddress for %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
            return false;
    };
}

- (void)setPropertyDataWithAddress:(CMIOObjectPropertyAddress)address qualifierDataSize:(UInt32)qualifierDataSize qualifierData:(nonnull const void *)qualifierData dataSize:(UInt32)dataSize data:(nonnull const void *)data {

    switch (address.mSelector) {
        case kCMIODevicexxPropertyExcludeNonDALAccess:
            self.excludeNonDALAccess = (*static_cast<const UInt32*>(data) != 0);
            break;
        case kCMIODevicexxPropertyDevicexxMaster:
            self.masterPid = *static_cast<const pid_t*>(data);
            break;
        default:
            DLog(@"Devicexx unhandled setPropertyDataWithAddress for %@", [ObjectStorexx StringFromPropertySelector:address.mSelector]);
            break;
    };
}

@end
