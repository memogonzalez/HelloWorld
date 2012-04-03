//
//  ManejadorConexiones.m
//  PlacasDF
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "ManejadorConexiones.h"

@interface ManejadorConexiones()

@property (strong, nonatomic) NSMutableData *receivedData;

@end


@implementation ManejadorConexiones

@synthesize receivedData = _receivedData;
@synthesize completionHanlder = _completionHanlder;


-(id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


#pragma mark - NSURLConnection Data Delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!_receivedData) {
        _receivedData = [[NSMutableData alloc] initWithCapacity:0];
    }
    
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _receivedData = nil;
    
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError * error;
    
    NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
    
    NSDictionary * diccionario = [NSJSONSerialization JSONObjectWithData:_receivedData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error];
    
    NSDictionary *multas = [diccionario objectForKey:@"multas"];
    
    NSArray *arrMultas = [multas objectForKey:@"multa"];
    
    for (NSDictionary * multa in arrMultas) {
        
        NSLog(@"%@", [multa objectForKey:@"multa_id"]);
        
    }
}

@end
