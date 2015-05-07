//
//  SubtitleManager.m
//  BaiduYunSubtitle
//
//  Created by xy on 15/5/6.
//
//

#import "SubtitleManager.h"
#import "UIActionSheet+Blocks.h"

#define URL_ROOT @"http://pan.baidu.com/api/resource/subtitle"

@interface DefaultConfiguration : NSObject
+ (id)sharedDefaultConfiguration;
@property(readonly, nonatomic) NSString *userBduss;
@end

@interface StringHelper : NSObject
+ (id)MD5:(id)arg1;
@end

@implementation SubtitleManager

+ (void)searchSubtitleWithVideoHash:(NSString *)hash completionHandler:(void (^)(NSArray *subtitlesArr, NSError* error)) handler
{
//    NSString *urlString = @"http://pan.baidu.com/api/resource/subtitle?hash_str=CAFE7F39A2FB78919F4426D62B5B5700&format=2&hash_method=1&BDUSS=liaWN4d1BBTjVEYTVyVTU5b21rRFRzTGVOUUpyRnZ-T3FKZS14T0tWSE5CSEJWQVFBQUFBJCQAAAAAAAAAAAEAAABfQwICc2FnZXhwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM13SFXNd0hVWk";
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    DefaultConfiguration *cfg = [NSClassFromString(@"DefaultConfiguration") sharedDefaultConfiguration];
    NSString *userBDuss = cfg.userBduss;
    
    NSString *urlString = [NSString stringWithFormat:@"%@?hash_str=%@&format=2&hash_method=1&BDUSS=%@",URL_ROOT,hash,userBDuss];
    NSLog(@"urlString=%@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error = nil;
        NSDictionary* json =[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray *array = json[@"records"];
        
        NSMutableArray *muArr = [[[NSMutableArray alloc] initWithCapacity:[array count]] autorelease];
        for (id obj in array) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                SubtitleModel *model = [[SubtitleModel alloc] init];
                model.name = obj[@"name"];
                model.file_path = obj[@"file_path"];
//                NSLog(@"model = %@",model);
                [muArr addObject:model];
                
                [model release];
            }
        }
        if (handler) {
            handler(muArr,connectionError);
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];

//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:queue
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                               NSString *rs = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                               NSLog(@"responseObject=%@ error=%@",rs,connectionError);
//                           }];
}

+ (void)downloadSubtitleWithUrl:(NSString *)urlStr
                       fileName:(NSString *)fileName
              completionHandler:(void (^)(NSString* str, NSError* error)) handler
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSAllDomainsMask, YES) firstObject];
//    NSString *folder = [cachePath stringByAppendingPathComponent:@"subtitles"];
//    if (![fileManager fileExistsAtPath:folder]) {
//        [fileManager createDirectoryAtPath:folder
//               withIntermediateDirectories:YES
//                                attributes:nil
//                                     error:nil];
//    }
//    NSString *filePath = [folder stringByAppendingPathComponent:fileName];
//    if ([fileManager fileExistsAtPath:filePath]) {
//        NSError *error = nil;
//        NSString *subtitle = [NSString stringWithContentsOfFile:filePath
//                                                       encoding:NSUTF8StringEncoding
//                                                          error:&error];
//        if (!error) {
//            if (handler) {
//                handler(subtitle,nil);
//            }
//        }else{
//            if (handler) {
//                handler(nil,error);
//            }
//        }
//        
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    }else{
    
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:queue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            NSString *rs = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
            
//            NSError *error = nil;
//            [rs writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
//            if (error) {
//                NSLog(@"save subtitle failed error=%@",error);
//            }
            
            if (handler) {
                handler(rs,connectionError);
            }
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }];
//    }
    
}

@end
