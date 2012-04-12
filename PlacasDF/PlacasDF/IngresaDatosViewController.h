//
//  IngresarViewController.h
//  Placas
//
//  Created by David Hernández on 3/17/12.
//  Copyright (c) 2012 GoldenRatio Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IngresaDatosDelegate <NSObject>
/**
 *  Metodo para decir al delegado que nos quite de aqui
 */
- (void)ingresaDatosDismissViewController;

@end

@interface IngresaDatosViewController : UIViewController

/* Enumeracion para identificar el tipo de vehiculo seleccionado */
typedef enum TipoVehiculoSeleccionado
{
    tipoVehiculoParticular             =       1,
    tipoVehiculoPublico,
    tipoVehiculoMoto,
    tipoVehiculoDeCarga,
    tipoVehiculoParticularDelEstado    =       100,            /* Vehiculos Particulares con placas del Edo. de Mexico */
    tipoVehiculoParticularParaDiscapacitados = 200,            /* Vehiculos Particulares para Discapacitados */
    tipoVehiculoParticularAntiguo      =       300,            /* Vehiculos Particulares Antiguos de mas de 8 anios */
    tipoVehiculoPublicoTaxi            =       1000,           /* Vehiculo Publico Tipo Taxi */
    tipoVehiculoPublicoMicrobus        =       2000            /* Vehiculo Publico Tipo Microbus */
    
}TipoVehiculoSeleccionado;

@property (weak, nonatomic) id<IngresaDatosDelegate> delegate;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UILabel *labelPlacas;
@property (strong, nonatomic) IBOutlet UILabel *labelModelo;
@property (strong, nonatomic) IBOutlet UILabel *labelIndicadorPlacas;
@property (strong, nonatomic) IBOutlet UILabel *labelIndicadorModelo;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@end
