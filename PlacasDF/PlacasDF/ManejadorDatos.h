//
//  ManejadorDatos.h
//  PlacasDF
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ManejadorDatos : NSObject

// Metodo para obtener todos los registros de una entidad en CoreData
- (NSArray *)fetchedResultsForEntity:(NSString *)entityName;

// Metodo para agregar un registro a una entidad de coredata
- (BOOL)addObject:(id)coredataObject forEntity:(NSString *)entityName;
@end
