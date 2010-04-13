//
//  TextureStorage.m
//  OpenGLEStest
//
//  Created by Samuel Goodwin on 4/12/10.
//  Copyright 2010 ID345. All rights reserved.
//

#import "ImageTileGenerator.h"
#import "GLErrorCheckAble.h"

typedef enum {
	TextureFormat_Invalid = 0,
	TextureFormat_A8,
	TextureFormat_LA88,
	TextureFormat_RGB_565,
	TextureFormat_RGBA_5551,
	TextureFormat_RGB_888,
	TextureFormat_RGBA_8888,
	TextureFormat_RGB_PVR2,
	TextureFormat_RGB_PVR4,
	TextureFormat_RGBA_PVR2,
	TextureFormat_RGBA_PVR4,
} TextureFormat;

static int GetGLColor(TextureFormat format) {
	
	switch (format) {
		case TextureFormat_RGBA_5551:
		case TextureFormat_RGB_888:
		case TextureFormat_RGBA_8888:
			return GL_RGBA;
		case TextureFormat_RGB_565:
			return GL_RGB;
		case TextureFormat_A8:
			return GL_ALPHA;
		case TextureFormat_LA88:
			return GL_LUMINANCE_ALPHA;
		default:
			return 0;
	}
}

static int GetGLFormat(TextureFormat format) {
	
	switch (format) {
		case TextureFormat_A8:
		case TextureFormat_LA88:
		case TextureFormat_RGB_888:
		case TextureFormat_RGBA_8888:
			return GL_UNSIGNED_BYTE;
		case TextureFormat_RGBA_5551:
			return GL_UNSIGNED_SHORT_5_5_5_1;
		case TextureFormat_RGB_565:
			return GL_UNSIGNED_SHORT_5_6_5;
		default:
			return 0;
	}
}

static bool NGIsPowerOfTwo(uint32_t n) {
	return ((n & (n-1)) == 0);
}

const int kMaxTextureSizeExp = 10;
#define kMaxTextureSize (1 << kMaxTextureSizeExp)

static int NextPowerOfTwo(int n) {
	
	if (NGIsPowerOfTwo(n)) return n;
	
	for (int i = kMaxTextureSizeExp - 1; i > 0; i--) {
		
		if (n & (1 << i)) return (1 << (i+1));
		
	}
	
	return kMaxTextureSize;
}

static TextureFormat GetImageFormat(CGImageRef image) {
	
	CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image);
	
	bool hasAlpha = FALSE;
	hasAlpha = (alpha != kCGImageAlphaNone && alpha != kCGImageAlphaNoneSkipLast && alpha != kCGImageAlphaNoneSkipFirst);
	
	CGColorSpaceRef color = CGImageGetColorSpace(image);
	CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(color);
	
	int bpp	= CGImageGetBitsPerPixel(image);
	
	if (color != NULL) {
		
		if ( colorSpaceModel == kCGColorSpaceModelMonochrome) {
			
			if (hasAlpha) {
				
				return TextureFormat_LA88;
			} else {
				
				return TextureFormat_A8;
			}
			
		}
		
		if (bpp == 16) {
			
			if (hasAlpha) {
				
				return TextureFormat_RGBA_5551;
			} else {
				
				return TextureFormat_RGB_565;
			}
			
		}
		
		if (hasAlpha) {
			
			return TextureFormat_RGBA_8888;
		} else {
			
			return TextureFormat_RGB_888;
		}
		
	}
	
	return TextureFormat_A8;
}

