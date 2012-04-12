//
//  MapasViewController.m
//  Placas
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "MapasViewController.h"
#define kENTITY_NAME    @"PuntoVehicular"       // Nombre de la Entidad a la que esta clase hace el query

@interface MapasViewController () <MKMapViewDelegate>
{
    NSArray *arrPuntosVerificentros;
    NSArray *arrPuntosCorralones;
    kTIPO_PUNTO_VEHICULAR _tipoPuntoVehicular;
}

- (void)agregarPuntoVehicularConDatos:(NSDictionary *)diccDatos;

- (void)borrarTodo;

/**
 *  Metodo que se encarga de mostrar los puntos vehiculares del tipo seleccionado en el mapa
 */
- (void)dropPuntosVehicularesTipo:(kTIPO_PUNTO_VEHICULAR)kTipoPuntoVehicular enMapa:(MKMapView *)mapView;

/**
 *  Metodo que devuelve un arreglo de puntos vehiculares del tipo deseado
 */
- (NSArray *)puntosVehicularesTipo:(kTIPO_PUNTO_VEHICULAR)kTipoPuntoVehicular;

/**
 *  Metodo que se llama al momento de seleccionar un punto del mapa
 */
- (void)mostrarMasInformacionDePuntoVehicularSeleccionado;

/**
 *  Metodo que obtiene los datos de los puntos vehiculares del tipo seleccionado
 */
- (NSArray *)getFromJSONPuntosVehicularesTipo:(kTIPO_PUNTO_VEHICULAR)tipoPuntoVehicular;

/**
 *  Metodo que calcula el punto central de una zona que contiene todos los puntos geograficos
 *  dados por el arreglo de puntos pasado como parametro dentro de si misma.
 */
- (CLLocationCoordinate2D)coordenadaCentralDadoPuntosFromArray:(NSArray *)arrPuntosCoordenadas;
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
    
    // Liberar Outlets
    _fetchedResultsController = nil;
    _mapa = nil;
    _segmentedControl = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Le damos un titulo a nuestra vista
    self.title = @"Mapas";
    
    // Obtenemos los Puntos Vehiculares tipo Verificentro desde CoreData
    arrPuntosCorralones = [self puntosVehicularesTipo:kTIPO_PUNTO_VEHICULAR_CORRALON];
    
    arrPuntosVerificentros = [self puntosVehicularesTipo:kTIPO_PUNTO_VEHICULAR_VERIFICENTRO];
    
    // Obtenemos el indice seleccionado del segmentedControl para cargar los puntos en el mapa
    [self seleccionarPuntoVehicularTipo:_segmentedControl];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Liberar los Outlets
    _fetchedResultsController = nil;
    _mapa = nil;
    _segmentedControl = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    
    // En caso de que el uisegmentedcontrol aun no este inicializado, seleccionamos el segmento 1
    if (segmentoSeleccionado < 0) {
        segmentoSeleccionado = 1;
    }
    
    // Eliminar los mapAnnotations anteriores
    NSArray *mapAnnotations = [_mapa annotations];
    [_mapa removeAnnotations:mapAnnotations];
    
    // guardar el punto vehicular seleccionado
    _tipoPuntoVehicular = segmentoSeleccionado;
    
    // Cargamos y mostramos los puntos vehiculares del tipo seleccionado
    [self dropPuntosVehicularesTipo:segmentoSeleccionado enMapa:_mapa];
}


#pragma mark - Metodo para llenar el mapa con puntos referentes a corralones y verificentros

