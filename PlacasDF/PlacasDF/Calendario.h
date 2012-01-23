//
//  Calendario.h
//  PlacasDF
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Calendario : NSManagedObject

@property (nonatomic, retain) NSNumber * tipo;
@property (nonatomic, retain) NSData * imagen_raw;

@end
