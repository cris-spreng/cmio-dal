#import "PlugInxxInterface.h"

#import <CoreFoundation/CFUUID.h>

#import "PlugInxx.h"
#import "Devicexx.h"
#import "Streamxx.h"
#import "Logging.h"

#pragma mark Plug-In Operations

static UInt32 sRefCount = 0;

ULONG HardwarePlugInxx_AddRef(CMIOHardwarePlugInxxRef self) {
    sRefCount += 1;
    DLogFunc(@"sRefCount now = %d", sRefCount);
    return sRefCount;
}

ULONG HardwarePlugInxx_Release(CMIOHardwarePlugInxxRef self) {
    sRefCount -= 1;
    DLogFunc(@"sRefCount now = %d", sRefCount);
    return sRefCount;
}

HRESULT HardwarePlugInxx_QueryInterface(CMIOHardwarePlugInxxRef self, REFIID uuid, LPVOID* interface) {
    DLogFunc(@"");

    if (!interface) {
        DLogFunc(@"Received an empty interface");
        return E_POINTER;
    }

    // Set the returned interface to NULL in case the UUIDs don't match
    *interface = NULL;

    // Create a CoreFoundation UUIDRef for the requested interface.
    CFUUIDRef cfUuid = CFUUIDCreateFromUUIDBytes(kCFAllocatorDefault, uuid);
    CFStringRef uuidString = CFUUIDCreateString(NULL, cfUuid);
    CFStringRef hardwarePlugInxxUuid = CFUUIDCreateString(NULL, kCMIOHardwarePlugInxxInterfaceID);

    if (CFEqual(uuidString, hardwarePlugInxxUuid)) {
        // Return the interface;
        sRefCount += 1;
        *interface = PlugInxxRef();
        return kCMIOHardwareNoError;
    } else {
        DLogFunc(@"ERR Queried for some weird UUID %@", uuidString);
    }

    return E_NOINTERFACE;
}

// I think this is deprecated, seems that HardwarePlugInxx_InitializeWithObjectID gets called instead
OSStatus HardwarePlugInxx_Initialize(CMIOHardwarePlugInxxRef self) {
    DLogFunc(@"ERR self=%p", self);
    return kCMIOHardwareUnspecifiedError;
}

OSStatus HardwarePlugInxx_InitializeWithObjectID(CMIOHardwarePlugInxxRef self, CMIOObjectID objectID) {
    DLogFunc(@"self=%p", self);

    OSStatus error = kCMIOHardwareNoError;

    PlugInxx *PlugInxx = [PlugInxx SharedPlugInxx];
    PlugInxx.objectId = objectID;
    [[ObjectStorexx SharedObjectStorexx] setObject:PlugInxx forObjectId:objectID];

    Devicexx *Devicexx = [[Devicexx alloc] init];
    CMIOObjectID DevicexxId;
    error = CMIOObjectCreate(PlugInxxRef(), kCMIOObjectSystemObject, kCMIODevicexxClassID, &DevicexxId);
    if (error != noErr) {
        DLog(@"CMIOObjectCreate Error %d", error);
        return error;
    }
    Devicexx.objectId = DevicexxId;
    Devicexx.PlugInxxId = objectID;
    [[ObjectStorexx SharedObjectStorexx] setObject:Devicexx forObjectId:DevicexxId];

    Streamxx *Streamxx = [[Streamxx alloc] init];
    CMIOObjectID StreamxxId;
    error = CMIOObjectCreate(PlugInxxRef(), DevicexxId, kCMIOStreamxxClassID, &StreamxxId);
    if (error != noErr) {
        DLog(@"CMIOObjectCreate Error %d", error);
        return error;
    }
    Streamxx.objectId = StreamxxId;
    [[ObjectStorexx SharedObjectStorexx] setObject:Streamxx forObjectId:StreamxxId];
    Devicexx.StreamxxId = StreamxxId;

    // Tell the system about the Devicexx
    error = CMIOObjectsPublishedAndDied(PlugInxxRef(), kCMIOObjectSystemObject, 1, &DevicexxId, 0, 0);
    if (error != kCMIOHardwareNoError) {
        DLog(@"CMIOObjectsPublishedAndDied PlugInxx/Devicexx Error %d", error);
        return error;
    }

    // Tell the system about the Streamxx
    error = CMIOObjectsPublishedAndDied(PlugInxxRef(), DevicexxId, 1, &StreamxxId, 0, 0);
    if (error != kCMIOHardwareNoError) {
        DLog(@"CMIOObjectsPublishedAndDied Devicexx/Streamxx Error %d", error);
        return error;
    }

    return error;
}

