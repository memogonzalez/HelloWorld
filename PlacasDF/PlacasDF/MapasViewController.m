//
//  MapasViewController.m
//  Placas
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "MapasViewController.h"
#define kENTITY_NAME    @"PuntoVehicular"       // Nombre de la Entidad a la que esta clase hace el query

@interface MapasViewController () 

- (void)agregarPuntoVehicularConDatos:(NSDictionary *)diccDatos;

- (void)borrarTodo;

- (void)dropPuntosVehicularesTipo:(kTIPO_PUNTO_VEHICULAR)kTipoPuntoVehicular enMapa:(MKMapView *)mapView;

// Metodo que devuelve un arreglo de puntos vehiculares del tipo deseado
- (NSArray *)puntosVehicularesTipo:(kTIPO_PUNTO_VEHICULAR)kTipoPuntoVehicular;

@end

@implementation MapasViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize mapa = _mapa;
@synthesize segmentedControl = _segmentedControl;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Liberar Memoria
    _fetchedResultsController = nil;
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // TODO: 
    // Bloque para obtener los datos de Puntos Vehiculares desde un archivo o BD en el bundle
    // y cargarlos en coredata para tenerlos persistentes
    
//    // TEST, agregamos algunos puntosVehiculares (dummies)
//    NSMutableDictionary *diccDatos = [[NSMutableDictionary alloc] initWithCapacity:0];
//    
//    for (int i=0; i<150; i++) {
//        [diccDatos setValue:@"descripcion Punto Vehicular" forKey:@"descripcion"];
//        [diccDatos setValue:@"direccion" forKey:@"direccion"];
//        [diccDatos setValue:[NSNumber numberWithFloat:10.0f] forKey:@"latitud"];
//        [diccDatos setValue:[NSNumber numberWithFloat:20.0f] forKey:@"longitud"];
//        [diccDatos setValue:[NSNumber numberWithInt:kTIPO_PUNTO_VEHICULAR_CORRALON] forKey:@"tipo"];
//        [diccDatos setValue:[NSString stringWithFormat:@"Corralon: %d", i] forKey:@"titulo"];
//        [diccDatos setValue:@"telefono" forKey:@"telefono"];
//        [diccDatos setValue:@"delegacion" forKey:@"delegacion"];
//        
//        [self agregarPuntoVehicularConDatos:diccDatos];
//        
//        [diccDatos removeAllObjects];
//    }
    
    
    // Obtenemos los Puntos Vehiculares tipo Corralon
    NSArray *arrCorralones = [self puntosVehicularesTipo:kTIPO_PUNTO_VEHICULAR_CORRALON];
    NSLog(@"Corralones: %@", arrCorralones);
    
    // Obtenemos los Puntos Vehiculares tipo Verificentro
    NSArray *arrVerificentros = [self puntosVehicularesTipo:kTIPO_PUNTO_VEHICULAR_VERIFICENTRO];
    NSLog(@"Verficentros: %@", arrVerificentros);
    
    // TODO: Podemos guardar estos arreglos como propiedades de la clase para no ejecutar el fetch mas que una sola vez
    // y asi presentar los puntos en el mapa
    
    // TODO: Fetch en el viewDidLoad, dispatch_async para obtener puntos buscados y cargar el mapa
    // o un backgroundSelector.

    
// TEST:: Metodo que borra todos los puntos vehiculares del persistentStore
//    [self borrarTodo];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Obtenemos el indice seleccionado del segmentedControl para cargar los puntos en el mapa
    [self seleccionarPuntoVehicularTipo:_segmentedControl];
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Metodo que se llama del SegmentedControl para selecionar el tipo de Puntos a mostrar en el mapa

- (IBAction)seleccionarPuntoVehicularTipo:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger segmentoSeleccionado = [segmentedControl selectedSegmentIndex];
    
    // Cargamos y mostramos los puntos vehiculares del tipo seleccionado
    [self dropPuntosVehicularesTipo:segmentoSeleccionado enMapa:_mapa];
}

#pragma mark - Metodo para llenar el mapa con puntos referentes a corralones y verificentros

