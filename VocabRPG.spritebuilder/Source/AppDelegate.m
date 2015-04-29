/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
 * Copyright (c) 2013 Apportable Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "cocos2d.h"

#import "AppDelegate.h"
#import "CCBuilderReader.h"
#import "MemoryModel.h"

@implementation AppController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Configure Cocos2d with the options set in SpriteBuilder
  NSString *configPath = [[[NSBundle mainBundle] resourcePath]
      stringByAppendingPathComponent:@"Published-iOS"]; // TODO: add support for
                                                        // Published-Android
                                                        // support
  configPath =
      [configPath stringByAppendingPathComponent:@"configCocos2d.plist"];

  NSMutableDictionary *cocos2dSetup =
      [NSMutableDictionary dictionaryWithContentsOfFile:configPath];

// Note: this needs to happen before configureCCFileUtils is called, because we
// need apportable to correctly setup the screen scale factor.
#ifdef APPORTABLE
  if ([cocos2dSetup[CCSetupScreenMode] isEqual:CCScreenModeFixed])
    [UIScreen mainScreen].currentMode =
        [UIScreenMode emulatedMode:UIScreenAspectFitEmulationMode];
  else
    [UIScreen mainScreen].currentMode =
        [UIScreenMode emulatedMode:UIScreenScaledAspectFitEmulationMode];
#endif

  // Configure CCFileUtils to work with SpriteBuilder
  [CCBReader configureCCFileUtils];

  // Do any extra configuration of Cocos2d here (the example line changes the
  // pixel format for faster rendering, but with less colors)
  //[cocos2dSetup setObject:kEAGLColorFormatRGB565 forKey:CCConfigPixelFormat];

  [self setupCocos2dWithOptions:cocos2dSetup];

  return YES;
}

#pragma mark - Life cycle

- (CCScene *)startScene {
  MemoryModel *memoryModel = [MemoryModel sharedMemoryModel];

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDate *firstPlayedTime = [defaults objectForKey:@"Day0"],
         *now = [NSDate date];

  if (!firstPlayedTime) {
    // THIS IS THE FIRST PLAY!
    [defaults setObject:now forKey:@"Day0"];
    [defaults synchronize];
    memoryModel.playedDays = 0;
  } else {
    NSInteger daysInBetween =
        [AppController daysBetweenDate:firstPlayedTime andDate:now];
    memoryModel.playedDays = daysInBetween;
  }

  return [CCBReader loadAsScene:@"Title"];
}

- (void)saveContext {
  NSError *error = nil;
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext != nil) {
    if ([managedObjectContext hasChanges] &&
        ![managedObjectContext save:&error]) {
      // Replace this implementation with code to handle the error
      // appropriately.
      // abort() causes the application to generate a crash log and terminate.
      // You should not use this function in a shipping application, although it
      // may be useful during development.
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
  }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the
// persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
  if (_managedObjectContext != nil) {
    return _managedObjectContext;
  }

  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's
// model.
- (NSManagedObjectModel *)managedObjectModel {
  if (_managedObjectModel != nil) {
    return _managedObjectModel;
  }
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MemoryModel"
                                            withExtension:@"momd"];
  _managedObjectModel =
      [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's
// store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if (_persistentStoreCoordinator != nil) {
    return _persistentStoreCoordinator;
  }

  NSString *currentSaveSlot =
      [[NSUserDefaults standardUserDefaults] stringForKey:@"currentSaveSlot"];
  // in case of first start
  if (!currentSaveSlot)
    currentSaveSlot = @"0";

  NSURL *storeURL = [[self applicationDocumentsDirectory]
      URLByAppendingPathComponent:
          [NSString stringWithFormat:@"%@_VocabRPG.sqlite", currentSaveSlot]];

  NSError *error = nil;
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
      initWithManagedObjectModel:[self managedObjectModel]];
  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil
                                                           URL:storeURL
                                                       options:nil
                                                         error:&error]) {
    /*
     Replace this implementation with code to handle the error appropriately.

     abort() causes the application to generate a crash log and terminate. You
     should not use this function in a shipping application, although it may be
     useful during development.

     Typical reasons for an error here include:
     * The persistent store is not accessible;
     * The schema for the persistent store is incompatible with current managed
     object model.
     Check the error message to determine what the actual problem was.

     If the persistent store is not accessible, there is typically something
     wrong with the file path. Often, a file URL is pointing into the
     application's resources directory instead of a writeable directory.

     If you encounter schema incompatibility errors during development, you can
     reduce their frequency by:
     * Simply deleting the existing store:
     [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]

     * Performing automatic lightweight migration by passing the following
     dictionary as the options parameter:
     @{NSMigratePersistentStoresAutomaticallyOption:@YES,
     NSInferMappingModelAutomaticallyOption:@YES}

     Lightweight migration will only work for a limited set of schema changes;
     consult "Core Data Model Versioning and Data Migration Programming Guide"
     for details.

     */
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }

  return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager]
      URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Helper functions

+ (NSInteger)daysBetweenDate:(NSDate *)fromDateTime
                     andDate:(NSDate *)toDateTime {
  NSDate *fromDate;
  NSDate *toDate;

  NSCalendar *calendar = [NSCalendar currentCalendar];

  [calendar rangeOfUnit:NSCalendarUnitDay
              startDate:&fromDate
               interval:NULL
                forDate:fromDateTime];
  [calendar rangeOfUnit:NSCalendarUnitDay
              startDate:&toDate
               interval:NULL
                forDate:toDateTime];

  NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                             fromDate:fromDate
                                               toDate:toDate
                                              options:0];

  return [difference day];
}

@end
