//
//  CoreDataObjectManager.m
//  PlacasDF
//
//  Created by David Hernández on 4/12/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "CoreDataObjectManager.h"
#import "AppDelegate.h"

@interface CoreDataObjectManager()
{
    NSManagedObjectContext *context;
}

@end

@implementation CoreDataObjectManager


+ (void)addObjects:(NSArray *)arrObjects forEntityName:(NSString *)entityName
{   
    // Obtenemos el managedObjectContext de la aplicacion
    NSManagedObjectContext *context = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    
    // Determinamos la entidad buscada
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName 
                                              inManagedObjectContext:context];
    
    for (NSDictionary *diccAttrs in arrObjects)
    {
        // En caso de que los objetos a agregar sea del tipo 'Multa'
        if ([entityName isEqualToString:@"Multa"])
        {
            // Insertar un nuevo object
            NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] 
                                                                              inManagedObjectContext:context];
            
            // Configuramos el nuevo objeto con los datos del diccionario
            NSNumber *situacion = [NSNumber numberWithInt:[[diccAttrs valueForKey:@"situacion"] intValue]];
            NSNumber *sancion = [NSNumber numberWithInt:[[diccAttrs valueForKey:@"sancion"] intValue]];
            
            [newManagedObject setValue:[diccAttrs valueForKey:@"motivo"] forKey:@"motivo"];
            [newManagedObject setValue:sancion forKey:@"sancion"];
            [newManagedObject setValue:situacion forKey:@"situacion"];
            
            [newManagedObject setValue:[diccAttrs valueForKey:@"fundamento"] forKey:@"fundamento"];
            [newManagedObject setValue:[diccAttrs valueForKey:@"folio"] forKey:@"folio"];
            
            [newManagedObject setValue:[diccAttrs valueForKey:@"fecha_infraccion"] forKey:@"fecha_infraccion"];
        } 
        /*else if ([entityName isEqualToString:@""])
        {
        
        }*/
    }
        
    // Guardamos el nuevo contexto
    NSError *error = nil;
    
    if (![context save:&error]) 
    {    
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();   
    }
}


+ (NSArray *)objectsForEntityName:(NSString *)entityName
{
    NSArray *arrObjs = nil;
    
    // Obtenemos el managedObjectContext de la aplicacion
    NSManagedObjectContext *context = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];

    // Especificamos el objeto request
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    
    NSError *error = nil;
    NSArray *objs = [context executeFetchRequest:request
                                           error:&error];
    if (!objs) 
    {
        NSLog(@"ERROR");
        abort();
    }
    else 
    {
        // NSLog(@"%@", objs);
        arrObjs = objs;
    }
    
    return arrObjs;
}


+ (void)removeObjectsForEntityName:(NSString *)entityName
{
    // Obtenemos el managedObjectContext de la aplicacion
    NSManagedObjectContext *context = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];

    // Obtenemos los objetos guardados para la entidad
    NSArray *arrObjs = [self objectsForEntityName:entityName];
    
    // Borramos uno por uno
    for (NSManagedObject *managedObj in arrObjs) 
    {
        [context deleteObject:managedObj];
    }
    
    // Guardamos el nuevo contexto (sin objetos)
    NSError *error = nil;
    if (![context save:&error])
    {
        NSLog(@"ERROR borrando objetos: %@", entityName);
        abort();
    }
    else 
    {
        NSLog(@"%@ objetos borrados", [self class]);
    }
}

@end
