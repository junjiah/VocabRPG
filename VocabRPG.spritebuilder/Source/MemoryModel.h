//
//  MemoryModel.m
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemoryModel : NSObject

- (NSString *)getNextPair;
- (void)setWord:(NSString *)word withMatch:(BOOL)matched;
- (NSMutableArray *)retreiveAllWords;

+ (MemoryModel *)sharedMemoryModel;

@end
