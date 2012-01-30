//
//  IngresaDatosViewController.m
//  PlacasDF
//
//  Created by David Hernández on 1/29/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "IngresaDatosViewController.h"

@interface IngresaDatosViewController ()
// Propiedades del 'picker View' para mostrar los datos correspondientes al tipo de vehiculo
@property (assign, nonatomic) NSUInteger numeroColumnas;
@property (strong, nonatomic) NSArray *arrNumeros;
@property (strong, nonatomic) NSArray *arrLetras;
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

- (IBAction)seleccionarVehiculo:(id)sender
{
    // Identificar al sender
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        
        // Obtener el indice seleccionado
        UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
        NSUInteger indiceSeleccionado = [segmentedControl selectedSegmentIndex];
        
        switch (indiceSeleccionado) {
            
            case -1:        /* En caso de que aun no exista el uiSegmentedControl */
            case 0:
                _tipoVehiculoSeleccionado = kTipoVehiculoParticular;
                break;
        
            case 1:
                _tipoVehiculoSeleccionado = kTipoVehiculoMoto;
                break;
                
            case 2:
                _tipoVehiculoSeleccionado = kTipoVehiculoPublico;
                break;
                
            case 3:
                _tipoVehiculoSeleccionado = kTipoVehiculoDeCarga;
                break;
                
            default:
                NSLog(@"indice: %d", indiceSeleccionado);
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
}

- (IBAction)ingresarModelo:(id)sender
{
    NSLog(@"ingresar modelo");
}

- (void)cargarPickerViewConDatosVehicularesTipo:(kTipoVehiculoSeleccionado)tipoVehiculo
{
    switch (tipoVehiculo) {
            
        case kTipoVehiculoParticular:
            _numeroColumnas = 6;
            break;
            
        case kTipoVehiculoMoto:
            _numeroColumnas = 5;
            break;
            
        case kTipoVehiculoPublico:
            _numeroColumnas = 7;
            break;
            
        case kTipoVehiculoDeCarga:
            _numeroColumnas = 5;
            break;
            
        default:
            break;
    }
    
    // Mandar a recargar el 'picker view'
    [_pickerView reloadAllComponents];
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
        case kTipoVehiculoParticular:
        {
            // Los tres primero digitos son numero
            if (component < 3) {
                numberRows = 10;
            } else {
                numberRows = [_arrLetras count];
            }
        }
            break;
            
        default:
            NSLog(@"%d", _tipoVehiculoSeleccionado);
            break;
    }
    
    return numberRows;
}

#pragma mark - Picker View DataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *strLetra = nil;
    
    switch (_tipoVehiculoSeleccionado) {
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
            
        default:
            NSLog(@"%d", _tipoVehiculoSeleccionado);
            break;
    }
    
    return strLetra;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

@end
