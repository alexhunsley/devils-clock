import g4p_controls.*;

/**
 * Clock. 
 * 
 * The current time can be read with the second(), minute(), 
 * and hour() functions. In this example, sin() and cos() values
 * are used to set the position of the hands.
 */
GSlider sdr;
int cx, cy;
float secondsRadius;
float secondsRadiusB;
float minutesRadius;
float hoursRadius;
float clockDiameter;
float numeralRadius;
float secondaryNumeralRadius;
PFont font;

int hoursOnClock = 4;
int hoursInDay = 2 * hoursOnClock;

float timeDirectionFactor = -1.0;

int faceBrightness = 40;
int faceDotsBrightness = 80;
int textMaxBrightness = 100;

int fps = 30;
int drawSeconds = 0;
int secsIncrement = 10;

float ss = 0;
float mm = 0;
float hh = 0;

int demoMode = 1;

// hades' timepiece
//float alpha = 12.0/11.0;

// Alpha parameter for clock.
// Popular with our customers:
//
// normal clock:       -1/11
// prioritise hours:   0
// devil's clock:      0.5
// prioritise minutes: 1
// hades' timepiece:   12/11
//
// (recommend CCW time dir for the 
// best hades' timepiece effect!)


//float alpha = -1.0/11.0;
float alpha = 12.0/11.0;

float numRotationsPerDay = (hoursInDay - 2) * alpha + 2.0;

// pradox clock: entire thing must rotate 5.5 whole turns CC every half day! ( = 1980 degrees)

