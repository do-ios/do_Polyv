//
//  do_Polyv_IMethod.h
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol do_Polyv_ISM <NSObject>

//实现同步或异步方法，parms中包含了所需用的属性
@required
- (void)download:(NSArray *)parms;
- (void)getCurrentTime:(NSArray *)parms;
- (void)getInfo:(NSArray *)parms;
- (void)getList:(NSArray *)parms;
- (void)getState:(NSArray *)parms;
- (void)play:(NSArray *)parms;
- (void)stop:(NSArray *)parms;

@end