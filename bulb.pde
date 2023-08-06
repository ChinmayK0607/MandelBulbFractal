import peasy.*;

// Set the dimensions of the grid
int DIM = 256;
PeasyCam cam;  // PeasyCam for interactive 3D camera control
ArrayList<MandelPoint> mandelbulb = new ArrayList<MandelPoint>();  // ArrayList to store MandelPoint objects
StringList points = new StringList();  // StringList to store points data as strings
int maxiterations = 20;  // Maximum number of iterations for the Mandelbulb calculation

// Class to represent a point in the Mandelbulb
class MandelPoint {
  PVector v;  // 3D vector representing the point's coordinates
  float i;    // Iteration value for the point

  MandelPoint(PVector v, float i) {
    this.v = v;
    this.i = i;
  }
}

void setup() {
  size(600, 600, P3D);  // Set the canvas size and mode to 3D
  cam = new PeasyCam(this, 600);  // Initialize the camera for interactive navigation

  // Loop through the grid to calculate Mandelbulb points
  for (int i = 0; i < DIM; i++) {
    for (int j = 0; j < DIM; j++) {
      boolean edge = false;
      int lastIteration = 0;
      
      // Iterate through the third dimension of the grid
      for (int k = 0; k < DIM; k++) {
        // Map grid indices to the range -1 to 1
        float x = map(i, 0, DIM, -1, 1);
        float y = map(j, 0, DIM, -1, 1);
        float z = map(k, 0, DIM, -1, 1);

        PVector zeta = new PVector(0, 0, 0);
        int n = 8;
        int iteration = 0;
        
        // Calculate Mandelbulb points
        while (true) {
          Spherical c = spherical(zeta.x, zeta.y, zeta.z);
          float newx = pow(c.r, n) * sin(c.theta * n) * cos(c.phi * n);
          float newy = pow(c.r, n) * sin(c.theta * n) * sin(c.phi * n);
          float newz = pow(c.r, n) * cos(c.theta * n);
          zeta.x = newx + x;
          zeta.y = newy + y;
          zeta.z = newz + z;
          iteration++;

          if (c.r > 2) {
            lastIteration = iteration;
            if (edge) {
              edge = false;
            }
            break;
          }
          if (iteration > maxiterations) {
            if (!edge) {
              edge = true;
              mandelbulb.add(new MandelPoint(new PVector(x * 200, y * 200, z * 200), lastIteration));
              points.append(x + " " + y + " " + z);
            }
            break;
          }
        }
      }
    }
  }
  
  // Save the calculated Mandelbulb points to a text file
  String[] output = points.array();
  saveStrings("mandelbulb.txt", output);
}

// Class to represent a point in spherical coordinates
class Spherical {
  float r, theta, phi;

  Spherical(float r, float theta, float phi) {
    this.r = r;
    this.theta = theta;
    this.phi = phi;
  }
}

// Function to convert Cartesian coordinates to spherical coordinates
Spherical spherical(float x, float y, float z) {
  float r = sqrt(x * x + y * y + z * z);
  float theta = atan2(sqrt(x * x + y * y), z);
  float phi = atan2(y, x);
  return new Spherical(r, theta, phi);
}

void draw() {
  background(0);  // Set the background color to black
  rotateX(PI / 4);  // Rotate the scene along the X-axis
  rotateY(-PI / 3);  // Rotate the scene along the Y-axis
  colorMode(HSB, 255);  // Set color mode to HSB
  
  // Draw Mandelbulb points
  for (MandelPoint m : mandelbulb) {
    stroke(map(m.i, 0, maxiterations, 255, 0), 255, 255);  // Map color based on iteration count
    strokeWeight(1);
    point(m.v.x, m.v.y, m.v.z);  // Draw a point in 3D space
  }
}
