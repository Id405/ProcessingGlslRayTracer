uniform vec2 iResolution = vec2(40.0, 40.0); //TODO import models as spherical volumes of distance, outside of distance volume the mdoel is just distance to the center of the distance volume, also try importing models as polys
uniform float maxsteps = 20.0;
uniform float margin = 0.1;
uniform float samples = 10;
uniform float renderDistance = 10;
uniform float fov = 90;

uniform float maxLight = -1;
uniform float minLight = 0;

uniform float transform = 2.2;

// uniform vec3 skycolor = vec3(135.0/255.0, 206.0/255.0, 235.0/255.0); // actual sky color
uniform vec3 skycolor = vec3(0.5); //gray
uniform vec3 suncolor = vec3(192.0/255.0, 191.0/255.0, 173.0/255.0);
uniform vec3 lightcolor = vec3(5, 0, 0);
uniform vec3 lightdir = vec3(0.5, -1.0, 1.0);
uniform float sunSharpness = 20.0;
uniform float sunPower = 5.0;
uniform float skyPower = 0.5;
uniform float frameCount = 0;

uniform vec3 materialColor = vec3(0.9);
uniform float metalRoughness = 0.9;

uniform float specular = 0.1;
uniform float phongRoughness = 0.0;
uniform float specularRoughness = 0.98;

uniform vec3 transl = vec3(0, -5, 0);
uniform vec3 rotation = vec3(0, 0, 0);

const float glowScale = 1.0;
vec4 glowColor = vec4(0.5, 0.8, 1.0, 1.0);

float sampleN = 0;

#define PI 3.1415926535897932384626433832795

uint hash( uint x ) {
    x += ( x << 10u );
    x ^= ( x >>  6u );
    x += ( x <<  3u );
    x ^= ( x >> 11u );
    x += ( x << 15u );
    return x;
}

