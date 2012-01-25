//
//  MainViewController.m
//  Placas
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "MainViewController.h"
#define kENTITY_NAME    @"Tip"


@implementation MainViewController

@synthesize managedObjectContext = _managedObjectContext;   // La propiedad se obtiene de la definicion del protocolo
@synthesize scrollView = _scrollView;
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    _fetchedResultsController = nil;
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_scrollView setContentSize:CGSizeMake(3200, 100)];
    
    // NSArray * tips = [NSArray arrayWithObjects:@"tip1", @"tip2", @"tip3", @"tip4", @"tip5", @"tip6", @"tip7", @"tip8", @"tip9", nil];
    NSArray *tips = [self.fetchedResultsController fetchedObjects];
    
    //NSArray * tips = [self getTips];
    
//    NSMutableDictionary * diccionarioTip = [[NSMutableDictionary alloc] init];
     
     // guardamos algunos tips dummies :)
//     for (int j = 0; j < 50; j++) {
//     
//     [diccionarioTip setValue:[NSString stringWithFormat:@"%d", j] forKey:@"tip_id"];
//     
//     [diccionarioTip setValue:[NSString stringWithFormat:@"Este es el tip %d", j] forKey:@"descripcion"];
//     
//     [self saveTip:diccionarioTip];
//     }
    
    int i = 0;
    
    for (id tip in tips) {
        
        [self addTip:i++ tip:[tip valueForKey:@"descripcion"]];
    }
    
    // NSLog(@"hay :%d", [[self.fetchedResultsController fetchedObjects] count]);
}

- (void) saveTip:(NSMutableDictionary *) tipDiccionario {
    
    // Creamos una nueva instancia de la entidad manegada por el fetchedResultsController
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // Configuramos el nuevo objeto con los datos del diccionario
    
    // NSLog(@"%@ %@", [tipDiccionario valueForKey:@"tip_id"], [tipDiccionario valueForKey:@"descripcion"]);
    
    NSNumber * tip_id = [NSNumber numberWithInt:[[tipDiccionario valueForKey:@"tip_id"] intValue]];
    
    [newManagedObject setValue:tip_id forKey:@"tip_id"];
    
    [newManagedObject setValue:[tipDiccionario valueForKey:@"descripcion"] forKey:@"descripcion"];
    
    // Guardamos el nuevo contexto
    NSError *error = nil;
    
    if (![context save:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        
    } else {
        
        // NSLog(@"Tip guardado: %@", [tipDiccionario valueForKey:@"descripcion"]);
    }
}

- (void) addTip:(int) posicion tip:(NSString *) text {
    
    // NSLog(@"%@ %d", text, posicion);
    
    UILabel * tipLabel = [[UILabel alloc] init];
    
    [tipLabel setText:text];
    
    tipLabel.frame = CGRectMake(posicion * 320, 40, 320, 100);
    
    [_scrollView addSubview:tipLabel];
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
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    static NSString *placasListas = @"placasListas";
    
    if (! [userDefaults valueForKey:placasListas] || 
        ! [[userDefaults valueForKey:placasListas] boolValue]) {
        
        [self performSegueWithIdentifier:@"segue_modal_ingresa_datos" sender:self];
        
        // Cuando el usuario ha ingresado sus datos, entonces establecemos la bandera en el userDefaults
        // que las placas ya estan listas
        [userDefaults setValue:[NSNumber numberWithBool:YES] forKey:placasListas];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Fetched results controller

// obtenemos todas las categorías del core :D
- (NSArray *) getTips {   
    
    // Define our table/entity to use  
    NSEntityDescription *entity = [NSEntityDescription entityForName:kENTITY_NAME inManagedObjectContext:self.managedObjectContext];   
    
    // Setup the fetch request  
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entity];
    
    // Fetch the records and handle an error  
    NSError *error;  
    
    NSArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];   
    
    if (!mutableFetchResults) {  
        // Handle the error.  
        // This is a serious error and should advise the user to restart the application  
    }   
    
    return mutableFetchResults;
    
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
                                                   cacheName:@"MainCache"];
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

@end
