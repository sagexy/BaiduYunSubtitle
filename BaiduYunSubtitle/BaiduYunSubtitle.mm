#line 1 "/Users/xy/WorkSpace/BaiduYunSubtitle/BaiduYunSubtitle/BaiduYunSubtitle.xm"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SubtitleManager.h"
#import "UIActionSheet+Blocks.h"
#import "SubtitleModel.h"
#import "SubtitleParser.h"

#pragma mark - BaiduYunStart




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

#include <logos/logos.h>
#include <substrate.h>
@class PlayerControlView; @class BaiduPlayerViewController; @class FileListViewController; 
static void (*_logos_orig$_ungrouped$FileListViewController$tableView$didSelectRowAtIndexPath$)(FileListViewController*, SEL, UITableView *, NSIndexPath *); static void _logos_method$_ungrouped$FileListViewController$tableView$didSelectRowAtIndexPath$(FileListViewController*, SEL, UITableView *, NSIndexPath *); static void (*_logos_orig$_ungrouped$PlayerControlView$drawPlayerControlPanel)(PlayerControlView*, SEL); static void _logos_method$_ungrouped$PlayerControlView$drawPlayerControlPanel(PlayerControlView*, SEL); static void (*_logos_orig$_ungrouped$PlayerControlView$resetViewFrame$animation$)(PlayerControlView*, SEL, CGRect, _Bool); static void _logos_method$_ungrouped$PlayerControlView$resetViewFrame$animation$(PlayerControlView*, SEL, CGRect, _Bool); static void _logos_method$_ungrouped$PlayerControlView$subTitleBtnClicked$(PlayerControlView*, SEL, id); static void (*_logos_orig$_ungrouped$BaiduPlayerViewController$dealloc)(BaiduPlayerViewController*, SEL); static void _logos_method$_ungrouped$BaiduPlayerViewController$dealloc(BaiduPlayerViewController*, SEL); static void (*_logos_orig$_ungrouped$BaiduPlayerViewController$viewDidLoad)(BaiduPlayerViewController*, SEL); static void _logos_method$_ungrouped$BaiduPlayerViewController$viewDidLoad(BaiduPlayerViewController*, SEL); static void (*_logos_orig$_ungrouped$BaiduPlayerViewController$viewWillDisappear$)(BaiduPlayerViewController*, SEL, BOOL); static void _logos_method$_ungrouped$BaiduPlayerViewController$viewWillDisappear$(BaiduPlayerViewController*, SEL, BOOL); static void (*_logos_orig$_ungrouped$BaiduPlayerViewController$handlePlayerStateTimer$)(BaiduPlayerViewController*, SEL, id); static void _logos_method$_ungrouped$BaiduPlayerViewController$handlePlayerStateTimer$(BaiduPlayerViewController*, SEL, id); static void _logos_method$_ungrouped$BaiduPlayerViewController$updateSubtitleDisplayWithCurrentPlaybackTime$withLabelToDisplay$(BaiduPlayerViewController*, SEL, double, UILabel *); static void _logos_method$_ungrouped$BaiduPlayerViewController$showSubTitle$(BaiduPlayerViewController*, SEL, id); static void _logos_method$_ungrouped$BaiduPlayerViewController$hideSubTitle$(BaiduPlayerViewController*, SEL, id); static void _logos_method$_ungrouped$BaiduPlayerViewController$downloadingSubTitle$(BaiduPlayerViewController*, SEL, id); static void _logos_method$_ungrouped$BaiduPlayerViewController$parsingSubTitle$(BaiduPlayerViewController*, SEL, id); 

#line 45 "/Users/xy/WorkSpace/BaiduYunSubtitle/BaiduYunSubtitle/BaiduYunSubtitle.xm"








static void _logos_method$_ungrouped$FileListViewController$tableView$didSelectRowAtIndexPath$(FileListViewController* self, SEL _cmd, UITableView * tableView, NSIndexPath * indexPath) {
    _logos_orig$_ungrouped$FileListViewController$tableView$didSelectRowAtIndexPath$(self, _cmd, tableView, indexPath);
    
    CacheFileMetaModel *model = self.fileList[indexPath.row];
    
    if(model.fileCategory == 1){ 
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setValue:model.blockListMd5 forKey:@"SelectFileMd5"];
        [userDefault synchronize];
    }













}