void setup() {
  size(640, 640);
  stroke(255);
  frameRate(demoMode == 1 ? fps : 1);
  
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
  
  G4P.setCursor(CROSS);
  //sdr = new GSlider(this, -cx + 20, cy - 50, 200, 40, 15);
  sdr = new GSlider(this, 10, 10, 200, 40, 15);
  
  sdr.setNbrTicks(11);
  sdr.setLimits(0, 0, 1);
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

public void handleSliderEvents(GValueControl slider, GEvent event) {
  println();
  
  alpha = sdr.getValueF();
  numRotationsPerDay = 22.0 * alpha + 2.0;

  println("alpha = " + alpha);
}

void draw() {
  background(0);

  if (demoMode == 1) {
    updateDemoClock();
  }
  else {
    ss = second();
    mm = minute();
    hh = hour();
  }

  //float totalMinutes = hh * 60.0 + mm + ss / 60.0;
  
 
  float percentageThroughDay = hh / float(hoursInDay)  +  mm / (60.0 * float(hoursInDay))  +  ss / (60.0 * 60.0 * float(hoursInDay));
  
  //println("PC: " + percentageThroughDay);
  // Angles for sin() and cos() start at 3 o'clock;
  // subtract HALF_PI to make them start at the top
  float s = map(ss, 0, 60.0, 0.0, TWO_PI); // - HALF_PI;
  float m = TWO_PI * (mm + ss / 60.0) / 60.0; // - HALF_PI;
  float h = TWO_PI * (hh + mm / 60.0 + ss / 3600.0) / float(hoursOnClock); // - HALF_PI;

  // digital time
  textAlign(LEFT);

  fill(200);
  // coord is left baseline of font
  
  textFont(font, 30);

  String timeStr = nf((int)hh, 2) + ":" + nf((int)mm, 2) + ":" + nf((int)ss, 2);
  text(timeStr, 20, 60);

  push();

  translate(cx, cy);

  //float amountRot = -totalMinutes * 13.0 / 4.0;

  
  //float totalTurnsNeeded = (hoursOnClock + 1);
  //float amountRot = -totalTurnsNeeded * 360.0 * percentageThroughDay;

  float amountRot = timeDirectionFactor * (-numRotationsPerDay * 360.0 * percentageThroughDay);
  
  //print("Degrees amount is " + amountRot);
  
  // note the half_pi, due to 0 degrees being 3pm, not midday
  //rotate(radians(- 360.0 * 11.0 * percentageThroughDay ) - HALF_PI/2);
  rotate(radians(amountRot));

  //print(" %% is: " + percentageThroughDay + "\n");
  
  // Draw the clock background
  fill(faceBrightness);
  noStroke();
  ellipse(0, 0, clockDiameter, clockDiameter); 
  
  
    // Draw the minute ticks
  strokeWeight(2);
  stroke(faceDotsBrightness);
  
  float mult;
  float multSlide;
  float multPower = 0.7;
  float multSlidePower = 0.5;
  int numMultSteps = 3;
  float useRadius;
  
  for (int a = 0; a < 360; a+=6) {
    float angle = radians(a);

    mult = 1.0;
    multSlide = 1.0;

    useRadius = secondsRadius;
    
    for (int multSteps = 0; multSteps < numMultSteps; multSteps++) {
      float angleOffset;
      
      if (multSteps == 0) {
        stroke(255);
        angleOffset = 0;
      }
      else {
        stroke(faceDotsBrightness);
        angleOffset = multSteps == 0 ? 0 : -percentageThroughDay * 10.0 / multSlide;  
      }
      
      float cs = -cos(timeDirectionFactor*(angle + angleOffset));
      float sn = sin(timeDirectionFactor*(angle + angleOffset));

      float x = sn * useRadius;
      float y = cs * useRadius;

      beginShape();
  
      vertex(x, y);
      if (multSteps == 0 && a % (360 / hoursOnClock) == 0) {
        float x2 = sn * secondsRadiusB;
        float y2 = cs * secondsRadiusB;
        vertex(x2, y2);
      }
      endShape();
      
      mult *= multPower;
      multSlide *= multSlidePower;
      useRadius = secondsRadius * mult;
      
      //angleOffset += PI/30.0 / numMultSteps;
    }
    
    //useRadius *= mult;
  }
  
  
  // Draw the hands of the clock
  stroke(255);
  
  if (drawSeconds > 0) {
    strokeWeight(1);
    line(0, 0, sin(timeDirectionFactor * s) * secondsRadius, -cos(timeDirectionFactor * s) * secondsRadius);
  }
  
  strokeWeight(2);
  line(0, 0, sin(timeDirectionFactor * m) * minutesRadius, -cos(timeDirectionFactor * m) * minutesRadius);

  float hourMinDiff = constrain((h % TWO_PI - m  % TWO_PI) % TWO_PI, - HALF_PI, HALF_PI);
  //println("diff clamp % PI: " + hourMinDiff + "  h: " + h + " m: " + m);
  
  hourMinDiff *= 3.0;
  
  hourMinDiff = constrain(hourMinDiff, -HALF_PI, HALF_PI);
  
  textFont(font, 15);
  
  float textBrightness = cos(hourMinDiff); 
  fill(map(textBrightness, 0.0, 1.0, faceBrightness, textMaxBrightness));

  //println("cos gives: " + textBrightness);
  
  push();
  rotate(timeDirectionFactor * m - HALF_PI);
  textAlign(LEFT);
  text("d e v i l ' s", 15, -10);
  pop();

  strokeWeight(4);
  line(0, 0, sin(timeDirectionFactor * h) * hoursRadius, -cos(timeDirectionFactor * h) * hoursRadius);
  
  push();
  rotate(timeDirectionFactor * h - HALF_PI);
  textAlign(LEFT);
  text("c l o c k", 100, -10);
  pop();
  
  // draw n hour numerals
  fill(200);
  textFont(font, 30);

  textAlign(CENTER);
  for (int hr = 0; hr < hoursOnClock; hr++) {
    float angle = timeDirectionFactor * radians(float(hr) * (360.0 / hoursOnClock));
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
    float angle = timeDirectionFactor * radians(float(hr) * (360.0 / (hoursOnClock - 1)));
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
