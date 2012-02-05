//
//  MultasTableViewController.m
//  Placas
//
//  Created by David Hernández on 1/15/12.
//  Copyright (c) 2012 Caos Inc. All rights reserved.
//

#import "MultasTableViewController.h"

#import "ManejadorConexiones.h"

#define URL @"http://www.caosinc.com/webservices/placa.php?placa=105val"


@implementation MultasTableViewController

@synthesize celdaMulta;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    receivedData = [[NSMutableData alloc] init];
    
    arrMultas = [[NSArray alloc] init];
    
    NSURL * url = [NSURL URLWithString:URL];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
    
    NSURLConnection * conexion = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [conexion start];

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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [arrMultas count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MultaCelda";
    
    MultaCelda *cell = (MultaCelda *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        
        [[NSBundle mainBundle] loadNibNamed:@"MultaCelda" owner:self options:nil];
        
        cell = celdaMulta;
        
        self.celdaMulta = nil;
    }
    
    NSDictionary * multa = [arrMultas objectAtIndex:[indexPath row]];
    
    NSString * imageName = ([[multa objectForKey:@"status"] isEqualToString:@"Pagada "]) ? @"ok.png": @"nook.png";
    
    UIImage * image = [UIImage imageNamed:imageName];
    
    cell.fecha.text = [multa objectForKey:@"fecha"];
    
    cell.sancion.text = [NSString stringWithFormat:@"%@ días de salario mínimo", [multa objectForKey:@"sancion"]];
    
    cell.motivo.text = [self formatString:[multa objectForKey:@"motivo"]];
    
    [cell.situacion setImage:image];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 92.0;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


// Manejo de conexión
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError * error;
    
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    
    NSDictionary * diccionario = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error];
    
    NSDictionary *multas = [diccionario objectForKey:@"multas"];
    
    arrMultas = [multas objectForKey:@"multa"];
    
    for (NSDictionary * multa in arrMultas) {
        
        NSLog(@"%@", [multa objectForKey:@"multa_id"]);
        
    }
    
    [self.tableView reloadData];
}

- (NSString *) formatString:(NSString *) text {
    
    NSString * str = [text stringByReplacingOccurrencesOfString:@"&Ntilde;" withString:@"Ñ"];
    
    str = [str stringByReplacingOccurrencesOfString:@"&Aacute;" withString:@"Á"];
    
    str = [str stringByReplacingOccurrencesOfString:@"&Eacute;" withString:@"É"];
    
    str = [str stringByReplacingOccurrencesOfString:@"&Iacute;" withString:@"Í"];
    
    str = [str stringByReplacingOccurrencesOfString:@"&Oacute;" withString:@"Ó"];
    
    str = [str stringByReplacingOccurrencesOfString:@"&Uacute;" withString:@"Ú"];
    
    str = [str lowercaseString];
    
    NSString * first = [[str substringWithRange:NSMakeRange(0, 1)] uppercaseString];
    
    str = [str stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:first];
    
    return str;
}


@end
