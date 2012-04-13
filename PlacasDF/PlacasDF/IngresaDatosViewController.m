//
//  IngresarViewController.m
//  Placas
//
//  Created by David Hernández on 3/17/12.
//  Copyright (c) 2012 GoldenRatio Apps. All rights reserved.
//

#import "IngresaDatosViewController.h"
#import "AsyncFileDownloader.h"
#import "JSONDataSerializator.h"
#import "CoreDataObjectManager.h"

#define kURL_CAOS_PLACAS @"http://www.caosinc.com/webservices/placa.php?placa="

#define kMODELO_MIN     1980
#define kMODELO_MAX     2012            // TODO: Calcular el anio actual

@interface IngresaDatosViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

/**
 *  Arreglo de letras para construir las placas
 */
@property (strong, nonatomic) NSArray *arrLetras;
/**
 *  Arreglo de modelos
 */
@property (strong, nonatomic) NSArray *arrModelos;
/**
 *  Bandera que indica si la etiqueta 'placas' se estan editando,
 *  de lo contrario se asume que se edita la etiqueta de 'modelo de auto'
 */
@property (nonatomic) BOOL editandoPlacas;
/**
 *  Variable que indica el numero de columnas que debe tener el pickerView
 */
@property (nonatomic) NSInteger columnsForPickerView;
/**
 *  Variable que indica el tipo de auto seleccionado
 */
@property (nonatomic) TipoVehiculoSeleccionado tipoVehiculoSeleccionado;
/**
 *  Variable que guarda el sender para cambiar de edicion de etiquetas,
 *  sirve para recordar el ultimo sender y no cargar los datos al pickerView
 */
@property (nonatomic) id lastSender;

/**
 *  Metodo que se llama al seleccionar un tipo de auto
 */
- (IBAction)seleccionarTipoAuto:(id)sender;
/**
 *  Metodo que anima el UIPickerView para desaparecer y aparecer con el nuevo numero de columnas
 */
- (void)animateAndReloadPickerView;
/**
 *  Metodo para comenzar la edicion del numero de placa
 */
- (IBAction)iniciaEdicionPlacas:(id)sender;
/**
 *  Metodo para iniciar la edicion del modelo del auto
 */
- (IBAction)iniciaEdicionModelo:(id)sender;
/**
 *  Metodo para actualizar la etiqueta en edicion con el valor de los componentes pickerView
 */
- (void)actualizarLabelEnEdicionConStr:(NSString *)str;
/**
 *  Metodo para recargar el pickerView con el numero de columnas adecuado
 */
- (void)cargarPickerViewConDatosVehicularesTipo:(TipoVehiculoSeleccionado)tipoVehiculo;
/**
 *  Metodo que indica debe usarse los datos seleccionados
 */
- (IBAction)usarButton:(id)sender;
/**
 *  Metodo que carga el pickerView a partir de la cadena que se muestra de la etiqueta en edicion seleccionada
 */
- (void)loadPickerViewComponentsFromString:(NSString *)str;
/**
 *  Metodo que se llama cuando se presiona un boton de edicion de 'Placas' o 'Modelo'
 *  Para cambiar el tipo de letra de la etiqueta a bold
 */
- (IBAction)entrarModoEdicion:(id)sender;
/**
 *  Metodo para quitar la vista
 */
- (IBAction)cancelButtonPressed:(id)sender;

/**
 *  Metodo que crea una vista del tamanio del scrollView de placas y modelos
 *  y la pone detras para que se visualice cuando el pickerView baja
 */
- (void)makeViewForBackgroundOf:(UIPickerView *)pickerView;

/**
 *  Metodo que se encarga de interpretar y administrar los datos descargados
 */
- (void)manageDownloadedData:(id)data;

@end

@implementation IngresaDatosViewController

