//
//  FileUtils.h
//  Pods
//
//  Created by Vivek Suthar on 19/12/23.
//

#import <Foundation/Foundation.h>

@interface FileUtils : NSObject

+ (unsigned long long)getCacheDirSize:(NSString *)path;

+ (void) flushCacheDir:(NSString *)path forSpace:(unsigned long long)size ;

@end
