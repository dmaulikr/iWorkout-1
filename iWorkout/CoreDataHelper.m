//
//  CoreDataHelper.m
//  Grocery Dude
//
//  Created by Dayan Yonnatan on 30/12/2015.
//  Copyright © 2015 Dayan Yonnatan. All rights reserved.
//

#import "CoreDataHelper.h"
//#import "Faulter.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@implementation CoreDataHelper

#define debugging 1

#pragma mark - FILES
NSString *storeFilename = @"iWorkout.sqlite";
NSString *sourceStoreFilename = @"DefaultData.sqlite";
NSString *iCloudStoreFilename = @"iCloud.sqlite";


#pragma mark - PATHS
-(NSURL*)iCloudStoreURL {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    return [[self applicationStoresDirectory] URLByAppendingPathComponent:iCloudStoreFilename];
}

-(NSString *)applicationDocumentsDirectory
{
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
-(NSURL *)applicationStoresDirectory
{
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    
    NSURL *storesDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Stores"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:[storesDirectory path]]) {
        NSError *error = nil;
        if([fileManager createDirectoryAtURL:storesDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            if(debugging) {
                NSLog(@"Successfully created Stores directory");
            }
        } else {
            NSLog(@"Failed to create Stores directory: %@", error);
        }
        
    }
    return storesDirectory;
}
-(NSURL *)storeURL {
    if(debugging) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    return [[self applicationStoresDirectory] URLByAppendingPathComponent:storeFilename];
}

-(NSURL*)sourceStoreURL {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    return [NSURL fileURLWithPath:[[NSBundle mainBundle]
                pathForResource:[sourceStoreFilename stringByDeletingPathExtension]
                                   ofType:[sourceStoreFilename pathExtension]]];
}


#pragma mark - SETUP

-(id)init
{
    if(debugging) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    self = [super init];
    if(!self) {
        return nil;
    }
    if([AppDelegate isSetupComplete]) {
        _model = [AppDelegate getModel];
        NSLog(@"Successfully created model!");
    } else {
        NSLog(@"ERROR! No model found!");
        exit(0);
    }
    //_model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
    
    // Setting up new Parent context
    _parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_parentContext performBlockAndWait:^{
        [_parentContext setPersistentStoreCoordinator:_coordinator];
        [_parentContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }];
    
    
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    //[_context setPersistentStoreCoordinator:_coordinator]; - NSInternalInconsistencyException - Context already has a coordinator; cannot replace
    [_context setParentContext:_parentContext]; // Set the parent context
    [_context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    // Set up of Import context
    _importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_importContext performBlockAndWait:^{
        //[_importContext setPersistentStoreCoordinator:_coordinator];
        [_importContext setParentContext:_context];
        [_importContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [_importContext setUndoManager:nil]; // the default on iOS
    }];
    
    //_sourceCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
    _sourceContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_sourceContext performBlockAndWait:^{
        //[_sourceContext setPersistentStoreCoordinator:_sourceCoordinator];
        [_sourceContext setParentContext:_context];
        [_sourceContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [_sourceContext setUndoManager:nil]; // the default on iOS
    }];
    
    // Seeding
    _seedCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
    _seedContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_seedContext performBlockAndWait:^{
        [_seedContext setPersistentStoreCoordinator:_seedCoordinator];
        [_seedContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [_seedContext setUndoManager:nil]; // the default on iOS
    }];
    _seedInProgress = NO;
    
    [self listenForStoreChanges];
    
    return self;
}

-(void)loadStore
{
    if(debugging) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    if(_store) {
        return; // Don't load store if it's already loaded
    }
    
    BOOL useMigrationManager = NO;
    
    if(useMigrationManager && [self isMigrationNecessaryForStore:[self storeURL]]) {
        //[self performBackgroundManagedMigrationForStore:[self storeURL]];
    } else {
        
        
        NSDictionary *options = @{NSSQLitePragmasOption: @{@"journal_mode":@"DELETE"},
                                  NSInferMappingModelAutomaticallyOption:@YES,
                                  NSMigratePersistentStoresAutomaticallyOption:@YES};
        
        
        
        NSError *error = nil;
        _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                            configuration:nil
                                                      URL:[self storeURL]
                                                  options:options
                                                    error:&error]; // Added 'options'
        if(!_store) {
            NSLog(@"Failed to add store. Error %@", error);
            abort();
        }
        else {
            if(debugging)
                NSLog(@"Successfully added store: %@", _store);
        }
    }
}
-(void)loadSourceStore {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if(_sourceStore) {
        return; // Don't load source store if it's already loaded
    }
    
    NSDictionary *options = @{NSReadOnlyPersistentStoreOption:@YES};
    NSError *error = nil;
    _sourceStore = [_sourceCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                    configuration:nil
                                                              URL:[self sourceStoreURL]
                                                          options:options
                                                            error:&error];
    if(!_sourceStore) {
        NSLog(@"Failed to add source store. Error: %@", error);
        abort();
    } else {
        NSLog(@"Successfully added source store: %@", _sourceStore);
    }
}

-(void)setupCoreData
{
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    /*
    if(!_store && !_iCloudStore) {
        if([self iCloudEnabledByUser]) {
            NSLog(@"** Attempting to load the iCloud Store **");
            if([self loadiCloudStore]) {
                return;
            }
        }
        NSLog(@"** Attempting to load the Local, Non-iCloud Store **");
        [self setDefaultDataStoreAsInitialStore];
        [self loadStore];
    } else {
        NSLog(@"SKIPPED setupCoreData, there's an existing Store: \n** _store(%@) \n** iCloudStore(%@)", _store, _iCloudStore);
    }*/
    
    // TESTING METHOD BELOW:
    [self loadStore];
    
    
    /*
    if(![self loadiCloudStore]) {
        [self setDefaultDataStoreAsInitialStore];
        [self loadStore];
    } else {
        NSLog(@"Loaded iCloud store.");
    }*/
    
    //[self importGroceryDudeTestData];
    //[self checkIfDefaultDataNeedsImporting];
    
}


#pragma mark - Saving
-(void)saveContext
{
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    
    if([_context hasChanges]) {
        NSError *error;
        if([_context save:&error]) {
            NSLog(@"_context SAVED changes to persistent store");
        } else {
            NSLog(@"Failed to save _context: %@", error);
            [self showValidationError:error];
        }
    } else {
        NSLog(@"Skipped _context SAVE, there are no changes!");
    }
}

-(void)backgroundSaveContext {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    // First, save the child context in the foreground (fast, all in memory)
    [self saveContext];
    
    // Then, save the parent context.
    [_parentContext performBlock:^{
        if([_parentContext hasChanges]) {
            NSError *error = nil;
            if([_parentContext save:&error]) {
                NSLog(@"_parentContext SAVED changes to the persistent store");
            } else {
                NSLog(@"_parentContext FAILED to save: %@", error);
                [self showValidationError:error];
            }
        } else {
            NSLog(@"_parentContext SKIPPED saving as there are no changes");
        }
        
    }];
}

#pragma mark - Migration Manager
-(BOOL)isMigrationNecessaryForStore:(NSURL*)storeUrl {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[self storeURL].path]) {
        if(debugging) { NSLog(@"Skipped migration: Source database missing"); }
        return NO;
    }
    NSError *error = nil;
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeUrl options:nil error:&error];
    NSManagedObjectModel *destinationModel = _coordinator.managedObjectModel;
    
    if([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]) {
        if(debugging) {
            NSLog(@"Skipped migration: Source is already compatible");
        }
        return NO;
    }
    return YES;
}