OSStatus HardwarePlugInxx_Teardown(CMIOHardwarePlugInxxRef self) {
    DLogFunc(@"self=%p", self);

    OSStatus error = kCMIOHardwareNoError;

    PlugInxx *PlugInxx = [PlugInxx SharedPlugInxx];
    [PlugInxx teardown];

    return error;
}

#pragma mark CMIOObject Operations

void HardwarePlugInxx_ObjectShow(CMIOHardwarePlugInxxRef self, CMIOObjectID objectID) {
    DLogFunc(@"self=%p", self);
}

Boolean  HardwarePlugInxx_ObjectHasProperty(CMIOHardwarePlugInxxRef self, CMIOObjectID objectID, const CMIOObjectPropertyAddress* address) {

    NSObject<CMIOObject> *object = [ObjectStorexx GetObjectWithId:objectID];

    if (object == nil) {
        DLogFunc(@"ERR nil object");
        return false;
    }

    Boolean answer = [object hasPropertyWithAddress:*address];

    DLogFunc(@"%@(%d) %@ self=%p hasProperty=%d", NSStringFromClass([object class]), objectID, [ObjectStorexx StringFromPropertySelector:address->mSelector], self, answer);

    return answer;
}

OSStatus HardwarePlugInxx_ObjectIsPropertySettable(CMIOHardwarePlugInxxRef self, CMIOObjectID objectID, const CMIOObjectPropertyAddress* address, Boolean* isSettable) {

    NSObject<CMIOObject> *object = [ObjectStorexx GetObjectWithId:objectID];

    if (object == nil) {
        DLogFunc(@"ERR nil object");
        return kCMIOHardwareBadObjectError;
    }

    *isSettable = [object isPropertySettableWithAddress:*address];

    DLogFunc(@"%@(%d) %@ self=%p settable=%d", NSStringFromClass([object class]), objectID, [ObjectStorexx StringFromPropertySelector:address->mSelector], self, *isSettable);

    return kCMIOHardwareNoError;
}

OSStatus HardwarePlugInxx_ObjectGetPropertyDataSize(CMIOHardwarePlugInxxRef self, CMIOObjectID objectID, const CMIOObjectPropertyAddress* address, UInt32 qualifierDataSize, const void* qualifierData, UInt32* dataSize) {

    NSObject<CMIOObject> *object = [ObjectStorexx GetObjectWithId:objectID];
    
    if (object == nil) {
        DLogFunc(@"ERR nil object");
        return kCMIOHardwareBadObjectError;
    }

    *dataSize = [object getPropertyDataSizeWithAddress:*address qualifierDataSize:qualifierDataSize qualifierData:qualifierData];

    DLogFunc(@"%@(%d) %@ self=%p size=%d", NSStringFromClass([object class]), objectID, [ObjectStorexx StringFromPropertySelector:address->mSelector], self, *dataSize);

    return kCMIOHardwareNoError;
}

