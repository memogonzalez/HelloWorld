//
//  CoreDataObjectManager.h
//  PlacasDF
//
//  Created by David Hernández on 4/12/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Clase que se encarga de guardar y/o devolver objetos desde CoreData
 */
@interface CoreDataObjectManager : NSObject

/**
 *  Metodo que construye objetos desde un arreglo de diccionarios y los guarda en CoreData
 */
+ (void)addObjects:(NSArray *)arrObjects forEntityName:(NSString *)entityName;

/**
 *  Metodo que devuelve los objetos guardados del tipo de la entidad deseada
 */
+ (NSArray *)objectsForEntityName:(NSString *)entityName;

/**
 *  Metodo que elimina todos los objetos guardados del tipo de la entidad deseada
 */
+ (void)removeObjectsForEntityName:(NSString *)entityName;


@end
