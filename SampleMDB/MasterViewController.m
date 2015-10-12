//
//  MasterViewController.m
//  SampleMDB
//
//  Created by Roderick Durham on 10/8/15.
//  Copyright © 2015 Roderick Durham. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

#import "AppDelegate.h"

#import "MovieReview.h"
#import "MovieReviewTableCell.h"

@interface MasterViewController ()
{
    NSArray *filteredMovieReviews;
}

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"modificationDate"];
    [newManagedObject setValue:@"New Title" forKey:@"movieName"];
    //[newManagedObject setValue:@"http://private-05248-rottentomatoes.apiary-mock.com" forKey:@"url"];
    [newManagedObject setValue:@"http://stickylipsbbq.com/stickylips/wp-content/uploads/2012/03/new2.jpg" forKey:@"imageUrl"];
    [newManagedObject setValue:@"For now is the time for all good men to come to the aid of their country."
                        forKey:@"movieDescription"];
    [newManagedObject setValue:@"NR" forKey:@"rating"];
    
    // Create in service
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[newManagedObject restPost:[(AppDelegate *)[[UIApplication sharedApplication] delegate] restURL]];
    [newManagedObject restPost:[NSURL URLWithString:[defaults objectForKey:@"serviceURL"]]];

    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    } else {
        // Sync to service
        
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object;
        if (self.searchDisplayController.active  == NO)
            object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        else
            object = [filteredMovieReviews objectAtIndex:indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        controller.navigationItem.title = [object valueForKey:@"movieName"];
        
        
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editButton addTarget:controller action:@selector(toggleEdit:) forControlEvents:UIControlEventTouchDown];
        [editButton setFrame:CGRectMake(0,0,53,31)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(3,5,50,20)];
        [label setFont:[UIFont fontWithName:@"Arial-MT" size:16]];
        [label setText:@"Edit"];
        label.textAlignment = UITextAlignmentCenter;
        [label setTextColor:[UIColor blueColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [editButton addSubview:label];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:editButton];
        
        controller.navigationItem.rightBarButtonItem = barButton;
    }
}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 71;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if (tableView == self.tableView) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        numberOfRows = [sectionInfo numberOfObjects];
    } else {
        numberOfRows = filteredMovieReviews.count;
    }
        
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MovieReviewTableCell" forIndexPath:indexPath];
    [self configureCell:cell tableView:tableView atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [managedObject restDelete];
        [context deleteObject:managedObject];
        
        /////////////////
        // Delete here from  REST service
            
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object;
    if (tableView == self.tableView)
        object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    else
        object = [filteredMovieReviews objectAtIndex:indexPath.row];
    
    NSString *imageUrl = [object valueForKey:@"imageUrl"];
    UIImage *image = nil;
    if (imageUrl) {
        NSURL *nsUrl = [NSURL URLWithString:imageUrl];
        NSData *imageData = [NSData dataWithContentsOfURL:nsUrl];
        image = [UIImage imageWithData:imageData];
    }

    if ([cell isMemberOfClass:[MovieReviewTableCell class]]) {
        ((MovieReviewTableCell *)cell).nameLabel.text = [object valueForKey:@"movieName"];
        ((MovieReviewTableCell *)cell).ratingLabel.text = [object valueForKey:@"rating"];
        if (image)
            ((MovieReviewTableCell *)cell).thumbnailImageView.image = image;
    } else {
        cell.textLabel.text = [[object valueForKey:@"movieName"] description];
        if (image)
            cell.imageView.image = image;
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MovieReview" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"movieName" ascending:NO];

    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Movies"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] tableView:tableView atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */


////////////////////////////
// Search bar functionality

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"movieName contains[c] %@", searchText];
    NSArray *movieReviews = self.fetchedResultsController.fetchedObjects;
    filteredMovieReviews = [movieReviews filteredArrayUsingPredicate:resultPredicate];
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}


@end