-(BOOL)migrateStore:(NSURL*)sourceStore {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    BOOL success = NO;
    NSError *error = nil;
    
    // STEP 1 - Gather the Source, Destination and Mapping Model
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                              URL:sourceStore
                                                                                          options:nil
                                                                                            error:&error];
    
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetadata];
    
    NSManagedObjectModel *destinModel = _model;
    
    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:destinModel];
    
    // STEP 2 - Perform migration, assuming the mapping model isn't null
    if(mappingModel) {
        NSError *error = nil;
        NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destinModel];
        [migrationManager addObserver:self forKeyPath:@"migrationProgress" options:NSKeyValueObservingOptionNew context:NULL];
        
        NSURL *destinStore = [[self applicationStoresDirectory] URLByAppendingPathComponent:@"Temp.sqlite"];
        
        success = [migrationManager migrateStoreFromURL:sourceStore type:NSSQLiteStoreType options:nil withMappingModel:mappingModel toDestinationURL:destinStore destinationType:NSSQLiteStoreType destinationOptions:nil error:&error];
        
        if(success) {
            // STEP 3 - Replace the old store with the new migrated store
            if([self replaceStore:sourceStore withStore:destinStore]) {
                if(debugging)
                    NSLog(@"Successfully migrated %@ to the Current Model", sourceStore.path);
                
                [migrationManager removeObserver:self forKeyPath:@"migrationProgress"];
            }
            
        } else {
            if(debugging)
                NSLog(@"Failed migration: %@", error);
        }
        
        
    } else {
        if(debugging)
            NSLog(@"Failed migration: Mapping model is null");
        
    }
    return YES; // indicates migration has finished, regardless of outcome.
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"migrationProgress"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
           
            float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            //self.migrationVC.progressView.progress = progress;
            int percentage = progress * 100;
            NSString *string = [NSString stringWithFormat:@"Migration Progress: %i%%", percentage];
            NSLog(@"progress val: %f", progress);
            NSLog(@"%@", string);
           // self.migrationVC.label.text = string;
        });
        
    }
}


