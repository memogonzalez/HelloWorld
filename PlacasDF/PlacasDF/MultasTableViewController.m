//
//  MultasTableViewController.m
//  Placas
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "MultasTableViewController.h"
#import "AppDelegate.h"
#import "ManejadorConexiones.h"
#import "Multa.h"
#import "MultaCelda.h"
#import "MBProgressHUD.h"

#define URL @"http://www.caosinc.com/webservices/placa.php?placa="
// #define URL @"http://localhost:8888/webservices/placa.php?placa="
#define kENTITY_NAME    @"Multa"
#define kPULLDOWN   @"1"
#define kWITHOUTDOWN @"2"

@implementation MultasTableViewController

@synthesize celdaMulta;

@synthesize managedObjectContext = _managedObjectContext;

@synthesize fetchedResultsController = _fetchedResultsController;

@synthesize mb = _mb;

@synthesize numeroMultas = _numeroMultas;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    _fetchedResultsController = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // animamos la carga de datos
    _mb = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [_mb setLabelText:@"Cargando"];
    
    [_mb show:YES];
    
    // Inicializamos variables
    _numeroMultas = [NSNumber numberWithInt:0];
    
    sinPagar = 0;
    
    isShowingList = NO;
    
    connectionError = NO;
    
    receivedData = [[NSMutableData alloc] init];
    
    arrMultas = [[NSArray alloc] init];
    
    // cargamos información de UserDefaults
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString * placas = [userDefaults objectForKey:@"Placas"];
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL, placas]];
    
    // verificamos si existen datos en CoreData, de lo contrario cargamos datos desde el WebService
    arrMultas = [self.fetchedResultsController fetchedObjects];
    
    if ([arrMultas count] == 0) {
        
        NSURLRequest * request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
        
        NSURLConnection * conexion = [NSURLConnection connectionWithRequest:request delegate:self];
        
        [conexion start]; 
    }
    
    // pedimos las multas frecuentes
    arrMultasFrecuentes = [self getMultasFrecuentes];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Dos secciones (Multas Frecuentes, Infracciones del usuario)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        return (!isShowingList) ? 1: [arrMultasFrecuentes count];
        
    } else {
        
        return [arrMultas count];
    }
}

// Este método carga los datos desde CoreData para multas frecuentes y desde el WebService para las multas del usuario
- (void) loadData {
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString * placas = [userDefaults objectForKey:@"Placas"];
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL, placas]];
    
    arrMultas = [self.fetchedResultsController fetchedObjects];
    
    if ([arrMultas count] == 0) {
        
        NSURLRequest * request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
        
        NSURLConnection * conexion = [NSURLConnection connectionWithRequest:request delegate:self];
        
        [conexion start]; 
    }
    
    arrMultasFrecuentes = [self getMultasFrecuentes];
    
    [self.tableView reloadData];
    
    [self stopLoading];
}


// Al hacer el pull down, refresca los datos
- (void) refresh {
    
    [_mb hide:YES];
    
    _mb = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [_mb setLabelText:@"Cargando"];
    
    [_mb show:YES];
    
    [self performSelector:@selector(loadData) withObject:nil afterDelay:2.0];
}

