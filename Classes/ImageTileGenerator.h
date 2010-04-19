//
//  TextureStorage.h
//  OpenGLEStest
//
//  Created by Samuel Goodwin on 4/12/10.
//  Copyright 2010 ID345. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface ImageTileGenerator : NSObject {
	GLuint arrayWidth;
	GLuint arrayHeight;
	GLuint *texture_ids;
	
	GLfloat *geometry;
}

- (id)initWithImage:(UIImage*)image;
- (GLuint)width;
- (GLuint)height;
- (GLuint)textureIDForTileAtX:(GLuint)xCord andY:(GLuint)yCord;

+ (GLuint)textureFromImage:(UIImage*)image;
+ (NSArray*)splitImageIntoRects:(CGImageRef)anImage with:(GLuint)slicesInX and:(GLuint)slicedInY;

@end