@synthesize delegate = _delegate;
@synthesize lastSender = _lastSender;
@synthesize navBar = _navBar;
@synthesize segmentedControl = _segmentedControl;
@synthesize labelIndicadorPlacas = _labelIndicadorPlacas;
@synthesize labelIndicadorModelo = _labelIndicadorModelo;
@synthesize pickerView = _pickerView;
@synthesize editandoPlacas = _editandoPlacas;
@synthesize labelModelo = _labelModelo;
@synthesize labelPlacas = _labelPlacas;
@synthesize columnsForPickerView = _columnsForPickerView;
@synthesize tipoVehiculoSeleccionado = _tipoVehiculoSeleccionado;
@synthesize arrLetras = _arrLetras;
@synthesize arrModelos = _arrModelos;
@synthesize cancelButton = _cancelButton;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    _navBar = nil;
    _segmentedControl = nil;
    _pickerView = nil;
    _labelPlacas = nil;
    _labelModelo = nil;
    _labelIndicadorPlacas = nil;
    _labelIndicadorModelo = nil;
    _cancelButton = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Agregamos una vista de background para el pickerView
    [self makeViewForBackgroundOf:_pickerView];
    
    // Somos delegados del pickerView
    [_pickerView setDelegate:self];
    [_pickerView setDataSource:self];
    
    // Navigation Bar
    [_navBar setFrame:CGRectMake(_navBar.frame.origin.x, _navBar.frame.origin.y, _navBar.frame.size.width, _navBar.frame.size.height + 37.0f)];
    
    // Cancel Button
    [_cancelButton setFrame:CGRectMake(_cancelButton.frame.origin.x - 11, (_navBar.frame.size.height - _cancelButton.frame.size.height) - 7, _cancelButton.frame.size.width, _cancelButton.frame.size.height)];
    
    // Title label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, _navBar.frame.size.width, _navBar.frame.size.height/3)];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:20.0f]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:@"Ingresa los datos"];
    [_navBar addSubview:titleLabel];    
    
    // UISegmentedControl
    UISegmentedControl *segmentedControl = _segmentedControl;
    [segmentedControl setFrame:CGRectMake(_segmentedControl.frame.origin.x, (_navBar.frame.size.height - _segmentedControl.frame.size.height) - 7, _segmentedControl.frame.size.width, _segmentedControl.frame.size.height)];
    [_navBar addSubview:segmentedControl];
    
    // Construir el arreglo de modelos y letras para las placas
    // Creamos el arreglo de letras
    NSMutableArray *mutArrLetras = [[NSMutableArray alloc] initWithCapacity:0];
    for (char c='A'; c <= 'Z'; c++) {
        [mutArrLetras addObject:[NSString stringWithFormat:@"%c", c]];
    }
    _arrLetras = [mutArrLetras copy];
    
    // Creamos el arreglo de modelos
    NSMutableArray *mutArrModelos = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger modelo=kMODELO_MAX; modelo >= kMODELO_MIN; modelo--) {
        [mutArrModelos addObject:[NSString stringWithFormat:@"%d", modelo]];
    }
    _arrModelos = [mutArrModelos copy];
    
    // Edicion de placas primero
    _editandoPlacas = YES;
    
    // Seleccionamos el tipo 'Particular' y recargamos el pickerView
    _tipoVehiculoSeleccionado = tipoVehiculoParticular;
    _columnsForPickerView = 6;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    _navBar = nil;
    _segmentedControl = nil;
    _pickerView = nil;
    _labelPlacas = nil;
    _labelModelo = nil;
    _labelIndicadorPlacas = nil;
    _labelIndicadorModelo = nil;
    _cancelButton = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)cancelButtonPressed:(id)sender
{
    // Pedir al delegado que nos quite de aqui
    if ([_delegate respondsToSelector:@selector(ingresaDatosDismissViewController)]) {
        [_delegate ingresaDatosDismissViewController];
    }
}

