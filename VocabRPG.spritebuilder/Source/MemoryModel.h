//
//  MemoryModel.m
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemoryModel : NSObject

@property (nonatomic, assign) NSInteger playedDays;

- (NSArray *)getWordsWith:(int)count;
- (void)setWord:(NSString *)word withMatch:(BOOL)matched;
- (NSMutableArray *)retreiveAllWords;
- (NSUInteger)getMemorizedVocabularySize;
- (NSArray *)getMemorizedVocabularyCounts;
- (NSArray *)getMemorizedVocabularyCountsInAllProficiencyLevels;

+ (MemoryModel *)sharedMemoryModel;

@end
