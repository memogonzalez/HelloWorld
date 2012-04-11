//
//  DetallePinTableViewController.h
//  PlacasDF
//
//  Created by David Hernández on 1/22/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetallePinTableViewController : UITableViewController

@property (copy, nonatomic) NSString *titulo;

@property (strong, nonatomic) IBOutlet UILabel *labelNombre;
@property (copy, nonatomic) NSString *nombre;

@property (strong, nonatomic) IBOutlet UILabel *labelDireccion;
@property (copy, nonatomic) NSString *direccion;

@property (strong, nonatomic) IBOutlet UILabel *labelTelefono;
@property (copy, nonatomic) NSString *telefono;

@property (strong, nonatomic) IBOutlet UILabel *lableDelegacion;
@property (copy, nonatomic) NSString *delegacion;

- (void)configureElementosTabla;

@end
