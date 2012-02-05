//
//  MultaCelda.h
//  PlacasDF
//
//  Created by Carlos Guillermo Guadarrama on 29/01/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultaCelda : UITableViewCell {
 
    IBOutlet UILabel * motivo;
    
    IBOutlet UILabel * fundamento;
    
    IBOutlet UILabel * sancion;
    
    IBOutlet UIImageView * situacion;
    
    IBOutlet UILabel * fecha;
    
    IBOutlet UILabel * multa_id;
    
}

@property (strong, nonatomic) IBOutlet UILabel * motivo;

@property (strong, nonatomic) IBOutlet UILabel * fundamento;

@property (strong, nonatomic) IBOutlet UILabel * sancion;

@property (strong, nonatomic) IBOutlet UIImageView * situacion;

@property (strong, nonatomic) IBOutlet UILabel * fecha;

@property (strong, nonatomic) IBOutlet UILabel * multa_id;

@end
