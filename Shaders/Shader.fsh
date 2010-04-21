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

varying float f_hue;
varying float f_saturation;
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

mat4 xrotatemat(mat4 matrix,float rs,float rc)
{
    mat4 mmat = mat4(vec4(1.0, 0.0, 0.0, 0.0), vec4(0.0, rc, rs, 0.0), vec4(0.0, -rs, rc, 0.0), vec4(0.0, 0.0, 0.0, 1.0));
	return matrixCompMult(mmat, matrix);
}

mat4 yrotatemat(mat4 matrix,float rs,float rc){
    mat4 mmat = mat4(vec4(rc, 0.0, -rs, 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(rs, 0.0, rc, 0.0), vec4(0.0, 0.0, 0.0, 1.0));
    return matrixCompMult(mmat, matrix);
}

mat4 zrotatemat(mat4 matrix,float rs,float rc){
    mat4 mmat = mat4(vec4(rc, rs, 0.0, 0.0), vec4(-rs, rc, 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0), vec4(0.0, 0.0, 0.0, 1.0));
	return matrixCompMult(mmat, matrix);
}

vec4 hue(vec4 color, float angle){
	// Matrix math explained here: http://en.wikipedia.org/wiki/Rotation_matrix#Basic_rotations
	//We make an identity matrix
	//   identmat(mmat);
	//Rotate the grey vector into positive Z
	//    mag = sqrt(2.0);
	//    xrs = 1.0/mag;
	//    xrc = 1.0/mag;
	//    xrotatemat(mmat,xrs,xrc);
	//    mag = sqrt(3.0);
	//    yrs = -1.0/mag;
	//    yrc = sqrt(2.0)/mag;
	//    yrotatemat(mmat,yrs,yrc);
	//    matrixmult(mmat,mat,mat);
	//Shear the space to make the luminance plane horizontal
	//    xformrgb(mmat,rwgt,gwgt,bwgt,&lx,&ly,&lz);
	//    zsx = lx/lz;
	//    zsy = ly/lz;
	//    zshearmat(mat,zsx,zsy);
	//Rotate the hue
	//    zrs = sin(rot*PI/180.0);
	//    zrc = cos(rot*PI/180.0);
	//    zrotatemat(mat,zrs,zrc);
	//Unshear the space to put the luminance plane back
	//    zshearmat(mat,-zsx,-zsy);
	//Rotate the grey vector back into place
	//    yrotatemat(mat,-yrs,yrc);
	//    xrotatemat(mat,-xrs,xrc);
	mat4 mmat = mat4(1.0);
	float mag = sqrt(2.0);
	float xrs = 1.0/mag;
	float xrc = 1.0/mag;
	mmat = xrotatemat(mmat, xrs, xrc);
	mag = sqrt(3.0);
	float yrs = -1.0/mag;
	float yrc = sqrt(2.0)/mag;
	mmat = yrotatemat(mmat,yrs,yrc);
	
	float zrs = sin(angle);
    float zrc = cos(angle);
    mmat = zrotatemat(mmat,zrs,zrc);
	// Rotate the grey vector back into place
    yrotatemat(mmat,-yrs,yrc);
    xrotatemat(mmat,-xrs,xrc);
	
	return mmat*color;
}

void main() {
	vec4 source = texture2D(myTexture, v_st);
	vec3 tmpColor = vec3(source[0], source[1], source[2]);
	vec3 csb = contrastSaturationBrightness(tmpColor, f_brightness, f_saturation, f_contrast);
	//vec4 color = vec4(csb.x, csb.y, csb.z, 1.0);
	
	// for f_hue, [0,2] => (-1) => [-1, 1] => (*pi/2) => [-pi/2, pi/2];
	float angle = (f_hue-1.0)*(3.14159/2.0);
	gl_FragColor = hue(vec4(csb.x, csb.y, csb.z, 1.0), angle);
}