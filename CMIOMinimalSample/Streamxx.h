#import <Foundation/Foundation.h>

#import "ObjectStorexx.h"

NS_ASSUME_NONNULL_BEGIN

@interface Streamxx : NSObject <CMIOObject>

@property CMIOStreamxxID objectId;

- (instancetype _Nonnull)init;

- (CMSimpleQueueRef)copyBufferQueueWithAlteredProc:(CMIODevicexxStreamxxQueueAlteredProc)alteredProc alteredRefCon:(void *)alteredRefCon;

- (void)startServingFrames;

- (void)stopServingFrames;

@end

NS_ASSUME_NONNULL_END
