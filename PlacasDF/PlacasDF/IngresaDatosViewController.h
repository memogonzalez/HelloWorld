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
    
    kTipoVehiculoParticular = 0,
    kTipoVehiculoMoto,
    kTipoVehiculoPublico,
    kTipoVehiculoDeCarga
    
}kTipoVehiculoSeleccionado;

@interface IngresaDatosViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;

@property (strong, nonatomic) IBOutlet UILabel *labelPlacasSeleccionadas;

@property (strong, nonatomic) IBOutlet UILabel *labelModeloSeleccionado;

@property (assign, nonatomic) kTipoVehiculoSeleccionado tipoVehiculoSeleccionado;

- (IBAction)seleccionarVehiculo:(id)sender;

- (IBAction)ingresarPlacas:(id)sender;

- (IBAction)ingresarModelo:(id)sender;

- (IBAction)buscar:(id)sender;

- (void)cargarPickerViewConDatosVehicularesTipo:(kTipoVehiculoSeleccionado)tipoVehiculo;

@end
