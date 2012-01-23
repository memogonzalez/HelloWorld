//
//  MapasViewController.h
//  Placas
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"
#import "MapKit/MapKit.h"
#import "CoreLocation/CoreLocation.h"
#import "CoreDataAdminProtocol.h"


@interface MapasViewController : UIViewController <CoreDataAdminProtocol, NSFetchedResultsControllerDelegate, MKMapViewDelegate>

// Controlador de objetos que devuelve el query a CoreData
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

// Referencia al mapView
@property (strong, nonatomic) IBOutlet MKMapView *mapa;

// Referencia al SegmentedControl
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

// Accion para seleccionar un tipo de punto vehicular
- (IBAction)seleccionarPuntoVehicularTipo:(id)sender;

@end
