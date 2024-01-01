#import "RnVideoThumbnails.h"
#import <React/RCTBridgeModule.h>
#import "Photos/Photos.h"
#import "AVFoundation/AVFoundation.h"
#import "Foundation/Foundation.h"
#import "FileUtils.h"
@implementation RnVideoThumbnails
RCT_EXPORT_MODULE()

#define CACHE_DIR_SIZE 100
#define CACHE_DIR_NAME @"RNVideoThumbNails"
#define TEMP_DIR_NAME @"Thumbnail_"

RCT_EXPORT_METHOD(getImageAsync:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    //Extract The USer Values from JS Side
    NSString *url=[options[@"fileUri"] lowercaseString];
    int timeStamp = [options[@"time"] intValue];
    NSNumber *quality=options[@"quality"];
    NSString *format=options[@"format"];
    NSLog(@"Video URL: %@", url);
    NSDictionary *headers = options[@"headers"] ?: @{};

    unsigned long long cacheDirSize = CACHE_DIR_SIZE * 1024 * 1024;

    @try {
        NSString *tempDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        tempDirectory = [tempDirectory stringByAppendingPathComponent:CACHE_DIR_NAME];

        // Check if the directory already exists
        if (![[NSFileManager defaultManager] fileExistsAtPath:tempDirectory]) {
            // If not, Create the temp directory
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:tempDirectory withIntermediateDirectories:YES attributes:nil error:&error];

            if (error) {
                NSLog(@"Error creating directory: %@", error);
            }
        }

        NSString *uniqueID = [[NSUUID UUID] UUIDString];
        NSString *fileName = [NSString stringWithFormat:@"frame-%@-%@.%@", CACHE_DIR_NAME, uniqueID, format];

        NSString* fullPath = [tempDirectory stringByAppendingPathComponent:fileName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:fullPath]];
            UIImage *thumbnail = [UIImage imageWithData:imageData];
            
            //return a Dirctory
            resolve(@{
                @"uri"     : fullPath,
                @"width"    : [NSNumber numberWithFloat: thumbnail.size.width],
                @"height"   : [NSNumber numberWithFloat: thumbnail.size.height]
            });
            return;
        }
        
        NSURL *localAssetURL = nil;
        

        if ([url hasPrefix:@"file://"]) {
            localAssetURL = [NSURL URLWithString:url];
        } else {
            localAssetURL = [NSURL fileURLWithPath:url];
        }

        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:localAssetURL options:@{@"AVURLAssetHTTPHeaderFieldsKey": headers}];
        NSTimeInterval timeStampInSeconds = timeStamp / 1000.0;

        CMTime assetDuration = asset.duration;
        NSTimeInterval assetDurationInSeconds = CMTimeGetSeconds(assetDuration);

        if (timeStampInSeconds > assetDurationInSeconds) {
            NSString *errorMessage = [NSString stringWithFormat:@"Invalid Duration: The provided timestamp (%d milliseconds) is greater than the asset duration (%.2f seconds).", timeStamp, assetDurationInSeconds];
            reject(@"Invalid Duration", errorMessage, nil);
            return;
        }
        
        [self extractImageAtTime:asset atTime:timeStamp completion:^(UIImage *thumbnail) {
            unsigned long long size = [FileUtils getCacheDirSize:tempDirectory];
            if (size >= cacheDirSize) {
                [FileUtils flushCacheDir:tempDirectory forSpace:CACHE_DIR_SIZE/2];
            }
            // Extract the Image Data
            NSData *data = nil;
            if ([format isEqual: @"png"]) {
                data = UIImagePNGRepresentation(thumbnail);
            } else {
                data = UIImageJPEGRepresentation(thumbnail,[quality floatValue]);
            }

            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager createFileAtPath:fullPath contents:data attributes:nil];

            // Resole the Image Path and details
            resolve(@{
                @"uri"     : fullPath,
                @"width"    : [NSNumber numberWithFloat: thumbnail.size.width],
                @"height"   : [NSNumber numberWithFloat: thumbnail.size.height],
            });
        } failure:^(NSError *error) {
            reject(error.domain, error.description, nil);
        }];
    } @catch(NSException *e) {
        reject(e.name, e.reason, nil);
    }
}

- (void) extractImageAtTime:(AVURLAsset *)asset atTime:(int)timeStamp completion:(void (^)(UIImage* thumbnail))onImageExtracted failure:(void (^)(NSError* error))onImageExtractError {
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    CMTime time = CMTimeMake(timeStamp, 1000);
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime timeRequested, CGImageRef image, CMTime timeActual, AVAssetImageGeneratorResult result, NSError *error) {
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *thumbnail = [UIImage imageWithCGImage:image];
            onImageExtracted(thumbnail);
        } else {
            onImageExtractError(error);
        }
    };
    
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:time]] completionHandler:handler];
}

@end
// For New Arch
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeRnVideoThumbnailsSpecJSI>(params);
}
#endif

