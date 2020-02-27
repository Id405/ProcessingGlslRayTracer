PShader TR;

float fov = 90;

float maxsteps = 250;
float margin = 0.05;

float transx = 0;
float transy = -5;
float transz = 0;

float rotationX = 0;
float rotationY = 0;
float rotationZ = 0;

float moveSpeed = 0.1;
float rotSpeed = 0.05;


void setup() {
  size(800, 800, P2D);
  //fullScreen(P2D);
  
  TR = loadShader("Tracer.glsl");
  TR.set("maxsteps", maxsteps);
  TR.set("margin", margin);
}

void draw() {
  background(100, 150, 100);
  TR.set("iResolution", float(width), float(height));
  TR.set("transl", transx, transy, transz);
  TR.set("rotation", rotationX, rotationY, rotationZ);
  
  println(frameRate);
  
  if(keyPressed) {
    if(key == 'w') {
      transRotate(new PVector(0, 1, 0));
    } else if (key == 's') {
      transy -= moveSpeed;
    } else if (key == 'a') {
      transx -= moveSpeed;
    } else if (key == 'd') {
      transx += moveSpeed;
    } else if (key == ' ') {
      transz += moveSpeed;
    } else if (key == 'c') {
      transz -= moveSpeed;
    } else if (keyCode == UP) {
      rotationX += rotSpeed;
    } else if (keyCode == DOWN) {
      rotationX -= rotSpeed;
    } else if (keyCode == LEFT) {
      rotationZ += rotSpeed;
    } else if (keyCode == RIGHT) {
      rotationZ -= rotSpeed;
    }
  }
  
  shader(TR);
  rect(0, 0, width, height);
}

void transRotate(PVector vec3) {
  PVector zRot = new PVector(vec3.x, vec3.y);
  zRot.rotate(rotationZ);
  vec3 = new PVector(zRot.x, zRot.y, vec3.z);
  
  PVector yRot = new PVector(vec3.x, vec3.z);
  yRot.rotate(rotationX);
  vec3 = new PVector(yRot.x, vec3.y, yRot.z);
  
  transy += moveSpeed * vec3.y;
  transx += moveSpeed * vec3.x;
  transz += moveSpeed * vec3.z;
}
