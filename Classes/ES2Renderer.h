//
//  ES2Renderer.h
//  OpenGLEStest
//
//  Created by Samuel Goodwin on 4/12/10.
//  Copyright ID345 2010. All rights reserved.
//

#import "ESRenderer.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

//#include <OpenGLES/ES1/gl.h>
//#include <OpenGLES/ES1/glext.h>

#import "ImageTileGenerator.h"

@class TEIRendererHelper;

@interface ES2Renderer : NSObject <ESRenderer>
{
@private
    EAGLContext *context;
	TEIRendererHelper *_rendererHelper;

    // The pixel dimensions of the CAEAGLLayer
    GLint backingWidth;
    GLint backingHeight;

    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view
    GLuint defaultFramebuffer, colorRenderbuffer;

    GLuint program;
	GLuint m_a_positionHandle;
	GLuint m_a_colorHandle;
	GLuint m_u_mvpHandle;
	
	GLfloat *geometry;
	
	ImageTileGenerator *storage;
}
@property (nonatomic, retain) TEIRendererHelper *rendererHelper;

- (void)render;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;

@end

