//
//  MultasTableViewController.h
//  Placas
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataAdminProtocol.h"

@class MultaCelda;

@interface MultasTableViewController : UITableViewController <NSURLConnectionDelegate, CoreDataAdminProtocol, NSFetchedResultsControllerDelegate> {
    
    NSMutableData * receivedData;
    
    NSArray * arrMultas;
    
    NSArray * arrMultasFrecuentes;
    
    IBOutlet MultaCelda * celdaMulta;
    
    bool isShowingList;
    
    int sinPagar;
}

@property (strong, nonatomic) IBOutlet MultaCelda * celdaMulta;

// Controlador de objetos que devuelve el query a CoreData
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (NSString *) formatString:(NSString *) text;

- (NSArray*) getMultasFrecuentes;

- (void)scheduleNotification;

@end
