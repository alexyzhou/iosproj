//
//  VJCDModel.m
//  vjourneychat
//
//  Created by hejianwen on 18/6/14.
//  Copyright (c) 2014年 PolyU. All rights reserved.
//

#import "VJDMModel.h"
#import "VJNYUtilities.h"

@implementation VJDMModel

@synthesize managedObjectContext=_managedObjectContext;
@synthesize managedObjectModel=_managedObjectModel;
@synthesize persistentStoreCoordinator=_persistentStoreCoordinator;


static VJDMModel * _sharedInstance=nil;

+(VJDMModel *)sharedInstance
{
    if (!_sharedInstance) {
        _sharedInstance=[[VJDMModel alloc] init];
    }
    return _sharedInstance;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
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
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"vjourney" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"vjourney.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


-(void)saveChanges
{
    NSError *error=nil;
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            //save failed
            NSLog(@"Save failed: %@",[error localizedDescription]);
        } else {
            NSLog(@"Save Succeeded");
        }
    }
}


-(void)cancelChanges
{
    [self.managedObjectContext rollback];
}

#pragma mark - Custom Methods

#pragma mark - Insert
-(NSManagedObject*)getNewEntity:(NSString*)entityName {
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
}

#pragma mark - Query
-(NSArray*)getEntityList:(NSString*)entityName {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:[VJDMModel sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError* error;
    NSArray *fetchedObjects = [[VJDMModel sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

-(NSArray*)getMessageListByTargetID:(NSNumber*)target_id {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VJDMMessage"
                                              inManagedObjectContext:[VJDMModel sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Sort
    NSSortDescriptor *sortByTime = [[NSSortDescriptor alloc] initWithKey:@"time"
                                                               ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByTime, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Where
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"target_id == %ld",[target_id longValue]];
    [fetchRequest setPredicate:predicateID];
    
    NSError* error;
    NSArray *fetchedObjects = [[VJDMModel sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

-(NSArray*)getThreadList {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VJDMThread"
                                              inManagedObjectContext:[VJDMModel sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Sort
    NSSortDescriptor *sortByTime = [[NSSortDescriptor alloc] initWithKey:@"last_time"
                                                               ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByTime, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError* error;
    NSArray *fetchedObjects = [[VJDMModel sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

-(NSManagedObject*)getThreadByTargetID:(NSNumber*)target_id {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VJDMThread"
                                              inManagedObjectContext:[VJDMModel sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Where
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"target_id == %ld",[target_id longValue]];
    [fetchRequest setPredicate:predicateID];
    
    NSError* error;
    NSArray *fetchedObjects = [[VJDMModel sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] == 0) {
        return NULL;
    }
    return fetchedObjects[0];
}

-(NSArray*)getNotifList {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VJDMNotification"
                                              inManagedObjectContext:[VJDMModel sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Sort
    NSSortDescriptor *sortByTime = [[NSSortDescriptor alloc] initWithKey:@"time"
                                                               ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByTime, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError* error;
    NSArray *fetchedObjects = [[VJDMModel sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

#pragma mark - Remove

-(void)removeManagedObject:(NSManagedObject *)obj {
    [self.managedObjectContext deleteObject:obj];
    [self saveChanges];
}

-(void)removeThreadAndMessageByID:(NSNumber*)thread_id {
    NSManagedObject* thread = [self getThreadByTargetID:thread_id];
    [self.managedObjectContext deleteObject:thread];
    
    NSArray* arrayOfMsg = [self getMessageListByTargetID:thread_id];
    for (NSManagedObject* obj in arrayOfMsg) {
        [self.managedObjectContext deleteObject:obj];
    }
    
    [self saveChanges];
}

@end
