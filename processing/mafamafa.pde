size(500, 500);
//http://www.planetozkids.com/images/acedetectives/desert-sand-dunes.jpg

//color(20, 187, 190);

/*PImage b;
b = loadImage("/Library/Application Support/Apple/iChat Icons/Planets/Earth (Australasia).gif");
background(b);
*/
background(200, 60, 50);
noFill();

/*I started out by doing it on a (100, 100) sized sketch to make numbers
simpler. Then I made the triangle on a (50, 50, 40, 60, 60, 60); scale,
then I adjusted the sketch to the size I wanted (a multiple of 100) and
multiplied the other values by that same value.
*/

triangle(250, 270, 200, 350, 300, 350);

//I can't get the color function to work. Trying to make a turquoise.

ellipse(250, 245, 10, 10);
ellipse(250, 245, 20, 20);
ellipse(250, 245, 30, 30);
ellipse(250, 245, 40, 40);
ellipse(250, 245, 50, 50);
ellipse(250, 245, 60, 60);
ellipse(250, 245, 70, 70);

ellipse(220, 240, 5, 5);
ellipse(220, 240, 10, 10);
ellipse(220, 240, 15, 15);
ellipse(220, 240, 20, 20);
ellipse(220, 240, 25, 25);
ellipse(220, 240, 30, 30);

ellipse(235, 220, 5, 5);
ellipse(235, 220, 10, 10);
ellipse(235, 220, 15, 15);
ellipse(235, 220, 20, 20);
ellipse(235, 220, 25, 25);
ellipse(235, 220, 30, 30);

ellipse(260, 220, 5, 5);
ellipse(260, 220, 10, 10);
ellipse(260, 220, 15, 15);
ellipse(260, 220, 20, 20);
ellipse(260, 220, 25, 25);
ellipse(260, 220, 30, 30);

ellipse(275, 240, 5, 5);
ellipse(275, 240, 10, 10);
ellipse(275, 240, 15, 15);
ellipse(275, 240, 20, 20);
ellipse(275, 240, 25, 25);
ellipse(275, 240, 30, 30);

//legs
line(220, 350, 200, 390);
line(280, 350, 300, 390);

//left arm
line(230, 300, 195, 300);
line(195, 300, 195, 270);
line(195, 270, 180, 270);

//right arm
line(270, 300, 305, 300);
line(305, 300, 305, 270);
line(305, 270, 320, 270);
