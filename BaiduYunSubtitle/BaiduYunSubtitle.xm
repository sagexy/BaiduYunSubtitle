#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SubtitleManager.h"
#import "UIActionSheet+Blocks.h"
#import "SubtitleModel.h"
#import "SubtitleParser.h"

#pragma mark - BaiduYunStart
//FileListViewController
//
//%group BaiduYun

@interface PlayerControlView : UIView
@property(retain, nonatomic) UISlider *contentChangeSlider;
@end

@interface DefaultConfiguration : NSObject
+ (id)sharedDefaultConfiguration;
@property(readonly, nonatomic) NSString *userBduss;
@end

@interface CyberPlayerController : NSObject
@property(readonly, nonatomic) long long playbackState;
@property(nonatomic) double currentPlaybackTime;
@end

@interface BaiduPlayerViewController : UIViewController
//@property(retain, nonatomic) NSString *streamURL;
@property(retain, nonatomic) CyberPlayerController *player;
@property(retain, nonatomic) PlayerControlView *controlView;
- (void)showSubTitle:(id)sender;
- (void)hideSubTitle:(id)sender;
- (void)updateSubtitleDisplayWithCurrentPlaybackTime:(double)time withLabelToDisplay:(UILabel *)label;
@end

@interface FileListViewController : UIViewController
@property(retain, nonatomic) NSMutableArray *fileList;
@end

@interface CacheFileMetaModel : NSObject
@property(copy, nonatomic) NSString *blockListMd5;
@property(nonatomic) int fileCategory;
@end

%hook FileListViewController
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CacheFileMetaModel *model = self.fileList[indexPath.row];
//    NSLog(@"model=%@",model);
//    return %orig;
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    %orig;
    
    CacheFileMetaModel *model = self.fileList[indexPath.row];
    
    if(model.fileCategory == 1){ //当为视频时保存文件md5
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setValue:model.blockListMd5 forKey:@"SelectFileMd5"];
        [userDefault synchronize];
    }
//    NSLog(@"model=%@",model.description);
//    unsigned int outCount;
//    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
//    for (int i = 0; i < outCount; i++)
//    {
//        objc_property_t property = properties[i];
//        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
//        
//        id value = [model valueForKey:propertyName];
//        
//        NSLog(@"key=%@ value=%@",propertyName,value);
//    }

}
%end

%hook PlayerControlView

- (void)drawPlayerControlPanel
{
    %orig;
    
    UIButton *subTitleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [subTitleBtn setTitle:@"字幕" forState:UIControlStateNormal];
    [subTitleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    subTitleBtn.tag = -100;
    subTitleBtn.frame = CGRectZero;
    [subTitleBtn addTarget:self action:@selector(subTitleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:subTitleBtn];
}

- (void)resetViewFrame:(CGRect)arg1 animation:(_Bool)arg2
{
    %orig;
    
    //    NSLog(@"contentChangeSlider=%@",NSStringFromCGRect(self.contentChangeSlider.frame));
    
    CGRect rect = self.contentChangeSlider.frame;
    rect.size.width -= 70;
    self.contentChangeSlider.frame = rect;
    
    UIButton *subTitleBtn = (UIButton *)[self viewWithTag:-100];
    subTitleBtn.frame = CGRectMake(rect.origin.x+rect.size.width,rect.origin.y+12,50,30);
}

%new
- (void)subTitleBtnClicked:(id)sender
{
    //    NSLog(@"subTitleBtnClicked");
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowSubTitle" object:nil];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *videoMd5 = [userDefault valueForKey:@"SelectFileMd5"];
    if(videoMd5 && videoMd5.length > 0){
        [SubtitleManager searchSubtitleWithVideoHash:videoMd5
                                   completionHandler:^(NSArray *subtitlesArr, NSError* error){
                                       if([subtitlesArr count] > 0){
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"字幕"
                                                                                                  delegate:nil
                                                                                         cancelButtonTitle:@"取消"
                                                                                    destructiveButtonTitle:nil
                                                                                         otherButtonTitles:nil];
                                               
                                                   for(SubtitleModel *model in subtitlesArr){
                                                       [sheet addButtonWithTitle:model.name];
                                                   }
                                               
                                               sheet.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                                                   
//                                                   NSLog(@"buttonIndex=%d",buttonIndex);
                                                   if(buttonIndex != actionSheet.cancelButtonIndex){
                                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadingSubTitle" object:nil];//通知字幕在下载
                                                       
                                                       SubtitleModel *model = subtitlesArr[buttonIndex-1];
                                                       
                                                       [SubtitleManager downloadSubtitleWithUrl:model.file_path
                                                                                       fileName:model.name
                                                                              completionHandler:^(NSString* str, NSError* error){
//                                                                                  NSLog(@"%@ download success",model.name);
                                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"ParsingSubTitle" object:nil]; //通知字幕在解析
                                                                                  
                                                                                  SubtitleParser *parse = [SubtitleParser sharedInstance];
                                                                                  [parse parseString:str];
                                                                                  
                                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowSubTitle" object:nil]; //通知显示字幕
                                                                                  });
                                                                              }];
                                                   }
                                                   
                                                   
                                               };
                                               
                                               [sheet showInView:[self superview]];
                                           });
                                       }
                                       
                                   }];
    }
}
%end

