//
//  OpenGLEStestAppDelegate.m
//  OpenGLEStest
//
//  Created by Samuel Goodwin on 4/12/10.
//  Copyright ID345 2010. All rights reserved.
//

#import "OpenGLEStestAppDelegate.h"
#import "EAGLView.h"

@implementation OpenGLEStestAppDelegate

@synthesize window;
@synthesize glView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions   
{
	[window setBackgroundColor:[UIColor grayColor]];
    [glView startAnimation];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [glView stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [glView startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [glView stopAnimation];
}

- (void)dealloc
{
    [window release];
    [glView release];

    [super dealloc];
}


- (IBAction)rotateRight{
	[UIView beginAnimations:@"rotation" context:nil];
	glView.transform = CGAffineTransformConcat(glView.transform, CGAffineTransformMakeRotation(M_PI/2.0f));
	[UIView commitAnimations];
}

- (IBAction)rotateLeft{
	[UIView beginAnimations:@"rotation" context:nil];
	glView.transform = CGAffineTransformConcat(glView.transform, CGAffineTransformMakeRotation(-M_PI/2.0f));
	[UIView commitAnimations];
}

@end
