class FloatImage {
  FloatColor[][] fImg;

  int imgWidth;
  int imgHeight;

  FloatImage(PImage img) {
    fImg = new FloatColor[img.width][img.height];
    imgWidth = img.width;
    imgHeight = img.height;

    for (int x=0; x<img.width; x++) {
      for (int y=0; y<img.height; y++) {
        fImg[x][y] = new FloatColor(img.get(x, y));
      }
    }
  }

  void average(float weight, FloatImage img) {
    for (int x=0; x < imgWidth; x++) {
      for (int y=0; y < imgHeight; y++) {
        fImg[x][y].average(weight, img.get(x, y));
      }
    }
  }

  FloatColor get(int x, int y) {
    return fImg[x][y];
  }

  PImage getImage() {
    PImage img = new PImage(imgWidth, imgHeight);
    
    for (int x=0; x<imgWidth; x++) {
      for (int y=0; y<imgHeight; y++) {
        img.set(x, y, fImg[x][y].getColor());
      }
    }
    
    return img;
  }
}

class FloatColor {
  float r;
  float g;
  float b;

  FloatColor(color c) {
    r = (float) red(c) / 255f;
    g = (float) green(c) / 255f;
    b = (float) blue(c) / 255f;
  }

  color getColor() {
    return color(r * 255, g * 255, b * 255);
  }

  void average(float weight, FloatColor col) {
    r = r * weight + col.r * (1.0 - weight);
    b = b * weight + col.b * (1.0 - weight);
    g = g * weight + col.g * (1.0 - weight);
  }
}
