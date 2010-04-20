//
//  Shader.fsh
//  OpenGLEStest
//
//  Created by Samuel Goodwin on 4/12/10.
//  Copyright ID345 2010. All rights reserved.
//

precision highp float;

varying	mediump vec2 v_st;

uniform sampler2D	myTexture;

varying float f_Hue;
varying float f_Saturation;
varying float f_Sharpness;
varying float f_Contrast;
varying float f_Brightness;
// HSSCB values will be blended into the texture color here;


void main() {
	gl_FragColor = texture2D(myTexture, v_st);		
}