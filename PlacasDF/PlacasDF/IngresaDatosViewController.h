//
//  IngresaDatosViewController.h
//  PlacasDF
//
//  Created by David Hernández on 1/29/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
 
/* Enumeracion para identificar el tipo de vehiculo seleccionado */
typedef enum {
    
    kModeloVehiculo = -100, /* Indica que se debe mostrar la lista de modelos de auto */
    kTipoVehiculoParticular = 0,
    kTipoVehiculoPublico,
    kTipoVehiculoMoto,
    kTipoVehiculoDeCarga,
    kTipoVehiculoParticularDelEstado = 100,             /* Vehiculos Particulares con placas del Edo. de Mexico */
    kTipoVehiculoParticularParaDiscapacitados = 200,    /* Vehiculos Particulares para Discapacitados */
    kTipoVehiculoParticularAntiguo = 300,               /* Vehiculos Particulares Antiguos de mas de 8 anios */
    kTipoVehiculoPublicoTaxi = 1000,                    /* Vehiculo Publico Tipo Taxi */
    kTipoVehiculoPublicoMicrobus = 2000                 /* Vehiculo Publico Tipo Microbus */

}kTipoVehiculoSeleccionado;

@interface IngresaDatosViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;

@property (strong, nonatomic) IBOutlet UILabel *labelPlacasSeleccionadas;

@property (strong, nonatomic) IBOutlet UILabel *labelModeloSeleccionado;

@property (strong, nonatomic) IBOutlet UIButton *botonCaracteristicas;

@property (strong, nonatomic) IBOutlet UIButton *botonSeleccionar;

@property (assign, nonatomic) kTipoVehiculoSeleccionado tipoVehiculoSeleccionado;

- (IBAction)seleccionarVehiculo:(id)sender;

- (IBAction)mostrarCaracteristicasVehiculo:(id)sender;

- (IBAction)ingresarPlacas:(id)sender;

- (IBAction)ingresarModelo:(id)sender;

- (IBAction)buscar:(id)sender;

- (void)cargarPickerViewConDatosVehicularesTipo:(kTipoVehiculoSeleccionado)tipoVehiculo;

// Metodo para mostrar la cadena con la 'placa' seleccionada
- (void)actualizarPlacaConStr:(NSString *)strPlaca;

// Metodo para mostrar la cadena con el modelo seleccionado
- (void)actualizarModeloConStr:(NSString *)strModelo;

// Metodo de Animaciones para esconder o mostrar el botono de Caracteristicas cuando sea pertinente
- (void)mostrarBotonCaracteristicas:(BOOL)mostrar;

@end
