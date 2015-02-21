//
//  VocabularySource.h
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemorizationModel : NSObject

- (NSString *)getNextPair;

- (void)setWord:(NSString *)word withMatch:(BOOL)matched;

@end
