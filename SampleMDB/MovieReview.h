//
//  MovieReview.h
//  SampleMDB
//
//  Created by Roderick Durham on 10/8/15.
//  Copyright © 2015 Roderick Durham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface MovieReview : NSManagedObject

- (void)setModificationDateText:(NSString *)dateText;


@end

@interface NSManagedObject (RESTExtensions)

+ (void)load:(NSURL *)sourceURL
     context:(NSManagedObjectContext *)managedObjectContext
mergeChanges:(BOOL)mergeChanges;

+ (MovieReview *)movieReviewWithURL:(NSURL *)restURL;

+ (NSString *)restElement;

+ (void)setRestElement:(NSString *)restElement;



- (void)restGet;

- (void)restPost:(NSURL *)sourceURL;

- (void)restPut;

- (void)restDelete;

+ (void)restOptions:(NSURL *)sourceURL;

+ (void)observeRESTAuthenticationSuccessNotification:(id)observer
                                          target:(SEL)selector;
+ (void)unbbserveRESTAuthenticationSuccessNotification:(id)observer;

+ (void)observeRESTAuthenticationFailureNotification:(id)observer
                                          target:(SEL)selector;
+ (void)unbbserveRESTAuthenticationFailureNotification:(id)observer;


@end

NS_ASSUME_NONNULL_END

#import "MovieReview+CoreDataProperties.h"
