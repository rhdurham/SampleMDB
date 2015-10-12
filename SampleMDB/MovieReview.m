//
//  MovieReview.m
//  SampleMDB
//
//  Created by Roderick Durham on 10/8/15.
//  Copyright © 2015 Roderick Durham. All rights reserved.
//

#import "MovieReview.h"

@implementation MovieReview

static NSDictionary *_movieReviewRestKeyMap = nil;

+ (NSDictionary *)restKeyMap {
    if(_movieReviewRestKeyMap == nil) {
        [self setRestKeyMap:@{@"url" : @"url",
                              @"image_url" : @"imageUrl",
                              @"modification_date" : @"modificationDateText",
                              @"movie_description" : @"movieDescription",
                              @"movie_name" : @"movieName",
                              @"rating" : @"rating"
                              }];
    }
    return _movieReviewRestKeyMap;
}

+ (void)setRestKeyMap:(NSDictionary *)restKeyMap
{
    _movieReviewRestKeyMap = restKeyMap;
}

static NSString *_movieReviewRestElement = nil;

+ (NSString *)restElement
{
    //static NSString *_restElement = nil;
    if (_movieReviewRestElement == nil) {
        [self setRestElement:@"moviereview/"];
    }
    return _movieReviewRestElement;
}

+ (void)setRestElement:(NSString *)restElement
{
    _movieReviewRestElement = restElement;
}




- (void)setModificationDateText:(NSString *)dateText
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDate *date = [dateFormatter dateFromString:dateText];
    
    self.modificationDate = date;
}

- (NSString *)modificationDateText
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    return [dateFormatter stringFromDate:self.modificationDate];
}



@end

@implementation NSManagedObject (RESTExtensions)

+ (void)load:(NSURL *)sourceURL
     context:(NSManagedObjectContext *)managedObjectContext
mergeChanges:(BOOL)mergeChanges
{
    // Read MovieReviews from json and save to Core Data DB
    
    // 1. Retrieve the json
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    
    NSURL *restUrl = [NSURL URLWithString:[self restElement] relativeToURL:sourceURL];
    
    NSURLSessionDataTask *dataTask =
    [sharedSession dataTaskWithURL:restUrl
                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                     
                     NSLog(@"Response Headers are:\n%@", [(NSHTTPURLResponse *)response allHeaderFields]);
        // Create the json;
        if (data) {
            NSError *jsonError;
            id jsonAsCollection = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&jsonError];
            NSLog(@"Retrieve JSON is: %@", jsonAsCollection);
            
            // Delete existing cached Objects
            NSError *nsError;
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MovieReview"];
            NSArray *cachedMovieReviews = [managedObjectContext executeFetchRequest:fetchRequest error:&nsError];
            
            if (cachedMovieReviews) {
                for (NSManagedObject *movieReview in cachedMovieReviews) {
                    [managedObjectContext deleteObject:movieReview];
                }
                [managedObjectContext save:&nsError];
            }
            
            // Add new objects
            if (jsonAsCollection && [jsonAsCollection isKindOfClass:[NSArray class]]) {
                for (NSDictionary *jsonRecord in jsonAsCollection) {
                    MovieReview *movieReview = [NSEntityDescription insertNewObjectForEntityForName:@"MovieReview"
                                                                             inManagedObjectContext:managedObjectContext];
                    NSDictionary *keyMap = [self restKeyMap];
                    NSArray *keys = [keyMap allKeys];
                    for (NSString *key in keys) {
                        [movieReview setValue:jsonRecord[key] forKey:keyMap[key]];
                    }
                }
                [managedObjectContext save:&nsError];
            }
        }
    }];
    
    [dataTask resume];
    
    return;
}


+ (MovieReview *)movieReviewWithURL:(NSURL *)restURL
{
    return nil;
}

static NSDictionary *_restKeyMap = nil;

+ (NSDictionary *)restKeyMap
{
    return _restKeyMap;
}

+ (void)setRestKeyMap:(NSDictionary *)restKeyMap
{
    _restKeyMap = restKeyMap;
}

static NSString *_restElement = nil;

+ (NSString *)restElement
{
    return _restElement;
}

+ (void)setRestElement:(NSString *)restElement
{
    _restElement = restElement;
}



- (void)restGet
{
    // Reload data from service
    return;
}



