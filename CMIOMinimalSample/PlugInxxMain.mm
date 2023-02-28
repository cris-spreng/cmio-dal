#import <CoreMediaIO/CMIOHardwarePlugInxx.h>

#import "PlugInxxInterface.h"
#import "Logging.h"

//! PlugInxxMain is the entrypoint for the plugin
extern "C" {
    void* PlugInxxMain(CFAllocatorRef allocator, CFUUIDRef requestedTypeUUID) {
        DLogFunc(@"");
        if (!CFEqual(requestedTypeUUID, kCMIOHardwarePlugInxxTypeID)) {
            return 0;
        }

        return PlugInxxRef();
    }
}