%hook BaiduPlayerViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ShowSubTitle" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DownloadingSubTitle" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ParsingSubTitle" object:nil];
    %orig;
}
- (void)viewDidLoad
{
    %orig;
    
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, [UIScreen mainScreen].bounds.size.height-50, [UIScreen mainScreen].bounds.size.width-20, 50)] autorelease];
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:20];
    label.tag = -200;
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    label.shadowColor = [UIColor blackColor];
//    label.shadowOffset = CGSizeMake(1, 1);
    label.hidden = YES;
    [self.view addSubview:label];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSubTitle:)
                                                 name:@"ShowSubTitle"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadingSubTitle:)
                                                 name:@"DownloadingSubTitle"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parsingSubTitle:)
                                                 name:@"ParsingSubTitle"
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self hideSubTitle:nil];
    
    %orig;
}

- (void)handlePlayerStateTimer:(id)arg1
{
    %orig;
    
    UILabel *label = (UILabel *)[self.view viewWithTag:-200];
    if(label && !label.hidden){
        [self updateSubtitleDisplayWithCurrentPlaybackTime:self.player.currentPlaybackTime
                                        withLabelToDisplay:label];
    }
}

%new
- (void)updateSubtitleDisplayWithCurrentPlaybackTime:(double)time withLabelToDisplay:(UILabel *)label
{
//    NSLog(@"time=%f",time);
    
    SubtitleParser *parse = [SubtitleParser sharedInstance];

    if([[parse.subtitlesParts allValues] count] > 0){
        NSPredicate *initialPredicate = [NSPredicate predicateWithFormat:@"(%@ >= %K) AND (%@ <= %K)", @(time), kStart, @(time), kEnd];
        NSArray *objectsFound = [[parse.subtitlesParts allValues] filteredArrayUsingPredicate:initialPredicate];
        NSDictionary *lastFounded = (NSDictionary *)[objectsFound lastObject];
        
        label.text = [lastFounded objectForKey:kText];
    }
}

%new
- (void)showSubTitle:(id)sender
{
    //    NSLog(@"showSubTitle");
    UILabel *label = (UILabel *)[self.view viewWithTag:-200];
    [self.view bringSubviewToFront:label];
    label.hidden = NO;
    
    NSInteger indexOfLabel = [[self.view subviews] indexOfObject:label];
    NSInteger indexOfControlView = [[self.view subviews] indexOfObject:self.controlView];
    [self.view exchangeSubviewAtIndex:indexOfLabel withSubviewAtIndex:indexOfControlView];
}

%new
- (void)hideSubTitle:(id)sender
{
    UILabel *label = (UILabel *)[self.view viewWithTag:-200];
//    if(label){
//        [label removeFromSuperview];
//        label = nil;
//    }
    label.hidden = YES;
}

%new
- (void)downloadingSubTitle:(id)sender
{
    UILabel *label = (UILabel *)[self.view viewWithTag:-200];
    label.hidden = NO;
    label.text = @"字幕加载中...";
}

%new
- (void)parsingSubTitle:(id)sender
{
    UILabel *label = (UILabel *)[self.view viewWithTag:-200];
    label.hidden = NO;
    label.text = @"字幕解析中...";
}

%end

//@interface FileListRequest : NSObject
//@property(nonatomic, assign) int requestMethod;
//@property(nonatomic, retain) id callBack;
//- (void)setParam:(id)arg1 forKey:(id)arg2;
//- (id)initWithHash:(NSString *)hash;
//@end
//
//%hook FileListRequest
//%new
//- (id)initWithHash:(NSString *)hash
//{
//    self = [self init];
//    if(self){
//
//        self.RequestMethod = 1;
//        [self setParam:hash forKey:@"hash_str"];
//        [self setParam:@"2" forKey:@"format"];
//        [self setParam:@"1" forKey:@"hash_method"];
//    }
//
//    return self;
//}
//%end
//
//@interface HTTPFacade
//+ (id)httpDataSource;
//+ (unsigned long long)startRequst:(id)arg1 callback:(id)arg2;
//@end
//
//%hook HTTPFacade
//%new
//- (long long)getMovieSubtitleWithHash:(NSString *)hash callback:(id)callback
//{
//    FileListRequest *request = [[[FileListRequest alloc] initWithHash:hash] autorelease];
//
//    return [[self httpDataSource] startRequst:request callback:callback];
//}
//%end

//%hook BaseRequest
//- (id)parseResponse:(id)arg1 header:(id)arg2
//{
//    NSLog(@"parseResponse arg1=%@ arg2=%@",arg1,arg2);
//
//    return %orig;
//}
//- (void)setHeader:(id)arg1 forKey:(id)arg2
//{
//    NSLog(@"setHeader arg1=%@ arg2=%@",arg1,arg2);
//    %orig;
//}
//- (void)setParam:(id)arg1 forKey:(id)arg2
//{
//    NSLog(@"setParam arg1=%@ arg2=%@",arg1,arg2);
//    %orig;
//}
//%end

//%end
#pragma mark - BaiduYunEnd