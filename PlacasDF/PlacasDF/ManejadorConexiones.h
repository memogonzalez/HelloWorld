//
//  ManejadorConexiones.h
//  PlacasDF
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ManejadorConexiones : NSObject <NSURLConnectionDelegate> {
    
    NSMutableData * receivedData;
}

@end

