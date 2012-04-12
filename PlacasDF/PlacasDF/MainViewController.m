//
//  MainViewController.m
//  Placas
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "MainViewController.h"
#import "IngresaDatosViewController.h"

#import "NSDate+ADNExtensions.h"
#define kENTITY_NAME    @"Tip"
#define kENERO 1
#define kFEBRERO 2
#define kMARZO 3
#define kABRIL 4
#define kMAYO 5
#define kJUNIO 6
#define kJULIO 7
#define kAGOSTO 8
#define kSEPTIEMBRE 9
#define kOCTUBRE 10
#define kNOVIEMBRE 11
#define kDICIEMBRE 12

@interface MainViewController() <IngresaDatosDelegate>

/**
 *  Metodo que muestra o quita la vista de 'Hoy No Circula'
 */
- (void)mostrarViewHoyNoCircula:(NSNumber *)numMostrar;

/**
 *  Metodo para mostrar los tips guardados en el ScrollView
 */
- (void)showTipsInScrollView;

/**
 *  Metodo que lee el archivo JSON que contiene los tips iniciales y devuelve un array de tips
 */
- (NSArray *)obtenerTipsFromJSONFile;

@end



@implementation MainViewController

@synthesize managedObjectContext = _managedObjectContext;   // La propiedad se obtiene de la definicion del protocolo
@synthesize scrollView = _scrollView;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize diasParaVerificar = _diasParaVerificar;
@synthesize viewHoyNoCircula = _viewHoyNoCircula;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    _fetchedResultsController = nil;
    _scrollView = nil;
    _diasParaVerificar = nil;
    _viewHoyNoCircula = nil;
}


-(void) viewWillAppear:(BOOL)animated {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Obtener los tips precargados
    //[self obtenerTipsFromJSONFile];
    [self getTips];
    
    NSUserDefaults * usersDefault = [NSUserDefaults standardUserDefaults];
    
    [usersDefault setValue:@"122UML" forKey:@"Placas"]; //737MZM
    
    [usersDefault setValue:@"2001" forKey:@"Modelo"];
    
    [usersDefault synchronize];
    
    [_diasParaVerificar setText:[NSString stringWithFormat:@"%d", [self diasParaVerificar]]];
    
    
    // TEST
    //[self agregarDummiesTips];
    [self showTipsInScrollView];
}

- (void)saveTipWithProperties:(NSDictionary *)tipProperties
{    
    // Creamos una nueva instancia de la entidad manegada por el fetchedResultsController
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // Configuramos el nuevo objeto con los datos del diccionario
    NSNumber *tip_id = [NSNumber numberWithInt:( [[tipProperties valueForKey:@"tip_id"] intValue] )];
    [newManagedObject setValue:tip_id forKey:@"tip_id"];
    [newManagedObject setValue:[tipProperties valueForKey:@"descripcion"] forKey:@"descripcion"];
    
    // Guardamos el nuevo contexto
    NSError *error = nil;
    
    if (![context save:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        
    } else {
        NSLog(@"Tip guardado: %@", [tipProperties valueForKey:@"descripcion"]);
    }
}

// TODO: Fade-In Fade-Out para cada tip, en lugar de un scrollView
- (void)showTipsInScrollView
{
    NSArray *arrTips = [_fetchedResultsController fetchedObjects];
    
    // Ampliamos la longitud del contenido del scrollView
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width * [arrTips count], _scrollView.frame.size.height)];
    [_scrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    
    // Creamos al vuelo 10 vistas que se agregan al scrollView y muestran cada tip
    int offsetX = 0;
    float contentInsetLabelWidth = 12.0f;           // Margen a los costados que se le da a la etiqueta que muestra cada tip
    for (id tip in arrTips) 
    {
        // Vista que contiene el tip
        UIView *viewTip = [[UIView alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width * offsetX++, 0, 
                                                                   _scrollView.frame.size.width, _scrollView.frame.size.height)];
        [viewTip setBackgroundColor:[UIColor colorWithRed:45.0f/255.0f green:96.0f/255.0f blue:149.0f/255.0f alpha:1.0f]];
        
        // Etiqueta que contiene la descripcion de cada tip
        UILabel *labelTip = [[UILabel alloc] initWithFrame:CGRectMake(contentInsetLabelWidth, 0, 
                                                                      viewTip.frame.size.width - (contentInsetLabelWidth * 2), viewTip.frame.size.height)];
        
        // Configurar cada etiqueta
        [labelTip setText:[tip valueForKey:@"descripcion"]];
        [labelTip setTextColor:[UIColor whiteColor]];
        [labelTip setFont:[UIFont systemFontOfSize:14.0f]];
        [labelTip setNumberOfLines:4];
        [labelTip setTextAlignment:UITextAlignmentCenter];
        [labelTip setBackgroundColor:[UIColor clearColor]];
        
        // Agregar la etiqueta a la vista
        [viewTip addSubview:labelTip];
        
        // Agregar la vista al scrollView
        [_scrollView addSubview:viewTip];
    }
}


