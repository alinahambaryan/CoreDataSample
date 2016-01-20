//
//  CoreDataManager.m
//  CoreDataSample
//
//  Created by Alina Hambaryan on 1/19/16.
//  Copyright © 2016 Alina Hambaryan. All rights reserved.
//

#import "CoreDataManager.h"
#import "Note.h"

@implementation CoreDataManager

@synthesize managedObjectContext       = _managedObjectContext;
@synthesize managedObjectModel         = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (nonnull instancetype)sharedManager
{
    static CoreDataManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[CoreDataManager alloc] init];
    });
    
    return sharedInstance;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Core Data Lyfecycle methods
//-------------------------------------------------------------------------------------------

- (NSManagedObjectModel *)managedObjectModel
{
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL     = [[NSBundle mainBundle] URLForResource:@"CoreDataSample" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL             = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataSample.sqlite"];
    NSError *error              = nil;
    
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict              = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey]        = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey]             = error;
        error                                  = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Fetch Result Controller
//-------------------------------------------------------------------------------------------

- (nullable NSFetchedResultsController *)fetchResultControllerForEntity:(FetchRequestEntityType)entity;
{
    NSFetchedResultsController *fetch  = [[NSFetchedResultsController alloc]initWithFetchRequest:[self setFetchRequestForEntity:entity]
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:@"localdb"];
    NSError *error = nil;
    if( ! [fetch performFetch: &error] )    {
        NSLog( @"Error Description: %@", [error userInfo] );
    }
    return fetch;
}


//-------------------------------------------------------------------------------------------
#pragma mark - Private Methods
//-------------------------------------------------------------------------------------------
-(NSFetchRequest *)setFetchRequestForEntity:(FetchRequestEntityType)entity
{
    NSSortDescriptor *sortDescriptor;
    NSFetchRequest   *request;
    
    switch (entity) {
        case FetchRequestEntityTypeNote:{
            request        = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"name" ascending: NO];
            break;
        }
        case FetchRequestEntityTypeFolder:{
            request        = [NSFetchRequest fetchRequestWithEntityName:@"Folder"];
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"date" ascending: NO];
            break;
        }
            break;
        default:
            break;
    }
    [request setSortDescriptors: @[sortDescriptor]];
    
    return request;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Note managment
//-------------------------------------------------------------------------------------------

- (nullable Note *)addNote:(nullable NSDictionary *)details intoFolder: (nullable Folder *)folder
{
    Note *aNote  = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    aNote.name   = details[@"name"];
    aNote.info   = details[@"info"];
    aNote.folder = folder;
    aNote.date   = [NSDate date];

    [self saveContext];
    
    return aNote;
}

-(void)deleteNote:(Note *)note
{
    if (self.fetchResultController.fetchedObjects.count > 0) {
        [self.managedObjectContext deleteObject:note];
    }
    
    [self saveContext];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Folder managment
//-------------------------------------------------------------------------------------------

- (nullable Folder *)addFolder:(nullable NSDictionary *)details
{
    Folder *aFolder = [NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:self.managedObjectContext];
    aFolder.name    = details[@"name"];
    aFolder.date    = [NSDate date];
    
    [self saveContext];
    
    return aFolder;
}

- (void)deleteFolder:(nonnull Folder *)folder
{
    [self.managedObjectContext deleteObject:folder];
    
    [self saveContext];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Core Data Saving support
//-------------------------------------------------------------------------------------------

- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
