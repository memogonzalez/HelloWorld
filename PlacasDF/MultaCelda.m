//
//  MultaCelda.m
//  PlacasDF
//
//  Created by Carlos Guillermo Guadarrama on 29/01/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "MultaCelda.h"

@implementation MultaCelda

@synthesize motivo, fundamento, sancion, situacion, fecha, multa_id;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
