//
//  Tip.h
//  PlacasDF
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tip : NSManagedObject

@property (nonatomic, retain) NSNumber * tip_id;
@property (nonatomic, retain) NSString * descripcion;

@end
