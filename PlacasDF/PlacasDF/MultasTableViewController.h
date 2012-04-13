//
//  MultasTableViewController.h
//  Placas
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataAdminProtocol.h"
#import "PullRefreshTableViewController.h"

@class MBProgressHUD;

@class MultaCelda;

@interface MultasTableViewController : PullRefreshTableViewController <NSURLConnectionDelegate, CoreDataAdminProtocol, NSFetchedResultsControllerDelegate> {
    
    NSMutableData * receivedData;
    
    NSArray * arrMultas;
    
    NSArray * arrMultasFrecuentes;
    
    IBOutlet MultaCelda * celdaMulta;
    
    bool isShowingList;
    
    int sinPagar;
    
    bool connectionError;
}

@property (strong, nonatomic) IBOutlet MultaCelda * celdaMulta;

@property (strong, nonatomic) MBProgressHUD * mb;

// Controlador de objetos que devuelve el query a CoreData
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) NSNumber * numeroMultas;

- (NSString *) formatString:(NSString *) text;

- (NSArray*) getMultasFrecuentes;

- (void)scheduleNotification;

- (IBAction) tweet:(id)sender;

- (void) loadData;

- (CGFloat) getHeightForText:(NSString *) text;

@end



////
////  MultasTableViewController.h
////  Placas
////
////  Created by David Hernández on 1/15/12.
////  Copyright (c) 2012 Caos Inc. All rights reserved.
////
//
//#import <UIKit/UIKit.h>
//#import "PullRefreshTableViewController.h"
//
//@class MBProgressHUD;
//@class MultaCelda;
//
//@interface MultasTableViewController : PullRefreshTableViewController <NSURLConnectionDelegate, NSFetchedResultsControllerDelegate> {
//    
//    NSMutableData * receivedData;
//    
//    NSArray * arrMultasFrecuentes;
//    
//    IBOutlet MultaCelda * celdaMulta;
//    
//    bool isShowingList;
//    
//    int sinPagar;
//    
//    bool connectionError;
//}
//
//@property (strong, nonatomic) NSArray *arrMultas;
//
//@property (strong, nonatomic) IBOutlet MultaCelda * celdaMulta;
//
//@property (strong, nonatomic) MBProgressHUD * mb;
//
//@property (strong, nonatomic) NSNumber * numeroMultas;
//
//- (NSString *) formatString:(NSString *) text;
//
//- (NSArray*) getMultasFrecuentes;
//
//- (void)scheduleNotification;
//
//- (IBAction) tweet:(id)sender;
//
//- (void) loadData;
//
//- (CGFloat) getHeightForText:(NSString *) text;
//
//@end
