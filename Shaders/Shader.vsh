//
//  Shader.vsh
//  OpenGLEStest
//
//  Created by Samuel Goodwin on 4/12/10.
//  Copyright ID345 2010. All rights reserved.
//

attribute mediump	vec2	myVertexST;
attribute highp		vec4	myVertexXYZ;

varying	mediump vec2 v_st;

void main() {

	gl_Position = myVertexXYZ;
	gl_Position.y = gl_Position.y/1.3333333333;
	v_st	= myVertexST;
}
