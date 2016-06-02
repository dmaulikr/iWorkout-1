//
//  CoreDataHelper.h
//  Grocery Dude
//
//  Created by Dayan Yonnatan on 30/12/2015.
//  Copyright © 2015 Dayan Yonnatan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreDataHelper : NSObject <NSXMLParserDelegate>

// iCloud Store
@property (nonatomic, readonly) NSPersistentStore *iCloudStore;

// Parent context
@property (nonatomic, readonly) NSManagedObjectContext *parentContext;

// Timer
@property (nonatomic, strong) NSTimer *importTimer;

// Source Stack
/*
@property (nonatomic, readonly) NSManagedObjectContext          *sourceContext;
@property (nonatomic, readonly) NSPersistentStoreCoordinator    *sourceCoordinator;
@property (nonatomic, readonly) NSPersistentStore               *sourceStore;

// Import context
@property (nonatomic, readonly) NSManagedObjectContext *importContext;
*/
@property (nonatomic, readonly) NSManagedObjectContext          *context;
@property (nonatomic, readonly) NSManagedObjectModel            *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator    *coordinator;
@property (nonatomic, readonly) NSPersistentStore               *store;


// MigrationViewController
//@property (nonatomic, retain) MigrationViewController *migrationVC;

// Import alert view
//@property (nonatomic, retain) UIAlertController *importAlertController;

// XML Parser
@property (nonatomic, strong) NSXMLParser *parser;

/*
// Seeding
@property (nonatomic, readonly) NSManagedObjectContext          *seedContext;
@property (nonatomic, readonly) NSPersistentStoreCoordinator    *seedCoordinator;
@property (nonatomic, readonly) NSPersistentStore               *seedStore;
//@property (nonatomic, retain)   UIAlertController               *seedAlertController;
@property (nonatomic)           BOOL                            seedInProgress;
*/

-(void)setupCoreData;
-(void)saveContext;
-(void)backgroundSaveContext;

-(BOOL)reloadStore;
-(NSURL*)applicationStoresDirectory;


// iCloud
-(BOOL)iCloudAccountIsSignedIn;
-(void)ensureAppropriateStoreIsLoaded;
-(BOOL)iCloudEnabledByUser;

@end



