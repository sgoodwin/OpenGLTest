//
//  Shader.vsh
//  OpenGLEStest
//
//  Created by Samuel Goodwin on 4/12/10.
//  Copyright ID345 2010. All rights reserved.
//

attribute mediump	vec2	myVertexST;
attribute highp		vec4	myVertexXYZ;

//attribute float myHue;
attribute float mySaturation;
//attribute float mySharpness;
attribute float myContrast;
attribute float myBrightness;

varying	mediump vec2 v_st;
//varying highp float f_hue;
varying highp float f_saturation;
//varying highp float f_sharpness;
varying highp float f_contrast;
varying highp float f_brightness;

void main() {

	gl_Position = myVertexXYZ;
	gl_Position.y = gl_Position.y/(4.0/3.0);
	v_st	= myVertexST;
	
	//f_hue = myHue;
	f_saturation = mySaturation;
	//f_sharpness = mySharpness;
	f_contrast = myContrast;
	f_brightness = myBrightness;
}