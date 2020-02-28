import java.awt.AWTException;
import java.awt.Robot;

PShader TR;
Robot rb;

float fov = 90;

float maxsteps = 100;
float margin = 0.01;
float samples = 1;

float transx = 0;
float transy = -5;
float transz = 0;

float rotationX = 0;
float rotationY = 0;
float rotationZ = 0;

boolean lock = true;

float moveSpeed = 0.1;
float rotSpeed = 0.05;
float sensitivity = 0.001;

int robotMoveAmountX;
int robotMoveAmountY;


void setup() {
  size(800, 800, P2D);
  //fullScreen(P2D);
  
  TR = loadShader("Tracer.glsl");
  TR.set("maxsteps", maxsteps);
  TR.set("margin", margin);
  
  try
  {
    rb = new Robot();
  }
  catch (AWTException e)
  {
    println("Robot class not supported by your system!");
    exit();
  }
  
  noCursor();
}

void draw() {
  background(100, 150, 100);
  TR.set("iResolution", float(width), float(height));
  TR.set("transl", transx, transy, transz);
  TR.set("rotation", rotationX, rotationY, rotationZ);
  TR.set("samples", samples);
  
  println(frameRate);
  
  if(keyPressed) {
    if(key == 'w') {
      transRotate(new PVector(0, 1, 0));
    } else if (key == 's') {
      transRotate(new PVector(0, -1, 0));
    } else if (key == 'a') {
      transRotate(new PVector(-1, 0, 0));
    } else if (key == 'd') {
      transRotate(new PVector(1, 0, 0));
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
    } else if (key == 'g') {
      lock = !lock;
      if(lock) {
        noCursor();
      } else {
        cursor(HAND);
      }
    }
  }
  
  if(lock) {
    int dX = mouseX-pmouseX+robotMoveAmountX;
    int dY = mouseY-pmouseY+robotMoveAmountY;
    
    rb.mouseMove(displayWidth/2, displayHeight/2);
    
    robotMoveAmountX = mouseX-width/2;
    robotMoveAmountY = mouseY-height/2;
    
    rotationX -= dY*sensitivity;
    rotationZ -= dX*sensitivity;
  }
  
  shader(TR);
  rect(0, 0, width, height);
}

void transRotate(PVector vec3) {
  PVector zRot = new PVector(vec3.x, vec3.y);
  zRot.rotate(rotationZ);
  vec3 = new PVector(zRot.x, zRot.y, vec3.z);
  
  PVector yRot = new PVector(vec3.y, vec3.z);
  yRot.rotate(rotationX);
  vec3 = new PVector(vec3.x, yRot.x, yRot.z);
  
  transy += moveSpeed * vec3.y;
  transx += moveSpeed * vec3.x;
  transz += moveSpeed * vec3.z;
}