- (IBAction)seleccionarTipoAuto:(id)sender
{
    if ([sender respondsToSelector:@selector(selectedSegmentIndex)]) {
        
        NSUInteger selectedIndex = [sender selectedSegmentIndex];
        switch (selectedIndex) {
            case 0:     // Particular
                _tipoVehiculoSeleccionado = tipoVehiculoParticular;
                break;
                
            case 1:     // Publico
                _tipoVehiculoSeleccionado = tipoVehiculoPublico;
                break;
                
            case 2:     // Moto
                _tipoVehiculoSeleccionado = tipoVehiculoMoto;
                break;
                
            case 3:     // De carga
                _tipoVehiculoSeleccionado = tipoVehiculoDeCarga;
                break;
                
            default:
                break;
        }
        
        // Recargar columnas del UIPickerView
        [self cargarPickerViewConDatosVehicularesTipo:_tipoVehiculoSeleccionado];
    }
}


- (void)animateAndReloadPickerView
{
    CGRect framePickerViewVisible = _pickerView.frame;
    CGRect framePickerViewHidden = CGRectMake(0, self.view.frame.size.height, _pickerView.frame.size.width, _pickerView.frame.size.height);
    
    // Desaparecer el picker View
    [UIView animateWithDuration:0.2f
                          delay:0.0f 
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         _pickerView.frame = framePickerViewHidden;
                         
                     } completion:^(BOOL finished) {
                         if (finished) {
                             
                             // borrar las etiquetas de 'placas' y 'modelo'
                             [_labelPlacas setText:@""];
                             [_labelModelo setText:@""];
                             
                             // Comenzar con la edicion de las placas
                             [self performSelectorOnMainThread:@selector(iniciaEdicionPlacas:) 
                                                    withObject:self 
                                                 waitUntilDone:YES];
                             
                             // Aparecer el picker View
                             [UIView animateWithDuration:0.4f 
                                                   delay:0.1f 
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{
                                                  
                                                  _pickerView.frame = framePickerViewVisible;
                                                  
                                              } completion:^(BOOL finished) {
                                                  // --- 
                                              }];
                         }
                     }];
}


- (IBAction)iniciaEdicionPlacas:(id)sender
{
    // No llamar el metodo si el boton es presionado consecutivamente
    if ([sender isKindOfClass:[UIButton class]] && _lastSender == sender) return;
    _lastSender = sender;
    
    // Establecer la bandera de edicion de placas solo si aun no esta establecida
    _editandoPlacas = YES;
    
    // Mostrar que se esta animando esta etiqueta,con la fuente bold
    [_labelIndicadorPlacas setFont:[UIFont boldSystemFontOfSize:19.0f]];
    [_labelIndicadorModelo setFont:[UIFont systemFontOfSize:17.0f]];
    
    // Recargar el picker view
    [_pickerView setNeedsLayout];
    
    // En caso de que la etiqueta de placas tenga texto, cargaremos el pickerView con esos datos
    [self loadPickerViewComponentsFromString:_labelPlacas.text];
}


- (IBAction)iniciaEdicionModelo:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]] && _lastSender == sender) return;
    _lastSender = sender;
    
    // Establecer la bandera de edicion de modelo solo si aun no esta establecida
    _editandoPlacas = NO;
    
    // Recargar el picker view
    [_pickerView setNeedsLayout];

    // En caso de que la etiqueta 'Modelo' tenga texto, cargamos el pickerView con esos datos
    [self loadPickerViewComponentsFromString:_labelModelo.text];
}


- (void)actualizarLabelEnEdicionConStr:(NSString *)str
{
    // Verificar que etiqueta es la que vamos a actualizar con la cadena del argumento
    if (_editandoPlacas) {
        [_labelPlacas setText:str];
    } else {
        [_labelModelo setText:str];
    }
}