-(BOOL)replaceStore:(NSURL*)oldStore withStore:(NSURL*)newStore
{
    
    BOOL success = NO;
    NSError *Error = nil;
    
    if([[NSFileManager defaultManager] removeItemAtURL:oldStore error:&Error]) {
        Error = nil;
        
        if([[NSFileManager defaultManager] moveItemAtURL:newStore toURL:oldStore error:&Error]) {
            success = YES;
        } else {
            if(debugging)
                NSLog(@"Failed to re-home new store %@", Error);
        }
        
    } else {
        if(debugging)
            NSLog(@"Failed to remove old store %@: Error: %@", oldStore, Error);
    }
    return success;
}
/*
-(void)performBackgroundManagedMigrationForStore:(NSURL*)storeURL {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    
    // Show migration progress view preventing the user from using the app
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.migrationVC = [sb instantiateViewControllerWithIdentifier:@"migrationViewController"];
    
    UIApplication *sa = [UIApplication sharedApplication];
    UINavigationController *nc = (UINavigationController*)sa.keyWindow.rootViewController;
    [nc presentViewController:self.migrationVC animated:NO completion:nil];
    
    // Perform migration in the background, so it doesn't freeze the UI.
    // This way progress can be shown to the user
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL done = [self migrateStore:storeURL];
        if(done) {
            // When migration finishes, add the newly migrated store
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = nil;
                _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                    configuration:nil
                                                              URL:[self storeURL]
                                                          options:nil error:&error];
                
                if(!_store) {
                    NSLog(@"Failed to add a migrated store. Error %@", error);
                    abort();
                } else {
                    NSLog(@"Successfully added a migrated store: %@", _store);
                }
                [self.migrationVC dismissViewControllerAnimated:NO completion:nil];
                self.migrationVC = nil;
            });
            
        }
        
        
    });
    
}*/

