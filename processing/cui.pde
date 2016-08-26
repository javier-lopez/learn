//-@-

size(600, 480);
colorMode(HSB, 360, 100, 100);

//color int
int pink = color(340, 15, 100);

//shape int, pignose and eyes will change as the value changes
int nose = 500;

noStroke();
background(360);

//ears, rect
fill(pink*3);
rect(100, 50 , 150, 150, 8);
rect(350, 50 , 150, 150, 8);

//face and nose, circle
fill(pink);
ellipse(width/2, height/2, 440, 400); //face

fill(pink*2);
ellipse(300, 300 , nose/3, nose/4);//nose

fill(200);
ellipse(270, 300, nose/15, nose/7);//left
ellipse(330, 300, nose/15, nose/7);//right

//eyes, circle
fill(150);
ellipse(200, 170, nose/5, nose/40);
ellipse(400, 170, nose/5, nose/40);