- (void)dropPuntosVehicularesTipo:(kTIPO_PUNTO_VEHICULAR)kTipoPuntoVehicular enMapa:(MKMapView *)mapView
{
    MKMapView *myMapView = mapView;
    
    MKPointAnnotation *punto = nil;
    
    // Region del mapa que sera visible
    MKCoordinateRegion mapRegion;
    
    // Array de punto vehiculares
    NSMutableArray *arrPuntos = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Hacemos el fetch de puntos segun el tipo seleccionado
    switch (kTipoPuntoVehicular) {
            
        case kTIPO_PUNTO_VEHICULAR_CORRALON:
        {
            NSLog(@"mostrando corralones");
            
            mapRegion.center = [self coordenadaCentralDadoPuntosFromArray:arrPuntosVerificentros];
            
            // Para cada objeto de coreData de tipo 'Corralon' crear un MKPointAnnotation
            for (id puntoVerificentro in arrPuntosCorralones) {
                MKPointAnnotation *pv = [[MKPointAnnotation alloc] init];
                pv.title = [puntoVerificentro valueForKey:@"titulo"];
                pv.coordinate = CLLocationCoordinate2DMake([[puntoVerificentro valueForKey:@"latitud"] doubleValue], 
                                                           [[puntoVerificentro valueForKey:@"longitud"] doubleValue]);
                pv.subtitle = [puntoVerificentro valueForKey:@"delegacion"];
                
                // Agregamos al arreglo de puntos
                [arrPuntos addObject:pv];
                
                // TEST: obtenemos el ultimo punto para centrar el mapa
                // TODO: algoritmo que encuentre los puntos mas lejanos y crear una area que los contenga
                if (pv.coordinate.latitude != 0) {
                    punto = pv;
                }
            }
        }
            break;
            
        case kTIPO_PUNTO_VEHICULAR_VERIFICENTRO:
        {
            NSLog(@"mostrando verificentros");
            
            mapRegion.center = [self coordenadaCentralDadoPuntosFromArray:arrPuntosCorralones];
            
            // Para cada objeto de coreData de tipo 'Verificentro' crear un MKPointAnnotation
            for (id puntoVerificentro in arrPuntosVerificentros) {
                
                MKPointAnnotation *pv = [[MKPointAnnotation alloc] init];
                pv.title = [puntoVerificentro valueForKey:@"titulo"];
                pv.coordinate = CLLocationCoordinate2DMake([[puntoVerificentro valueForKey:@"latitud"] doubleValue], 
                                                               [[puntoVerificentro valueForKey:@"longitud"] doubleValue]);
                pv.subtitle = [puntoVerificentro valueForKey:@"delegacion"];
                
                // Agregamos al arreglo de puntos
                [arrPuntos addObject:pv];
                
                // TEST: obtenemos el ultimo punto para centrar el mapa
                // TODO: algoritmo que encuentre los puntos mas lejanos y crear una area que los contenga
                if (pv.coordinate.latitude != 0) {
                    punto = pv;
                }
            }
          
        }
            break;
            
        default:
            break;
    }
    
    // Agregamos todos los puntos al mapa
    [_mapa addAnnotations:arrPuntos];
    
// TODO: Todos los puntos deben tener coordenadas para que la funcion funcione!!
// TODO: Cambiar el arreglo desde el cual se obtienen los puntos de referencia
// TODO: Una vez que se calculan los valores, guardarlos y regresarlos sin calcular nuevamente los mismos datos
    mapRegion.span = MKCoordinateSpanMake(0.30, 0.30);
    [myMapView setRegion:mapRegion animated: YES];
}

- (CLLocationCoordinate2D)coordenadaCentralDadoPuntosFromArray:(NSArray *)arrPuntosCoordenadas
{
    CLLocationCoordinate2D centralCoord = {};
    
    // Obtenemos 4 puntos importantes, la latitud min y max. La longitud min y max de entre todos los puntos
    double latMax = 0.0;
    double latMin = 0.0;
    double longMax = 0.0;
    double longMin = 0.0;
    
    latMin = [[arrPuntosCoordenadas valueForKeyPath:@"@min.latitud"] doubleValue];
    latMax = [[arrPuntosCoordenadas valueForKeyPath:@"@max.latitud"] doubleValue];
    longMin = [[arrPuntosCoordenadas valueForKeyPath:@"@min.longitud"] doubleValue];
    longMax = [[arrPuntosCoordenadas valueForKeyPath:@"@max.longitud"] doubleValue];
    
    // TEST:
    if (latMin == 0) latMin = 19.4785;
    if (longMax == 0) longMax = -99.2471;
    
//    NSLog(@"lat min: %f", latMin);
//    NSLog(@"lat max: %f", latMax);
//    NSLog(@"long min: %f", longMin);
//    NSLog(@"long max: %f", longMax);
    
    // Construir la estructura CLLocationCoordinate2D
    centralCoord = CLLocationCoordinate2DMake((latMin + latMax) / 2, (longMin + longMax) / 2);
    return centralCoord;
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
        
        // NSLog(@"dato guardado: %@", [diccDatos valueForKey:@"titulo"]);
    }
}

#pragma mark "Manejo de Datos"

/** 
 *  Metodo que devuelve un arreglo con objetos CoreData (ManagedObjectModel) tipo "PuntoVehicular" del tipo pasado como parametro
 *  kTipoPuntoVehicular: Enum que define el tipo de PuntoVehicular deseado
 *  (NSArray *): un arreglo con los objetos buscados
 */