- (void)restPost:(NSURL *)sourceURL
{
    // Insert new object into service
    // 1. Serialize data to json string
    //    based on keyMap
    NSDictionary *restKeyMap = [self.class restKeyMap];
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithCapacity:[restKeyMap count]];
    
    NSArray *restKeys = [restKeyMap allKeys];
    for (NSString *restKey in restKeys) {
        id value = [self valueForKey:restKeyMap[restKey]];
        if (value)
            [jsonDict setObject:value forKey:restKey];
    }
        
    
    // 2. Post to service
    NSLog(@"JSONDict is: %@", jsonDict);
    NSURLSession *postSession = [NSURLSession sharedSession];
    NSURL *restURL = [NSURL URLWithString:[self.class restElement] relativeToURL:sourceURL];

    NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] initWithURL:restURL];
    postRequest.HTTPMethod = @"POST";
    
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // 3. Set authorization
    /////////////////
    // Authentication add
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:@"username"];
    NSString *password = [defaults objectForKey:@"password"];
    
    NSString *authString = [NSString stringWithFormat:@"%@:%@",username,password];//@"admin:password";
    NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [postRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    // End Authentication add
    /////////////////
    
    NSError *serializationError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                       options:0
                                                         error:&serializationError];
    
    // 4. Update object with changed data (url)
    NSURLSessionUploadTask *postTask =
    [postSession uploadTaskWithRequest:postRequest fromData:jsonData
                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"Headers are:\n%@",[(NSHTTPURLResponse *)response allHeaderFields]);
        // Process the data and set object
        if (data) {
            NSError *jsonError;
            NSDictionary *jsonAsCollection = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&jsonError];
            NSLog(@"Retrieved JSON is: %@", jsonAsCollection);
            NSDictionary *restKeyMap = [self.class restKeyMap];
            NSArray *restKeys = [restKeyMap allKeys];
            for (NSString *restKey in restKeys) {
                [self setValue:jsonAsCollection[restKey] forKey:restKeyMap[restKey]];
            }
            NSLog(@"New values are: %@", self);
        }

        
    }];
    [postTask resume];
    
    // 5. Save changes to DB cache
    
    return;
}



- (void)restPut
{
    NSDictionary *restKeyMap = [self.class restKeyMap];
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithCapacity:[restKeyMap count]];
    
    NSArray *restKeys = [restKeyMap allKeys];
    for (NSString *restKey in restKeys) {
        id value = [self valueForKey:restKeyMap[restKey]];
        if (value)
            [jsonDict setObject:value forKey:restKey];
    }

    
    NSString *resourceURLString = [self valueForKey:@"url"];
    if (resourceURLString) {
        NSURLSession *putSession = [NSURLSession sharedSession];
        
        NSURL *restURL = [NSURL URLWithString:[self valueForKey:@"url"]];
        
        NSMutableURLRequest *putRequest = [[NSMutableURLRequest alloc] initWithURL:restURL];
        putRequest.HTTPMethod = @"PUT";
        
        [putRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // 3. Set authorization
        /////////////////
        // Authentication add
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults objectForKey:@"username"];
        NSString *password = [defaults objectForKey:@"password"];
        
        NSString *authString = [NSString stringWithFormat:@"%@:%@",username,password];//@"admin:password";
        NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
        [putRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
        // End Authentication add
        /////////////////
        
        NSError *serializationError;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                           options:0
                                                             error:&serializationError];
        
        // 4. Update object with changed data (url)
        NSURLSessionUploadTask *putTask =
        [putSession uploadTaskWithRequest:putRequest fromData:jsonData
                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                             NSLog(@"Headers are:\n%@",[(NSHTTPURLResponse *)response allHeaderFields]);
                             // Process the data and set object
                             if (data) {
                                 NSError *jsonError;
                                 NSDictionary *jsonAsCollection = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data
                                                                                                                  options:NSJSONReadingMutableContainers
                                                                                                                    error:&jsonError];
                                 NSLog(@"Retrieved JSON is: %@", jsonAsCollection);
                                 NSDictionary *restKeyMap = [self.class restKeyMap];
                                 NSArray *restKeys = [restKeyMap allKeys];
                                 for (NSString *restKey in restKeys) {
                                     [self setValue:jsonAsCollection[restKey] forKey:restKeyMap[restKey]];
                                 }
                                 NSLog(@"New values are: %@", self);
                             }
                             
                             
                         }];
        [putTask resume];

        
        
    }

    
    return;
}



