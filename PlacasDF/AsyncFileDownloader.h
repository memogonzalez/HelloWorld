//
//  AsyncFileDownloader.h
//  PlacasDF
//
//  Created by David Hernández on 4/12/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 *  Block que se ejecuta cuando se termino de descargar un archivo
 */
typedef void (^FileDownloaderCompletionBlock)(BOOL finished);

@interface AsyncFileDownloader : NSObject

/**
 *  Bloque de finalizacion que se ejecuta al terminar la descarga de datos
 */
@property (copy, nonatomic) FileDownloaderCompletionBlock fileDownloaderCompletionBlock;

/**
 *  Metodo iniciar un objeto que se encarga de descargar datos desde la URL dada
 *  y ejecuta el bloque de finalizacion al concluir la descarga de datos
 */
- (id)initWithURL:(NSURL *)url;

@end
