//
//  do_Polyv_SM.m
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_Polyv_SM.h"

#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"
#import "PLVMoviePlayerController.h"
#import "doJsonHelper.h"
#import "PvUrlSessionDownload.h"
#import <UIKit/UIKit.h>
#import "doServiceContainer.h"
#import "doIModuleExtManage.h"
#import "PolyvSettings.h"
#import "doILogEngine.h"
#import "doIPageView.h"
#import "doIPage.h"
#import "PLVMoviePlayerController.h"

@interface do_Polyv_SM()<PvUrlSessionDownloadDelegate>
@end

@implementation do_Polyv_SM
{
    PLVMoviePlayerController *plvMovieVC;
    PvUrlSessionDownload *downloader;
    NSURLSession *urlSession;
    NSMutableURLRequest *request;
    CGFloat point;
}
#pragma mark - 方法
#pragma mark - 同步异步方法的实现
- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}
//同步
//同步
- (void)download:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //自己的代码实现
    NSString *vid = [doJsonHelper GetOneText:_dictParas :@"id" :@""];
    if (!vid || vid.length == 0) {
        [[doServiceContainer Instance].LogEngine WriteError:nil :@"id不能为空"];
        return;
    }
    int bitRate = [doJsonHelper GetOneInteger:_dictParas :@"bitRate" :1];
    //初始化下载器
    downloader = [[PvUrlSessionDownload alloc]initWithVid:vid level:bitRate];
    //设置下载代理为自身，需要实现四个代理方法
    [downloader setDownloadDelegate:self];
    
    //要配合AppDelegate设置实现后端下载
    [downloader setCompleteBlock:^{
        //        id<UIApplicationDelegate>appDelegate = [[UIApplication sharedApplication] delegate];
        //
        //        if(appDelegate.backgroundSessionCompletionHandler)
        //        {
        //            void (^handler)() = appDelegate.backgroundSessionCompletionHandler;
        //
        //            appDelegate.backgroundSessionCompletionHandler = nil;
        //
        //            handler();
        //        }
        
    }];
    //开始下载流畅码率视频，level的取值分别为流畅 1，高清 2，超清3
    //如果设置的码率不存在，就会下载默认最高清的码率，该码率参数可以通过_downloader.level获得
    [downloader start];
    //_invokeResult设置返回值
    
}
- (void)getCurrentTime:(NSArray *)parms
{
    //参数字典_dictParas
    //自己的代码实现
    
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //自己的代码实现
    CGFloat time = plvMovieVC.currentPlaybackTime;
    time = time * 1000;
    //回调函数名_callbackName
    //_invokeResult设置返回值
    if (isnan(time)) {
        time = 0;
    }
    [_invokeResult SetResultFloat:time];
}
- (void)getState:(NSArray *)parms
{
    //自己的代码实现
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    MPMoviePlaybackState state =plvMovieVC.playbackState;
    NSString *stateStr;
    if (state == MPMoviePlaybackStateStopped) {
        stateStr = @"0";
    }
    else if(state == MPMoviePlaybackStatePlaying)
    {
        stateStr = @"1";
    }
    else
    {
        stateStr = @"0";
    }
    NSLog(@"getState =%@",stateStr);
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    [node setObject:stateStr forKey:@"state"];
    [_invokeResult SetResultNode:node];
}
- (void)play:(NSArray *)parms
{
    //参数字典_dictParas
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    NSString *vid = [doJsonHelper GetOneText:_dictParas :@"id" :@""];
    
    if (!vid || vid.length == 0) {
        [[doServiceContainer Instance].LogEngine WriteError:nil :@"id不能为空"];
        return;
    }
    point = [doJsonHelper GetOneInteger:_dictParas :@"point" :0];
    point = point / 1000;
    
    int bitRate = [doJsonHelper GetOneInteger:_dictParas :@"bitRate" :1];
    
    //iOS只支持全屏
    //BOOL isFull = [doJsonHelper GetOneBoolean:_dictParas :@"isFull" :@"true"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerWillExitFullscreenNotification:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerDidExitFullscreenNotification:)
                                                 name:MPMoviePlayerDidExitFullscreenNotification
                                               object:nil];
    
    id<doIPage>pageModel = _scritEngine.CurrentPage;
    UIViewController *currentVC = (UIViewController *)pageModel.PageView;
    plvMovieVC = [[PLVMoviePlayerController alloc]init];
    
    [plvMovieVC prepareToPlay];
    [currentVC.view addSubview:plvMovieVC.view];
    [plvMovieVC setVid:vid level:bitRate];
    plvMovieVC.fullscreen = YES;
    [plvMovieVC play];
}
- (void)stop:(NSArray *)parms
{
    [plvMovieVC stop];
    [plvMovieVC.view removeFromSuperview];
    plvMovieVC = nil;
}
- (void)getInfo:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    NSString *_callbackName = [parms objectAtIndex:2];
    //回调函数名_callbackName
    doInvokeResult *_invokeResult  = [[doInvokeResult alloc] init];
    //自己的代码实现
    NSString *vid = [doJsonHelper GetOneText:_dictParas :@"id" :@""];
    if (!vid || vid.length == 0) {
        [[doServiceContainer Instance].LogEngine WriteError:nil :@"id不能为空"];
        return;
    }
    
    NSString *baseUrl = @"http://v.polyv.net/uc/services/rest?method=getById";
    NSString *fromatUrl = [NSString stringWithFormat:@"%@&readtoken=%@&vid=%@",baseUrl,PolyvReadtoken,vid];
    //_invokeResult设置返回值
    
    request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:fromatUrl]];
    [request setHTTPMethod:@"GET"];
    
    urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSMutableDictionary *node = [NSMutableDictionary dictionary];
        @try {
            if(data!=nil){
                NSDictionary * jsondata = [NSJSONSerialization
                                           JSONObjectWithData:data
                                           options:0
                                           error:&error];
                NSArray *videos = [jsondata objectForKey:@"data"];
                NSDictionary *videoDict = [videos firstObject];
                node = [self getVideoInfo:videoDict :vid];
            }
        }
        @catch (NSException *exception) {
            [[doServiceContainer Instance].LogEngine WriteError:exception :@"返回结果出错"];
        }
        @finally {
            [_invokeResult SetResultNode:node];
            [_scritEngine Callback:_callbackName :_invokeResult];
        }
        
    }] resume];
}

