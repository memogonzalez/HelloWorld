//
//  SettingsPlacas.h
//  PlacasDF
//
//  Created by David Hernández on 2/26/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsPlacas : NSObject <NSCoding>

@property (copy, nonatomic) NSString *strPlacas;

@property (copy, nonatomic) NSString *strModelo;

@property (strong, nonatomic) NSNumber *numTipoVehiculo;

@property (strong, nonatomic) NSDictionary *diccAttributes;

@end
