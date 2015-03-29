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

/**
 *  Get next @p count words.
 *  Current strategy is to retrieve @a 2/3 * @p count of words to be reviewed,
 *  and the remaining words are randomly chosen (not necessarily new).
 *
 *  @param count Total number of words to retrieve.
 *
 *  @return An array of words, mixed with ones to be reviewed and others
 *  chosen randomly.
 */
- (NSArray *)getWordsWith:(int)count {
  NSAssert(count <= 10, @"required too many pairs");
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  // only retrieve words which should be reviewed today or earlier
  NSPredicate *priorityPredicate = [NSPredicate predicateWithFormat:@"%K <= %@", @"priority", @(0)];
  NSSortDescriptor *prioritySortDescriptor =
      [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES];
  NSSortDescriptor *proficiencySortDescriptor =
      [NSSortDescriptor sortDescriptorWithKey:@"proficiency" ascending:YES];
  [fetchRequest setEntity:_entityDescription];
  [fetchRequest setPredicate:priorityPredicate];
  [fetchRequest setSortDescriptors:@[prioritySortDescriptor, proficiencySortDescriptor]];
  [fetchRequest setFetchLimit:count];
  
  NSError *error;
  NSArray *result = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
  
  if (error) {
    NSLog(@"Error fetching data.");
    NSLog(@"%@, %@", error, error.localizedDescription);
    // TODO: fallback to random selection
    return NULL;
  }
  
  NSMutableArray *words = [NSMutableArray array];
  // 2/3 of count pairs should be reviewed
  int reviewWordLimit = MIN((int)result.count, count * 2 / 3);
  for (int i = 0; i < reviewWordLimit; ++i) {
    NSManagedObject *storedWord = (NSManagedObject *)[result objectAtIndex:i];
    NSString *wordString = [storedWord valueForKey:@"word"];
    NSString *definition = [_vocabulary objectForKeyedSubscript:wordString];
    Word *word = [[Word alloc]
                  initWithWord:wordString
                  ofDefinition:definition
                  ofProficiency:-1]; // proficiency does't matter
    
    // TODO: what if duplicate words are there?
    [words addObject:word];
  }
  
  // random for the rest
  // TODO: should be new words?
  NSArray *allKeys = [_vocabulary allKeys];
  for (int i = reviewWordLimit; i <count; ++i) {
    unsigned int randomIndex = arc4random_uniform((unsigned int)[allKeys count]);
    NSString *wordString = [allKeys objectAtIndex:randomIndex];
    NSString *definition = [_vocabulary objectForKey:wordString];
    Word *word = [[Word alloc]
                  initWithWord:wordString ofDefinition:definition ofProficiency:-1];
    [words addObject:word];
  }
  NSAssert(words.count == count, @"retrieved word number doesn't match");
  return words;
}

- (void)setWord:(NSString *)word withMatch:(BOOL)matched {
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSPredicate *wordPredicate =
      [NSPredicate predicateWithFormat:@"%K == %@", @"word", word];
  [fetchRequest setEntity:_entityDescription];
  [fetchRequest setPredicate:wordPredicate];

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
      [newWord setValue:@(1) forKey:@"proficiency"];
      [newWord setValue:@(1) forKey:@"priority"];
      if (![newWord.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
      }
    }
  } else {
    NSManagedObject *storedWord = (NSManagedObject *)[result objectAtIndex:0];
    int proficiency = [[storedWord valueForKey:@"proficiency"] intValue];
    if (matched) {
      // correct
      [storedWord setValue:@(proficiency + 1) forKey:@"proficiency"];
      [storedWord setValue:@([MemoryModel calculateNextReviewTimeFor:proficiency])
                    forKey:@"priority"];
    } else {
      // wrong match, TODO: better way to punish?
      [storedWord setValue:@(MAX(1, proficiency - 1)) forKey:@"proficiency"];
      // review immediately
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

+ (int)calculateNextReviewTimeFor:(int)currentProficiency {
  // simulate Fibonacci
  if (currentProficiency <= 1)
    return currentProficiency + 1;
  else
    return currentProficiency + (currentProficiency / 2);
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
