void setup(){
  size(500, 500);
  background(60);
  frameRate(30);
}

void draw(){
  noCursor();
  smooth();

  if(mousePressed == true) {
     fill(60, 40);
     rect(0, 0, 500, 500);
     float transp2 = random(60, 150);

     fill(255, transp2);
     noStroke();


     fill(0, 255, 255, 60);
     triangle(mouseX-5, mouseY, mouseX + 5, mouseY, random(500), 0);
     triangle(mouseX-5, mouseY, mouseX + 5, mouseY, random(500), 500);
     filter(BLUR, .6);

     fill(255);
     ellipse(mouseX + random(-50, 50), mouseY + random(-50, 50), 50, 50);
     ellipse(mouseX + random(-60, 60), mouseY + random(-60, 60), 50, 50);
     ellipse(mouseX + random(-60, 60), mouseY + random(-60, 60), 50, 50);
     ellipse(mouseX + random(-20, 20), mouseY + random(-10, 10), 100, 100);
     ellipse(mouseX + random(-20, 20), mouseY + random(-10, 10), 100, 100);

     strokeWeight(2);
     stroke(0);
     //draw face
     line(mouseX - 17, mouseY, mouseX - 11, mouseY - 5);
     line(mouseX - 11, mouseY - 5, mouseX - 5, mouseY);

     line(mouseX + 17, mouseY, mouseX + 11, mouseY - 5);
     line(mouseX + 11, mouseY - 5, mouseX + 5, mouseY);

     line(mouseX - 7, mouseY + 7, mouseX + 7, mouseY + 7);


  }

  else {
     fill(60, 60);
     rect(0, 0, 500, 500);
     float transp2 = random(60, 150);

     fill(255, transp2);
     noStroke();

     ellipse(mouseX + random(-50, 50), mouseY + random(-50, 50), 50, 50);
     ellipse(mouseX + random(-60, 60), mouseY + random(-60, 60), 50, 50);
     ellipse(mouseX + random(-60, 60), mouseY + random(-60, 60), 50, 50);
     ellipse(mouseX + random(-20, 20), mouseY + random(-10, 10), 100, 100);
     ellipse(mouseX + random(-20, 20), mouseY + random(-10, 10), 100, 100);

     strokeWeight(2);
     stroke(0);
     //draw face
     line(mouseX - 17, mouseY, mouseX - 11, mouseY - 5);
     line(mouseX - 11, mouseY - 5, mouseX - 5, mouseY);

     line(mouseX + 17, mouseY, mouseX + 11, mouseY - 5);
     line(mouseX + 11, mouseY - 5, mouseX + 5, mouseY);

     line(mouseX - 7, mouseY + 7, mouseX + 7, mouseY + 7);

   }
}