// Títulos de las secciones
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0) {
        
        return @"Infracciones más frecuentes";
    
    } else {
        
        return @"Tus Infracciones";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MultaCelda";
    
    MultaCelda *cell = (MultaCelda *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        
        [[NSBundle mainBundle] loadNibNamed:@"MultaCelda" owner:self options:nil];
        
        cell = celdaMulta;
        
        self.celdaMulta = nil;
    }
    
    if ([indexPath section] == 1) { // Infracciones del usuario
        
        if (connectionError) {
            
            cell.motivo.text = @"Hubo un error en la comunicación, vuelve a intentarlo";
            
        } else if ([_numeroMultas intValue] > 0) {
    
            NSDictionary * multa = [arrMultas objectAtIndex:[indexPath row]];
    
            NSString * imageName = ([[multa objectForKey:@"status"] isEqualToString:@"Pagada"]) ? @"ok.png": @"nook.png";
    
            UIImage * image = [UIImage imageNamed:imageName];
    
            cell.fecha.text = [multa objectForKey:@"fecha"];
    
            cell.sancion.text = [NSString stringWithFormat:@"%@ días de salario mínimo", [multa objectForKey:@"sancion"]];
    
            cell.motivo.text = [self formatString:[multa objectForKey:@"motivo"]];
    
            [cell.situacion setImage:image];
            
        } else {

            cell.motivo.text = @"Yay, no tienes multas!";
        }
    
    } else { // Multas más frecuentes
        
        if (isShowingList) {
        
            NSDictionary * multaFrecuente = [arrMultasFrecuentes objectAtIndex:[indexPath row]];
            
            NSNumber * corralon = [multaFrecuente objectForKey:@"corralon"];
            
            NSString * imageName = ([corralon isEqualToNumber:[NSNumber numberWithInt:1]]) ? @"ok.png": @"nook.png";
            
            UIImage * image = [UIImage imageNamed:imageName];

            cell.motivo.text = [multaFrecuente objectForKey:@"descripcion"];
        
            cell.sancion = [NSString stringWithFormat:@"%@ días de salario mínimo", [multaFrecuente objectForKey:@"multa"]];
            
            cell.fecha.text = [multaFrecuente objectForKey:@"fundamento"];
            
            [cell.situacion setImage:image];
            
        } else {
            
            cell.motivo.text = @"Ver las multas más frecuentes";
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.fecha.text = @"";
            
            cell.sancion.text = @"";
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath section] == 3) {
    
        NSDictionary * multa = [arrMultas objectAtIndex:[indexPath row]];
    
        NSString * text = [self formatString:[multa objectForKey:@"motivo"]];
        
        return [self getHeightForText:text];
        
    } else {
        
        return 92.0;
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        
        isShowingList = !isShowingList;
        
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
    } else {
        
        return;
    }
}


// Manejo de conexión
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

// Error de conexión
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    connectionError = YES;
    
    arrMultas = [NSArray arrayWithObject:@"Error de conexión"];
    
    [_mb setLabelText:@"Error"];
    
    [_mb hide:YES];
    
    // [self.tableView reloadData];
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

// conectividad correcta
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError * error;
    
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    
    NSDictionary * diccionario = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error];
    
    connectionError = NO;
    
    NSDictionary *multas = [diccionario objectForKey:@"multas"];
    
    NSString * stringMultas = [diccionario objectForKey:@"infracciones"];
    
    _numeroMultas = [NSNumber numberWithInteger:[stringMultas integerValue]];
    
    NSLog(@"Multas totales %@", stringMultas);
    
    // verificamos si el usuario tiene multas
    if ([_numeroMultas intValue] > 0) {
        
        sinPagar = 0;
        
        arrMultas = [multas objectForKey:@"multa"];
    
        for (NSDictionary * multa in arrMultas) {
        
            sinPagar = ([[multa objectForKey:@"status"] isEqualToString:@"No pagada"]) ? sinPagar + 1: sinPagar;
        
            NSLog(@"%@", [multa objectForKey:@"multa_id"]);        
        }
        
    } else {
        
        arrMultas = [NSArray arrayWithObject:@"Sin multas"];
    }
    
    if (sinPagar > 0) {
        
        self.tabBarController.selectedViewController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", sinPagar];
    }
    
    [self scheduleNotification];
    
    [_mb hide:YES];
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