- (NSArray *)puntosVehicularesTipo:(kTIPO_PUNTO_VEHICULAR)kTipoPuntoVehicular
{
    // Liberera los objetos recolectados anteriormente para volver a realizar el fetch
    self.fetchedResultsController = nil;
    
    // Obtenemos todos los puntos vehiculares
    NSArray *puntosVehiculares = [self.fetchedResultsController fetchedObjects];
    
    // Predicado para obtener los puntos del tipo seleccionado
    NSPredicate *predicateTipoPunto = [NSPredicate predicateWithFormat:@"tipo == %d", kTipoPuntoVehicular];
    NSArray *puntosBuscados = [puntosVehiculares filteredArrayUsingPredicate:predicateTipoPunto];
    
    // En caso de que no haya objetos de ese tipo guardados, los obtenemos del JSON local y los metemos a CoreData
    if ([puntosBuscados count] == 0) {
        puntosBuscados = [self getFromJSONPuntosVehicularesTipo:kTipoPuntoVehicular];
        
        // Para cada diccionario obtenido, guardamos en CoreData un objeto
        NSMutableDictionary *mutDictPuntoVehicular = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        for (NSDictionary *dicc in puntosBuscados) {
            
            // Construir el diccionario para un punto vehicular
            [mutDictPuntoVehicular setValue:[dicc valueForKey:@"_Punto_Vehicular__delegacion"] forKey:@"delegacion"];
            [mutDictPuntoVehicular setValue:[dicc valueForKey:@"_Punto_Vehicular__direccion"] forKey:@"direccion"];
            
            // Lat y Long estan dentro de un diccionario, 
            // primero lo obtenemos y luego buscamos las llaves 'lat' y 'long'
            NSDictionary *tempDictCoordenadas = [dicc valueForKey:@"_Punto_Vehicular__coordenadas"];
            NSNumber *latitud = [NSNumber numberWithDouble:([[tempDictCoordenadas valueForKey:@"lat"] doubleValue])];
            NSNumber *longitud = [NSNumber numberWithDouble:([[tempDictCoordenadas valueForKey:@"long"] doubleValue])];
            
            [mutDictPuntoVehicular setValue:latitud forKey:@"latitud"];
            [mutDictPuntoVehicular setValue:longitud forKey:@"longitud"];
            
            // es un array de telefonos
            //[mutDictPuntoVehicular setValue:[dicc valueForKey:@"_Punto_Vehicular__telefonos"] forKey:@"telefono"];
            [mutDictPuntoVehicular setValue:[NSNumber numberWithInt:kTipoPuntoVehicular] forKey:@"tipo"];
            [mutDictPuntoVehicular setValue:[dicc valueForKey:@"_Punto_Vehicular__nombre"] forKey:@"titulo"];
            
            // Agregamos los datos a CoreData
            [self agregarPuntoVehicularConDatos:mutDictPuntoVehicular];
            
            // Limpiamos el diccionario de las llaves agregadas
            [mutDictPuntoVehicular removeAllObjects];
        }
        
        // Hacemos un re-fetch de los nuevos objetos guardados
        puntosBuscados = nil;
        NSArray *nuevosPuntosVehiculares = [self puntosVehicularesTipo:kTipoPuntoVehicular];
        
        // Filtramos los puntos buscados
        NSArray *nuevosPuntosBuscados = [nuevosPuntosVehiculares filteredArrayUsingPredicate:predicateTipoPunto];
        
        return nuevosPuntosBuscados;
    }
    
    return puntosBuscados;
}

