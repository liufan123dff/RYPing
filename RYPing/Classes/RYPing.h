//
//  RYPing.h
//  OCTest
//
//  Created by raiyi on 16/9/8.
//  Copyright © 2016年 liufan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RYPing;
@protocol RYPingDelegate <NSObject>

- (void)RYPingEnded:(RYPing *)ping result:(NSDictionary *)resultInfo;

@end

@interface RYPing : NSObject

@property (nonatomic, weak) id<RYPingDelegate> delegate;

- (void)startPing:(NSString *)hostName forceIPv4:(BOOL)isIPv4 forceIPv6:(BOOL)isIPv6 repeatTimes:(int)repeatTimes;
- (void)stop;
@end
