//
//  JSONDataSerializator.m
//  PlacasDF
//
//  Created by David Hernández on 4/12/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "JSONDataSerializator.h"

@implementation JSONDataSerializator

+ (id)serializeData:(NSData *)data
{
    id dataContainer = nil;
    
    NSError *error = nil;
    id serializedData = [NSJSONSerialization JSONObjectWithData:data 
                                                        options:NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers | NSJSONReadingAllowFragments
                                                          error:&error];
    
    if (!error) 
    {
        if ([serializedData respondsToSelector:@selector(valueForKey:)]) 
        {
            NSLog(@"we have a dictionary");
            dataContainer = [[NSDictionary alloc] initWithDictionary:serializedData];
        } 
        else if ([serializedData respondsToSelector:@selector(objectAtIndex:)]) 
        {
            NSLog(@"we have an array");
            dataContainer = [[NSArray alloc] initWithArray:serializedData];
        }    
    }
    
    return dataContainer;
}

@end