- (void)cargarPickerViewConDatosVehicularesTipo:(TipoVehiculoSeleccionado)tipoVehiculo
{    
    switch (tipoVehiculo) {
            
        case tipoVehiculoParticular:
            _columnsForPickerView = 6;
            break;
            
        case tipoVehiculoParticularDelEstado:
            _columnsForPickerView = 7;
            break;
            
        case tipoVehiculoParticularAntiguo:
            _columnsForPickerView = 5;
            break;
            
        case tipoVehiculoParticularParaDiscapacitados:
            _columnsForPickerView = 5;
            break;
            
        case tipoVehiculoPublico:  
        case tipoVehiculoPublicoTaxi:
            _columnsForPickerView = 6;
            break;
            
        case tipoVehiculoMoto:
            _columnsForPickerView = 5;
            break;
            
        case tipoVehiculoDeCarga:
            _columnsForPickerView = 6;
            break;
            
        case tipoVehiculoPublicoMicrobus:
            _columnsForPickerView = 7;
            break;
            
        default:
            abort();
            break;
    }
    
    // Recargar el picker view
    [self animateAndReloadPickerView];
}


#pragma mark - UIPickerView DataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSInteger numberComponents = 1;
    
    if (_editandoPlacas) {
        numberComponents = _columnsForPickerView;
    }
    
    // NSLog(@"calculando number of components: %d", numberComponents);
    
    return numberComponents;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    // NSLog(@"numero de filas para componente: %d", component);
    
    NSInteger numberRows = 0;
    
    if (_editandoPlacas) {
        switch (_tipoVehiculoSeleccionado) {
                
            case tipoVehiculoParticular:
            {
                // Los tres primeros digitos son numero
                if (component < 3) {
                    numberRows = 10;
                } else {
                    numberRows = [_arrLetras count];
                }
            }
                break;
                
            case tipoVehiculoParticularDelEstado:
            {
                // Los 3 primeros digitos son letras
                if (component < 3) { 
                    numberRows = [_arrLetras count];
                } else {
                    numberRows = 10;   
                }
            }
                break;
                
            case tipoVehiculoParticularAntiguo:
            {
                // Los dos primeros digitos son letra
                if (component < 2) {
                    numberRows = [_arrLetras count];
                } else {
                    numberRows = 10;
                }
            }
                break;
                
            case tipoVehiculoPublico:
            case tipoVehiculoPublicoTaxi:
            {
                // Solo el primero es letra
                if (component < 1) {
                    numberRows = [_arrLetras count];
                } else {
                    numberRows = 10;
                }
            }
                break;
                
                
            case tipoVehiculoMoto:   
            {
                // Los 4 primeros digitos son numero
                if (component < 4) {
                    numberRows = 10;
                } else {
                    numberRows = [_arrLetras count];
                } 
                
            }    
                break;
                
            case tipoVehiculoDeCarga:
            {
                // Los 4 primeros digitos son numero
                if (component < 4) {
                    numberRows = 10;
                } else {
                    numberRows = [_arrLetras count];
                }
            }
                break;
                
            default:
                break;
        }
    } else {
        // Numero de modelos disponibles
        numberRows = [_arrModelos count];
    }
    
    return numberRows;
}


- (IBAction)entrarModoEdicion:(id)sender
{
    UIButton *botonEdicion = (UIButton *)sender;
    NSInteger tagOfSender = [botonEdicion tag];
    switch (tagOfSender) {
        case 1:     // Boton de edicion de 'placas'
            [_labelIndicadorPlacas setFont:[UIFont boldSystemFontOfSize:19.0f]];
            [_labelIndicadorModelo setFont:[UIFont systemFontOfSize:17.0f]];
            break;
            
        case 2:     // Boton de edcion de 'modelo'
            [_labelIndicadorModelo setFont:[UIFont boldSystemFontOfSize:19.0f]];
            [_labelIndicadorPlacas setFont:[UIFont systemFontOfSize:17.0f]];
            break;
            
        default:
            break;
    }
    
    [_labelPlacas setNeedsLayout];
    [_labelModelo setNeedsLayout];
}


