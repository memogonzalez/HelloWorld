//
//  CoreDataAdminProtocol.h
//  PlacasDF
//
//  Created by David Hernández on 1/17/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CoreDataAdminProtocol <NSObject>
@required
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end
