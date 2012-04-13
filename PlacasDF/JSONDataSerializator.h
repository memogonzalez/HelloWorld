//
//  JSONDataSerializator.h
//  PlacasDF
//
//  Created by David Hernández on 4/12/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSONDataSerializator : NSObject

/**
 *  Metodo que serializa los datos dados
 */
+ (id)serializeData:(NSData *)data;

@end
