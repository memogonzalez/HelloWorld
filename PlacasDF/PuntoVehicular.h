//
//  PuntoVehicular.h
//  PlacasDF
//
//  Created by David Hernández on 4/8/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PuntoVehicular : NSManagedObject

@property (nonatomic, retain) NSString * delegacion;
@property (nonatomic, retain) NSString * direccion;
@property (nonatomic, retain) NSNumber * latitud;
@property (nonatomic, retain) NSNumber * longitud;
@property (nonatomic, retain) NSString * telefono;
@property (nonatomic, retain) NSNumber * tipo;
@property (nonatomic, retain) NSString * titulo;

@end