static void _logos_method$_ungrouped$PlayerControlView$drawPlayerControlPanel(PlayerControlView* self, SEL _cmd) {
    _logos_orig$_ungrouped$PlayerControlView$drawPlayerControlPanel(self, _cmd);
    
    UIButton *subTitleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [subTitleBtn setTitle:@"字幕" forState:UIControlStateNormal];
    [subTitleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    subTitleBtn.tag = -100;
    subTitleBtn.frame = CGRectZero;
    [subTitleBtn addTarget:self action:@selector(subTitleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:subTitleBtn];
}


static void _logos_method$_ungrouped$PlayerControlView$resetViewFrame$animation$(PlayerControlView* self, SEL _cmd, CGRect arg1, _Bool arg2) {
    _logos_orig$_ungrouped$PlayerControlView$resetViewFrame$animation$(self, _cmd, arg1, arg2);
    
    
    
    CGRect rect = self.contentChangeSlider.frame;
    rect.size.width -= 70;
    self.contentChangeSlider.frame = rect;
    
    UIButton *subTitleBtn = (UIButton *)[self viewWithTag:-100];
    subTitleBtn.frame = CGRectMake(rect.origin.x+rect.size.width,rect.origin.y+12,50,30);
}



static void _logos_method$_ungrouped$PlayerControlView$subTitleBtnClicked$(PlayerControlView* self, SEL _cmd, id sender) {
    

    
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
                                                   

                                                   if(buttonIndex != actionSheet.cancelButtonIndex){
                                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadingSubTitle" object:nil];
                                                       
                                                       SubtitleModel *model = subtitlesArr[buttonIndex-1];
                                                       
                                                       [SubtitleManager downloadSubtitleWithUrl:model.file_path
                                                                                       fileName:model.name
                                                                              completionHandler:^(NSString* str, NSError* error){

                                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"ParsingSubTitle" object:nil]; 
                                                                                  
                                                                                  SubtitleParser *parse = [SubtitleParser sharedInstance];
                                                                                  [parse parseString:str];
                                                                                  
                                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowSubTitle" object:nil]; 
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





static void _logos_method$_ungrouped$BaiduPlayerViewController$dealloc(BaiduPlayerViewController* self, SEL _cmd) {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ShowSubTitle" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DownloadingSubTitle" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ParsingSubTitle" object:nil];
    _logos_orig$_ungrouped$BaiduPlayerViewController$dealloc(self, _cmd);
}

static void _logos_method$_ungrouped$BaiduPlayerViewController$viewDidLoad(BaiduPlayerViewController* self, SEL _cmd) {
    _logos_orig$_ungrouped$BaiduPlayerViewController$viewDidLoad(self, _cmd);
    
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, [UIScreen mainScreen].bounds.size.height-50, [UIScreen mainScreen].bounds.size.width-20, 50)] autorelease];
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:20];
    label.tag = -200;
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;


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


static void _logos_method$_ungrouped$BaiduPlayerViewController$viewWillDisappear$(BaiduPlayerViewController* self, SEL _cmd, BOOL animated) {
    [self hideSubTitle:nil];
    
    _logos_orig$_ungrouped$BaiduPlayerViewController$viewWillDisappear$(self, _cmd, animated);
}


static void _logos_method$_ungrouped$BaiduPlayerViewController$handlePlayerStateTimer$(BaiduPlayerViewController* self, SEL _cmd, id arg1) {
    _logos_orig$_ungrouped$BaiduPlayerViewController$handlePlayerStateTimer$(self, _cmd, arg1);
    
    UILabel *label = (UILabel *)[self.view viewWithTag:-200];
    if(label && !label.hidden){
        [self updateSubtitleDisplayWithCurrentPlaybackTime:self.player.currentPlaybackTime
                                        withLabelToDisplay:label];
    }
}



static void _logos_method$_ungrouped$BaiduPlayerViewController$updateSubtitleDisplayWithCurrentPlaybackTime$withLabelToDisplay$(BaiduPlayerViewController* self, SEL _cmd, double time, UILabel * label) {

    
    SubtitleParser *parse = [SubtitleParser sharedInstance];

    if([[parse.subtitlesParts allValues] count] > 0){
        NSPredicate *initialPredicate = [NSPredicate predicateWithFormat:@"(%@ >= %K) AND (%@ <= %K)", @(time), kStart, @(time), kEnd];
        NSArray *objectsFound = [[parse.subtitlesParts allValues] filteredArrayUsingPredicate:initialPredicate];
        NSDictionary *lastFounded = (NSDictionary *)[objectsFound lastObject];
        
        label.text = [lastFounded objectForKey:kText];
    }
}



static void _logos_method$_ungrouped$BaiduPlayerViewController$showSubTitle$(BaiduPlayerViewController* self, SEL _cmd, id sender) {
    
    UILabel *label = (UILabel *)[self.view viewWithTag:-200];
    [self.view bringSubviewToFront:label];
    label.hidden = NO;
    
    NSInteger indexOfLabel = [[self.view subviews] indexOfObject:label];
    NSInteger indexOfControlView = [[self.view subviews] indexOfObject:self.controlView];
    [self.view exchangeSubviewAtIndex:indexOfLabel withSubviewAtIndex:indexOfControlView];
}



static void _logos_method$_ungrouped$BaiduPlayerViewController$hideSubTitle$(BaiduPlayerViewController* self, SEL _cmd, id sender) {
    UILabel *label = (UILabel *)[self.view viewWithTag:-200];




    label.hidden = YES;
}



static void _logos_method$_ungrouped$BaiduPlayerViewController$downloadingSubTitle$(BaiduPlayerViewController* self, SEL _cmd, id sender) {
    UILabel *label = (UILabel *)[self.view viewWithTag:-200];
    label.hidden = NO;
    label.text = @"字幕加载中...";
}



static void _logos_method$_ungrouped$BaiduPlayerViewController$parsingSubTitle$(BaiduPlayerViewController* self, SEL _cmd, id sender) {
    UILabel *label = (UILabel *)[self.view viewWithTag:-200];
    label.hidden = NO;
    label.text = @"字幕解析中...";
}






























































#pragma mark - BaiduYunEnd
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$FileListViewController = objc_getClass("FileListViewController"); MSHookMessageEx(_logos_class$_ungrouped$FileListViewController, @selector(tableView:didSelectRowAtIndexPath:), (IMP)&_logos_method$_ungrouped$FileListViewController$tableView$didSelectRowAtIndexPath$, (IMP*)&_logos_orig$_ungrouped$FileListViewController$tableView$didSelectRowAtIndexPath$);Class _logos_class$_ungrouped$PlayerControlView = objc_getClass("PlayerControlView"); MSHookMessageEx(_logos_class$_ungrouped$PlayerControlView, @selector(drawPlayerControlPanel), (IMP)&_logos_method$_ungrouped$PlayerControlView$drawPlayerControlPanel, (IMP*)&_logos_orig$_ungrouped$PlayerControlView$drawPlayerControlPanel);MSHookMessageEx(_logos_class$_ungrouped$PlayerControlView, @selector(resetViewFrame:animation:), (IMP)&_logos_method$_ungrouped$PlayerControlView$resetViewFrame$animation$, (IMP*)&_logos_orig$_ungrouped$PlayerControlView$resetViewFrame$animation$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$PlayerControlView, @selector(subTitleBtnClicked:), (IMP)&_logos_method$_ungrouped$PlayerControlView$subTitleBtnClicked$, _typeEncoding); }Class _logos_class$_ungrouped$BaiduPlayerViewController = objc_getClass("BaiduPlayerViewController"); MSHookMessageEx(_logos_class$_ungrouped$BaiduPlayerViewController, @selector(dealloc), (IMP)&_logos_method$_ungrouped$BaiduPlayerViewController$dealloc, (IMP*)&_logos_orig$_ungrouped$BaiduPlayerViewController$dealloc);MSHookMessageEx(_logos_class$_ungrouped$BaiduPlayerViewController, @selector(viewDidLoad), (IMP)&_logos_method$_ungrouped$BaiduPlayerViewController$viewDidLoad, (IMP*)&_logos_orig$_ungrouped$BaiduPlayerViewController$viewDidLoad);MSHookMessageEx(_logos_class$_ungrouped$BaiduPlayerViewController, @selector(viewWillDisappear:), (IMP)&_logos_method$_ungrouped$BaiduPlayerViewController$viewWillDisappear$, (IMP*)&_logos_orig$_ungrouped$BaiduPlayerViewController$viewWillDisappear$);MSHookMessageEx(_logos_class$_ungrouped$BaiduPlayerViewController, @selector(handlePlayerStateTimer:), (IMP)&_logos_method$_ungrouped$BaiduPlayerViewController$handlePlayerStateTimer$, (IMP*)&_logos_orig$_ungrouped$BaiduPlayerViewController$handlePlayerStateTimer$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = 'd'; i += 1; memcpy(_typeEncoding + i, @encode(UILabel *), strlen(@encode(UILabel *))); i += strlen(@encode(UILabel *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$BaiduPlayerViewController, @selector(updateSubtitleDisplayWithCurrentPlaybackTime:withLabelToDisplay:), (IMP)&_logos_method$_ungrouped$BaiduPlayerViewController$updateSubtitleDisplayWithCurrentPlaybackTime$withLabelToDisplay$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$BaiduPlayerViewController, @selector(showSubTitle:), (IMP)&_logos_method$_ungrouped$BaiduPlayerViewController$showSubTitle$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$BaiduPlayerViewController, @selector(hideSubTitle:), (IMP)&_logos_method$_ungrouped$BaiduPlayerViewController$hideSubTitle$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$BaiduPlayerViewController, @selector(downloadingSubTitle:), (IMP)&_logos_method$_ungrouped$BaiduPlayerViewController$downloadingSubTitle$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$BaiduPlayerViewController, @selector(parsingSubTitle:), (IMP)&_logos_method$_ungrouped$BaiduPlayerViewController$parsingSubTitle$, _typeEncoding); }} }
#line 344 "/Users/xy/WorkSpace/BaiduYunSubtitle/BaiduYunSubtitle/BaiduYunSubtitle.xm"