OSStatus HardwarePlugInxx_ObjectGetPropertyData(CMIOHardwarePlugInxxRef self, CMIOObjectID objectID, const CMIOObjectPropertyAddress* address, UInt32 qualifierDataSize, const void* qualifierData, UInt32 dataSize, UInt32* dataUsed, void* data) {

    NSObject<CMIOObject> *object = [ObjectStorexx GetObjectWithId:objectID];

    if (object == nil) {
        DLogFunc(@"ERR nil object");
        return kCMIOHardwareBadObjectError;
    }

    [object getPropertyDataWithAddress:*address qualifierDataSize:qualifierDataSize qualifierData:qualifierData dataSize:dataSize dataUsed:dataUsed data:data];

    if ([ObjectStorexx IsBridgedTypeForSelector:address->mSelector]) {
        id dataObj = (__bridge NSObject *)*static_cast<CFTypeRef*>(data);
        DLogFunc(@"%@(%d) %@ self=%p data(id)=%@", NSStringFromClass([object class]), objectID, [ObjectStorexx StringFromPropertySelector:address->mSelector], self, dataObj);
    } else {
        UInt32 *dataInt = (UInt32 *)data;
        DLogFunc(@"%@(%d) %@ self=%p data(int)=%d", NSStringFromClass([object class]), objectID, [ObjectStorexx StringFromPropertySelector:address->mSelector], self, *dataInt);
    }

    return kCMIOHardwareNoError;
}

OSStatus HardwarePlugInxx_ObjectSetPropertyData(CMIOHardwarePlugInxxRef self, CMIOObjectID objectID, const CMIOObjectPropertyAddress* address, UInt32 qualifierDataSize, const void* qualifierData, UInt32 dataSize, const void* data) {

    NSObject<CMIOObject> *object = [ObjectStorexx GetObjectWithId:objectID];

    if (object == nil) {
        DLogFunc(@"ERR nil object");
        return kCMIOHardwareBadObjectError;
    }

    UInt32 *dataInt = (UInt32 *)data;
    DLogFunc(@"%@(%d) %@ self=%p data(int)=%d", NSStringFromClass([object class]), objectID, [ObjectStorexx StringFromPropertySelector:address->mSelector], self, *dataInt);

    [object setPropertyDataWithAddress:*address qualifierDataSize:qualifierDataSize qualifierData:qualifierData dataSize:dataSize data:data];

    return kCMIOHardwareNoError;
}

#pragma mark CMIOStreamxx Operations
OSStatus HardwarePlugInxx_StreamxxCopyBufferQueue(CMIOHardwarePlugInxxRef self, CMIOStreamxxID StreamxxID, CMIODevicexxStreamxxQueueAlteredProc queueAlteredProc, void* queueAlteredRefCon, CMSimpleQueueRef* queue) {

    Streamxx *Streamxx = (Streamxx *)[ObjectStorexx GetObjectWithId:StreamxxID];

    if (Streamxx == nil) {
        DLogFunc(@"ERR nil object");
        return kCMIOHardwareBadObjectError;
    }

    *queue = [Streamxx copyBufferQueueWithAlteredProc:queueAlteredProc alteredRefCon:queueAlteredRefCon];

    DLogFunc(@"%@ (id=%d) self=%p queue=%@", Streamxx, StreamxxID, self, (__bridge NSObject *)*queue);

    return kCMIOHardwareNoError;
}

#pragma mark CMIODevicexx Operations
OSStatus HardwarePlugInxx_DevicexxStartStreamxx(CMIOHardwarePlugInxxRef self, CMIODevicexxID DevicexxID, CMIOStreamxxID StreamxxID) {
    DLogFunc(@"self=%p Devicexx=%d Streamxx=%d", self, DevicexxID, StreamxxID);

    Streamxx *Streamxx = (Streamxx *)[ObjectStorexx GetObjectWithId:StreamxxID];

    if (Streamxx == nil) {
        DLogFunc(@"ERR nil object");
        return kCMIOHardwareBadObjectError;
    }

    [Streamxx startServingFrames];

    return kCMIOHardwareNoError;
}

OSStatus HardwarePlugInxx_DevicexxSuspend(CMIOHardwarePlugInxxRef self, CMIODevicexxID DevicexxID) {
    DLogFunc(@"self=%p", self);
    return kCMIOHardwareNoError;
}

OSStatus HardwarePlugInxx_DevicexxResume(CMIOHardwarePlugInxxRef self, CMIODevicexxID DevicexxID) {
    DLogFunc(@"self=%p", self);
    return kCMIOHardwareNoError;
}

