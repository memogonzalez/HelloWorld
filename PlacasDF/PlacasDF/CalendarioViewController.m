//
//  CalendarioViewController.m
//  Placas
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "CalendarioViewController.h"

@implementation CalendarioViewController

@synthesize segmentedControl = _segmentedControl;

@synthesize imageView = _imageView;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self colocaImagenCalendario:kTIPO_CALENDARIO_NO_CIRCULA];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)seleccionaCalendario:(id)sender {
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger segmentoSeleccionado = [segmentedControl selectedSegmentIndex];
    
    if (segmentoSeleccionado < 0) {
        segmentoSeleccionado = 0;
    }
    
    // Cargamos y mostramos los puntos vehiculares del tipo seleccionado
    [self colocaImagenCalendario:segmentoSeleccionado];
}

- (void)colocaImagenCalendario:(kTIPO_CALENDARIO)kTipoCalendario 
{    
    UIImage *imagen = nil;
    
    if (kTipoCalendario == kTIPO_CALENDARIO_NO_CIRCULA) {
        
        imagen = [UIImage imageNamed:@"no-circula.jpg"];
        
    } else if (kTipoCalendario == kTIPO_CALENDARIO_VERIFICACION) {
        
        imagen = [UIImage imageNamed:@"verifica.jpg"];
    }
    
    [_imageView setImage:imagen];
}

@end