- (IBAction)usarButton:(id)sender
{
    // Verificar que existan valores en las etiquetas de 'placas' y 'modelo'
    if ([_labelPlacas.text isEqualToString:@""] || [_labelModelo.text isEqualToString:@""]) {
        // Mostramos una alerta
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aun faltan datos" 
                                                        message:@"Por favor ingresa las placas y modelo de tu auto"
                                                       delegate:nil
                                              cancelButtonTitle:@"Aceptar" 
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        // Guardar los datos en el NSUserDefaults
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:_labelPlacas.text forKey:@"Placas"];
        [userDefaults setValue:_labelModelo.text forKey:@"Modelo"];
        
        // Mostramos una alerta
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Datos Completos" 
                                                        message:@"Descargando información de tu auto"
                                                       delegate:self
                                              cancelButtonTitle:@"Aceptar" 
                                              otherButtonTitles:nil];
        [alert show];
        
        UIButton *alertButton = (UIButton *)[alert viewWithTag:1];
        [alertButton setHidden:YES];
        
        // Agregamos un ActivityIndicator a la alerta
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicatorView setCenter:CGPointMake(alert.frame.size.width/2 - activityIndicatorView.frame.size.width/2, alert.frame.size.height - activityIndicatorView.frame.size.height - 20)];
        [activityIndicatorView setHidesWhenStopped:YES];
        [activityIndicatorView startAnimating];
        [alert addSubview:activityIndicatorView];
        
        // Comenzamos la conexion con el servidor para obtener la info necesaria dadas las placas
        NSURL *urlWS = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kURL_CAOS_PLACAS, _labelPlacas.text]];
        AsyncFileDownloader *asyncFileDownloader = [[AsyncFileDownloader alloc] initWithURL:urlWS];
        
        // Especificamos la accion a tomar con el resultado de la descarga de datos
        [asyncFileDownloader setFileDownloaderCompletionBlock:^(BOOL finished, NSData *datosDescargados){    
            if (finished) 
            {
                // Mostramos una alerta de exito  
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert setTitle:@"¡¡ Excelente !!"];
                    [alert setMessage:@"Los datos de tu auto han sido descargados"];
                    [activityIndicatorView stopAnimating];
                    [alertButton setHidden:NO];
                });
                
                // Manejo de datos descargados
                id container = [JSONDataSerializator serializeData:datosDescargados];
                [self performSelectorOnMainThread:@selector(manageDownloadedData:) 
                                       withObject:container 
                                    waitUntilDone:NO];
            } 
            else 
            {
                // Mostramos una alerta de error de descarga
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert setTitle:@"Grrrrrrrr :\\"];
                    [alert setMessage:@"No se ha podido descargar información. ¿Intentas más tarde?"];
                    [activityIndicatorView stopAnimating];
                    [alertButton setHidden:NO];
                });
            }
        }];
    }
}

- (void)manageDownloadedData:(id)data
{
    if ([data isKindOfClass:[NSDictionary class]]) 
    {
        // Se van a guardar datos nuevos, borraremos los anteriores
        [CoreDataObjectManager removeObjectsForEntityName:@"Multa"];
        
        NSDictionary *diccMultas = [(NSDictionary *)data objectForKey:@"multas"];
        NSArray *arrMultas = [diccMultas objectForKey:@"multa"];
        
        // Para cada multa obtenida
        NSMutableArray *arrObjetos = [[NSMutableArray alloc] initWithCapacity:[arrMultas count]];
        
        for (NSDictionary *multa in arrMultas) 
        {
            NSMutableDictionary *diccAttributes = [[NSMutableDictionary alloc] initWithCapacity:0];
            
            // TODO: construir una fecha a partir de una cadna
            [diccAttributes setValue:( [NSDate date]/*[multa valueForKey:@"fecha"]*/ ) forKey:@"fecha_infraccion"];
            
            [diccAttributes setValue:[multa valueForKey:@"fundamento"] forKey:@"fundamento"];
            [diccAttributes setValue:[multa valueForKey:@"motivo"] forKey:@"motivo"];
            [diccAttributes setValue:[multa valueForKey:@"multa_id"] forKey:@"folio"];
            
            [diccAttributes setValue:( [NSNumber numberWithInt:( [[multa valueForKey:@"sancion"] intValue] )] ) forKey:@"sancion"];
            [diccAttributes setValue:( [NSNumber numberWithInt:( [[multa valueForKey:@"situacion"] intValue] )] ) forKey:@"situacion"];
            
            // NSLog(@"%@", diccAttributes);
            
            [arrObjetos addObject:diccAttributes];
        }
        
        // NSLog(@"%@", arrObjetos);
        
        // Crear un objeto tipo 'Multa' en CoreData a partir de los atributos encontrados
        [CoreDataObjectManager addObjects:arrObjetos forEntityName:@"Multa"];
        
        arrObjetos = nil;
        arrMultas = nil;
        diccMultas = nil;
    }
    
    NSArray *arrObjs = [CoreDataObjectManager objectsForEntityName:@"Multa"];
    NSLog(@"%@", arrObjs);
}


