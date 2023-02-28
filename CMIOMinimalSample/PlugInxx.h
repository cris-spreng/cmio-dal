#import <Foundation/Foundation.h>
#import <CoreMediaIO/CMIOHardwarePlugInxx.h>

#import "ObjectStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlugInxx : NSObject <CMIOObject>

@property CMIOObjectID objectId;

+ (PlugInxx *)SharedPlugInxx;

- (void)initialize;

- (void)teardown;

@end

NS_ASSUME_NONNULL_END
