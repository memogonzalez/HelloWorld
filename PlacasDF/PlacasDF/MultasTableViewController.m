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

#define URL @"http://www.caosinc.com/webservices/placa.php?placa="

#define kENTITY_NAME    @"Multa"

@implementation MultasTableViewController

@synthesize celdaMulta;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;

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
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    _fetchedResultsController = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sinPagar = 0;
    
    isShowingList = NO;
    
    receivedData = [[NSMutableData alloc] init];
    
    arrMultas = [[NSArray alloc] init];
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString * placas = [userDefaults objectForKey:@"Placas"];
    
    NSLog(@"Mis placas son %@", placas);
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL, placas]];
    
    arrMultas = [self.fetchedResultsController fetchedObjects];
    
    if ([arrMultas count] == 0) {
    
        NSURLRequest * request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
    
        NSURLConnection * conexion = [NSURLConnection connectionWithRequest:request delegate:self];
    
        [conexion start]; 
            
    }
    
    arrMultasFrecuentes = [self getMultasFrecuentes];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0)
        
        return @"Infracciones más frecuentes";
    
    else
        
        return @"Tus Infracciones";
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
    
    if ([indexPath section] == 1) {
    
        NSDictionary * multa = [arrMultas objectAtIndex:[indexPath row]];
    
        NSString * imageName = ([[multa objectForKey:@"status"] isEqualToString:@"Pagada "]) ? @"ok.png": @"nook.png";
    
        UIImage * image = [UIImage imageNamed:imageName];
    
        cell.fecha.text = [multa objectForKey:@"fecha"];
    
        cell.sancion.text = [NSString stringWithFormat:@"%@ días de salario mínimo", [multa objectForKey:@"sancion"]];
    
        cell.motivo.text = [self formatString:[multa objectForKey:@"motivo"]];
    
        [cell.situacion setImage:image];
    
    } else {
        
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
    return 92.0;
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError * error;
    
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    
    NSDictionary * diccionario = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error];
    
    NSDictionary *multas = [diccionario objectForKey:@"multas"];
    
    arrMultas = [multas objectForKey:@"multa"];
    
    for (NSDictionary * multa in arrMultas) {
        
        NSLog(@"%@", [multa objectForKey:@"multa_id"]);
        
    }
    
    sinPagar = 4;
    
    self.tabBarController.selectedViewController.tabBarItem.badgeValue = @"1";
    
    [self scheduleNotification];
    
    [self.tableView reloadData];
}

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
    
    [newManagedObject setValue:[multaDiccionario valueForKey:@"motivo"] forKey:@"motivo"];
    
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:kENTITY_NAME 
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Batch Size a 20 objetos a la vez
    [fetchRequest setFetchBatchSize:20];
    
    // Editamos un sort descriptor, devuelve los puntos vehiculares ordenados por titulo
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"folio" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = 
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                        managedObjectContext:self.managedObjectContext 
                                          sectionNameKeyPath:nil 
                                                   cacheName:@"MultaCache"];
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


// leyendo la plist
- (NSArray *) getMultasFrecuentes {
    
    NSString *path = [[NSBundle mainBundle] pathForResource: @"MultasFrecuentes" ofType:@"plist"];
    
    NSDictionary *multas = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    return [multas objectForKey:@"multas"];
}

// Notificaciones
- (void)scheduleNotification
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    
    if (localNotif == nil)
        return;
    
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

@end
