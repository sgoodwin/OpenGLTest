
//
//  EAGLView.h
//  OpenGLEStest
//
//  Created by Samuel Goodwin on 4/12/10.
//  Copyright ID345 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ES2Renderer.h"

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView
{    
@private
    ES2Renderer *renderer;

    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
    // Use of the CADisplayLink class is the preferred method for controlling your animation timing.
    // CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
    // The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
    // isn't available.
    id displayLink;
    NSTimer *animationTimer;
	
	BOOL needsRendering;
	
	UISlider *contrastSlider;
	UISlider *brightnessSlider;
	UISlider *saturationSlider;
	UISlider *hueSlider;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

@property(nonatomic, retain) IBOutlet UISlider *contrastSlider;
@property(nonatomic, retain) IBOutlet UISlider *brightnessSlider;
@property(nonatomic, retain) IBOutlet UISlider *saturationSlider;
@property(nonatomic, retain) IBOutlet UISlider *hueSlider;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView:(id)sender;
- (void)setNeedsRendering;

- (IBAction)brightnessChanged:(UISlider*)sender;
- (IBAction)contrastChanged:(UISlider*)sender;
- (IBAction)saturationChanged:(UISlider*)sender;
- (IBAction)hueChanged:(UISlider*)sender;
@end
