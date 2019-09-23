//
//  LFRedParamManager.m
//  AppList
//
//  Created by jennifor on 2019/9/19.
//  Copyright © 2019 linfen chu. All rights reserved.
//

#import "LFRedParamManager.h"

@implementation LFRedParamManager

-(NSDictionary *)singProtoParam
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setValue:self.channelId forKey:@"channelId"];
    [paramDic setValue:self.headImg forKey:@"headImg"];
    [paramDic setValue:self.msgType forKey:@"msgType"];
    [paramDic setValue:self.nativeUrl forKey:@"nativeUrl"];
    [paramDic setValue:self.nickName forKey:@"nickName"];
    [paramDic setValue:self.sendId forKey:@"sendId"];
    [paramDic setValue:self.sign forKey:@"sign"];
    [paramDic setValue:self.sessionUserName forKey:@"sessionUserName"];
    [paramDic setValue:self.timingIdentifier forKey:@"timingIdentifier"];
    return paramDic;
}

@end
