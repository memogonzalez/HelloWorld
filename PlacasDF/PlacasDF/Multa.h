//
//  Multa.h
//  PlacasDF
//
//  Created by David Hernández on 1/17/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Multa : NSManagedObject

@property (nonatomic, retain) NSDate * fecha_infraccion;
@property (nonatomic, retain) NSString * folio;
@property (nonatomic, retain) NSString * fundamento;
@property (nonatomic, retain) NSString * motivo;
@property (nonatomic, retain) NSNumber * sancion;
@property (nonatomic, retain) NSNumber * situacion;

@end
