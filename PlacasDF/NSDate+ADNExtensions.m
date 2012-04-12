//
//  NSDate+ADNExtensions.m
//  PlacasDF
//
//  Created by Carlos Guillermo Guadarrama on 26/02/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

//  NSDate+ADNExtensions.m

#import "NSDate+ADNExtensions.h"


@implementation NSDate (ADNExtensions)


- (NSInteger)numberOfDaysUntil:(NSDate *)aDate {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:self toDate:aDate options:0];
    
    return [components day];
}


@end