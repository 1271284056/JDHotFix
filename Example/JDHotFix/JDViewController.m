//
//  JDViewController.m
//  JDHotFix
//
//  Created by zhangjiangdong on 03/28/2022.
//  Copyright (c) 2022 zhangjiangdong. All rights reserved.
//

#import "JDViewController.h"
#import <JDHotFix/JDHotFixConfig.h>
#import "JDHotFix_Example-Swift.h"

@interface JDViewController ()
@property (nonatomic, strong) TestSwift *testSwift;

@end

@implementation JDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.testSwift = [TestSwift new];
    JDHotFixConfig *config = [[JDHotFixConfig alloc] init];
    [config configHotFix];
    //hotfix方法调用后的方法才可以被热修复
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self test1:@"测试1"];
    [self.testSwift test];
    
    
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
