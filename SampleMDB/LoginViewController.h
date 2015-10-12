//
//  LoginViewController.h
//  SampleMDB
//
//  Created by Roderick Durham on 10/10/15.
//  Copyright © 2015 Roderick Durham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *serverURLTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *tryAgainLabel;

- (IBAction)loginAndClose:(id)sender;

@end
