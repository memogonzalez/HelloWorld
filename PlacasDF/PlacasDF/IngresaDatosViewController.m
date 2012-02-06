//
//  IngresaDatosViewController.m
//  PlacasDF
//
//  Created by David Hernández on 1/29/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "IngresaDatosViewController.h"

#define kMODELO_MIN     1960
#define kMODELO_MAX     2012            // TODO: Calcular el anio actual chavo

@interface IngresaDatosViewController ()
// Propiedades del 'picker View' para mostrar los datos correspondientes al tipo de vehiculo
@property (assign, nonatomic) NSUInteger numeroColumnas;
@property (strong, nonatomic) NSArray *arrNumeros;
@property (strong, nonatomic) NSArray *arrLetras;
@property (strong, nonatomic) NSArray *arrModelos;      // Arreglo de anios
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Identificar el indice seleccionado al aparecer la vista
    UISegmentedControl *sc = [[UISegmentedControl alloc] init];
    [self seleccionarVehiculo:sc];
    
    // Llenamos los arreglos de numeros y letras
//    NSMutableArray *mutArrNums = [[NSMutableArray alloc] initWithCapacity:0];
//    for (int i=0; i<10; i++) {
//        [mutArrNums addObject:[NSNumber numberWithInt:i]];
//    }
//    _arrNumeros = [mutArrNums copy];
    
    NSMutableArray *mutArrLetras = [[NSMutableArray alloc] initWithCapacity:0];
    for (char c='A'; c <= 'Z'; c++) {
        [mutArrLetras addObject:[NSString stringWithFormat:@"%c", c]];
    }
    _arrLetras = [mutArrLetras copy];
    
    // Creamos el arreglo de modelos
    NSMutableArray *mutArrModelos = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger modelo=kMODELO_MIN; modelo <= kMODELO_MAX; modelo++) {
        [mutArrModelos addObject:[NSString stringWithFormat:@"%d", modelo]];
    }
    _arrModelos = [mutArrModelos copy];
    
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

// El metodo que se llama al presionar el boton de caracteristicas
// para determinar mas informacion del tipo de auto seleccionado
- (IBAction)mostrarCaracteristicasVehiculo:(id)sender
{
    NSLog(@"mostrar caracteristicas");
    
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
            
            case -1:        /* En caso de que aun no exista el uiSegmentedControl */
            case 0:         /* Forzamos que se elija la primera opcion */
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
        
        // Recargar los datos del 'picker View' respecto al tipo de vehiculo seleccionado
        [self cargarPickerViewConDatosVehicularesTipo:_tipoVehiculoSeleccionado];
    }
}

- (IBAction)buscar:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)ingresarPlacas:(id)sender
{
    NSLog(@"ingresar placas");
    // Volvemos a indicar el indice del uisegmentedcontrol actualmente seleccionado
    [self seleccionarVehiculo:_segmentedControl];
}

- (IBAction)ingresarModelo:(id)sender
{
    NSLog(@"ingresar modelo");
    [self cargarPickerViewConDatosVehicularesTipo:kModeloVehiculo];
}


// Este metodo sirve para determinar el numero de columnas necesarias para mostrar la info de placas
// segun el tipo de auto seleccionado
- (void)cargarPickerViewConDatosVehicularesTipo:(kTipoVehiculoSeleccionado)tipoVehiculo
{
    switch (tipoVehiculo) {
            
        case kModeloVehiculo:
            _tipoVehiculoSeleccionado = kModeloVehiculo;
            _numeroColumnas = 1;        // Solo desplegara una columna, la de anios disponibles
            break;
            
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
            
        case kTipoVehiculoPublico:  case kTipoVehiculoPublicoTaxi:
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
}

- (void)mostrarBotonCaracteristicas:(BOOL)mostrar
{
    // Animacion para mostrar / ocultar el boton de 'caracteristicas'
    if (mostrar) {
        
    } else {
        
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
    
    switch (_tipoVehiculoSeleccionado) {
            
        case kModeloVehiculo:
            // Numero de modelos disponibles
            numberRows = [_arrModelos count];
            break;
            
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
            // NSLog(@"%d", _tipoVehiculoSeleccionado);
            break;
    }
    
    return numberRows;
}

#pragma mark - Picker View DataSource
// TODO: Crear los UIViews para mostrar las etiquetas con mejor formato, centradas, etc.
//
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//    
//}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *strLetra = nil;
    
    switch (_tipoVehiculoSeleccionado) {
            
        case kModeloVehiculo:
        {
            NSInteger modelo = [[_arrModelos objectAtIndex:row] integerValue];
            strLetra = [NSString stringWithFormat:@"%d", modelo];
        }
            break;
            
        case kTipoVehiculoParticular:
        {
            // Los tres primero digitos son numero
            if (component < 3) {
                strLetra = [NSString stringWithFormat:@"%d", row];
            } else {
                strLetra = [_arrLetras objectAtIndex:row];
            }
        }
            break;
            
        case kTipoVehiculoParticularDelEstado:
        {
            // Los tres primero digitos son letra
            if (component < 3) {
                strLetra = [_arrLetras objectAtIndex:row];
            } else {
                strLetra = [NSString stringWithFormat:@"%d", row];
            }
        }
            break;
            
        case kTipoVehiculoParticularAntiguo:
        {
            // Los dos primero digitos son letras
            if (component < 2) {
                strLetra = [_arrLetras objectAtIndex:row];
            } else {
                strLetra = [NSString stringWithFormat:@"%d", row];
            }
        }
            break;
            
        case kTipoVehiculoParticularParaDiscapacitados:
        {
            // Los tres primero digitos son numero
            if (component < 3) {
                strLetra = [NSString stringWithFormat:@"%d", row];
            } else {
                strLetra = [_arrLetras objectAtIndex:row];
            }
        }
            break;
            
            
        case kTipoVehiculoPublico:      case kTipoVehiculoPublicoTaxi:
        {
            // Solo el primer digito es numero
            if (component < 1) {
                strLetra = [_arrLetras objectAtIndex:row];
            } else {
                strLetra = [NSString stringWithFormat:@"%d", row];
            }
        }  
            break;
            
            
        case kTipoVehiculoMoto:
        {
            // Los 4 primeros digitos son numero
            if (component < 4) {
                strLetra = [NSString stringWithFormat:@"%d", row];
            } else {
                strLetra = [_arrLetras objectAtIndex:row];
            }
        }
            break;
            
        case kTipoVehiculoDeCarga:
        {
            // Los 4 primeros digitos son numero
            if (component < 4) {
                strLetra = [NSString stringWithFormat:@"%d", row];
            } else {
                strLetra = [_arrLetras objectAtIndex:row];
            }
        }
            break;
            
        default:
            // NSLog(@"%d", _tipoVehiculoSeleccionado);
            break;
    }
    
    return strLetra;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // TODO: Obtener el label del picker en cada row seleccionado
    NSMutableString *strPlaca = nil;
    for (NSInteger aComponent=0; aComponent < [pickerView numberOfComponents]; aComponent++) {
        for (NSInteger aRow=0; aRow < [pickerView numberOfRowsInComponent:aComponent]; aRow++) {
            UIView *viewSeleecionada = [pickerView viewForRow:aRow forComponent:aComponent];
            NSLog(@"%@", viewSeleecionada);
        }
    }
}

- (void)actualizarPlacaConStr:(NSString *)strPlaca
{
    // Actulizar la etiqueta que muestra la placa
    [_labelPlacasSeleccionadas setText:strPlaca];
}

@end
