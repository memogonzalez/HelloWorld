//
//  IngresaDatosViewController.m
//  PlacasDF
//
//  Created by David Hernández on 1/29/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "IngresaDatosViewController.h"
#import "SettingsPlacas.h"

#define kMODELO_MIN     1970
#define kMODELO_MAX     2012            // TODO: Calcular el anio actual chavo

@interface IngresaDatosViewController ()

// Propiedades del 'picker View' para mostrar los datos correspondientes al tipo de vehiculo
@property (assign, nonatomic) NSUInteger numeroColumnas;
@property (strong, nonatomic) NSArray *arrNumeros;
@property (strong, nonatomic) NSArray *arrLetras;       // Arreglo de letras para contruir las placas
@property (strong, nonatomic) NSArray *arrModelos;      // Arreglo de anios

/**
 *  Informacion guardada previamente
 */
@property (strong, nonatomic) SettingsPlacas *settingsPlacas;

/**
 *  Bandera que indica si hay que actualizar la etiqueta de placas o de modelo
 */
@property (assign, nonatomic) BOOL actualizarPlacas;

/**
 *  Metodo que obtiene los datos a mostrar en la vista en caso de haber guardados previamente
 */
- (SettingsPlacas *)informacionSettingsPlacasTipoVehiculo:(NSNumber *)numTipoVehiculo;

/**
 *  Metodo de recarga el pickerView con modelos de auto
 */
- (void)cargarPickerViewConDatosDeModelosDeAuto;

/**
 *  Metodo que limpia las etiquetas de placas y modelo
 */
- (void)limpiaLabelsPlacaModelo;

@end

@implementation IngresaDatosViewController

@synthesize segmentedControl = _segmentedControl;
@synthesize pickerView = _pickerView;
@synthesize labelPlacasSeleccionadas = _labelPlacasSeleccionadas;
@synthesize labelModeloSeleccionado = _labelModeloSeleccionado;
@synthesize tipoVehiculoSeleccionado = _tipoVehiculoSeleccionado;
@synthesize numeroColumnas = _numeroColumnas;
@synthesize arrNumeros = _arrNumeros;
@synthesize arrLetras = _arrLetras;
@synthesize arrModelos = _arrModelos;
@synthesize botonSeleccionar = _botonSeleccionar;
@synthesize botonCaracteristicas = _botonCaracteristicas;
@synthesize actualizarPlacas = _actualizarPlacas;
@synthesize settingsPlacas = _settingsPlacas;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    // Seleccionar el tipo de vehiculo 'Particular'
    [self seleccionarVehiculo:_segmentedControl];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancelar:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// El metodo que se llama al presionar el boton de caracteristicas
// para determinar mas informacion del tipo de auto seleccionado
- (IBAction)mostrarCaracteristicasVehiculo:(id)sender
{
    // Determinamos el tipo de vehiculo seleccionado desde el uisegmentedcontrol
    switch ([_segmentedControl selectedSegmentIndex]) {
            
        case kTipoVehiculoParticular:
            // Mostramos las vista de seleccion de caracteristicas para auto particular
            [self performSegueWithIdentifier:@"caracteristicas_particular" sender:self];
            break;
            
        case kTipoVehiculoPublico:
            // Mostramos las vista de seleccion de caracteristicas para auto publico: taxi o micro
            [self performSegueWithIdentifier:@"caracteristicas_publico" sender:self];
            break;
            
        default:
            break;
    }
}

- (IBAction)seleccionarVehiculo:(id)sender
{
    // Identificar al sender
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        
        // Obtener el indice seleccionado
        UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
        NSUInteger indiceSeleccionado = [segmentedControl selectedSegmentIndex];

        switch (indiceSeleccionado) {
            
            case 0:
                _tipoVehiculoSeleccionado = kTipoVehiculoParticular;
                [self mostrarBotonCaracteristicas:YES];
                break;
        
            case 1:
                _tipoVehiculoSeleccionado = kTipoVehiculoPublico;
                [self mostrarBotonCaracteristicas:YES];
                break;
                
            case 2:
                _tipoVehiculoSeleccionado = kTipoVehiculoMoto;
                [self mostrarBotonCaracteristicas:NO];
                break;
                
            case 3:
                _tipoVehiculoSeleccionado = kTipoVehiculoDeCarga;
                [self mostrarBotonCaracteristicas:NO];
                break;
                                
            default:
                // NSLog(@"indice: %d", indiceSeleccionado);
                break;
        }
        
        // limpiar las etiquetas
        [self limpiaLabelsPlacaModelo];
        
        // Seleccionar el modo de edicion de la etiqueta 'placas'
        [self ingresarPlacas:self];
    } 
}

