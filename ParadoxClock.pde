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
float secondaryNumeralRadius;
PFont font;

int hoursOnClock = 12;
int hoursInDay = 2 * hoursOnClock;

int faceBrightness = 40;
int textMaxBrightness = 100;

int fps = 30;
int drawSeconds = 0;
int secsIncrement = 30;

int ss = 0;
int mm = 0;
int hh = 0;

// pradox clock: entire thing must rotate 5.5 whole turns CC every half day! ( = 1980 degrees)

void setup() {
  size(640, 640);
  stroke(255);
  frameRate(fps);
  
  font = createFont("Arial", 16, true);
  
  int radius = min(width, height) / 2;
  secondsRadius = radius * 0.72;
  secondsRadiusB = radius * 0.75;
  minutesRadius = radius * 0.60;
  hoursRadius = radius * 0.50;
  clockDiameter = radius * 1.8;
  numeralRadius = radius * 0.785;
  secondaryNumeralRadius = radius * 0.65;
  
  cx = width / 2;
  cy = height / 2;
}

void updateDemoClock() {
  ss = (ss + secsIncrement) % 60;
  if (ss == 0) {
    mm = (mm + 1) % 60;
    if (mm == 0) {
      hh = (hh + 1) % hoursInDay;
      //if (hh == 0) {
      //  hh = 1;
      //}
    }
  }
}

void draw() {
  background(0);

  updateDemoClock();
  //float ss = second();
  //float mm = minute();
  //float hh = hour();
  

  //float totalMinutes = hh * 60.0 + mm + ss / 60.0;
  
 
  float percentageThroughDay = hh / float(hoursInDay)  +  mm / (60.0 * float(hoursInDay))  +  ss / (60.0 * 60.0 * float(hoursInDay));
  
  //println("PC: " + percentageThroughDay);
  // Angles for sin() and cos() start at 3 o'clock;
  // subtract HALF_PI to make them start at the top
  float s = map(float(ss), 0, 60.0, 0.0, TWO_PI); // - HALF_PI;
  float m = TWO_PI * (float(mm) + float(ss) / 60.0) / 60.0; // - HALF_PI;
  float h = TWO_PI * (float(hh) + float(mm) / 60.0 + float(ss)/ 3600.0) / float(hoursOnClock); // - HALF_PI;

  // digital time
  textAlign(LEFT);

  fill(200);
  // coord is left baseline of font
  
  textFont(font, 30);

  String timeStr = nf((int)hh, 2) + ":" + nf((int)mm, 2) + ":" + nf((int)ss, 2);
  text(timeStr, 20, 60);

  translate(cx, cy);

  push();

  //float amountRot = -totalMinutes * 13.0 / 4.0;

  float totalTurnsNeeded = (hoursOnClock + 1);
  
  float amountRot = -totalTurnsNeeded * 360.0 * percentageThroughDay;
  
  //print("Degrees amount is " + amountRot);
  
  // note the half_pi, due to 0 degrees being 3pm, not midday
  //rotate(radians(- 360.0 * 11.0 * percentageThroughDay ) - HALF_PI/2);
  rotate(radians(amountRot));

  //print(" %% is: " + percentageThroughDay + "\n");
  
  // Draw the clock background
  fill(faceBrightness);
  noStroke();
  ellipse(0, 0, clockDiameter, clockDiameter); 
  
  // Draw the hands of the clock
  stroke(255);
  
  if (drawSeconds > 0) {
    strokeWeight(1);
    line(0, 0, sin(s) * secondsRadius, -cos(s) * secondsRadius);
  }
  
  strokeWeight(2);
  line(0, 0, sin(m) * minutesRadius, -cos(m) * minutesRadius);

  float hourMinDiff = constrain((h % TWO_PI - m  % TWO_PI) % TWO_PI, - HALF_PI, HALF_PI);
  //println("diff clamp % PI: " + hourMinDiff + "  h: " + h + " m: " + m);
  
  hourMinDiff = constrain(hourMinDiff, -HALF_PI, HALF_PI);
  
  textFont(font, 15);
  
  float textBrightness = pow(cos(hourMinDiff), 10.0); 
  fill(map(textBrightness, 0.0, 1.0, faceBrightness, textMaxBrightness));

  //println("cos gives: " + textBrightness);
  
  push();
  rotate(m - HALF_PI);
  textAlign(LEFT);
  text("d e v i l ' s", 15, -10);
  pop();

  strokeWeight(4);
  line(0, 0, sin(h) * hoursRadius, -cos(h) * hoursRadius);
  
  push();
  rotate(h - HALF_PI);
  textAlign(LEFT);
  text("c l o c k", 100, -10);
  pop();

  // Draw the minute ticks
  strokeWeight(2);
  for (int a = 0; a < 360; a+=6) {
    beginShape();
    float angle = radians(a);
    float x = sin(angle) * secondsRadius;
    float y = -cos(angle) * secondsRadius;
    vertex(x, y);
    if (a % (360 / hoursOnClock) == 0) {
      float x2 = sin(angle) * secondsRadiusB;
      float y2 = -cos(angle) * secondsRadiusB;
      vertex(x2, y2);
    }
    endShape();
  }

  // draw n hour numerals
  fill(200);
  textFont(font, 30);

  textAlign(CENTER);
  for (int hr = 0; hr < hoursOnClock; hr++) {
    float angle = radians(float(hr) * (360.0 / hoursOnClock));
    float x = sin(angle) * numeralRadius;
    float y = -cos(angle) * numeralRadius;

    String numeral = str(hr % hoursOnClock);
    if (numeral.equals("0")) {
      numeral = str(hoursOnClock);
    }

    push();
    translate(x, y);
    rotate(angle);
    text(numeral, 0, 0);
    pop();
  }

  // draw n-1 hour numerals
  textFont(font, 20);
  fill(200, 140, 140);
  textAlign(CENTER);
  for (int hr = 0; hr < (hoursOnClock - 1); hr++) {
    float angle = radians(float(hr) * (360.0 / (hoursOnClock - 1)));
    float x = sin(angle) * secondaryNumeralRadius;
    float y = -cos(angle) * secondaryNumeralRadius;

    //String numeral = str((12 + hr) % 13);
    String numeral = str(hr % (hoursOnClock - 1));
    if (numeral.equals("0")) {
      numeral = str(hoursOnClock - 1);
    }

    push();
    translate(x, y);
    rotate(angle);
    text(numeral, 0, 0);
    pop();
  }

  pop(); // undo the push for entire clock rotation
  
  //saveFrame("######.tif");
}
