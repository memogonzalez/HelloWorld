//
//  CalendarioViewController.h
//  Placas
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"

@interface CalendarioViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

-(void) colocaImagenCalendario:(kTIPO_CALENDARIO)kTipoCalendario;

- (IBAction)seleccionaCalendario:(id)sender;
@end