- (IBAction)buscar:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)ingresarPlacas:(id)sender
{
    // Cargar el pickerView con las columnas necesarias para el tipo de vehiculo seleccionado
    [self cargarPickerViewConDatosVehicularesTipo:_tipoVehiculoSeleccionado];
    
    // Bandera que indica que se actualizara la etiqueta de placas 
    _actualizarPlacas = YES;
    
    // En caso de que exista texto en la etiqueta de placas
    // Entonces, cargar el pickerView con los datos de la etiqueta
    if ([[_labelPlacasSeleccionadas text] isEqualToString:@""]) {
        
        
    } else {
        
    }

}

- (IBAction)ingresarModelo:(id)sender
{
    // Establecer la bandera para actualizar placas en falso
    // asi se actualizan la etiqueta de modelo
    _actualizarPlacas = NO;
    
    // Seleccionar 'Modelo' para mostrar el picker view con anios
    [self cargarPickerViewConDatosDeModelosDeAuto];
    
    if ([[_labelModeloSeleccionado text] isEqualToString:@""]) {
        
    } else {
        
    }
}


// Este metodo sirve para determinar el numero de columnas necesarias para mostrar la info de placas
// segun el tipo de auto seleccionado
- (void)cargarPickerViewConDatosVehicularesTipo:(kTipoVehiculoSeleccionado)tipoVehiculo
{    
    switch (tipoVehiculo) {
            
        case kTipoVehiculoParticular:
            _numeroColumnas = 6;
            break;
            
        case kTipoVehiculoParticularDelEstado:
            _numeroColumnas = 7;
            break;
        
        case kTipoVehiculoParticularAntiguo:
            _numeroColumnas = 5;
            break;
            
        case kTipoVehiculoParticularParaDiscapacitados:
            _numeroColumnas = 5;
            break;
            
        case kTipoVehiculoPublico:  
        case kTipoVehiculoPublicoTaxi:
            _numeroColumnas = 6;
            break;
            
        case kTipoVehiculoMoto:
            _numeroColumnas = 5;
            break;
            
        case kTipoVehiculoDeCarga:
            _numeroColumnas = 6;
            break;
        
        case kTipoVehiculoPublicoMicrobus:
            _numeroColumnas = 7;
            break;
            
        default:
            break;
    }
    
    // Mandar a recargar el 'picker view'
    [_pickerView reloadAllComponents];
    
//    for (NSInteger component = 0; component < [_pickerView numberOfComponents]; component++) {
//        NSLog(@"component: %d", component);
//        NSLog(@"val: %@", [[[[_pickerView viewForRow:[_pickerView selectedRowInComponent:component] forComponent:component] subviews] lastObject] text]);
//    }
}

- (void)cargarPickerViewConDatosDeModelosDeAuto
{
    _numeroColumnas = 1;        // Solo desplegara una columna, la de anios disponibles
    [_pickerView reloadAllComponents];
}

- (void)mostrarBotonCaracteristicas:(BOOL)mostrar
{
    // Animacion para mostrar / ocultar el boton de 'caracteristicas'
    if (mostrar) {
        [_botonCaracteristicas setHidden:NO];
    } else {
        [_botonCaracteristicas setHidden:YES];
    }
}

