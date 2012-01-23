//
//  DetallePinTableViewController.h
//  PlacasDF
//
//  Created by David Hernández on 1/22/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetallePinTableViewController : UITableViewController

@property (copy, nonatomic) NSString *nombre;

@property (copy, nonatomic) NSString *direccion;

@property (copy, nonatomic) NSString *telefono;

@property (copy, nonatomic) NSString *delegacion;

- (void)configureElementosTabla;

@end
