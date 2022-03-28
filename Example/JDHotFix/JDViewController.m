//
//  JDViewController.m
//  JDHotFix
//
//  Created by zhangjiangdong on 03/28/2022.
//  Copyright (c) 2022 zhangjiangdong. All rights reserved.
//

#import "JDViewController.h"
#import <JDHotFix/JDHotFixConfig.h>

@interface JDViewController ()

@end

@implementation JDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    JDHotFixConfig *config = [[JDHotFixConfig alloc] init];
    [config configHotFix];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self test1:@"测试1"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)test1:(NSString *)str {
    
    NSLog(@"test1111--->");
}

- (void)test2:(NSString *)str {
    
    NSLog(@"test2222---> ++ %@", str);
}

@end
