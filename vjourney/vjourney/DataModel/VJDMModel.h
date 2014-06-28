//
//  VJCDModel.h
//  vjourneychat
//
//  Created by hejianwen on 18/6/14.
//  Copyright (c) 2014年 PolyU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface VJDMModel : NSObject

+(VJDMModel *)sharedInstance;

@property (readonly,strong,nonatomic)NSManagedObjectContext *managedObjectContext;
@property(readonly,strong,nonatomic)NSManagedObjectModel *managedObjectModel;
@property(readonly,strong,nonatomic)NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)saveChanges;
-(void)cancelChanges;

// Custom Methods
// Insert
-(NSManagedObject*)getNewEntity:(NSString*)entityName;
// Query
-(NSArray*)getEntityList:(NSString*)entityName;
-(NSArray*)getMessageListByTargetID:(NSNumber*)target_id;
-(NSArray*)getThreadList;
-(NSManagedObject*)getThreadByTargetID:(NSNumber*)target_id;
-(NSArray*)getNotifList;
// Remove
-(void)removeManagedObject:(NSManagedObject*)obj;
-(void)removeThreadAndMessageByID:(NSNumber*)thread_id;
@end
