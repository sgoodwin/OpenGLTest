//
//  Shader.vsh
//  OpenGLEStest
//
//  Created by Samuel Goodwin on 4/12/10.
//  Copyright ID345 2010. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;

varying vec4 colorVarying;

uniform float translate;

void main()
{
    gl_Position = position;
    gl_Position.y += sin(translate) / 2.0;

    colorVarying = color;
}
