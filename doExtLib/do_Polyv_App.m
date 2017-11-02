//
//  do_Polyv_App.m
//  DoExt_SM
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_Polyv_App.h"
#import "PolyvUtil.h"
#import "PolyvSettings.h"
#import "doServiceContainer.h"
#import "doIModuleExtManage.h"
#import "doServiceContainer.h"
#import "doIGlobal.h"

static do_Polyv_App* instance;
@implementation do_Polyv_App
@synthesize OpenURLScheme;
+(id) Instance
{
    if(instance==nil)
        instance = [[do_Polyv_App alloc]init];
    return instance;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *userId = [[doServiceContainer Instance].ModuleExtManage GetThirdAppKey:@"doPolyv.plist" :@"userId" ];
    NSString *readtoken = [[doServiceContainer Instance].ModuleExtManage GetThirdAppKey:@"doPolyv.plist" :@"readtoken" ];
    NSString *writetoken = [[doServiceContainer Instance].ModuleExtManage GetThirdAppKey:@"doPolyv.plist" :@"writetoken" ];
    NSString *privateKey = [[doServiceContainer Instance].ModuleExtManage GetThirdAppKey:@"doPolyv.plist" :@"privateKey" ];
    //设置下载目录
    NSString *libraryPath;
    
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    libraryPath = [cachePaths lastObject];
    
    NSString *filePath = [NSString stringWithFormat:@"deviceone/data/temp/do_Polyv"];
    
    
    [[PolyvSettings sharedInstance] setDownloadDir:[libraryPath stringByAppendingPathComponent:filePath]];
    //执行初始化
    [[PolyvSettings sharedInstance] initVideoSettings:privateKey Readtoken:readtoken Writetoken:writetoken UserId:userId];

    return YES;
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[PolyvSettings sharedInstance] reloadSettings];
}
@end
