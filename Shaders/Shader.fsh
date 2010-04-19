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

void main() {
	gl_FragColor = texture2D(myTexture, v_st);		
}

//precision mediump float; 
//uniform float u_blurStep;
//void main(void) {
//	vec4 sample0, sample1, sample2, sample3;
//	float step = 5.0 / 100.0;
//	sample0 = texture2D(myTexture, vec2(v_st.x - step, v_st.y - step));
//	sample1 = texture2D(myTexture, vec2(v_st.x + step, v_st.y + step)); 
//	sample2 = texture2D(myTexture, vec2(v_st.x + step, v_st.y - step));
//	sample3 = texture2D(myTexture, vec2(v_st.x - step, v_st.y + step)); 
//	gl_FragColor = (sample0 + sample1 + sample2 + sample3) / 4.0;
//}