- (void)addTip:(int)posicion tip:(NSString *)text
{
    // Vista que contiene un Tip
    UIView *viewForTip = [[UIView alloc] initWithFrame:CGRectMake(( posicion * 320 ), 0, _scrollView.frame.size.width, 100)];
    [viewForTip setBackgroundColor:[UIColor grayColor]];
    
    // Etiqueta de cada tip
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:viewForTip.frame];
    [tipLabel setText:text];
    [tipLabel setBackgroundColor:[UIColor clearColor]];
    [tipLabel setTextAlignment:UITextAlignmentCenter];
    [viewForTip addSubview:tipLabel];
    
    // Agregar cada vista del tip al scrollView
    [_scrollView addSubview:viewForTip];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _fetchedResultsController = nil;
    _scrollView = nil;
    _diasParaVerificar = nil;
    _viewHoyNoCircula = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    static NSString *placasListas = @"placasListas";
    
    if (! [userDefaults valueForKey:placasListas] || 
        ! [[userDefaults valueForKey:placasListas] boolValue]) {
        
        [self performSegueWithIdentifier:@"modal_ingresa_datos" sender:self];
        
        // Cuando el usuario ha ingresado sus datos, entonces establecemos la bandera en el userDefaults
        // que las placas ya estan listas
        [userDefaults setValue:[NSNumber numberWithBool:YES] forKey:placasListas];

    }
    
    // ========================================
    // TEST: Mostrar vista 'Hoy no Circulas'
    [self performSelector:@selector(mostrarViewHoyNoCircula:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.0];
    [self performSelector:@selector(mostrarViewHoyNoCircula:) withObject:[NSNumber numberWithBool:YES] afterDelay:4.0];
    // ========================================
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Fetched results controller

// obtenemos todas las categorias del core :D
- (NSArray *)getTips 
{       
    // Liberera los objetos recolectados anteriormente para volver a realizar el fetch
    self.fetchedResultsController = nil;
    
    // Obtenemos todos los puntos vehiculares
    NSArray *arrTips = [self.fetchedResultsController fetchedObjects];
    
    // En caso de que no haya objetos guardados, los obtenemos del JSON local 'tips.json' y los metemos a CoreData
    if ([arrTips count] == 0) 
    {
        arrTips = [self obtenerTipsFromJSONFile];
        
        // Para cada diccionario obtenido, guardamos en CoreData un objeto
        NSMutableDictionary *mutDictOfTips = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        int tip_id = 0;
        for (NSDictionary *diccTip in arrTips) 
        {
            // Construir el diccionario para un tip
            [mutDictOfTips setValue:[diccTip valueForKey:@"_Tip__description"] forKey:@"descripcion"];
            [mutDictOfTips setValue:[NSNumber numberWithInt:tip_id++] forKey:@"tip_id"];
                        
            // Agregamos los datos a CoreData
            [self saveTipWithProperties:mutDictOfTips];
            
            // Limpiamos el diccionario de las llaves agregadas
            [mutDictOfTips removeAllObjects];
        }
        
        // Hacemos un re-fetch de los nuevos objetos guardados
        arrTips = nil;
        NSArray *nuevosTips = [self getTips];
        
        return nuevosTips;
    }
    
    return arrTips;
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tip_id" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = 
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                        managedObjectContext:self.managedObjectContext 
                                          sectionNameKeyPath:nil 
                                                   cacheName:@"MainTipsCache"];
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

- (NSNumber *) _diasParaVerificar {
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString * placas = [userDefaults objectForKey:@"Placas"];
    
    NSNumber * terminacion = [NSNumber numberWithChar:([placas characterAtIndex:2] - 48)];
    
    NSLog(@"%d", [terminacion integerValue]);
    
    // NSDate * fecha = [NSDate date];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    
    NSInteger day = [components day];    
    
    NSInteger month = [components month];
    
    NSInteger year = [components year];
    
    NSLog(@"Dia %d Mes %d Año %d", day, month, year);
    
    
    NSDate *startDate = [NSDate date];
    
    NSDate *endDate = [[NSDate date] dateByAddingTimeInterval:(10 * 60 * 60 * 24)];
    
    NSInteger difference = [startDate numberOfDaysUntil:endDate];
    
    NSLog(@"Diff = %d", difference);
    
    if ([self estaEnPeriodoDeVerificacion:[terminacion intValue]]) {
        
        NSLog(@"Está en mi periodo de verificación");        
        
    } else {
        
        NSLog(@"NO estoy en mi periodo de verificación");        
    }
    

    
    [self lastDateOfMonth];
    
    return [NSNumber numberWithInt:1];
    
}


- (void) lastDateOfMonth {
    
    NSDate *curDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:curDate]; // Get necessary date components
    
    // set last of month
    [comps setMonth:[comps month]+1];
    [comps setDay:0];
    NSDate *tDateMonth = [calendar dateFromComponents:comps];
    NSLog(@"%@", tDateMonth);
}


