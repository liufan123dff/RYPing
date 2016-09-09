//
//  RYPingInfo.h
//  OCTest
//
//  Created by raiyi on 16/9/8.
//  Copyright © 2016年 liufan. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, RYPingStatus) {
    SendPacketSuccess,
    SendPacketFail,
    ReceivePingResponsePacket,
};


@interface RYPingModel : NSObject
@property (nonatomic, assign) uint16_t sequenceNumber;
@property (nonatomic, assign) RYPingStatus status;
@property (nonatomic, strong) NSDate *time;
@end
