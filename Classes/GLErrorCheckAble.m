//
//  GLErrorCheckAble.m
//  OpenGLEStest
//
//  Created by Samuel Goodwin on 4/13/10.
//  Copyright 2010 ID345. All rights reserved.
//

#import "GLErrorCheckAble.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@implementation NSObject (GLErrorCheckAble)
+ (void)errorCheck{
	switch(glGetError()){
		case GL_NO_ERROR:
			NSLog(@"No error has been recorded. The value of this symbolic constant is guaranteed to be 0.");
			break;	
		case GL_INVALID_ENUM:
			NSLog(@"An unacceptable value is specified for an enumerated argument. The offending command is ignored and has no other side effect than to set the error flag.");
			break;
		case GL_INVALID_VALUE:
			NSLog(@"A numeric argument is out of range. The offending command is ignored and has no other side effect than to set the error flag.");
			break;
		case GL_INVALID_OPERATION:
			NSLog(@"The specified operation is not allowed in the current state. The offending command is ignored and has no other side effect than to set the error flag.");
			break;
			//case GL_STACK_OVERFLOW:
			//			NSLog(@"This command would cause a stack overflow. The offending command is ignored and has no other side effect than to set the error flag.");
			//			break;
			//		case GL_STACK_UNDERFLOW:
			//			NSLog(@"This command would cause a stack underflow. The offending command is ignored and has no other side effect than to set the error flag.");
			//			break;
			//		case GL_OUT_OF_MEMORY:
			//			NSLog(@"There is not enough memory left to execute the command. The state of the GL is undefined, except for the state of the error flags, after this error is recorded.");
			//			break;
			//		case GL_TABLE_TOO_LARGE:
			//			NSLog(@"table too large!");
			//			break;
	}
}
@end
