//
//  SettingsTableViewController.h
//  Placas
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController {
    
    BOOL isShowingList;
    
    IBOutlet UISwitch * general;
    
    IBOutlet UISwitch * noCircula;
    
    IBOutlet UISwitch * refrendo;
    
    IBOutlet UISwitch * verificacion;
    
    IBOutlet UISwitch * infracciones;
}

- (IBAction) showSettings:(id)sender;

@end