/**
 *  Metodo para borrar todos los registros de la Entidad para esta clase
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

#pragma mark MKMapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // Creamos la vista de punto a desplegar
    // Reusando algun pin anterior
    MKPinAnnotationView *pinView = nil;
    pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinPuntoVehicular"];
    
    if (! pinView) {
         pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinPuntoVehicular"];
        
        // Configuramos la vista del punto        
        [pinView setAnimatesDrop:NO];
        [pinView setCanShowCallout:YES];
        [pinView setCalloutOffset:CGPointMake(-8.0f, 0.0f)];
        
        [pinView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
        [(UIButton *)pinView.rightCalloutAccessoryView addTarget:self 
                                                          action:@selector(mostrarMasInformacionDePuntoVehicularSeleccionado) 
                                                forControlEvents:UIControlEventTouchUpInside];
    }
    
    switch (_tipoPuntoVehicular) {
        case kTIPO_PUNTO_VEHICULAR_CORRALON:
            [pinView setPinColor:MKPinAnnotationColorRed];
            break;
            
        case kTIPO_PUNTO_VEHICULAR_VERIFICENTRO:
            [pinView setPinColor:MKPinAnnotationColorGreen];
            break;
            
        default:
            break;
    }
    
    // Seleccionamos el pin para mostrar la informacion de inmediato
    [mapView selectAnnotation:annotation animated:YES];
    
    return pinView;
}

- (void)mostrarMasInformacionDePuntoVehicularSeleccionado
{
    [self performSegueWithIdentifier:@"segue_detalle_pin" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segue_detalle_pin"]) {

        // Obtenemos el MKAnnotationView seleccionado
        NSArray *arrAnnotations = [_mapa selectedAnnotations];
        MKPointAnnotation *pointAnnotation = [arrAnnotations lastObject];
        
        // Configurar la vista de detalle
        id vistaDetalle = [segue destinationViewController];
        
        // Valores para la vista de detalle
        NSString *nombre = nil;
        NSString *direccion = nil;
        NSString *telefono = nil;
        NSString *delegacion = nil;
        
        // Predicado de busqueda por nombre
        NSPredicate *predicateSearch = [NSPredicate predicateWithFormat:@"titulo LIKE %@", pointAnnotation.title];
        
        // Segun el tipo de punto seleccionado
        switch (_tipoPuntoVehicular) {
            case kTIPO_PUNTO_VEHICULAR_CORRALON:
            {
                // Titulo de la vista de detalle
                [vistaDetalle setValue:@"Corralón" forKey:@"titulo"];
                
                // Filtramos el arreglo de Corralones por los puntos que se llaman como el punto seleccionado
                NSArray *arrPuntoSeleccionado = [arrPuntosCorralones filteredArrayUsingPredicate:predicateSearch];

                if ([arrPuntoSeleccionado count] > 0) 
                {
                    // Obtenemos el punto vehicular deseado
                    id pv = [arrPuntoSeleccionado lastObject];
                    nombre = [pv valueForKey:@"titulo"];
                    direccion = [pv valueForKey:@"direccion"];
                    telefono = [pv valueForKey:@"telefono"];
                    delegacion = [pv valueForKey:@"delegacion"];
                }
            }
                break;
                
            case kTIPO_PUNTO_VEHICULAR_VERIFICENTRO:
            {
                
                // Titulo de la vista de detalle
                [vistaDetalle setValue:@"Verificentro" forKey:@"titulo"];
                
                // Filtramos el arreglo de Verificentros por los puntos que se llaman como el punto seleccionado
                NSArray *arrPuntoSeleccionado = [arrPuntosVerificentros filteredArrayUsingPredicate:predicateSearch];
                
                if ([arrPuntoSeleccionado count] > 0) 
                {    
                    // Obtenemos el punto vehicular deseado
                    id pv = [arrPuntoSeleccionado lastObject];
                    nombre = [pv valueForKey:@"titulo"];
                    direccion = [pv valueForKey:@"direccion"];
                    telefono = [pv valueForKey:@"telefono"];
                    delegacion = [pv valueForKey:@"delegacion"];
                }
            }
                break;
                
            default:
                break;
        }
        
        [vistaDetalle setValue:nombre forKey:@"nombre"];
        [vistaDetalle setValue:direccion forKey:@"direccion"];
        [vistaDetalle setValue:telefono forKey:@"telefono"];
        [vistaDetalle setValue:delegacion forKey:@"delegacion"];
    }
}


#pragma mark - Manejo de Datos "PuntoVehiculares"

- (NSArray *)getFromJSONPuntosVehicularesTipo:(kTIPO_PUNTO_VEHICULAR)tipoPuntoVehicular
{
    // Establecemos la llave para obtener los datos JSON correspondientes
    NSString *strLlaveDiccJson = nil;
    
    switch (tipoPuntoVehicular) {
        case kTIPO_PUNTO_VEHICULAR_VERIFICENTRO:
            strLlaveDiccJson = @"verificentros";
            break;
            
        case kTIPO_PUNTO_VEHICULAR_CORRALON:
            strLlaveDiccJson = @"corralones";
            break;
            
        default:
            NSLog(@"ERROR: Punto Vehicular no definido");
            abort();
            break;
    }
    
    // Leemos el archivo JSON con los datos de puntos vehiculares
    NSString *strPathDatosVehiculares = [[NSBundle mainBundle] pathForResource:strLlaveDiccJson ofType:@"json"];
    NSData *dataPuntosVehiculares = [NSData dataWithContentsOfFile:strPathDatosVehiculares];
    
    // Cargamos un diccionario con el contenido del archivo especificado
    NSError *error = nil;
    NSDictionary *diccDatos = [NSJSONSerialization JSONObjectWithData:dataPuntosVehiculares 
                                                              options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers|NSJSONReadingAllowFragments 
                                                                error:&error];
    
    NSArray *arrPuntosVehiculares = [diccDatos valueForKey:strLlaveDiccJson];
    // NSLog(@"%@", arrPuntosVehiculares);
    
    return arrPuntosVehiculares;
}

@end
