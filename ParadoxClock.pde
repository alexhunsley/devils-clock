/**
 * Clock. 
 * 
 * The current time can be read with the second(), minute(), 
 * and hour() functions. In this example, sin() and cos() values
 * are used to set the position of the hands.
 */

int cx, cy;
float secondsRadius;
float secondsRadiusB;
float minutesRadius;
float hoursRadius;
float clockDiameter;
float numeralRadius;
PFont font;

// pradox clock: entire thing must rotate 5.5 whole turns CC every half day! ( = 1980 degrees)

void setup() {
  size(640, 640);
  stroke(255);
  frameRate(1);
  
  font = createFont("Arial",16,true); // STEP 2 Create Font
  
  int radius = min(width, height) / 2;
  secondsRadius = radius * 0.72;
  secondsRadiusB = radius * 0.75;
  minutesRadius = radius * 0.60;
  hoursRadius = radius * 0.50;
  clockDiameter = radius * 1.8;
  numeralRadius = radius * 0.785;
  
  cx = width / 2;
  cy = height / 2;
}

void draw() {
  background(0);

  float ss = second();
  float mm = minute();
  float hh = hour();
  
  // force 15
  //hh = 16.5;
  //mm = 30.0;
  //ss = 0.0;

  // force midnight
  //hh = 0.0;
  //mm = 0.0;
  //ss = 0.0;

  // force 12am
  //hh = 12.0;
  //mm = 0.0;
  //ss = 0.0;

// 11 hour clock first hour point
  //hh = 1.0;
  //mm = 5.0;
  //ss = 45.0;

  float totalMinutes = hh * 60.0 + mm + ss / 60.0;
  
  float percentageThroughDay = hh / 24.0  +  mm / (60.0 * 24.0)  +  ss / (60.0 * 60.0 * 24.0);
  
  // Angles for sin() and cos() start at 3 o'clock;
  // subtract HALF_PI to make them start at the top
  float s = map(ss, 0, 60, 0, TWO_PI) - HALF_PI;
  float m = map(mm + norm(ss, 0, 60), 0, 60, 0, TWO_PI) - HALF_PI; 
  float h = map(hh + norm(mm, 0, 60), 0, 24, 0, TWO_PI * 2) - HALF_PI;

  // digital time
  textAlign(LEFT);

  fill(200);
  textFont(font, 30);
  // coord is left baseline of font
  
  String timeStr = nf((int)hh, 2) + ":" + nf((int)mm, 2) + ":" + nf((int)ss, 2);
  text(timeStr, 10, 60);

  translate(cx, cy);

  push();

  //float amountRot = 2 * -360.0 * 5.5 * percentageThroughDay;

  float amountRot = -totalMinutes * 13.0 / 4.0;

  print("Degrees amount is " + amountRot);
  
  // note the half_pi, due to 0 degrees being 3pm, not midday
  //rotate(radians(- 360.0 * 11.0 * percentageThroughDay ) - HALF_PI/2);
  rotate(radians(amountRot));

  print(" %% is: " + percentageThroughDay + "\n");
  
  // Draw the clock background
  fill(40);
  noStroke();
  ellipse(0, 0, clockDiameter, clockDiameter); 
  
  // Draw the hands of the clock
  stroke(255);
  strokeWeight(1);
  line(0, 0, cos(s) * secondsRadius, sin(s) * secondsRadius);
  strokeWeight(2);
  line(0, 0, cos(m) * minutesRadius, sin(m) * minutesRadius);
  strokeWeight(4);
  line(0, 0, cos(h) * hoursRadius, sin(h) * hoursRadius);
  
  // Draw the minute ticks
  strokeWeight(2);
  for (int a = 0; a < 360; a+=6) {
    beginShape();
    float angle = radians(a);
    float x = cos(angle) * secondsRadius;
    float y = sin(angle) * secondsRadius;
    vertex(x, y);
    if (a % 30 == 0) {
      float x2 = cos(angle) * secondsRadiusB;
      float y2 = sin(angle) * secondsRadiusB;
      vertex(x2, y2);
    }
    endShape();
  }

  // draw hour numerals
  fill(200);
  textAlign(CENTER);
  for (int hr = 0; hr < 12; hr++) {
    float angle = radians(float(hr) * (360.0 / 12.0));
    float x = sin(angle) * numeralRadius;
    float y = -cos(angle) * numeralRadius;

    //String numeral = str((12 + hr) % 13);
    String numeral = str(hr % 12);
    if (numeral.equals("0")) {
      numeral = "12";
    }

    push();
    translate(x, y);
    rotate(angle);
    text(numeral, 0, 0);
    pop();
  }
  
  pop(); // undo the push for entire clock rotation
}
