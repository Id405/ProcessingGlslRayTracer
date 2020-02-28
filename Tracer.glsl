uniform vec2 iResolution = vec2(40.0, 40.0);
uniform float maxsteps = 20.0;
uniform float margin = 0.1;
uniform vec3 skycolor = vec3(0.9, 0.9, 1.0);
uniform vec3 suncolor = vec3(1.0, 1.0, 0.5);
uniform vec3 materialColor = vec3(0.9);
uniform float samples = 10;
uniform float renderDistance = 50;
uniform vec3 lightdir = vec3(0.5, -1.0, 1.0);

uniform vec3 transl = vec3(0, -5, 0);
uniform vec3 rotation = vec3(0, 0, 0);

const float glowScale = 1.0;
vec4 glowColor = vec4(0.5, 0.8, 1.0, 1.0);

float sampleN = 0;

#define PI 3.1415926535897932384626433832795

float rand(float x) {
	return fract(sin(x*1000000.0)*100000.0);
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

float f( in vec3 p) {
    // return min(sphereDist(p, vec3(0.0), 1.0), planeDist(p, -1.0));
	return sphereDist(p, vec3(0.0), 1.0);
}

vec3 calcNormal( in vec3 p ) {
    const float h = 0.0001;
    return normalize(vec3(
        f(vec3(p.x + h, p.y, p.z)) - f(vec3(p.x - h, p.y, p.z)),
        f(vec3(p.x, p.y + h, p.z)) - f(vec3(p.x, p.y - h, p.z)),
        f(vec3(p.x, p.y, p.z  + h)) - f(vec3(p.x, p.y, p.z - h))
    ));
}

vec3 scatter(vec3 p) {
	// vec3 rayVel = normalize(rotate(calcNormal(p), vec3((rand(p.x + sampleN) * 2 - 1) * PI, (rand(p.y + sampleN) * 2 - 1) * PI, (rand(p.z + sampleN) * 2 - 1) * PI)));
	return calcNormal(p);
}

vec4 trace(vec2 p, vec3 transl) {
    vec2 s = vec2(p.x - iResolution.x/2.0f, p.y - iResolution.y/2.0f);
    vec3 raypos = transl;
    vec3 rayvel = normalize(vec3(s.x, 1000, s.y));
	rayvel = rotate(rotation, rayvel);

	float bounces = 0.0;

    for(float i=0.0; i<maxsteps; i++) {
        float distance = f(raypos);
        raypos += rayvel * distance;

        if(distance < margin) {
			bounces += 1.0;
			rayvel = scatter(raypos);
        }
		
		if(distance > renderDistance) {
			break;
		}
    }
	
	vec3 sunlight = suncolor * pow(dot(normalize(lightdir), rayvel)/2, 1.0) + skycolor;
	
    return vec4(sunlight, 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

		for(int i=0; i < samples; i++) {
			sampleN = i;
			fragColor += trace(fragCoord+(vec2(rand(i), rand(i+25.6))*2-1.0), transl);
		}

		fragColor.xyz /= samples;

    // fragColor = pow(fragColor, vec4(1.0/2.2));
}

void main() {
	mainImage(gl_FragColor,gl_FragCoord.xy);
}
