//
//  VocabularySource.m
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MemorizationModel.h"
#import "AppDelegate.h"
#import "Word.h"

static NSMutableArray *vocabulary;

static NSUInteger predefinedCounter = 0;

@implementation MemorizationModel {
  NSManagedObjectContext *_managedObjectContext;
  NSEntityDescription *_entityDescription;
}

- (id)init {
  AppController *appDelegate =
      (AppController *)[[UIApplication sharedApplication] delegate];
  _managedObjectContext = appDelegate.managedObjectContext;
  _entityDescription =
      [NSEntityDescription entityForName:@"Vocabulary"
                  inManagedObjectContext:_managedObjectContext];
  return self;
}

- (NSString *)getNextPair {
  NSUInteger index = (++predefinedCounter) % vocabulary.count;
  if (index == 0) {
    [MemorizationModel shuffle:vocabulary];
    predefinedCounter = 0;
  }
  Word *word = [vocabulary objectAtIndex:index];
  return [NSString stringWithFormat:@"%@:%@", word.word, word.definition];
}

- (void)setWord:(NSString *)word withMatch:(BOOL)matched {
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity =
      [NSEntityDescription entityForName:@"Vocabulary"
                  inManagedObjectContext:_managedObjectContext];
  NSPredicate *predicate =
      [NSPredicate predicateWithFormat:@"%K == %@", @"word", word];
  [fetchRequest setEntity:entity];
  [fetchRequest setPredicate:predicate];

  NSError *error;
  NSArray *result =
      [_managedObjectContext executeFetchRequest:fetchRequest error:&error];

  if (error) {
    NSLog(@"Error fetching data.");
    NSLog(@"%@, %@", error, error.localizedDescription);
    return;
  }

  if (result.count == 0) {
    // no such record, insert if correct, otherwise skip
    if (matched) {
      NSManagedObject *newWord =
          [[NSManagedObject alloc] initWithEntity:_entityDescription
                   insertIntoManagedObjectContext:_managedObjectContext];
      [newWord setValue:word forKey:@"word"];
      [newWord setValue:(matched ? @(1) : @(0))forKey:@"proficiency"];
      [newWord setValue:@(1) forKey:@"priority"];
      if (![newWord.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
      }
    }
  } else {
    NSManagedObject *storedWord = (NSManagedObject *)[result objectAtIndex:0];
    int profiency = [[storedWord valueForKey:@"profiency"] intValue],
        priority = [[storedWord valueForKey:@"priority"] intValue];
    if (matched) {
      // correct
      [storedWord setValue:@(profiency + 1) forKey:@"profiency"];
      [storedWord
          setValue:@([MemorizationModel calculateNextReviewTimeFor:priority])
            forKey:@"priority"];
    } else {
      // wrong match
      [storedWord setValue:@(MAX(0, profiency - 1)) forKey:@"proficiency"];
      [storedWord setValue:@(1) forKey:@"priority"];
    }
    // save
    if (![storedWord.managedObjectContext save:&error]) {
      NSLog(@"Unable to save managed object context.");
      NSLog(@"%@, %@", error, error.localizedDescription);
    }
  }
}

#pragma mark Class methods

+ (void)shuffle:(NSMutableArray *)array {
  NSUInteger count = [array count];
  for (NSUInteger i = 0; i < count; ++i) {
    NSInteger remainingCount = count - i;
    NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t)remainingCount);
    [array exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
  }
}

+ (void)initialize {
  NSString *vocabList =
      [[NSBundle mainBundle] pathForResource:@"TOEFL-test" ofType:@"tsv"];
  NSString *vocabFile =
      [[NSString alloc] initWithContentsOfFile:vocabList
                                      encoding:NSUTF8StringEncoding
                                         error:nil];
  NSArray *allLines = [vocabFile componentsSeparatedByCharactersInSet:
                                     [NSCharacterSet newlineCharacterSet]];

  vocabulary = [NSMutableArray new];
  for (NSString *line in allLines) {
    if ([line length] == 0) {
      break;
    }

    NSArray *parts = [line componentsSeparatedByString:@"\t"];
    Word *w = [[Word alloc] initWithWord:[parts objectAtIndex:0]
                            ofDefinition:[parts objectAtIndex:1]];
    [vocabulary addObject:w];
  }
  [MemorizationModel shuffle:vocabulary];
}

+ (int)calculateNextReviewTimeFor:(int)currentTime {
  // simulate Fibonacci
  if (currentTime == 1)
    return 2;
  else
    return currentTime + (currentTime / 2);
}
@end
