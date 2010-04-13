//
//  Shader.fsh
//  OpenGLEStest
//
//  Created by Samuel Goodwin on 4/12/10.
//  Copyright ID345 2010. All rights reserved.
//

precision highp float;

varying lowp	vec4 v_rgba;
varying	mediump vec2 v_st;

uniform sampler2D	myTexture_0;
uniform sampler2D	myTexture_1;

void main() {

	vec4 dev_null;
	dev_null = v_rgba;
	
	vec4 rgba_0 = texture2D(myTexture_0, v_st);	
	vec4 rgba_1 = texture2D(myTexture_1, v_st);	

// Blend the textures together
	float interpolate = 0.75;
	gl_FragColor.r = interpolate * rgba_0.r + (1.0 - interpolate) * rgba_1.r;
	gl_FragColor.g = interpolate * rgba_0.g + (1.0 - interpolate) * rgba_1.g;
	gl_FragColor.b = interpolate * rgba_0.b + (1.0 - interpolate) * rgba_1.b;
	gl_FragColor.a = interpolate * rgba_0.a + (1.0 - interpolate) * rgba_1.a;

// Luminence
//	float lum = 0.30 * rgba_0.r * 0.59 * rgba_0.g + 0.11 * rgba_0.b;
//	gl_FragColor.r = lum;
//	gl_FragColor.g = lum;
//	gl_FragColor.b = lum;
//	gl_FragColor.a = rgba_0.a;
	
}
