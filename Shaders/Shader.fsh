//
//  Shader.fsh
//  OpenGLEStest
//
//  Created by Samuel Goodwin on 4/12/10.
//  Copyright ID345 2010. All rights reserved.
//

precision highp float;

//varying lowp	vec4 v_rgba;
varying	mediump vec2 v_st;

uniform sampler2D	myTexture_0;
//uniform sampler2D	myTexture_1;

void main() {
	gl_FragColor = texture2D(myTexture_0, v_st);		
}
