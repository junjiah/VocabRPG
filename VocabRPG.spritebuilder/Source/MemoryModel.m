//
//  MemoryModel.m
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MemoryModel.h"
#import "AppDelegate.h"
#import "Word.h"

@implementation MemoryModel {
  NSManagedObjectContext *_managedObjectContext;
  NSEntityDescription *_entityDescription;
  NSMutableDictionary *_vocabulary;
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
  NSArray *allKeys = [_vocabulary allKeys];
  unsigned int randomIndex = arc4random_uniform((unsigned int)[allKeys count]);
  NSString *word = [allKeys objectAtIndex:randomIndex];
  NSString *definition = [_vocabulary objectForKey:word];
  return [NSString stringWithFormat:@"%@:%@", word, definition];
}

- (void)setWord:(NSString *)word withMatch:(BOOL)matched {
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSPredicate *predicate =
      [NSPredicate predicateWithFormat:@"%K == %@", @"word", word];
  [fetchRequest setEntity:_entityDescription];
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
    int proficiency = [[storedWord valueForKey:@"proficiency"] intValue],
        priority = [[storedWord valueForKey:@"priority"] intValue];
    if (matched) {
      // correct
      [storedWord setValue:@(proficiency + 1) forKey:@"proficiency"];
      [storedWord setValue:@([MemoryModel calculateNextReviewTimeFor:priority])
                    forKey:@"priority"];
    } else {
      // wrong match
      [storedWord setValue:@(MAX(0, proficiency - 1)) forKey:@"proficiency"];
      [storedWord setValue:@(1) forKey:@"priority"];
    }
    // save
    if (![storedWord.managedObjectContext save:&error]) {
      NSLog(@"Unable to save managed object context.");
      NSLog(@"%@, %@", error, error.localizedDescription);
    }
  }
}

- (NSMutableArray *)retreiveAllWords {
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSSortDescriptor *sortDescriptor =
      [NSSortDescriptor sortDescriptorWithKey:@"word" ascending:YES];
  [fetchRequest setEntity:_entityDescription];
  [fetchRequest setSortDescriptors:@[ sortDescriptor ]];

  NSError *error;
  NSArray *result =
      [_managedObjectContext executeFetchRequest:fetchRequest error:&error];

  if (error) {
    NSLog(@"Error fetching data.");
    NSLog(@"%@, %@", error, error.localizedDescription);
    return [NSMutableArray array];
  }

  NSMutableArray *words = [NSMutableArray array];
  for (NSManagedObject *object in result) {
    NSString *wordString = [object valueForKey:@"word"];
    NSString *definition = [_vocabulary objectForKeyedSubscript:wordString];
    Word *word = [[Word alloc]
         initWithWord:wordString
         ofDefinition:definition
        ofProficiency:[[object valueForKey:@"proficiency"] intValue]];
    [words addObject:word];
  }
  return words;
}

#pragma mark I/O functions

/**
 *  Read vocabulary files for words and corresponding definitions
 */
- (void)readVocabularyFile {
  NSString *vocabList =
      [[NSBundle mainBundle] pathForResource:@"TOEFL-test" ofType:@"tsv"];
  NSString *vocabFile =
      [[NSString alloc] initWithContentsOfFile:vocabList
                                      encoding:NSUTF8StringEncoding
                                         error:nil];
  NSArray *allLines = [vocabFile componentsSeparatedByCharactersInSet:
                                     [NSCharacterSet newlineCharacterSet]];

  _vocabulary = [NSMutableDictionary new];
  for (NSString *line in allLines) {
    if ([line length] == 0) {
      break;
    }

    NSArray *parts = [line componentsSeparatedByString:@"\t"];
    [_vocabulary setValue:[parts objectAtIndex:1]
                  forKey:[parts objectAtIndex:0]];
  }
}

#pragma mark Class methods

+ (int)calculateNextReviewTimeFor:(int)currentTime {
  // simulate Fibonacci
  if (currentTime == 1)
    return 2;
  else
    return currentTime + (currentTime / 2);
}

+ (MemoryModel *)sharedMemoryModel {
  static MemoryModel *model = nil;
  if (model == nil) {
    model = [[self alloc] init];
    [model readVocabularyFile];
  }
  return model;
}
@end
