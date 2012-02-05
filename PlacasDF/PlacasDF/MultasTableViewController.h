//
//  MultasTableViewController.h
//  Placas
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultaCelda.h"


@interface MultasTableViewController : UITableViewController <NSURLConnectionDelegate> {
    
    NSMutableData * receivedData;
    
    NSArray * arrMultas;
    
    IBOutlet MultaCelda * celdaMulta;
}

@property (strong, nonatomic) IBOutlet MultaCelda * celdaMulta;

- (NSString *) formatString:(NSString *) text;

@end
