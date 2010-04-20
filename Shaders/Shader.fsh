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

//varying float f_hue;
varying float f_saturation;
//varying float f_sharpness;
varying float f_contrast;
varying float f_brightness;

/*
** Contrast, saturation, brightness
** Code of this function is from TGM's shader pack
** http://irrlicht.sourceforge.net/phpBB2/viewtopic.php?t=21057
*/

// For all settings: 1.0 = 100% 0.5=50% 1.5 = 150%
vec3 contrastSaturationBrightness(vec3 color, float brt, float sat, float contrast)
{
	const vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721);
	
	vec3 AvgLumin = vec3(0.5, 0.5, 0.5);
	vec3 brtColor = color * brt;
	
	vec3 intensity = vec3(dot(brtColor, LumCoeff));
	//return intensity;
	vec3 satColor = mix(intensity, brtColor, sat);
	//return satColor;
	vec3 conColor = mix(AvgLumin, satColor, contrast);
	return conColor;
}

void main() {
	vec4 source = texture2D(myTexture, v_st);
	vec3 tmpColor = vec3(source.x, source.y, source.z);
	vec3 csb = contrastSaturationBrightness(tmpColor, 1.0, 1.0, 1.0);//f_brightness, f_saturation, f_contrast);
	vec4 color = vec4(csb.x, csb.y, csb.z, 0.0);
	gl_FragColor = vec4(csb.x, csb.y, csb.z, 0.0);
}