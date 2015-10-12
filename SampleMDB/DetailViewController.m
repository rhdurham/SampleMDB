//
//  DetailViewController.m
//  SampleMDB
//
//  Created by Roderick Durham on 10/8/15.
//  Copyright © 2015 Roderick Durham. All rights reserved.
//

#import "DetailViewController.h"

#import <CoreData/Coredata.h>
#import "MovieReview.h"

@interface DetailViewController ()

@property (nonatomic) BOOL isEditing;

- (void)updateDetailItem;
- (void)saveDetailItem;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"movieName"] description];
        NSString *imageUrl = [self.detailItem valueForKey:@"imageUrl"];
        if (imageUrl) {
            NSURL *nsUrl = [NSURL URLWithString:imageUrl];
            NSData *imageData = [NSData dataWithContentsOfURL:nsUrl];
            UIImage *detailImage = [UIImage imageWithData:imageData];
            self.detailImageView.image = detailImage;
        }
        NSString *movieDescription = [self.detailItem valueForKey:@"movieDescription"];
        if (movieDescription) {
            self.detailTextView.text = movieDescription;
        }
        NSString *rating = [self.detailItem valueForKey:@"rating"];
        if (rating) {
            self.detailRatingLabel.text = rating;
        }
        NSString *imageURL = [self.detailItem valueForKey:@"imageUrl"];
        if (imageURL) {
            self.detailImageURLLabel.text = imageURL;
        }

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleEdit:(id)sender
{
    NSLog(@"Edit toggle");
    self.isEditing = !(self.isEditing);
    UILabel *label = [[sender subviews] objectAtIndex:0];
    self.detailTextView.editable = self.isEditing;
    self.detailDescriptionLabel.enabled = self.isEditing;
    self.detailRatingLabel.enabled = self.isEditing;
    self.detailImageURLLabel.enabled = self.isEditing;

    if (self.isEditing) {
        [label setText:@"Done"];
        self.detailDescriptionLabel.borderStyle = UITextBorderStyleRoundedRect;
        self.detailRatingLabel.borderStyle = UITextBorderStyleRoundedRect;
        self.detailImageURLLabel.borderStyle = UITextBorderStyleRoundedRect;
        self.detailTextView.layer.borderWidth = 0.5f;
        self.detailTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    } else {
        // Save Changes
        [label setText:@"Edit"];
        
        self.detailDescriptionLabel.borderStyle = UITextBorderStyleNone;
        self.detailRatingLabel.borderStyle = UITextBorderStyleNone;
        self.detailImageURLLabel.borderStyle = UITextBorderStyleNone;
        self.detailTextView.layer.borderWidth = 0.0f;
        self.detailTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];

        
        [self updateDetailItem];
        [self saveDetailItem];
        
    }
    return;
}

- (void)updateDetailItem
{
    [self.detailItem setValue:self.detailTextView.text forKey:@"movieDescription"];
    [self.detailItem setValue:self.detailRatingLabel.text forKey:@"rating"];
    [self.detailItem setValue:self.detailDescriptionLabel.text forKey:@"movieName" ];
    [self.detailItem setValue:[NSDate date] forKey:@"modificationDate"];
    [self.detailItem setValue:self.detailImageURLLabel.text forKey:@"imageUrl"];
    
    self.navigationItem.title = self.detailDescriptionLabel.text;
    
    return;
}

- (void)saveDetailItem
{
    // restPut and then save
    NSManagedObject *detailManagedObject = (NSManagedObject *)self.detailItem;
    NSManagedObjectContext *managedObjectContext = [detailManagedObject managedObjectContext];
    
    [detailManagedObject restPut];
    
    if (managedObjectContext) {
        NSError *nsError;
        [managedObjectContext save:&nsError];
    }
    
    return;
}

@end