float rand (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

float rand(float x) {
	 return rand(vec2(x + frameCount) + gl_FragCoord.xy); // random numbers in glsl suuuuuuuuuuuck
}

mat4 rotationX( in float angle ) { //https://gist.github.com/onedayitwillmake/3288507
	return mat4(	1.0,		0,			0,			0,
									0, 	cos(angle),	-sin(angle),		0,
									0, 	sin(angle),	 cos(angle),		0,
									0, 			0,			  0, 		1);
}

mat4 rotationY( in float angle ) {
	return mat4(	cos(angle),		0,		sin(angle),	0,
								0,		1.0,			 0,	0,
								-sin(angle),	0,		cos(angle),	0,
								0, 		0,				0,	1);
}

mat4 rotationZ( in float angle ) {
	return mat4(	cos(angle),		-sin(angle),	0,	0,
								sin(angle),		cos(angle),		0,	0,
								0,				0,		1,	0,
								0,				0,		0,	1);
}

vec3 rotate(vec3 r, vec3 p) {
	vec4 vertex = vec4(p.xyz, 1.0);

	vertex = vertex * rotationX(r.x) * rotationY(r.y) * rotationZ(r.z);

	return vertex.xyz;
}

float sphereDist(in vec3 p, in vec3 sP, in float sS) {
	return distance(p, vec3(sP)) - sS;
}

float planeDist(in vec3 p, in float pP) {
	return p.z-pP;
}

float diffuseF(in vec3 p) {
	return min(sphereDist(p, vec3(0.0), 1.0), planeDist(p, -1.0));
}

// float diffuseF( in vec3 p) mandelbulb //https://www.shadertoy.com/view/ltfSWn
// {
//     vec3 w = p;
//     float m = dot(w,w);
//
//     vec4 trap = vec4(abs(w),m);
// 	float dz = 1.0;
//
//
// 	for( int i=0; i<7; i++ )
//     {
//         dz = 8.0*pow(sqrt(m),7.0)*dz + 1.0;
//
//         float r = length(w);
//         float b = 8.0*acos( w.y/r);
//         float a = 8.0*atan( w.x, w.z );
//         w = p + pow(r,8.0) * vec3( sin(b)*sin(a), cos(b), sin(b)*cos(a) );
//
//         trap = min( trap, vec4(abs(w),m) );
//
//         m = dot(w,w);
// 		if( m > 256.0 )
//             break;
//     }
//
//     return 0.25*log(m)*sqrt(m)/dz;
// }

float emissiveF(in vec3 p) {
	return sphereDist(p, vec3(1.0, 0.5, 1.0), 0.5);
}

float metallicF(in vec3 p) {
	return sphereDist(p, vec3(2.5, -0.4, 0.0), 1.0);
}

float f( in vec3 p) {
	return min(min(emissiveF(p), diffuseF(p)), metallicF(p));
	// return sphereDist(p, vec3(0.0), 1.0);
}

vec3 calcNormal( in vec3 p ) {
const float h = 0.0001;
return normalize(vec3(
	f(vec3(p.x + h, p.y, p.z)) - f(vec3(p.x - h, p.y, p.z)),
	f(vec3(p.x, p.y + h, p.z)) - f(vec3(p.x, p.y - h, p.z)),
	f(vec3(p.x, p.y, p.z  + h)) - f(vec3(p.x, p.y, p.z - h))
	));
}

vec3 metalScatter(vec3 p, vec3 v, vec3 n) {
	vec3 rayVel = v - 2*dot(v, n) * n;
	return rayVel;
}

vec3 scatter(vec3 p, vec3 v, vec3 n) {
	// vec3 rayVel = normalize(vec3(rand(p.x+sampleN) * 2 - 1, rand(p.y+sampleN) * 2 - 1, rand(p.z+sampleN) * 2 - 1));
	vec3 rayVel = normalize(rotate(calcNormal(p), normalize(vec3((rand(p.x) * 2 - 1) * PI, (rand(p.y) * 2 - 1) * PI, (rand(p.z) * 2 - 1) * PI))));
	// return calcNormal(p);
	return rayVel;
}

vec3 phong(vec3 p, vec3 v, vec3 n, float spec) {
	if(rand(length(v + n)) > spec) {
		return metalScatter(p, v, n) * phongRoughness + scatter(p, v, n) * (1 - metalRoughness);
	} else {
		return metalScatter(p, v, n) * specularRoughness + scatter(p, v, n) * (1 - metalRoughness);
	}
}

vec4 trace(vec2 p, vec3 transl) {
	vec2 s = vec2(p.x - iResolution.x/2.0f, p.y - iResolution.y/2.0f);
	vec3 raypos = transl;
	vec3 rayvel = normalize(vec3(s.x/iResolution.x, fov, s.y/iResolution.x));
	rayvel = rotate(rotation, rayvel);

	float bounces = 0.0;

	vec3 light = vec3(0);

	for(float i=0.0; i<maxsteps; i++) {
		float distance = f(raypos);
		raypos += rayvel * distance;

		if(emissiveF(raypos) < margin) {
			light = lightcolor;
			break;
		}

		if(metallicF(raypos) < margin) {
			bounces += 1.0;
			vec3 n = calcNormal(raypos);
			rayvel = normalize(metalScatter(raypos, rayvel, n) * metalRoughness + scatter(raypos, rayvel, n) * (1 - metalRoughness));
			raypos += calcNormal(raypos)*margin;
		}

		if(distance < margin) {
			bounces += 1.0;
			vec3 n = calcNormal(raypos);
			rayvel = scatter(raypos, rayvel, n);
			raypos += n*margin;
		}

		if(distance > renderDistance) {
			break;
		}
	}

	vec3 sunlight = suncolor * pow(max(dot(normalize(lightdir), rayvel), 0.0), sunSharpness) * sunPower + skycolor * skyPower;

	return vec4((light + sunlight) * pow(materialColor, vec3(bounces)), 1.0);
	// return vec4(pow(materialColor, vec3(bounces)), 1.0);
	// return vec4(sunlight, 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float samplesCount = samples;

	for(int i=0; i < samples; i++) {
		sampleN = i;
		vec4 col = trace(fragCoord+(vec2(rand(i), rand(i+25.6))), transl);

		if(col.x < minLight) {
			samplesCount -= 1;
			col = vec4(0);
		}
		if(col.y < minLight) {
			samplesCount -= 1;
			col = vec4(0);
		}
		if(col.z < minLight) {
			samplesCount -= 1;
			col = vec4(0);
		}

		if(maxLight > 0.0) {
			if(col.x > maxLight) {
				samplesCount -= 1;
				col = vec4(0);
			}
			if(col.y > maxLight) {
				samplesCount -= 1;
				col = vec4(0);
			}
			if(col.z > maxLight) {
				samplesCount -= 1;
				col = vec4(0);
			}
		}

		fragColor += trace(fragCoord+(vec2(rand(i), rand(i+25.6))*2-1.0), transl);
	}

	fragColor /= samplesCount;

	// fragColor = pow(fragColor, vec4(vec3(1.0/2.2), 1.0));
}

void main() {
	mainImage(gl_FragColor,gl_FragCoord.xy);
}
