//
//  SubtitleManager.h
//  BaiduYunSubtitle
//
//  Created by xy on 15/5/6.
//
//

#import <Foundation/Foundation.h>
#import "SubtitleModel.h"

@interface SubtitleManager : NSObject

+ (void)searchSubtitleWithVideoHash:(NSString *)hash
                  completionHandler:(void (^)(NSArray *subtitlesArr, NSError* error))handler;

+ (void)downloadSubtitleWithUrl:(NSString *)urlStr
                       fileName:(NSString *)fileName
              completionHandler:(void (^)(NSString* str, NSError* error))handler;

@end
