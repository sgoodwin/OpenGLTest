//
//  ES2Renderer.m
//  OpenGLEStest
//
//  Created by Samuel Goodwin on 4/12/10.
//  Copyright ID345 2010. All rights reserved.
//

#import "ES2Renderer.h"
#import "TEIRendererHelper.h"
#import "ConstantsAndMacros.h"
#import "JLMMatrixLibrary.h"

// uniform index
enum {
	ProjectionViewModelUniformHandle,
	ViewModelMatrixUniformHandle,
	ModelMatrixUniformHandle,
	SurfaceNormalMatrixUniformHandle,
    UniformCount
};

GLint uniforms[UniformCount];

// attribute index
enum {
    VertexXYZAttributeHandle,
    VertexSTAttributeHandle,
    AttributeCount
};

@interface ES2Renderer (PrivateMethods)
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation ES2Renderer
@synthesize rendererHelper = _rendererHelper, drawn;

// Create an OpenGL ES 2.0 context
- (id)init
{
    if ((self = [super init]))
    {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

        if (!context || ![EAGLContext setCurrentContext:context] || ![self loadShaders])
        {
            [self release];
            return nil;
        }

		_rendererHelper = [[TEIRendererHelper alloc] init];
		
        // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
        glGenFramebuffers(1, &defaultFramebuffer);
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
		
		glEnable(GL_TEXTURE_2D);
		glEnable(GL_DEPTH_TEST);
		glFrontFace(GL_CCW);	
		glEnable (GL_REPLACE);
		
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
		drawn = NO;
    }

    return self;
}

- (void)render{			
	if(drawn)
		return;
    glViewport(0, 0, backingWidth, backingHeight);

    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		
	GLfloat squareSize = 2.0f/[self->storage width];
	GLfloat xStart = -1.0f;
	GLfloat yStart = 0.0f-squareSize*([self->storage height]/2.0f);
	
    // Use shader program
    glUseProgram(program);
	for(GLuint i = 0;i <  [self->storage width];i++
		){
		for(GLuint j=0;j < [self->storage height];j++){
			static GLfloat verticesST[] = {
				0.0f, 0.0f,
				1.0f, 0.0f,
				0.0f, 1.0f,
				1.0f, 1.0f,
			};
	
			static GLfloat verticesXYZ[] = {
				-1.0f, -1.0f, 0.0f,
				-1.0f, -1.0f, 0.0f,
				-1.0f,  -0.5f, 0.0f,
				-0.5f,  -0.5f, 0.0f,
			};
			verticesXYZ[0] = xStart+(GLfloat)i*squareSize;
			verticesXYZ[3] = verticesXYZ[0]+squareSize;
			verticesXYZ[6] = verticesXYZ[0];
			verticesXYZ[9] = verticesXYZ[0]+squareSize;
			
			verticesXYZ[1] = yStart+(GLfloat)j*squareSize;
			verticesXYZ[4] = verticesXYZ[1];
			verticesXYZ[7] = verticesXYZ[1]+squareSize;
			verticesXYZ[10] = verticesXYZ[1]+squareSize;
			glActiveTexture( GL_TEXTURE0 );
			GLuint texture = [self->storage textureIDForTileAtX:i andY:j];
			glBindTexture(GL_TEXTURE_2D, texture);
			GLuint location = glGetUniformLocation(program, "myTexture");
			glUniform1i(location, 0);
	
			glVertexAttribPointer(VertexXYZAttributeHandle, 3, GL_FLOAT, 0, 0, verticesXYZ);
			glEnableVertexAttribArray(VertexXYZAttributeHandle);
	
			glVertexAttribPointer(VertexSTAttributeHandle, 2, GL_FLOAT, 0, 0, verticesST);
			glEnableVertexAttribArray(VertexSTAttributeHandle);
			
			// Validate program before drawing. This is a good check, but only really necessary in a debug build.
			// DEBUG macro must be defined in your debug configurations if that's not already the case.
			#if defined(DEBUG)
				if (![self validateProgram:program])
				{
					NSLog(@"Failed to validate program: %d", program);
					return;
				}
			#endif

			// Draw
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		}
	}

    // This application only creates a single color renderbuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
	drawn = YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;

    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return FALSE;
    }

    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);

#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif

    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return FALSE;
    }

    return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;

    glLinkProgram(prog);

#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif

    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;

    return TRUE;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;

    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }

    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;

    return TRUE;
}

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;

    // Create shader program
    program = glCreateProgram();

    // Create and compile vertex shader
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return FALSE;
    }

    // Create and compile fragment shader
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return FALSE;
    }

    // Attach vertex shader to program
    glAttachShader(program, vertShader);

    // Attach fragment shader to program
    glAttachShader(program, fragShader);

    // Link program
    if (![self linkProgram:program])
    {
        NSLog(@"Failed to link program: %d", program);

        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return FALSE;
    }

    // Release vertex and fragment shaders
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);

	glBindAttribLocation(program, VertexXYZAttributeHandle,	"myVertexXYZ");
	glBindAttribLocation(program, VertexSTAttributeHandle,		"myVertexST");
    return TRUE;
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
    // Allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
	
	storage = [[ImageTileGenerator alloc] initWithImage:[UIImage imageNamed:@"danny.jpg"]];
	
	
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }

    return YES;
}

- (void)dealloc
{
    // Tear down GL
    if (defaultFramebuffer)
    {
        glDeleteFramebuffers(1, &defaultFramebuffer);
        defaultFramebuffer = 0;
    }

    if (colorRenderbuffer)
    {
        glDeleteRenderbuffers(1, &colorRenderbuffer);
        colorRenderbuffer = 0;
    }

    if (program)
    {
        glDeleteProgram(program);
        program = 0;
    }

    // Tear down context
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];

    [context release];
    context = nil;

    [super dealloc];
}

@end