- (void)loadPickerViewComponentsFromString:(NSString *)str
{
    // Si la cadena esta vacia, entonces todos los componentes de pickerView estaran en la posicion inicial
    if ([str isEqualToString:@""]) {
        for (int i = 0; i < [_pickerView numberOfComponents]; i++) {
            [_pickerView selectRow:0 inComponent:i animated:NO];
        }
    } else {
        
        // Si estamos editando las placas y ya hay una cadena en la etiqueta, cargamos el pickerView
        // con cada letra y numero de la cadena
        if (_editandoPlacas) {
            for (int i = 0; i < [str length]; i++) {
                const char charAtIndexFromStr = [str characterAtIndex:i];
                
                if (isnumber(charAtIndexFromStr)) {
                    // Seleccionamos el numero de fila indicada por el numero encontrado
                    [_pickerView selectRow:atoi(&charAtIndexFromStr) inComponent:i animated:YES];
                    
                } else if (isalpha(charAtIndexFromStr)) {
                    // Obtenemos la posicion de la letra y la seleccionamos
                    [_pickerView selectRow:(charAtIndexFromStr - 'A') inComponent:i animated:YES];
                }
            }
        } else {
            // Estamos editando la etiqueta 'Modelo', por lo tanto debemos cargar el modelo
            [_pickerView selectRow:( kMODELO_MAX - atoi([str UTF8String]) ) inComponent:0 animated:YES];
        }
        
    }
}


