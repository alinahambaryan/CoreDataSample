//
//  Folder+CoreDataProperties.h
//  CoreDataSample
//
//  Created by Alina Hambaryan on 1/19/16.
//  Copyright © 2016 Alina Hambaryan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Folder.h"

NS_ASSUME_NONNULL_BEGIN

@interface Folder (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) Folder *notes;

@end

NS_ASSUME_NONNULL_END
