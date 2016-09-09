//
//  RYPing.m
//  OCTest
//
//  Created by raiyi on 16/9/8.
//  Copyright © 2016年 liufan. All rights reserved.
//

#include <sys/socket.h>
#include <netdb.h>
#import "RYPing.h"
#import "SimplePing.h"
#import "RYPingModel.h"
#import "RYPingIntegrate.h"

@interface RYPing()<SimplePingDelegate>
@property (nonatomic, strong) SimplePing *simplePing;
@property (nonatomic, strong) NSTimer *sendTimer;
@property (nonatomic, assign) int repeatTimes;
@property (nonatomic, strong) RYPingIntegrate *modelManager;
@end

@implementation RYPing

- (instancetype)init{
    self = [super init];
    if (self) {
        self.modelManager = [[RYPingIntegrate alloc] init];
    }
    return self;
}


- (SimplePing *)newSimplePing:(NSString *)hostName forceIPv4:(BOOL)isIPv4 forceIPv6:(BOOL)isIPv6{
    
    SimplePing *simplePing = [[SimplePing alloc] initWithHostName:hostName];
    if (isIPv4 && !isIPv6) {
        simplePing.addressStyle = SimplePingAddressStyleICMPv4;
    } else if (isIPv6 && !isIPv4) {
        simplePing.addressStyle = SimplePingAddressStyleICMPv6;
    }
    return simplePing;
}

- (void)stop{
    if (self.simplePing) {
        [self.simplePing stop];
        self.simplePing = nil;
    }
    
    if (self.sendTimer) {
        [self.sendTimer invalidate];
        self.sendTimer = nil;
    }
    
}

- (void)startPing:(NSString *)hostName forceIPv4:(BOOL)isIPv4 forceIPv6:(BOOL)isIPv6 repeatTimes:(int)repeatTimes{
    [self stop];
    self.repeatTimes = repeatTimes;
    self.simplePing = [self  newSimplePing:hostName forceIPv4:isIPv4 forceIPv6:isIPv6];
    self.simplePing.delegate = self;
    [self.simplePing start];
}

- (void)sendPing:(NSTimer *)timer{
    if (self.simplePing && self.repeatTimes > 0) {
        [self.simplePing sendPingWithData:timer.userInfo];
        self.repeatTimes --;
    }else{
        [self stop];
        if (self.delegate && [self.delegate respondsToSelector:@selector(RYPingEnded:result:)]) {
            [self.delegate RYPingEnded:self result:[self.modelManager getPingResult]];
            [self.modelManager reset];
        }
        NSLog(@"ping stopped");
    }
}

- (NSString *)shortErrorFormError:(NSError *)error{
    if (error.domain == (__bridge NSString *)kCFErrorDomainCFNetwork && error.code == kCFHostErrorUnknown) {
        NSNumber *errorCode = error.userInfo[(__bridge NSString *)kCFGetAddrInfoFailureKey];
        if (errorCode) {
            if (errorCode.intValue != 0) {
                const char *f = gai_strerror(errorCode.intValue);
                if (f != nil) {
                    return [NSString stringWithUTF8String:f];
                }
            }
        }
    }
    if (error.localizedFailureReason) {
        return error.localizedFailureReason;
    }
    return error.localizedDescription;
}

#pragma mark - SimplePingDelegate
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address{
    if (pinger == self.simplePing) {
        [self.simplePing sendPingWithData:nil];
        self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendPing:) userInfo:nil repeats:YES];
    }
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error{
    [self stop];
    if (self.delegate && [self.delegate respondsToSelector:@selector(RYPingEnded:result:)]) {
        [self.delegate RYPingEnded:self result:[self.modelManager getPingResult]];
        [self.modelManager reset];
    }
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber{
    if (pinger == self.simplePing) {
        NSLog(@"%d sent", sequenceNumber);
        RYPingModel *info = [[RYPingModel alloc] init];
        info.status = SendPacketSuccess;
        info.time = [NSDate date];
        info.sequenceNumber = sequenceNumber;
        [self.modelManager addInfo:info];
    }
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error{
    if (pinger == self.simplePing) {
        NSLog(@"%d send failed: %@", sequenceNumber, [self shortErrorFormError:error]);
        RYPingModel *info = [[RYPingModel alloc] init];
        info.status = SendPacketFail;
        info.time = [NSDate date];
        info.sequenceNumber = sequenceNumber;
        [self.modelManager addInfo:info];
    }
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber{
    if (pinger == self.simplePing) {
        RYPingModel *info = [[RYPingModel alloc] init];
        info.status = ReceivePingResponsePacket;
        info.time = [NSDate date];
        info.sequenceNumber = sequenceNumber;
        [self.modelManager addInfo:info];
    }
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet{
    NSLog(@"unexpected packet, size=%lu", (unsigned long)packet.length);
}
@end
