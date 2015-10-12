//
//  LoginViewController.m
//  SampleMDB
//
//  Created by Roderick Durham on 10/10/15.
//  Copyright © 2015 Roderick Durham. All rights reserved.
//

#import "LoginViewController.h"
#import "MovieReview.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set the defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *usernameDefault = [defaults objectForKey:@"username"];
    NSString *passwordDefault = [defaults objectForKey:@"password"];
    NSString *serviceURLDefault = [defaults objectForKey:@"serviceURL"];
    
    if (!usernameDefault)
        usernameDefault = @"admin";
    
    if (!passwordDefault)
        passwordDefault = @"password";
    
    if (!serviceURLDefault)
        serviceURLDefault = @"http://localhost:8000/";
    
    self.usernameTextField.text = usernameDefault;
    self.passwordTextField.text = passwordDefault;
    self.serverURLTextField.text = serviceURLDefault;
    
    self.loginButton.enabled = YES;
    self.tryAgainLabel.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)loginAndClose:(id)sender
{
    // Attempt login with credentials and continue if
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.usernameTextField.text forKey:@"username"];
    [defaults setObject:self.passwordTextField.text forKey:@"password"];
    [defaults setObject:self.serverURLTextField.text forKey:@"serviceURL"];
    
    [MovieReview observeRESTAuthenticationSuccessNotification:self
                                                       target:@selector(authentificationSuccess:)];
    [MovieReview observeRESTAuthenticationFailureNotification:self
                                                       target:@selector(authentificationFailure:)];
    
    [MovieReview restOptions:[NSURL URLWithString:[defaults objectForKey:@"serviceURL"]]];
    
    self.loginButton.enabled = NO;
    
    return;
}

- (void)authentificationSuccess:(NSNotification *)successNotification
{
    self.loginButton.enabled = NO;
    self.tryAgainLabel.hidden = YES;

    [self dismissViewControllerAnimated:YES completion:nil];

    return;
}

- (void)authentificationFailure:(NSNotification *)failureNotification
{
    // Bring up failure text
    
    self.loginButton.enabled = YES;
    self.tryAgainLabel.hidden = NO;

    return;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
