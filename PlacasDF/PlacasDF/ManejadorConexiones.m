//
//  ManejadorConexiones.m
//  PlacasDF
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "ManejadorConexiones.h"

@implementation ManejadorConexiones

-(id) init{

    receivedData = [[NSMutableData alloc] init];
    
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError * error;
    
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    
    NSDictionary * diccionario = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error];
    
    NSDictionary *multas = [diccionario objectForKey:@"multas"];
    
    NSArray *arrMultas = [multas objectForKey:@"multa"];
    
    for (NSDictionary * multa in arrMultas) {
        
        NSLog(@"%@", [multa objectForKey:@"multa_id"]);
        
    }
}

@end
