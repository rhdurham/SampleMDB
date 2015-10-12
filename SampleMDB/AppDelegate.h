//
//  AppDelegate.h
//  SampleMDB
//
//  Created by Roderick Durham on 10/8/15.
//  Copyright © 2015 Roderick Durham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//@property (strong, nonatomic) NSURL *restURL;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