- (BOOL)estaEnPeriodoDeVerificacion:(int)terminacion 
{    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    
    int mes = [components month];
    
    if ((terminacion == 5 || terminacion == 6) && (mes == kENERO || mes == kFEBRERO || mes == kJULIO || mes == kAGOSTO)) {
        
        return YES;
        
    } else if ((terminacion == 7 || terminacion == 8) && (mes == kFEBRERO || mes == kMARZO || mes == kAGOSTO || mes == kSEPTIEMBRE)) {
        
        return YES;
        
    } else if ((terminacion == 3 || terminacion == 4) && (mes == kMARZO || mes == kABRIL || mes == kSEPTIEMBRE || mes == kOCTUBRE)) {
        
        return YES;
        
    } else if ((terminacion == 1 || terminacion == 2) && (mes == kABRIL || mes == kMAYO || mes == kOCTUBRE || mes == kNOVIEMBRE)) { 
        
        return YES;
    
    } else if ((terminacion == 9 || terminacion == 0) && (mes == kMAYO || mes == kJUNIO || mes == kNOVIEMBRE || mes == kDICIEMBRE)) {
        
        return YES;
        
    } else {
        
        return NO;
    }
}


- (NSNumber *) diasParaVerificar 
{
    return [NSNumber numberWithInt:1];
}


- (void)mostrarViewHoyNoCircula:(NSNumber *)numMostrar
{
    if ([numMostrar boolValue]) 
    {
        CGRect frameVisible = CGRectMake(_viewHoyNoCircula.frame.origin.x, _viewHoyNoCircula.frame.origin.y - _viewHoyNoCircula.frame.size.height,
                                         _viewHoyNoCircula.frame.size.width, _viewHoyNoCircula.frame.size.height);
        /*
         *  Animacion: Mostrar la vista 'Hoy no Circulas'
         */
        [UIView animateWithDuration:0.7f 
                              delay:0.0f 
                            options:UIViewAnimationCurveEaseIn 
                         animations:^{
                             [_viewHoyNoCircula setFrame:frameVisible];
                         } completion:^(BOOL finished) {
                             
                         }];
    } 
    else 
    {    
        CGRect frameOculto = CGRectMake(_viewHoyNoCircula.frame.origin.x, _viewHoyNoCircula.frame.origin.y + _viewHoyNoCircula.frame.size.height,
                                        _viewHoyNoCircula.frame.size.width, _viewHoyNoCircula.frame.size.height);
        
        /* 
         *  Animacion: Ocultar la vista 'Hoy no Circulas' 
         */
        [UIView animateWithDuration:0.7f 
                              delay:0.0f 
                            options:UIViewAnimationCurveEaseIn 
                         animations:^{
                             [_viewHoyNoCircula setFrame:frameOculto];
                         } completion:^(BOOL finished) {

                         }];
    }
}


#pragma mark - IngresarDatos Delegate

- (void)ingresaDatosDismissViewController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Prepare For Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"modal_ingresa_datos"]) 
    {
        IngresaDatosViewController *idvc = (IngresaDatosViewController *)[segue destinationViewController];
        [idvc setDelegate:self];
    }
}

#pragma mark - Manejo de Archivo JSON con tips

- (NSArray *)obtenerTipsFromJSONFile
{
    // Leemos el archivo JSON con los datos de puntos vehiculares
    NSString *strPathTips = [[NSBundle mainBundle] pathForResource:@"tips" ofType:@"json"];
    NSData *dataPuntosVehiculares = [NSData dataWithContentsOfFile:strPathTips];
    
    // Cargamos un diccionario con el contenido del archivo especificado
    NSError *error = nil;
    NSDictionary *diccDatos = [NSJSONSerialization JSONObjectWithData:dataPuntosVehiculares 
                                                              options:NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers| NSJSONReadingAllowFragments 
                                                                error:&error];
    
    NSArray *arrTips = [diccDatos valueForKey:@"tips"];
    // NSLog(@"%@", arrTips);
    
    return arrTips;
}

@end