static uint8_t *GetImageData(CGImageRef image, TextureFormat format) {
	
	CGContextRef	context		= NULL;
	uint8_t*		data		= NULL;
	CGColorSpaceRef	colorSpace	= NULL;
	
	int src_width	= CGImageGetWidth(image);
	int src_height	= CGImageGetHeight(image);
	
	int width	= NextPowerOfTwo(src_width);
	int height	= NextPowerOfTwo(src_height);
	
	int num_channels = 0;
	
	switch (format) {
			
		case TextureFormat_RGBA_8888:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			num_channels = 4;
			data = malloc(height * width * num_channels);
			context = CGBitmapContextCreate(data, 
											width, 
											height, 
											8, 
											num_channels * width, 
											colorSpace, 
											kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
			
		case TextureFormat_RGB_888:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			num_channels = 4;
			data = malloc(height * width * num_channels);
			context = CGBitmapContextCreate(data, 
											width, 
											height, 
											8, 
											num_channels * width, 
											colorSpace, 
											kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
			
		case TextureFormat_A8:
			data = malloc(height * width);
			context = CGBitmapContextCreate(data, 
											width, 
											height, 
											8, 
											width, 
											NULL, 
											kCGImageAlphaOnly);
			break;
			
		case TextureFormat_LA88:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(height * width * 4);
			context = CGBitmapContextCreate(data, 
											width, 
											height, 
											8, 
											4 * width, 
											colorSpace, 
											kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
			
		default:
			break;
	}
	
	if(context == NULL) {
		return NULL;
	}
	
    CGContextSetBlendMode(context, kCGBlendModeCopy);
	
	// This is needed because Quartz uses an origin at lower left and UIKit uses
	// origin at upper left
	// CGAffineTransformMake(a b c d tx ty)
	//
	//   a  c  tx
	//   b  d  ty
	//
	// To invert the image do this
	//   1   0  0
	//   0  -1  height
	//
	CGAffineTransform flipped = CGAffineTransformMake(1, 0, 0, -1, 0, height);
	CGContextConcatCTM(context, flipped);
	
	CGRect rect =  CGRectMake(0, 0, width, height);
	CGContextDrawImage(context, rect, image);
	
	CGContextRelease(context);
	
	return data;
}


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
		for (GLuint i = 0; i < arrayWidth; ++i)
		{
			array[i] = (GLuint*)malloc(arrayHeight * sizeof(GLuint));
			for(GLuint j=0;j<arrayHeight;j++){
				GLuint index = (i*(arrayWidth-1))+j;
				NSLog(@"Using index: %i", index);
				UIImage *imageToTexture = [splits objectAtIndex:index];
				if(!!imageToTexture)
					array[i][j] = [ImageTileGenerator textureFromImage:imageToTexture];
			}
		}
		self->texture_ids = array;
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

+ (GLuint)textureFromImage:(UIImage*)image{
	GLuint texture[1];
	
	if (image != NULL) {
		
		TextureFormat format	= GetImageFormat(image.CGImage);
		int glColor				= GetGLColor(format);
		int glFormat			= GetGLFormat(format);
		
		GLuint _width	= NextPowerOfTwo(CGImageGetWidth(image.CGImage));
		GLuint _height	= NextPowerOfTwo(CGImageGetHeight(image.CGImage));
		
		uint8_t *data = GetImageData(image.CGImage, format);
		
		glGenTextures(1, texture);
		glBindTexture(GL_TEXTURE_2D, texture[0]);

		
		// Wrap at texture boundaries
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		
		// lerp 4 nearest texels and lerp between pyramid levels.
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
		
		// lerp 4 nearest texels.
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		
		
		glTexImage2D(GL_TEXTURE_2D, 0, glColor, _width, _height, 0, glColor, glFormat, data);
		
		glGenerateMipmap( GL_TEXTURE_2D );
		
		free(data);
	}
	
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
			NSLog(@"Making chunk: %@", NSStringFromCGRect(frame));
															
			CGImageRef subimage = CGImageCreateWithImageInRect(anImage, frame);
			UIImage *uiImage = [UIImage imageWithCGImage:subimage];
			UIImageWriteToSavedPhotosAlbum(uiImage, NULL, NULL, NULL);
			[splitLayers addObject:uiImage];
			CFRelease(subimage);
		}
    }
    return splitLayers; 
}
@end