#pragma mark - Validation Error Handling
-(void)showValidationError:(NSError*)anError {
    
    if(anError && [anError.domain isEqualToString:@"NSCocoaErrorDomain"]) {
        NSArray *errors = nil;      // holds all errors
        NSString *txt = @"";        // the error message text of the alert
        
        // Populate array with error(s)
        if(anError.code == NSValidationMultipleErrorsError) {
            errors = [anError.userInfo objectForKey:NSDetailedErrorsKey];
        } else {
            errors = [NSArray arrayWithObject:anError];
        }
        
        // Display the error(s)
        if(errors && errors.count > 0) {
            // Build error message text based on errors
            for(NSError *error in errors) {
                NSString *entity = [[[error.userInfo objectForKey:@"NSValidationErrorObject"] entity]name];
                
                NSString *property = [error.userInfo objectForKey:@"NSValidationErrorKey"];
                
                switch (error.code) {
                    case NSValidationRelationshipDeniedDeleteError:
                        txt = [txt stringByAppendingFormat:@"%@ delete was denied because there are associated %@\n(Error Code %li)\n\n",entity,property,(long)error.code];
                        break;
                    case NSValidationRelationshipLacksMinimumCountError:
                        txt = [txt stringByAppendingFormat:@"the '%@' relationship count is too small (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationRelationshipExceedsMaximumCountError:
                        txt = [txt stringByAppendingFormat:@"the '%@' relationship count is too large (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationMissingMandatoryPropertyError:
                        txt = [txt stringByAppendingFormat:@"the '%@' property is missing (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationNumberTooSmallError:
                        txt = [txt stringByAppendingFormat:@"the '%@' number is too small (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationNumberTooLargeError:
                        txt = [txt stringByAppendingFormat:@"the '%@' number is too large (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationDateTooSoonError:
                        txt = [txt stringByAppendingFormat:@"the '%@' date is too soon (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationDateTooLateError:
                        txt = [txt stringByAppendingFormat:@"the '%@' date is too late (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationInvalidDateError:
                        txt = [txt stringByAppendingFormat:@"the '%@' date is invalid (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationStringTooLongError:
                        txt = [txt stringByAppendingFormat:@"the '%@' text is too long (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationStringTooShortError:
                        txt = [txt stringByAppendingFormat:@"the '%@' text is too short (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationStringPatternMatchingError:
                        txt = [txt stringByAppendingFormat:@"the '%@' text doesn't match the specified pattern (Code %li).", property, (long)error.code];
                        break;
                    case NSManagedObjectValidationError:
                        txt = [txt stringByAppendingFormat:@"generated validation error (Code %li)", (long)error.code];
                        break;
                    default:
                        txt = [txt stringByAppendingFormat:@"Unhandled error code %li in showValidationError method", (long)error.code];
                        break;
                }
            }
            
            // display error message txt message
            [self displayAlertwithTitle:@"Validation Error" withMessage:[NSString stringWithFormat:@"%@Please double-tap the home button and close this application by swiping the application screenshot upwards", txt]];
            
            
            
        }
        
        
    }
    
}
-(void)displayAlertwithTitle:(NSString*)title withMessage:(NSString*)message
{
    UIViewController *root = (UIViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    //[alert showViewController:alert sender:nil]; - Does this do anything ???
    
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [root dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:close];
    [root presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - DATA IMPORT

-(BOOL)isDefaultDataAlreadyImportedForStoreWithURL:(NSURL*)url
                                            ofType:(NSString*)type {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    NSError *error;
    
    NSDictionary *dictionary = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type URL:url options:nil error:&error];
    
    if(error) {
        NSLog(@"Error reading persistent store metadata: %@", error.localizedDescription);
    } else {
        NSNumber *defaultDataAlreadyImported = [dictionary valueForKey:@"DefaultDataImported"];
        if(![defaultDataAlreadyImported boolValue]) {
            NSLog(@"Default Data has NOT already been imported");
            return NO;
        }
    }
    
    if(debugging) {
        NSLog(@"Default Data HAS already been imported");
        //[self replaceData:self.store]; REMOVE
    }
    return YES;
}

-(void)checkIfDefaultDataNeedsImporting {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    UIViewController *root = (UIViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    /*
    if(![self isDefaultDataAlreadyImportedForStoreWithURL:[self storeURL] ofType:NSSQLiteStoreType]) {
        self.importAlertController = [UIAlertController alertControllerWithTitle:@"Import Default Data?" message:@"If you've never used Grocery Dude before then some default data might help you understand how to use it. Tap 'Import' to import default data. Tap 'Cancel' to skip the import, especially if you've done this before on other devices." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *importAction = [UIAlertAction actionWithTitle:@"Import" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self alertControllerChoseToImport:YES];
            [root dismissViewControllerAnimated:NO completion:nil];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self alertControllerChoseToImport:NO];
            [root dismissViewControllerAnimated:NO completion:nil];
        }];
        
        [self.importAlertController addAction:importAction];
        [self.importAlertController addAction:cancelAction];
        [root presentViewController:self.importAlertController animated:NO completion:nil];
    }
     */
    NSLog(@"Default data unavailable.");
}

-(void)importFromXML:(NSURL*)url {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    self.parser.delegate = self;
    
    NSLog(@"**** START PARSE OF %@", url.path);
    [self.parser parse];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
    NSLog(@"***** END PARSE OF %@", url.path);
}
/* REMOVE
-(void)replaceData:(NSPersistentStore*)theStore {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[[theStore metadata] copy]];
    
    [dictionary removeObjectForKey:@"DefaultDataImported"];
    [self.coordinator setMetadata:dictionary forPersistentStore:theStore];
    [self saveContext];
}*/
-(void)setDefaultDataAsImportedForStore:(NSPersistentStore*)aStore {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    // get metadata dictionary
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[[aStore metadata] copy]];
    
    if(debugging) {
        NSLog(@"__Store metadata BEFORE changes___ \n %@", dictionary);
    }
    
    // edit metadata dictionary
    [dictionary setObject:@YES forKey:@"DefaultDataImported"];
    
    // set metadata dictionary
    [self.coordinator setMetadata:dictionary forPersistentStore:aStore];
    
    if(debugging) {
        NSLog(@"__Store Metadata AFTER changes___ \n %@", dictionary);
    }
}
-(void)setDefaultDataStoreAsInitialStore {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:self.storeURL.path]) {
        NSURL *defaultDataURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"DefaultData" ofType:@"sqlite"]];
        NSError *error;
        
        if(![fileManager copyItemAtURL:defaultDataURL
                                 toURL:self.storeURL
                                 error:&error]) {
            NSLog(@"DefaultData.sqlite copy FAIL: %@", error.localizedDescription);
        } else {
            NSLog(@"A copy of DefaultData.sqlite was set as the initial store for %@", self.storeURL.path);
        }
    }
}


#pragma mark - UIALERTVIEW
-(void)alertControllerChoseToImport:(BOOL)importBool {
    /* Due to UIAlertView being deprecated, here we create a custom method for use with UIAlertController
     * instead, making it as if UIAlertView still exists, in a way ;)
     */
    if(importBool) {
        // User chose to import
        NSLog(@"Default Data Import Approved by User");
        [_importContext performBlock:^{
           // XML Import
            [self importFromXML:[[NSBundle mainBundle] URLForResource:@"DefaultData" withExtension:@"xml"]];
        }];
        
        // Deep Copy Import From Persistent Store
        
        //[self loadSourceStore];
        //[self deepCopyFromPersistentStore:[self sourceStoreURL]];
    } else {
        // User chose to cancel
        NSLog(@"Default Data Import Cancelled by User");
    }
    [self setDefaultDataAsImportedForStore:_store];
    
}

#pragma mark - UNIQUE ATTRIBUTE SELECTION 

/**
 * This code is Grocery Dude data specific and is used when instantiating CoreDataImporter
 *
 * If you redeploy CoreDataImporter and CoreDataHelper to your own applications to import data,
 *  you will need to update this method with selected unique attributes specific to your own managed object model
 */

-(NSDictionary*)selectedUniqueAttributes {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    NSMutableArray *entities = [NSMutableArray new];
    NSMutableArray *attributes = [NSMutableArray new];
    
    // Select an attribute in each entity for uniqueness
    [entities addObject:@"Item"]; [attributes addObject:@"name"];
    [entities addObject:@"Unit"]; [attributes addObject:@"name"];
    [entities addObject:@"LocationAtHome"]; [attributes addObject:@"storedIn"];
    [entities addObject:@"LocationAtShop"]; [attributes addObject:@"aisle"];
    [entities addObject:@"Item_Photo"]; [attributes addObject:@"data"];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:attributes forKeys:entities];
    return dictionary;
}






#pragma mark - UNDERLYING DATA CHANGE NOTIFICATION
-(void)somethingChanged {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    // Send a notification that tells observing interfaces to refresh their data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
}



#pragma mark - CORE DATA RESET

-(void)resetContext:(NSManagedObjectContext*)moc {
    [moc performBlockAndWait:^{
        [moc reset];
    }];
}
-(BOOL)reloadStore {
    BOOL success = NO;
    NSError *error = nil;
    if(![_coordinator removePersistentStore:_store error:&error]) {
        NSLog(@"Unable to remove persistent store: %@", error);
    }
    [self resetContext:_sourceContext];
    [self resetContext:_importContext];
    [self resetContext:_context];
    [self resetContext:_parentContext];
    _store = nil;
    [self setupCoreData];
    [self somethingChanged];
    if(_store) {
        success = YES;
    }
    
    return success;
}


#pragma mark - ICLOUD
-(BOOL)iCloudAccountIsSignedIn {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    if(token) {
        NSLog(@"** iCloud is SIGNED IN with token '%@' **", token);
        return YES;
    }
    NSLog(@"** iCloud is NOT SIGNED IN **");
    NSLog(@"--> Is iCloud Documents and Data enabled for a valid iCloud account on your Mac & iOS Device or iOS Simuator?");
    NSLog(@"--> Have you enabled the iCloud Capability in the Application Target?");
    NSLog(@"--> Is there a CODE_SIGN_ENTITLEMENTS Xcode warning that needs fixing? You may need to specifically choose a developer instead of using Automatic selection");
    NSLog(@"--> Are you using a Pre-iOS 7 Simulator?");
    return NO;
    
}

-(BOOL)loadiCloudStore {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if(_iCloudStore) {
        return YES; }// Don't load iCloud store if it's already loaded
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES,
                              NSInferMappingModelAutomaticallyOption:@YES,
                              NSPersistentStoreUbiquitousContentNameKey:@"Grocery-Dude",
                              NSPersistentStoreUbiquitousContentURLKey:@"ChangeLogs" // Optional since iOS 7
                              };
    NSError *error;
    _iCloudStore = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self iCloudStoreURL] options:options error:&error];
    
    if(_iCloudStore) {
        NSLog(@"** The iCloud Store has been successfully configured at '%@' **", _iCloudStore.URL.path);
       // [self confirmMergeWithiCloud];
        //[self destroyAlliCloudDataForThisApplication];
        return YES;
    }
    NSLog(@"** FAILED to configure the iCloud Store: %@ **", error);
    return NO;
}

-(void)listenForStoreChanges {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    
    [dc addObserver:self selector:@selector(storesWillChange:) name:NSPersistentStoreCoordinatorStoresWillChangeNotification object:_coordinator];
    [dc addObserver:self selector:@selector(storesDidChange:) name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:_coordinator];
    [dc addObserver:self selector:@selector(persistentStoreDidImportUbiquitiousContentChanges:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:_coordinator];
}

-(void)storesWillChange:(NSNotification*)n {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    [_importContext performBlockAndWait:^{
        [_importContext save:nil];
        [self resetContext:_importContext];
    }];
    [_context performBlockAndWait:^{
        [_context save:nil];
        [self resetContext:_context];
    }];
    [_parentContext performBlockAndWait:^{
        [_parentContext save:nil];
        [self resetContext:_parentContext];
    }];
    
    // Refresh UI
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
}
-(void)storesDidChange:(NSNotification*)n {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    // Refresh UI
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
}
-(void)persistentStoreDidImportUbiquitiousContentChanges:(NSNotification*)n {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    
    [_context performBlock:^{
        [_context mergeChangesFromContextDidSaveNotification:n];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
    }];
}

-(BOOL)iCloudEnabledByUser {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"iCloudEnabled"] boolValue]) {
        NSLog(@"** iCloud is ENABLED in Settings **");
        return YES;
    }
    NSLog(@"** iCloud is DISABLED in Settings **");
    return NO;
}

-(void)ensureAppropriateStoreIsLoaded {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if(!_store && !_iCloudStore) {
        return; // If neither store is loaded, skip (usually first launch)
    }
    if(![self iCloudEnabledByUser] && _store) {
        NSLog(@"The non-iCloud Store is loaded as it should be");
        return;
    }
    if([self iCloudEnabledByUser] && _iCloudStore) {
        NSLog(@"The iCloud Store is loaded as it should be");
        return;
    }
    NSLog(@"** The user preference on using iCloud with this application appears to have changed. Core Data will now be reset. **");
    [self resetCoreData];
    [self setupCoreData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
    [self displayAlertwithTitle:@"Content has been updated" withMessage:@"Your preference on using iCloud with this application appears to have changed"];
}

#pragma mark - CORE DATA RESET
-(void)removeAllStoresFromCoordinator:(NSPersistentStoreCoordinator*)psc {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    for (NSPersistentStore *s in psc.persistentStores) {
        NSError *error = nil;
        if(![psc removePersistentStore:s error:&error]) {
            NSLog(@"Error removing persistent store: %@", error);
        }
    }
}
-(void)resetCoreData {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    [_importContext performBlockAndWait:^{
        [_importContext save:nil];
        [self resetContext:_importContext];
    }];
    
    [_context performBlockAndWait:^{
        [_context save:nil];
        [self resetContext:_context];
    }];
    [_parentContext performBlockAndWait:^{
        [_parentContext save:nil];
        [self resetContext:_parentContext];
    }];
    [self removeAllStoresFromCoordinator:_coordinator];
    _store = nil;
    _iCloudStore = nil;
}
/*
 For brevity, there will be no check performed to ensure that seeding was successful before deleting the iCloud data.
 In your own applications, you may wish to prompt the user or implement code to detect seeding status prior to deletion
 */
-(BOOL)unloadStore:(NSPersistentStore*)ps {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if(ps) {
        NSPersistentStoreCoordinator *psc = ps.persistentStoreCoordinator;
        NSError *error = nil;
        if(![psc removePersistentStore:ps error:&error]) {
            NSLog(@"ERROR removing store from the coordinator: %@", error);
            return NO; // Fail
        } else {
            ps = nil;
            return YES; // Reset complete
        }
    }
    return YES; // No need to reset, store is nil
}
-(void)removeFileAtURL:(NSURL*)url {
    NSError *error = nil;
    
    if(![[NSFileManager defaultManager] removeItemAtURL:url error:&error]) {
        NSLog(@"Failed to delete '%@' from '%@'", [url lastPathComponent], [url URLByDeletingLastPathComponent]);
    } else {
        NSLog(@"Deleted '%@' from '%@'", [url lastPathComponent], [url URLByDeletingLastPathComponent]);
    }
}

#pragma mark - ICLOUD SEEDING
-(BOOL)loadNoniCloudStoreAsSeedStore {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if(_seedInProgress) {
        NSLog(@"Seed already in progress...");
        return NO;
    }
    if(![self unloadStore:_seedStore]) {
        NSLog(@"Failed to ensure _seedStore was removed prior to migration.");
        return NO;
    }
    if(![self unloadStore:_store]) {
        NSLog(@"Failed to ensure _store was removed prior to migration.");
        return NO;
    }
    
    NSDictionary *options = @{NSReadOnlyPersistentStoreOption:@YES};
    NSError *error = nil;
    
    _seedStore = [_seedCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:options error:&error];
    if(!_seedStore) {
        NSLog(@"Failed to load non-iCloud Store as Seed Store. Error: %@", error);
        return NO;
    }
    NSLog(@"Successfully loaded Non-iCloud Store as Seed Store: %@", _seedStore);
    return YES;
}

#pragma mark - ICLOUD RESET
-(void)destroyAlliCloudDataForThisApplication {
    if(debugging)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[[_iCloudStore URL] path]]) {
        NSLog(@"Skipped destroying iCloud content, _iCloudStore.URL is %@", [[_iCloudStore URL] path]);
        return;
    }
    
    NSLog(@"\n\n\n\n\n **** Destroying ALL iCloud content for this application, this could take a while... **** \n\n\n\n\n\n");
    [self removeAllStoresFromCoordinator:_coordinator];
    [self removeAllStoresFromCoordinator:_seedCoordinator];
    _coordinator = nil;
    _seedCoordinator = nil;
    
    NSDictionary *options = @{NSPersistentStoreUbiquitousContentNameKey:@"Grocery-Dude",
                              NSPersistentStoreUbiquitousContentURLKey:@"ChangeLogs"}; // Optional since iOS 7 (URLKey)
    
    NSError *error;
    if([NSPersistentStoreCoordinator removeUbiquitousContentAndPersistentStoreAtURL:[_iCloudStore URL] options:options error:&error]) {
        NSLog(@"\n\n\n\n\n");
        NSLog(@"*        This application's iCloud content has been destroyed        *");
        NSLog(@"* on ALL devices, please delete any reference to this application in *");
        NSLog(@"*  Settings -> iCloud > Storage & Backup > Manage Storage > Show All *");
        NSLog(@"\n\n\n\n\n");
        abort();
        /*
            The application is force closed to ensure iCloud data is wiped cleanly.
            This method shouldn't be called in a production application.
         */
    } else {
        NSLog(@"\n\n FAILED to destroy iCloud content at URL: %@  Error: %@", [_iCloudStore URL], error);
    }
}




/*
 
 
 
 
 
 
 
 
 */


@end











/*
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 */
