//
//  RYPingIntegrate.h
//  OCTest
//
//  Created by raiyi on 16/9/8.
//  Copyright © 2016年 liufan. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString* const RYPingFail;
extern NSString* const RYPingLag;
extern NSString* const RYPingLoss;
@class RYPingModel;

@interface RYPingIntegrate : NSObject

- (void)reset;

- (void)addInfo:(RYPingModel *)model;

- (NSDictionary <NSString *, NSNumber *>*)getPingResult;
@end
