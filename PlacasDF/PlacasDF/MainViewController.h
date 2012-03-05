//
//  MainViewController.h
//  Placas
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataAdminProtocol.h"


@interface MainViewController : UIViewController <CoreDataAdminProtocol, NSFetchedResultsControllerDelegate>

// Controlador de objetos que devuelve el query a CoreData
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UILabel * diasParaVerificar;

/*!
 *  Vista que indica que el auto no circula el dia de hoy
 */
@property (strong, nonatomic) IBOutlet UIView *viewHoyNoCircula;

- (void) addTip:(int) posicion tip:(NSString *) text;

- (void) saveTip:(NSMutableDictionary *) tip;

- (void) saveTip:(NSMutableDictionary *) tipDiccionario;

- (NSArray *) getTips;

- (NSNumber *) _diasParaVerificar;

- (NSNumber *) diasParaVerificar;

- (void) lastDateOfMonth;

- (BOOL) estaEnPeriodoDeVerificacion:(int)terminacion;

@end