// Realiza un replace de HTML entities
- (NSString *) formatString:(NSString *) text {
    
    NSString * str = [text stringByReplacingOccurrencesOfString:@"&Ntilde;" withString:@"Ñ"];
    
    str = [str stringByReplacingOccurrencesOfString:@"&Aacute;" withString:@"Á"];
    
    str = [str stringByReplacingOccurrencesOfString:@"&Eacute;" withString:@"É"];
    
    str = [str stringByReplacingOccurrencesOfString:@"&Iacute;" withString:@"Í"];
    
    str = [str stringByReplacingOccurrencesOfString:@"&Oacute;" withString:@"Ó"];
    
    str = [str stringByReplacingOccurrencesOfString:@"&Uacute;" withString:@"Ú"];
    
    str = [str lowercaseString];
    
    NSString * first = [[str substringWithRange:NSMakeRange(0, 1)] uppercaseString];
    
    str = [str stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:first];
    
    return str;
}


// CoreData protocol
- (void) saveMulta:(NSMutableDictionary *) multaDiccionario {
    
    // Creamos una nueva instancia de la entidad manegada por el fetchedResultsController
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // Configuramos el nuevo objeto con los datos del diccionario
    
    // NSLog(@"%@ %@", [tipDiccionario valueForKey:@"tip_id"], [tipDiccionario valueForKey:@"descripcion"]);
    
    NSNumber * situacion = [NSNumber numberWithInt:[[multaDiccionario valueForKey:@"situacion"] intValue]];
    
    NSNumber * sancion = [NSNumber numberWithInt:[[multaDiccionario valueForKey:@"sancion"] intValue]];
    
    [newManagedObject setValue:[multaDiccionario valueForKey:@"motivo"] forKey:@"motivo"];
    
    //[newManagedObject setValue:[multaDiccionario valueForKey:@"motivo"] forKey:@"motivo"];
    
    [newManagedObject setValue:sancion forKey:@"multa_id"];
    
    [newManagedObject setValue:situacion forKey:@"multa_id"];
    
    [newManagedObject setValue:[multaDiccionario valueForKey:@"motivo"] forKey:@"motivo"];
    
    [newManagedObject setValue:[multaDiccionario valueForKey:@"fundamento"] forKey:@"fundamento"];
    
    // Guardamos el nuevo contexto
    NSError *error = nil;
    
    if (![context save:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        
    } else {
        
        // NSLog(@"Tip guardado: %@", [tipDiccionario valueForKey:@"descripcion"]);
    }
}

// obtiene los resultados de la BD en Core Data
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Creamos el request para esta clase
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Editamos la entidad que se pide
    NSEntityDescription *entity = [NSEntityDescription entityForName:kENTITY_NAME inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    // Batch Size a 20 objetos a la vez
    [fetchRequest setFetchBatchSize:20];
    
    // Editamos un sort descriptor, devuelve los puntos vehiculares ordenados por titulo
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"folio" ascending:NO];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"MultaCache"];
    
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


// Se len las multas más frecuentes desde una plist
- (NSArray *) getMultasFrecuentes {
    
    NSString *path = [[NSBundle mainBundle] pathForResource: @"MultasFrecuentes" ofType:@"plist"];
    
    NSDictionary *multas = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    return [multas objectForKey:@"multas"];
}

// Se programan las notificaciones
- (void)scheduleNotification
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    
    if (localNotif == nil) {
        
        return;
    }
    
    localNotif.fireDate = [[NSDate date] addTimeInterval:+(10)]; // 10 segundos :D
    
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = [NSString stringWithFormat:@"No haz pagado %d tenencias", sinPagar];
    
    localNotif.alertAction = @"Ver detalles";
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    
    localNotif.applicationIconBadgeNumber = sinPagar;
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"No Pagados" forKey:@"tenencias"];
    
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = sinPagar;
    
    NSLog(@"Se ha programado %d", sinPagar);
}

- (IBAction) tweet:(id)sender {
    
    // [self performSegueWithIdentifier:@"TweetSegue" sender:self];
}

- (CGFloat) getHeightForText:(NSString *) text {
    
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:12.0];
    
    CGSize constraintSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 100, MAXFLOAT);
    
    CGSize labelSize = [text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height + 20;
}


@end