- (void)dropPuntosVehicularesTipo:(kTIPO_PUNTO_VEHICULAR)kTipoPuntoVehicular enMapa:(MKMapView *)mapView
{
    MKMapView *myMapView = mapView;
    
    // Hacemos el fetch de puntos segun el tipo seleccionado
    switch (kTipoPuntoVehicular) {
            
        case kTIPO_PUNTO_VEHICULAR_CORRALON:
        {
            NSLog(@"mostrando corralones");
            
            // Creamos un pin
            MKPointAnnotation *puntoA = [[MKPointAnnotation alloc] init];
            puntoA.title = @"Corralón";
            puntoA.coordinate = CLLocationCoordinate2DMake(19.435478, -99.136479);
            puntoA.subtitle = [NSString stringWithFormat:@"lat: %f long: %f", puntoA.coordinate.latitude, 
                               puntoA.coordinate.longitude];
            
            // Lo agregamos al mapa
            [myMapView addAnnotation:puntoA];
            [myMapView setCenterCoordinate:puntoA.coordinate animated:YES];
            
            // Zoom al mapa para mostrar solo la region donde esta el pin, con un span de 1000 mts de radio
            MKCoordinateRegion mapRegion;
            mapRegion.center = puntoA.coordinate;
            mapRegion.span = MKCoordinateSpanMake(0.01, 0.01);
            [myMapView setRegion:mapRegion animated: YES];
        }
            break;
            
        case kTIPO_PUNTO_VEHICULAR_VERIFICENTRO:
        {
            NSLog(@"mostrando verificentros");
            
            // Creamos un pin
            MKPointAnnotation *puntoA = [[MKPointAnnotation alloc] init];
            puntoA.title = @"Verificentro";
            puntoA.coordinate = CLLocationCoordinate2DMake(19.50, -99.15);
            puntoA.subtitle = [NSString stringWithFormat:@"lat: %f long: %f", puntoA.coordinate.latitude, 
                               puntoA.coordinate.longitude];
            
            // Lo agregamos al mapa
            [myMapView addAnnotation:puntoA];
            [myMapView setCenterCoordinate:puntoA.coordinate animated:YES];
            
            // Zoom al mapa para mostrar solo la region donde esta el pin, con un span de 1000 mts de radio
            MKCoordinateRegion mapRegion;
            mapRegion.center = puntoA.coordinate;
            mapRegion.span = MKCoordinateSpanMake(0.01, 0.01);
            [myMapView setRegion:mapRegion animated: YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Creamos el request para esta clase
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Editamos la entidad que se pide
    NSEntityDescription *entity = [NSEntityDescription entityForName:kENTITY_NAME 
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Batch Size a 20 objetos a la vez
    [fetchRequest setFetchBatchSize:20];
    
    // Editamos un sort descriptor, devuelve los puntos vehiculares ordenados por titulo
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"titulo" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = 
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                        managedObjectContext:self.managedObjectContext 
                                          sectionNameKeyPath:nil 
                                                   cacheName:@"MasterMapasViewController"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

#pragma mark "Metodos TEST para cargar la BD"

- (void)agregarPuntoVehicularConDatos:(NSDictionary *)diccDatos
{
    // Creamos una nueva instancia de la entidad manegada por el fetchedResultsController
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // Configuramos el nuevo objeto con los datos del diccionario
    NSArray *llavesDiccDatos = [diccDatos allKeys];
    
    for (NSString *llave in llavesDiccDatos) {
        [newManagedObject setValue:[diccDatos valueForKey:llave] forKey:llave];
    }
    
    // Guardamos el nuevo contexto
    NSError *error = nil;
    
    if (![context save:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        
    } else {
        
        NSLog(@"dato guardado: %@", [diccDatos valueForKey:@"titulo"]);
    }
}

#pragma mark "Manejo de Datos"

/** 
 @brief Metodo que devuelve un arreglo con objetos CoreData (ManagedObjectModel) tipo "PuntoVehicular" del tipo pasado como parametro
 @param kTipoPuntoVehicular: Enum que define el tipo de PuntoVehicular deseado
 @return (NSArray *): un arreglo con los objetos buscados
 
 */

- (NSArray *)puntosVehicularesTipo:(kTIPO_PUNTO_VEHICULAR)kTipoPuntoVehicular
{
    // Obtenemos todos los puntos vehiculares
    NSArray *puntosVehiculares = [self.fetchedResultsController fetchedObjects];
    
    // Predicado para obtener los puntos del tipo seleccionado
    NSPredicate *predicateTipoPunto = [NSPredicate predicateWithFormat:@"tipo == %d", kTipoPuntoVehicular];
    NSArray *puntosBuscados = [puntosVehiculares filteredArrayUsingPredicate:predicateTipoPunto];
    
    return puntosBuscados;
}

/**
 Metodo para borrar todos los registros de la Entidad para esta clase
*/

- (void)borrarTodo
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    NSArray *objetosBorrar = [self.fetchedResultsController fetchedObjects];
    for (id obj in objetosBorrar) {
        [context deleteObject:obj];
    }
    
    // Guardar los cambios
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
@end
