//
//  MovieReview+CoreDataProperties.h
//  SampleMDB
//
//  Created by Roderick Durham on 10/8/15.
//  Copyright © 2015 Roderick Durham. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MovieReview.h"

NS_ASSUME_NONNULL_BEGIN

@interface MovieReview (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *movieName;
@property (nullable, nonatomic, retain) NSString *imageUrl;
@property (nullable, nonatomic, retain) NSString *rating;
@property (nullable, nonatomic, retain) NSString *movieDescription;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSDate   *modificationDate;

@property (nonatomic, retain) NSString *modificationDateText;

@end

NS_ASSUME_NONNULL_END