#pragma mark - UIPickceView Delegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    // NSLog(@"creando vista para componente: %d y fila: %d", component, row);
    
    UIView *viewForRow = view;
    UILabel *labelForRow = nil;
    
    // Obtenemos el tamanio de cada vista dentro de cada fila en el pickerView
    CGSize sizeForRow = [_pickerView rowSizeForComponent:component];
    
    if (!viewForRow) {
        
        // Construimos la vista de cada fila en el picker view
        viewForRow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sizeForRow.width, sizeForRow.height)];
        labelForRow = [[UILabel alloc] initWithFrame:viewForRow.frame];
        
        // Configurar atributos de la etiqueta
        [labelForRow setTag:100];
        [labelForRow setTextAlignment:UITextAlignmentCenter];
        [labelForRow setBackgroundColor:[UIColor clearColor]];
        [labelForRow setFont:[UIFont boldSystemFontOfSize:24.0f]];
        
        [labelForRow setText:[_arrModelos objectAtIndex:row]];
        
        // Agregar la etiqueta a la vista
        [viewForRow addSubview:labelForRow];
        
    } else {
    
        // Apuntar a la etiqueta dentro de la vista de cada row en el pickerView
        labelForRow = (UILabel *)[viewForRow viewWithTag:100];
    }
        

    if (_editandoPlacas) {
        switch (_tipoVehiculoSeleccionado) {
                
            case tipoVehiculoParticular:
            {
                // Los tres primero digitos son numero
                if (component < 3) {
                    [labelForRow setText:[NSString stringWithFormat:@"%d", row]];
                } else {
                    [labelForRow setText:[NSString stringWithFormat:@"%@", [_arrLetras objectAtIndex:row]]];
                }
            }
                break;
                
            case tipoVehiculoParticularDelEstado:
            {
                // Los tres primero digitos son letra
                if (component < 3) {
                    [labelForRow setText:[NSString stringWithFormat:@"%d", row]];
                } else {
                    [labelForRow setText:[NSString stringWithFormat:@"%@", [_arrLetras objectAtIndex:row]]];
                }
            }
                break;
                
            case tipoVehiculoParticularAntiguo:
            {
                // Los dos primero digitos son letras
                if (component < 2) {
                    [labelForRow setText:[NSString stringWithFormat:@"%d", row]];
                } else {
                    [labelForRow setText:[NSString stringWithFormat:@"%@", [_arrLetras objectAtIndex:row]]];
                }
            }
                break;
                
            case tipoVehiculoParticularParaDiscapacitados:
            {
                // Los tres primeros digitos son numero
                if (component < 3) {
                    [labelForRow setText:[NSString stringWithFormat:@"%d", row]];
                } else {
                    [labelForRow setText:[NSString stringWithFormat:@"%@", [_arrLetras objectAtIndex:row]]];
                }
            }
                break;
                
                
            case tipoVehiculoPublico:
            case tipoVehiculoPublicoTaxi:
            {
                // Solo el primer digito es letra
                if (component < 1) {
                    [labelForRow setText:[NSString stringWithFormat:@"%@", [_arrLetras objectAtIndex:row]]];
                } else {
                    [labelForRow setText:[NSString stringWithFormat:@"%d", row]];
                }
            }  
                break;
                
                
            case tipoVehiculoMoto:
            {
                // Los 4 primeros digitos son numero
                if (component < 4) {
                    [labelForRow setText:[NSString stringWithFormat:@"%d", row]];
                } else {
                    [labelForRow setText:[NSString stringWithFormat:@"%@", [_arrLetras objectAtIndex:row]]];
                }
            }
                break;
                
            case tipoVehiculoDeCarga:
            {
                // Los 4 primeros digitos son numero
                if (component < 4) {
                    [labelForRow setText:[NSString stringWithFormat:@"%d", row]];
                } else {
                    [labelForRow setText:[NSString stringWithFormat:@"%@", [_arrLetras objectAtIndex:row]]];
                }
            }
                break;
                
            default:
                break;
        }
        
    } else {
        NSInteger modelo = [[_arrModelos objectAtIndex:row] integerValue];
        [labelForRow setText:[NSString stringWithFormat:@"%d", modelo]];
    }
    
    return viewForRow;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // Creamos una cadena mutable que contendra la cadena actual seleccionada en el pickerView
    NSMutableString *mutableString = [[NSMutableString alloc] initWithCapacity:[pickerView numberOfComponents]];
    
    // Obtener todos los caracteres seleccionados actualmente en el pickerView
    for (NSInteger componentIndex = 0; componentIndex < [pickerView numberOfComponents]; componentIndex++) {
        
        UIView *viewForRow = [pickerView viewForRow:[pickerView selectedRowInComponent:componentIndex] forComponent:componentIndex];
        UILabel *titleLabel = [[viewForRow subviews] lastObject];
        NSString *characterSeleccionado = [titleLabel text];
        
        [mutableString appendString:[NSString stringWithFormat:@"%@", characterSeleccionado]];
    }
    
    // Actulizar la etiqueta seleccionada para su edicion
    [self actualizarLabelEnEdicionConStr:mutableString];
}


- (void)makeViewForBackgroundOf:(UIPickerView *)pickerView
{
    UIView *viewbg = [[UIView alloc] initWithFrame:pickerView.frame];
    [viewbg setBackgroundColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]];
    
    [self.view addSubview:viewbg];
    [self.view sendSubviewToBack:viewbg];
}

#pragma mark AlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self performSelector:@selector(cancelButtonPressed:) withObject:self afterDelay:0.1f];
}

@end
