//
//  IngresarDatosViewController.h
//  PlacasDF
//
//  Created by David Hernández on 1/23/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IngresarDatosViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIPickerView *pickerViewModelo;

@property (strong, nonatomic) IBOutlet UITextField *fieldPlacas;

- (IBAction)done:(id)sender;

@end