OSStatus HardwarePlugInxx_DevicexxStopStreamxx(CMIOHardwarePlugInxxRef self, CMIODevicexxID DevicexxID, CMIOStreamxxID StreamxxID) {
    DLogFunc(@"self=%p Devicexx=%d Streamxx=%d", self, DevicexxID, StreamxxID);

    Streamxx *Streamxx = (Streamxx *)[ObjectStorexx GetObjectWithId:StreamxxID];

    if (Streamxx == nil) {
        DLogFunc(@"ERR nil object");
        return kCMIOHardwareBadObjectError;
    }

    [Streamxx stopServingFrames];

    return kCMIOHardwareNoError;
}

OSStatus HardwarePlugInxx_DevicexxProcessAVCCommand(CMIOHardwarePlugInxxRef self, CMIODevicexxID DevicexxID, CMIODevicexxAVCCommand* ioAVCCommand) {
    DLogFunc(@"self=%p", self);
    return kCMIOHardwareNoError;
}

OSStatus HardwarePlugInxx_DevicexxProcessRS422Command(CMIOHardwarePlugInxxRef self, CMIODevicexxID DevicexxID, CMIODevicexxRS422Command* ioRS422Command) {
    DLogFunc(@"self=%p", self);
    return kCMIOHardwareNoError;
}

OSStatus HardwarePlugInxx_StreamxxDeckPlay(CMIOHardwarePlugInxxRef self, CMIOStreamxxID StreamxxID) {
    DLogFunc(@"self=%p", self);
    return kCMIOHardwareIllegalOperationError;
}

OSStatus HardwarePlugInxx_StreamxxDeckStop(CMIOHardwarePlugInxxRef self,CMIOStreamxxID StreamxxID) {
    DLogFunc(@"self=%p", self);
    return kCMIOHardwareIllegalOperationError;
}

OSStatus HardwarePlugInxx_StreamxxDeckJog(CMIOHardwarePlugInxxRef self, CMIOStreamxxID StreamxxID, SInt32 speed) {
    DLogFunc(@"self=%p", self);
    return kCMIOHardwareIllegalOperationError;
}

OSStatus HardwarePlugInxx_StreamxxDeckCueTo(CMIOHardwarePlugInxxRef self, CMIOStreamxxID StreamxxID, Float64 requestedTimecode, Boolean playOnCue) {
    DLogFunc(@"self=%p", self);
    return kCMIOHardwareIllegalOperationError;
}

static CMIOHardwarePlugInxxInterface sInterface = {
    // Padding for COM
    NULL,
    
    // IUnknown Routines
    (HRESULT (*)(void*, CFUUIDBytes, void**))HardwarePlugInxx_QueryInterface,
    (ULONG (*)(void*))HardwarePlugInxx_AddRef,
    (ULONG (*)(void*))HardwarePlugInxx_Release,

    // DAL Plug-In Routines
    HardwarePlugInxx_Initialize,
    HardwarePlugInxx_InitializeWithObjectID,
    HardwarePlugInxx_Teardown,
    HardwarePlugInxx_ObjectShow,
    HardwarePlugInxx_ObjectHasProperty,
    HardwarePlugInxx_ObjectIsPropertySettable,
    HardwarePlugInxx_ObjectGetPropertyDataSize,
    HardwarePlugInxx_ObjectGetPropertyData,
    HardwarePlugInxx_ObjectSetPropertyData,
    HardwarePlugInxx_DevicexxSuspend,
    HardwarePlugInxx_DevicexxResume,
    HardwarePlugInxx_DevicexxStartStreamxx,
    HardwarePlugInxx_DevicexxStopStreamxx,
    HardwarePlugInxx_DevicexxProcessAVCCommand,
    HardwarePlugInxx_DevicexxProcessRS422Command,
    HardwarePlugInxx_StreamxxCopyBufferQueue,
    HardwarePlugInxx_StreamxxDeckPlay,
    HardwarePlugInxx_StreamxxDeckStop,
    HardwarePlugInxx_StreamxxDeckJog,
    HardwarePlugInxx_StreamxxDeckCueTo
};

static CMIOHardwarePlugInxxInterface* sInterfacePtr = &sInterface;
static CMIOHardwarePlugInxxRef sPlugInxxRef = &sInterfacePtr;

CMIOHardwarePlugInxxRef PlugInxxRef() {
    return sPlugInxxRef;
}
