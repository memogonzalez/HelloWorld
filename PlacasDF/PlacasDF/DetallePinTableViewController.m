//
//  DetallePinTableViewController.m
//  PlacasDF
//
//  Created by David Hernández on 1/22/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "DetallePinTableViewController.h"


@implementation DetallePinTableViewController
@synthesize nombre = _nombre;
@synthesize telefono = _telefono;
@synthesize direccion = _direccion;
@synthesize delegacion = _delegacion;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // El titulo de la vista es el nombre del Punto Vehicular
    self.title = _nombre;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    UITableViewCell *celda = nil;
    
    // Celda de direccion
    celda = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    celda.detailTextLabel.text = _direccion;
    
    // Celda de telefono
    celda = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    celda.detailTextLabel.text = _telefono;
    
    // Celda de delegacion
    celda = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    celda.detailTextLabel.text = _delegacion;
}

@end
