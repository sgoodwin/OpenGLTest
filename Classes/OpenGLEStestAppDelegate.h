//
//  OpenGLEStestAppDelegate.h
//  OpenGLEStest
//
//  Created by Samuel Goodwin on 4/12/10.
//  Copyright ID345 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface OpenGLEStestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
	
	int angle;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

- (IBAction)rotateRight;
- (IBAction)rotateLeft;
@end

