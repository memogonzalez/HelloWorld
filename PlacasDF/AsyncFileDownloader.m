//
//  AsyncFileDownloader.m
//  PlacasDF
//
//  Created by David Hernández on 4/12/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "AsyncFileDownloader.h"

@interface AsyncFileDownloader() <NSURLConnectionDataDelegate>
{
    /**
     *  Contenedor de bytes descargados
     */
    NSMutableData *datosDescargados;
}

/**
 *  URL desde donde se descargaran los datos
 */
@property (strong, nonatomic) NSURL *urlForDownload;

/**
 *  Metodo para inciar la descarga de datos desde una url
 */
- (void)startDownloadingDataFromURL:(NSURL *)url;

@end


@implementation AsyncFileDownloader

@synthesize fileDownloaderCompletionBlock = _fileDownloaderCompletionBlock;
@synthesize urlForDownload = _urlForDownload;

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    
    if (self) 
    {
        if (url) 
        {
            _urlForDownload = url;
            
            // Comenzamos la conexion y descarga del archivo dada la URL
            [self startDownloadingDataFromURL:_urlForDownload];
        }
    }
    
    return self;
}

- (void)startDownloadingDataFromURL:(NSURL *)url
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url 
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                              timeoutInterval:15.0f];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request 
                                                                 delegate:self];
    
    [connection start];
}

#pragma mark - NSURL Connection Data Delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!datosDescargados) 
    {
        datosDescargados = [[NSMutableData alloc] initWithCapacity:0];
    }
    
    // Agregar los nuevos datos descargados
    [datosDescargados appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"%@ finished", [self class]);
    
    // Mandamos llamar el bloque de finalizacion de la clase
    if (_fileDownloaderCompletionBlock) {
        _fileDownloaderCompletionBlock(YES);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@ Error descarga", [self class]);
    
    if (_fileDownloaderCompletionBlock) {
        _fileDownloaderCompletionBlock(NO);
    }
}
@end
