//
//  DetallePinTableViewController.m
//  PlacasDF
//
//  Created by David Hernández on 1/22/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "DetallePinTableViewController.h"


@implementation DetallePinTableViewController

@synthesize titulo = _titulo;
@synthesize labelNombre = _labelNombre;
@synthesize nombre = _nombre;
@synthesize labelTelefono = _labelTelefono;
@synthesize telefono = _telefono;
@synthesize labelDireccion = _labelDireccion;
@synthesize direccion = _direccion;
@synthesize lableDelegacion = _lableDelegacion;
@synthesize delegacion = _delegacion;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    _titulo = nil;
    _nombre = nil;
    _direccion = nil;
    _telefono = nil;
    _delegacion = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_titulo) {
        self.title = _titulo;
    } else {
        self.title = @"Punto Vehicular";
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    _titulo = nil;
    _nombre = nil;
    _direccion = nil;
    _telefono = nil;
    _delegacion = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Mostrar los datos de cada celda con los valores del punto Vehicular
    [self configureElementosTabla];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)configureElementosTabla
{
    _labelNombre.text = _nombre;
    _labelDireccion.text = _direccion;
    _labelTelefono.text = _telefono;
    _lableDelegacion.text = _delegacion;
}

@end