#pragma mark - Picker View Delegate

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return _numeroColumnas;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger numberRows = 0;
    
    if (_actualizarPlacas) {
        switch (_tipoVehiculoSeleccionado) {
                
            case kTipoVehiculoParticular:
            {
                // Los tres primeros digitos son numero
                if (component < 3) {
                    numberRows = 10;
                } else {
                    numberRows = [_arrLetras count];
                }
            }
                break;
                
            case kTipoVehiculoParticularDelEstado:
            {
                // Los 3 primeros digitos son letras
                if (component < 3) { 
                    numberRows = [_arrLetras count];
                } else {
                    numberRows = 10;   
                }
            }
                break;
                
            case kTipoVehiculoParticularAntiguo:
            {
                // Los dos primeros digitos son letra
                if (component < 2) {
                    numberRows = [_arrLetras count];
                } else {
                    numberRows = 10;
                }
            }
                break;
                
            case kTipoVehiculoPublico: case kTipoVehiculoPublicoTaxi:
            {
                // Solo el primero es letra
                if (component < 1) {
                    numberRows = [_arrLetras count];
                } else {
                    numberRows = 10;
                }
            }
                break;
                
                
            case kTipoVehiculoMoto:   
            {
                // Los 4 primeros digitos son numero
                if (component < 4) {
                    numberRows = 10;
                } else {
                    numberRows = [_arrLetras count];
                } 
                
            }    
                break;
                
            case kTipoVehiculoDeCarga:
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

#pragma mark - Picker View DataSource

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView *viewForRow = nil;
    
    // Obtenemos el tamanio de cada vista dentro de cada fila en el pickerView
    CGSize sizeForRow = [_pickerView rowSizeForComponent:component];
    
    // Construimos la vista de cada fila en el picker view
    viewForRow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sizeForRow.width, sizeForRow.height)];
    UILabel *labelForRow = [[UILabel alloc] initWithFrame:viewForRow.frame];

    // Configurar atributos de la etiqueta
    [labelForRow setTextAlignment:UITextAlignmentCenter];
    [labelForRow setBackgroundColor:[UIColor clearColor]];
    [labelForRow setFont:[UIFont boldSystemFontOfSize:25.0f]];
    
    [labelForRow setText:[_arrModelos objectAtIndex:row]];
    
    if (_actualizarPlacas) {
        switch (_tipoVehiculoSeleccionado) {
                
            case kTipoVehiculoParticular:
            {
                // Los tres primero digitos son numero
                if (component < 3) {
                    [labelForRow setText:[NSString stringWithFormat:@"%d", row]];
                } else {
                    [labelForRow setText:[NSString stringWithFormat:@"%@", [_arrLetras objectAtIndex:row]]];
                }
            }
                break;
                
            case kTipoVehiculoParticularDelEstado:
            {
                // Los tres primero digitos son letra
                if (component < 3) {
                    [labelForRow setText:[NSString stringWithFormat:@"%d", row]];
                } else {
                    [labelForRow setText:[NSString stringWithFormat:@"%@", [_arrLetras objectAtIndex:row]]];
                }
            }
                break;
                
            case kTipoVehiculoParticularAntiguo:
            {
                // Los dos primero digitos son letras
                if (component < 2) {
                    [labelForRow setText:[NSString stringWithFormat:@"%d", row]];
                } else {
                    [labelForRow setText:[NSString stringWithFormat:@"%@", [_arrLetras objectAtIndex:row]]];
                }
            }
                break;
                
            case kTipoVehiculoParticularParaDiscapacitados:
            {
                // Los tres primero digitos son numero
                if (component < 3) {
                    [labelForRow setText:[NSString stringWithFormat:@"%d", row]];
                } else {
                    [labelForRow setText:[NSString stringWithFormat:@"%@", [_arrLetras objectAtIndex:row]]];
                }
            }
                break;
                
                
            case kTipoVehiculoPublico:      case kTipoVehiculoPublicoTaxi:
            {
                // Solo el primer digito es numero
                if (component < 1) {
                    [labelForRow setText:[NSString stringWithFormat:@"%d", row]];
                } else {
                    [labelForRow setText:[NSString stringWithFormat:@"%@", [_arrLetras objectAtIndex:row]]];
                }
            }  
                break;
                
                
            case kTipoVehiculoMoto:
            {
                // Los 4 primeros digitos son numero
                if (component < 4) {
                    [labelForRow setText:[NSString stringWithFormat:@"%d", row]];
                } else {
                    [labelForRow setText:[NSString stringWithFormat:@"%@", [_arrLetras objectAtIndex:row]]];
                }
            }
                break;
                
            case kTipoVehiculoDeCarga:
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
    
    // Agregar la etiqueta a la vista
    [viewForRow addSubview:labelForRow];
    
    return viewForRow;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // Creamos una cadena mutable que contendra la cadena actual seleccionada en el pickerView
    NSMutableString *mutableString = [[NSMutableString alloc] initWithCapacity:[_pickerView numberOfComponents]];
    
    // Obtener todos los caracteres seleccionados actualmente en el pickerView
    for (NSInteger componentIndex = 0; componentIndex < [_pickerView numberOfComponents]; componentIndex++) {
        
        UIView *viewForRow = [_pickerView viewForRow:[_pickerView selectedRowInComponent:componentIndex] forComponent:componentIndex];
        UILabel *titleLabel = [[viewForRow subviews] lastObject];
        NSString *characterSeleccionado = [titleLabel text];
        
        [mutableString appendString:[NSString stringWithFormat:@"%@", characterSeleccionado]];
    }
    
    // Mandar actualizar la etiqueta correspondiente
    if (_actualizarPlacas) {
        [self actualizarPlacaConStr:mutableString];
    } else {
        [self actualizarModeloConStr:mutableString];
    }
}

- (void)actualizarPlacaConStr:(NSString *)strPlaca
{
    // Actualizar la etiqueta que muestra la placa
    [_labelPlacasSeleccionadas setText:strPlaca];
}

- (void)actualizarModeloConStr:(NSString *)strModelo
{
    // Actualizar la etiqueta que muestra el modelo
    [_labelModeloSeleccionado setText:strModelo];
}


- (SettingsPlacas *)informacionSettingsPlacasTipoVehiculo:(NSNumber *)numTipoVehiculo
{
    SettingsPlacas *settingsPlacas = nil;
    
    // Obtener el objeto guardado en caso de que exista previamente
    SettingsPlacas *sp = [[SettingsPlacas alloc] init];
    [sp setNumTipoVehiculo:[NSNumber numberWithInteger:kTipoVehiculoMoto]];
    [sp setStrPlacas:@"1760C"];
    [sp setStrModelo:@"2010"];
    [sp setDiccAttributes:nil];
    
    settingsPlacas = sp;
    
    return settingsPlacas;
}

- (void)limpiaLabelsPlacaModelo
{
    [_labelPlacasSeleccionadas setText:@""];
    [_labelModeloSeleccionado setText:@""];
}

@end
