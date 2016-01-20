//
//  CoreDataManager.h
//  CoreDataSample
//
//  Created by Alina Hambaryan on 1/19/16.
//  Copyright © 2016 Alina Hambaryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Note.h"
#import "Folder.h"

/**
 *  Enum for all type of entitites
 */
typedef NS_ENUM (NSInteger, FetchRequestEntityType) {
    /**
     *  Fetch request for not specified entity
     */
    FetchRequestEntityTypeNone,
    /**
     *  Fetch request for Note entity
     */
    FetchRequestEntityTypeNote,
    /**
     *  Fetch request for Folder entity
     */
    FetchRequestEntityTypeFolder,
};

@interface CoreDataManager : NSObject

@property (nonnull, readonly, strong, nonatomic ) NSManagedObjectContext       *managedObjectContext;
@property (nonnull, readonly, strong, nonatomic ) NSManagedObjectModel         *managedObjectModel;
@property (nonnull, readonly, strong, nonatomic ) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nullable, nonatomic, strong, readonly) NSFetchedResultsController   *fetchResultController;


+ (nonnull instancetype)sharedManager;

- (nullable NSFetchedResultsController *)fetchResultControllerForEntity:(FetchRequestEntityType)entity;

- (nullable Note *)addNote:(nullable NSDictionary *)details intoFolder: (nullable Folder *)folder;
- (void)deleteNote:(nonnull Note *)note;

- (nullable Folder *)addFolder:(nullable NSDictionary *)details;
- (void)deleteFolder:(nonnull Folder *)folder;

- (void)saveContext;

@end
