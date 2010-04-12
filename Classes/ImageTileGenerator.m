//
//  TextureStorage.m
//  OpenGLEStest
//
//  Created by Samuel Goodwin on 4/12/10.
//  Copyright 2010 ID345. All rights reserved.
//

#import "ImageTileGenerator.h"


@implementation ImageTileGenerator
- (id)initWithImage:(UIImage*)image{
	if((self = [super init])){
		CGFloat aWidth = CGImageGetWidth(image.CGImage);
		CGFloat aHeight = CGImageGetHeight(image.CGImage);
		
		arrayWidth = ceil(aWidth/512.0f);
		arrayHeight = ceil(aHeight/512.0f);
		NSLog(@"Alive! (%.2f,%.2f) => (%i,%i)", aWidth, aHeight, arrayWidth, arrayHeight);
		NSArray *splits = [ImageTileGenerator splitImageIntoRects:image.CGImage with:arrayWidth and:arrayHeight];
		NSLog(@"split image into %d pieces.", [splits count]);
			  
		GLuint** array = (GLuint**)malloc(arrayWidth * sizeof(GLuint*));
		
		GLuint i = 0;
		for (i = 0; i < arrayWidth; ++i)
		{
			array[i] = (GLuint*)malloc(arrayHeight * sizeof(GLuint));
			for(GLuint j=0;j<arrayHeight;j++){
				array[i][j] = [ImageTileGenerator textureFromImage:(CGImageRef)[splits objectAtIndex:i]];
			}
		}
		self->texture_ids = array;
		
		//GLfloat ** geomarray = (GLfloat**)malloc(arrayWidth*arrayHeight*3*sizeof(GLfloat[3])); // 3 points for every point.
//		for(i =0;i<arrayWidth;i++){
//			for(GLuint j=0;j<arrayHeight;j++){
//				GLuint index = (i*(arrayHeight))+j;
//				GLfloat point[3] = {0.0f, 0.0f, 0.0f};
//				geomarray[index] = point;
//			}
//		}
//		GLfloat *triangles = (GLfloat*)malloc(sizeof(GLfloat)*arrayWidth*arrayHeight);
//		
	}
	return self;
}

- (GLuint)width{
	return arrayWidth;
}

- (GLuint)height{
	return arrayHeight;
}


- (GLuint)textureIDForTileAtX:(GLuint)xCord andY:(GLuint)yCord{
	GLuint texture = self->texture_ids[xCord][yCord];
	if(texture == -1){
		NSLog(@"No texture yet!");
	}
	return texture;
}

+ (GLuint)textureFromImage:(CGImageRef)image{
	GLuint texture[1];
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	//glBlendFunc(GL_ONE, GL_SRC_COLOR);
	glGenTextures(1, &texture[0]);
	glBindTexture(GL_TEXTURE_2D, texture[0]);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
	
	if (image == nil)
	{
		NSLog(@"Do real error checking here");
		return 42;
	}
	
	GLuint width = CGImageGetWidth(image);
	GLuint height = CGImageGetHeight(image);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	void *imageData = calloc( height * width * 4 ,1);
	CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
	
	// Flip the Y-axis
	CGContextTranslateCTM (context, 0, height);
	CGContextScaleCTM (context, 1.0, -1.0);
	
	CGColorSpaceRelease( colorSpace );
	CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
	CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image );
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);		
	CGContextRelease(context);
	
	free(imageData);
	
	//NSLog(@"Value of width = %i", width); // This outputs "Value of width = 64"
	//NSLog(@"Value of height = %i", height); // This outputs "Value of height = 64"
	//NSLog(@"Value of texture[0] = %i", texture[0]);  // This outputs "Value of texture[0] = 1"
	return texture[0];
}

+ (NSArray*)splitImageIntoRects:(CGImageRef)anImage with:(GLuint)slicesInX and:(GLuint)slicedInY{
	
    //CGSize imageSize = CGSizeMake(CGImageGetWidth(anImage), CGImageGetHeight(anImage));
	
	NSMutableArray *splitLayers = [NSMutableArray array];
	
	for(int x = 0;x < slicesInX;x++) {
		for(int y = 0;y < slicedInY;y++) {
			CGRect frame = CGRectMake((512.0f) * x,
									  (512.0f) * y,
									  (512.0f),
									  (512.0f));
															
			CGImageRef subimage = CGImageCreateWithImageInRect(anImage, frame);
			UIImageWriteToSavedPhotosAlbum([UIImage imageWithCGImage:subimage], NULL, NULL, NULL);
			[splitLayers addObject:(UIImage*)subimage];
			CFRelease(subimage);
		}
    }
    return splitLayers; 
}
@end
