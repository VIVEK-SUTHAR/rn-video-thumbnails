
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNRnVideoThumbnailsSpec.h"

@interface RnVideoThumbnails : NSObject <NativeRnVideoThumbnailsSpec>
#else
#import <React/RCTBridgeModule.h>

@interface RnVideoThumbnails : NSObject <RCTBridgeModule>
#endif

@end