- (NSMutableDictionary *)getVideoInfo:(NSDictionary *)dict :(NSString *)vid
{
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    NSString *title = [dict objectForKey:@"title"];
    if (!title) {
        title = @"";
    }
    NSNumber *duration = [dict objectForKey:@"duration"];
    if (!duration) {
        duration = [NSNumber new];
    }
    NSString *first_image = [dict objectForKey:@"first_image"];
    if (!first_image) {
        first_image = @"";
    }
    NSNumber *source_filesize = [dict objectForKey:@"source_filesize"];
    if (!source_filesize) {
        source_filesize = [NSNumber new];
    }
    NSNumber *df = [dict objectForKey:@"df"];
    if (!df) {
        df = [NSNumber new];
    }
    NSString *ids = [dict objectForKey:@"vid"];
    if (!ids) {
        ids = @"";
    }
    if (!vid || vid.length == 0) {
        vid = ids;
    }
    [node setObject:vid forKey:@"id"];
    [node setObject:title forKey:@"title"];
    [node setObject:duration forKey:@"duration"];
    [node setObject:first_image forKey:@"imageUrl"];
    [node setObject:source_filesize forKey:@"fileSize"];
    [node setObject:df forKey:@"bitRates"];
    
    return node;
}

- (void)getList:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    int pageIndex = [doJsonHelper GetOneInteger:_dictParas :@"pageIndex" :1];
    int pageSize = [doJsonHelper GetOneInteger:_dictParas :@"pageSize" :10];
    pageIndex ++;
    NSString *_callbackName = [parms objectAtIndex:2];
    //回调函数名_callbackName
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    //_invokeResult设置返回值
    
    NSString *listbaseUrl = @"http://v.polyv.net/uc/services/rest?method=getNewList";
    NSString *formatStr = [NSString stringWithFormat:@"readtoken=%@&pageNum=%d&numPerPage=%d",PolyvReadtoken,pageIndex,pageSize];
    NSString *formatUlr = [NSString stringWithFormat:@"%@&%@",listbaseUrl,formatStr];
    request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:formatUlr]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:60];
    urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          NSMutableArray *nodeArray = [NSMutableArray array];
          @try {
              if(data!=nil){
                  NSDictionary * jsondata = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&error];
                  
                  NSMutableArray *videos = [jsondata objectForKey:@"data"];
                  for(int i=0;i<videos.count;i++){
                      NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
                      NSDictionary*item = [videos objectAtIndex:i];
                      tempDic = [self getVideoInfo:item :@""];
                      [nodeArray addObject:tempDic];
                  }
              }
          }
          @catch (NSException *exception) {
              [[doServiceContainer Instance].LogEngine WriteError:exception :@"返回结果出错"];
          }
          @finally {
              [_invokeResult SetResultArray:nodeArray];
              [_scritEngine Callback:_callbackName :_invokeResult];
              
          }
          
      }] resume];
    
}
- (void)moviePlaybackStateDidChange:(NSNotification*)notification
{
    MPMoviePlayerController *moviePlayer = [notification object];
    [moviePlayer setCurrentPlaybackTime:point];
}

- (void)moviePlayerWillExitFullscreenNotification:(NSNotification*)notification
{
    [plvMovieVC stop];
}
- (void)moviePlayerDidExitFullscreenNotification:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil ];
    
    [self stop:nil];
}
#pragma mark - PvUrlSessionDownloadDelegate 代理方法
- (void)downloadDidFinished:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid
{
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    [node setObject:@(0) forKey:@"type"];
    doInvokeResult *_invokeResult = [[doInvokeResult alloc]init];
    [_invokeResult SetResultNode:node];
    [self.EventCenter FireEvent:@"success" :_invokeResult];
}

- (void)dataDownloadFailed:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid reason:(NSString *)reason
{
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    [node setObject:@(0) forKey:@"type"];
    doInvokeResult *_invokeResult = [[doInvokeResult alloc]init];
    [_invokeResult SetResultNode:node];
    [self.EventCenter FireEvent:@"fail" :_invokeResult];
}
- (void)dataDownloadAtPercent:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid percent:(NSNumber *)aPercent
{
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    [node setObject:aPercent.stringValue forKey:@"progress"];
    doInvokeResult *_invokeResult = [[doInvokeResult alloc]init];
    [_invokeResult SetResultNode:node];
    [self.EventCenter FireEvent:@"downloadProgress" :_invokeResult];
}
@end