uniform vec2 iResolution = vec2(40.0, 40.0);
uniform float maxsteps = 40.0;
uniform float margin = 0.01;

uniform vec3 transl = vec3(0, -5, 0);
uniform vec3 rotation = vec3(0, 0, 0);

const float glowScale = 1.0;
vec4 glowColor = vec4(0.5, 0.8, 1.0, 1.0);

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
    return min(sphereDist(p, vec3(0.0), 1.0), planeDist(p, -2.0));
}

//float scatter(vec3 p, vec3 vel) {	
//    
//}

vec3 calcNormal( in vec3 p ) {
    const float h = 0.0001;
    const vec2 k = vec2(1.0,-1.0);
    return normalize( k.xyy*f( p + k.xyy*h ) + 
                      k.yyx*f( p + k.yyx*h ) + 
                      k.yxy*f( p + k.yxy*h ) + 
                      k.xxx*f( p + k.xxx*h ) );
}

vec4 trace(vec2 p, vec3 transl) {
    vec2 s = vec2(p.x - iResolution.x/2.0f, p.y - iResolution.y/2.0f);
    vec3 raypos = transl;
    vec3 rayvel = normalize(vec3(s.x, 1000, s.y));
	rayvel = rotate(rotation, rayvel);
        
    vec4 color = vec4(0);
    
    float min = 1000.0;
    
    for(float i=0.0; i<maxsteps; i++) {
        float distance = f(raypos);
        raypos += rayvel * distance;
        
        if(distance < margin) {
            float gray = i/maxsteps;
            color = vec4(gray, gray, gray, 1.0);
            return color;
        }
        
        if(distance < min) {
            min = distance;
        }
        
    }
    return vec4(0.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
    
    fragColor = trace(fragCoord, transl);
    fragColor = pow(fragColor, vec4(1.0/2.2));
}

void main() {
	mainImage(gl_FragColor,gl_FragCoord.xy);
}