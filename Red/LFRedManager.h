//
//  LFRedManager.h
//  AppList
//
//  Created by jennifor on 2019/9/18.
//  Copyright © 2019 linfen chu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LFRedParamManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFRedManager : NSObject

//主动抢红包按钮
@property(nonatomic,assign)BOOL isAutoRed;

+(instancetype)sharedInstance;

//添加对象
-(void) addParams:(LFRedParamManager *) params;

//获得对象
- (LFRedParamManager *) getParams;

@end

NS_ASSUME_NONNULL_END
