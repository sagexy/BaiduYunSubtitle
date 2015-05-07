//
//  SubtitleModel.m
//  BaiduYunSubtitle
//
//  Created by xy on 15/5/6.
//
//

#import "SubtitleModel.h"

@implementation SubtitleModel

- (void)dealloc
{
    [_file_path release];
    [_name release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"file_path=%@ name=%@",_file_path,_name];
}

@end
