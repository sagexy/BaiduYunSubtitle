//
//  SubtitleParser.h
//  BaiduYunSubtitle
//
//  Created by xy on 15/5/6.
//
//

#import <Foundation/Foundation.h>

static NSString *const kIndex = @"kIndex";
static NSString *const kStart = @"kStart";
static NSString *const kEnd = @"kEnd";
static NSString *const kText = @"kText";

@interface SubtitleParser : NSObject

@property (strong, nonatomic) NSMutableDictionary *subtitlesParts;

+ (instancetype)sharedInstance;

- (void)parseString:(NSString *)srtString;

@end
