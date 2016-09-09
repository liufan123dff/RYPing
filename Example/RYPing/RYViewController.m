//
//  RYViewController.m
//  RYPing
//
//  Created by raiyi on 09/09/2016.
//  Copyright (c) 2016 raiyi. All rights reserved.
//

#import "RYViewController.h"
#import <RYPing/RYPing.h>
@interface RYViewController ()<RYPingDelegate>
@property (nonatomic,retain) RYPing *ping;
@end

@implementation RYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (self.ping == nil) {
        self.ping = [[RYPing alloc] init];
        self.ping.delegate = self;
    }
    [self.ping startPing:@"www.w99wen.tk" forceIPv4:YES forceIPv6:NO repeatTimes:10];
}

- (void)RYPingEnded:(RYPing *)ping result:(NSDictionary *)resultInfo;{
    NSLog(@"resultInfo = %@",[resultInfo description]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
