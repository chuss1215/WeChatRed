//
//  LFRedManager.m
//  AppList
//
//  Created by jennifor on 2019/9/18.
//  Copyright © 2019 linfen chu. All rights reserved.
//

#import "LFRedManager.h"

@interface LFRedManager()
@property(nonatomic,strong)NSMutableArray *array;

@end

@implementation LFRedManager

+(instancetype)sharedInstance
{
    static LFRedManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LFRedManager alloc]init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _array = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)addParams:(LFRedParamManager *)params
{
    [self.array addObject:params];
}

-(LFRedParamManager *)getParams
{
    if (self.array.count) {
        LFRedParamManager *param = self.array.firstObject;
        [self deleteParam];
        return param;
    }
    return nil;
}

-(void)deleteParam
{
    [self.array removeAllObjects];
}

//红包助手开关
-(void)dealWithRedSwitch{
    self.isAutoRed = ! self.isAutoRed;
}

@end
