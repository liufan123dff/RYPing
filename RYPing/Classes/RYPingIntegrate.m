//
//  RYPingIntegrate.m
//  OCTest
//
//  Created by raiyi on 16/9/8.
//  Copyright © 2016年 liufan. All rights reserved.
//

#import "RYPingIntegrate.h"
#import "RYPingModel.h"


NSString* const RYPingFail = @"RYPingFail";
NSString* const RYPingLag = @"RYPingLag";
NSString* const RYPingLoss = @"RYPingLoss";


@interface RYPingIntegrate()
@property (nonatomic, strong) NSMutableArray *modelArr;
@property (nonatomic, strong) NSMutableDictionary *sendDateDict;//ping成功发出的时间字典
@property (nonatomic, strong) NSMutableDictionary *recivedDataDict;//ping收到回应的时间字典

//结果数组
@property (nonatomic, strong) NSMutableArray *failedPingArr;//发送失败数组
@property (nonatomic, strong) NSMutableDictionary *lagDict;//延迟字典
@property (nonatomic, strong) NSMutableArray *lossPingArr;//丢包数组
@end

@implementation RYPingIntegrate

- (instancetype)init{
    self = [super init];
    if (self) {
        self.modelArr = [NSMutableArray array];
        self.sendDateDict = [NSMutableDictionary dictionary];
        self.failedPingArr = [NSMutableArray array];
        self.lagDict = [NSMutableDictionary dictionary];
        self.recivedDataDict = [NSMutableDictionary dictionary];
        self.lossPingArr = [NSMutableArray array];
    }
    return self;
}

- (void)reset{
    self.modelArr = [NSMutableArray array];
    self.sendDateDict = [NSMutableDictionary dictionary];
    self.failedPingArr = [NSMutableArray array];
    self.lagDict = [NSMutableDictionary dictionary];
    self.recivedDataDict = [NSMutableDictionary dictionary];
    self.lossPingArr = [NSMutableArray array];
}

- (void)addInfo:(RYPingModel *)model{
    [self.modelArr addObject:model];
    
    if (model.status == SendPacketSuccess) {
        [self.sendDateDict setObject:model.time forKey:[NSString stringWithFormat:@"%d", model.sequenceNumber]];
    }else if (model.status == SendPacketFail){
        [self.failedPingArr addObject:[NSString stringWithFormat:@"%d", model.sequenceNumber]];
    }else if (model.status == ReceivePingResponsePacket){
        NSString *key = [NSString stringWithFormat:@"%d", model.sequenceNumber];//某次ping的序号
        
        
        if ([self.sendDateDict objectForKey:key] && ([self.recivedDataDict objectForKey:key] == nil)) {
            [self.lagDict setObject:@([model.time timeIntervalSinceDate:[self.sendDateDict objectForKey:key]]) forKey:[NSString stringWithFormat:@"%d", model.sequenceNumber]];
        }
        if ([self.recivedDataDict objectForKey:key] == nil) {
            [self.recivedDataDict setObject:[NSMutableArray arrayWithObjects:model.time, nil] forKey:key];
        }else{
            [[self.recivedDataDict objectForKey:key] addObject:model.time];
        }
        
    }
}

- (NSDictionary <NSString *, NSNumber *>*)getPingResult{
    __weak RYPingIntegrate *weakSelf = self;
    [self.sendDateDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (weakSelf.recivedDataDict[key] == nil) {
            [weakSelf.lossPingArr addObject:key];
        }
    }];
    return @{RYPingFail:self.failedPingArr,RYPingLag:self.lagDict,RYPingLoss:self.lossPingArr};
}
@end
