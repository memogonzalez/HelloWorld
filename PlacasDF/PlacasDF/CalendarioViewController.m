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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self colocaImagenCalendario:kTIPO_CALENDARIO_NO_CIRCULA];
}


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

- (IBAction)seleccionaCalendario:(id)sender {
    
    NSLog(@"Entre");
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    NSInteger segmentoSeleccionado = [segmentedControl selectedSegmentIndex];
    
    // Cargamos y mostramos los puntos vehiculares del tipo seleccionado
    [self colocaImagenCalendario:segmentoSeleccionado];
}

-(void) colocaImagenCalendario:(kTIPO_CALENDARIO)kTipoCalendario {
    
    
    UIImage * imagen;
    
    if (kTipoCalendario == kTIPO_CALENDARIO_NO_CIRCULA) {
        
        imagen = [UIImage imageNamed:@"no-circula.jpg"];
        
    } else if (kTipoCalendario == kTIPO_CALENDARIO_VERIFICACION) {
        
        imagen = [UIImage imageNamed:@"verifica.jpg"];
    }
    
    UIImageView * imageView = [[UIImageView alloc] initWithImage:imagen];
    
    [imageView removeFromSuperview];
    
    [self.view addSubview:imageView];
    
    
}

@end