- (void)restDelete
{
    NSString *resourceURLString = [self valueForKey:@"url"];
    if (resourceURLString) {
        NSURLSession *deleteSession = [NSURLSession sharedSession];

        NSURL *restURL = [NSURL URLWithString:[self valueForKey:@"url"]];
        
        NSMutableURLRequest *deleteRequest = [[NSMutableURLRequest alloc] initWithURL:restURL];
        deleteRequest.HTTPMethod = @"DELETE";
        
        [deleteRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // 3. Set authorization
        /////////////////
        // Authentication add
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults objectForKey:@"username"];
        NSString *password = [defaults objectForKey:@"password"];
        
        NSString *authString = [NSString stringWithFormat:@"%@:%@",username,password];//@"admin:password";
        NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
        [deleteRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
        // End Authentication add
        /////////////////
        
        NSURLSessionDataTask *deleteTask =
        [deleteSession dataTaskWithRequest:deleteRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"Headers are:\n%@",[(NSHTTPURLResponse *)response allHeaderFields]);
        }];
        [deleteTask resume];

    }

    return;
}


+ (void)restOptions:(NSURL *)serviceURL
{
    // Return the options and field descriptions
    // Perform the same as a GET
    NSMutableDictionary *optionsDictionary = nil;
    
    if (serviceURL) {
        NSURLSession *optionsSession = [NSURLSession sharedSession];
        
        NSURL *restURL = [NSURL URLWithString:[self restElement] relativeToURL:serviceURL];
        
        NSMutableURLRequest *optionsRequest = [[NSMutableURLRequest alloc] initWithURL:restURL];
        optionsRequest.HTTPMethod = @"OPTIONS";
        
        [optionsRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // 3. Set authorization
        /////////////////
        // Authentication add
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults objectForKey:@"username"];
        NSString *password = [defaults objectForKey:@"password"];

        NSString *authString = [NSString stringWithFormat:@"%@:%@",username,password];//@"admin:password";
        NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
        [optionsRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
        // End Authentication add
        /////////////////
        
        NSURLSessionDataTask *optionsTask =
        [optionsSession dataTaskWithRequest:optionsRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"Headers are:\n%@",[(NSHTTPURLResponse *)response allHeaderFields]);
            if (!(error) && (data)) {
                NSError *jsonError;
                NSDictionary *jsonAsCollection = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data
                                                                                                 options:NSJSONReadingMutableContainers
                                                                                                   error:&jsonError];
                NSLog(@"Retrieved JSON is: %@", jsonAsCollection);
                NSDictionary *putDictionary = (jsonAsCollection[@"actions"])[@"POST"];
                NSLog(@"New values are: %@", putDictionary);
                
                // Send in authenticationnotification on main thread passing in dictionary as argument
                if (putDictionary) {
                    NSNotification *successNotification = [NSNotification notificationWithName:@"RESTAuthenticationSuccess"
                                                                                        object:putDictionary];
                    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:)
                                                                           withObject:successNotification
                                                                        waitUntilDone:NO];
                } else {
                    NSNotification *failureNotification = [NSNotification notificationWithName:@"RESTAuthenticationFailure"
                                                                                        object:nil];
                    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:)
                                                                           withObject:failureNotification
                                                                        waitUntilDone:NO];
                }
            }
        }];
        [optionsTask resume];
    }

    
    return;
}


+ (void)observeRESTAuthenticationSuccessNotification:(id)observer
                                              target:(SEL)selector
{
    [self unbbserveRESTAuthenticationSuccessNotification:observer];
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:selector
                                                 name:@"RESTAuthenticationSuccess"
                                               object:nil];

    return;
}


+ (void)unbbserveRESTAuthenticationSuccessNotification:(id)observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer
                                                    name:@"RESTAuthenticationSuccess"
                                                  object:nil];

    return;
}


+ (void)observeRESTAuthenticationFailureNotification:(id)observer
                                              target:(SEL)selector
{
    [self unbbserveRESTAuthenticationFailureNotification:observer];
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:selector
                                                 name:@"RESTAuthenticationFailure"
                                               object:nil];

    return;
}


+ (void)unbbserveRESTAuthenticationFailureNotification:(id)observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer
                                                    name:@"RESTAuthenticationFailure"
                                                  object:nil];

    return;
}




@end
