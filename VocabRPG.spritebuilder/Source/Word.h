//
//  Word.h
//  VocabRPG
//
//  Created by Junjia He on 3/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Word : NSObject

@property (nonatomic, strong) NSString *word;
@property (nonatomic, strong) NSString *definition;
@property (nonatomic, assign) int proficiency;

- (id)initWithWord:(NSString *)word ofDefinition:(NSString *)definition;

@end
