//
// Created by Milker on 2019-03-04.
// Copyright (c) 2019 lanjingren. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MPHotfix : NSObject

+ (instancetype)shared;

- (void)fix:(NSString *)js;

- (void)fixAtPath:(NSString *)path;

@end
