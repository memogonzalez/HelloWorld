//
//  IngresarDatosViewController.m
//  PlacasDF
//
//  Created by David Hernández on 1/23/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "IngresarDatosViewController.h"

@implementation IngresarDatosViewController

@synthesize pickerViewModelo = _pickerViewModelo;
@synthesize fieldPlacas = _fieldPlacas;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *celdaPlacasId = @"celda_placas";
    static NSString *celdaModeloId = @"celda_modelo";
    
    UITableViewCell *celda = nil;
    
    switch (indexPath.row) {
        case 0:
            celda = [tableView dequeueReusableCellWithIdentifier:celdaPlacasId];
            break;
            
            
        case 1:
            celda = [tableView dequeueReusableCellWithIdentifier:celdaModeloId];
            break;
            
        default:
            break;
    }
    
    return celda;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Celda de Modelo
    if (indexPath.row == 0) {
        [_pickerViewModelo setHidden:YES];
        [_fieldPlacas becomeFirstResponder];
    }
    // Celda de Modelo
    if (indexPath.row == 1) {
        [_fieldPlacas resignFirstResponder];
        [_pickerViewModelo setHidden:NO];
    }
}

#pragma mark - Picker View DataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 1;
}

#pragma mark - Picker View Delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return @"Selecciona un modelo";
}

@end
