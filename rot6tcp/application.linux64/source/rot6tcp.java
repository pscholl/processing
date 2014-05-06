import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.net.*; 
import processing.serial.*; 
import jpcap.*; 
import jpcap.packet.*; 
import processing.opengl.*; 
import peasy.test.*; 
import peasy.org.apache.commons.math.*; 
import peasy.*; 
import peasy.org.apache.commons.math.geometry.*; 
import shapes3d.utils.*; 
import shapes3d.animation.*; 
import shapes3d.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class rot6tcp extends PApplet {



















Box box1,box2;
Rot nullrot=new Rot(1,0,0,0,false),
        rot1=new Rot(1,0,0,0,false),
        rot2=new Rot(1,0,0,0,false);
PeasyCam pCamera;
PMatrix3D baseMat;

Client rx;

public void setup()
{
  size(600, 600, P3D);

  rx = new Client(this, "localhost", 5555);

  box1 = new Box(this);
  box1.setSize(100,50,20);

  box2 = new Box(this);
  box2.setSize(100,50,20);

  baseMat = g.getMatrix(baseMat);

  pCamera = new PeasyCam(this, 300);
  pCamera.rotateX(PI/2);
  pCamera.lookAt(0, 0, 0, 280);

  textMode(SCREEN);
}

public void keyPressed() {
}

double distance = 0.f;
public double dot(Rot r1, Rot r2)   { return r1.getQ0()*r2.getQ0() + r1.getQ1()*r2.getQ1() + r1.getQ2()*r2.getQ2() + r1.getQ3()*r2.getQ3(); }
public double angle(Rot r1, Rot r2) { return 2.f / Math.PI * Math.acos( dot(r1,r2) ); }

public void clientEvent(Client p)
{
  String msg = "";
  float q0,q1,q2,q3;
  int id;

 if (p==null)
   return;

  msg = p.readStringUntil('\n');

 if (msg==null)
    return;

    System.out.println(msg);

  String[] list;
  msg = msg.trim();
  list = split(msg, '\t');

  if (list.length >= 5)
  {
    id=Integer.parseInt(list[0]);
    q0=Float.parseFloat(list[1]);
    q1=Float.parseFloat(list[2]);
    q2=Float.parseFloat(list[3]);
    q3=Float.parseFloat(list[4]);
    if (id==0) {
      rot1=new Rot(q0,q1,q2,q3,true);
      rot1=rot1.applyInverseTo(nullrot); // calculate inverse
    } else {
      rot2=new Rot(q0,q1,q2,q3,true);
      rot2=rot2.applyInverseTo(nullrot); // calculate inverse
    }

    distance = angle(rot1,rot2);
  }

}

public void draw()
{
  background(20);

  // stage lighting
  pushMatrix();
  g.setMatrix(baseMat);
  directionalLight(200, 200, 200, 100, 150, -100);
  ambientLight(160, 160, 160);
  popMatrix();

  scale(-1,-1,-1);

  /* apply the rotation to box 1*/
  pushMatrix();
  rotateX(rot1.getAngles(RotOrder.XYZ)[0]);
  rotateY(rot1.getAngles(RotOrder.XYZ)[1]);
  rotateZ(rot1.getAngles(RotOrder.XYZ)[2]);
  drawCoordinates(1);
  box1.draw();
  popMatrix();

  pushMatrix();
  translate(200,0);
  rotateX(rot2.getAngles(RotOrder.XYZ)[0]);
  rotateY(rot2.getAngles(RotOrder.XYZ)[1]);
  rotateZ(rot2.getAngles(RotOrder.XYZ)[2]);
  drawCoordinates(1);
  box2.draw();
  popMatrix();

  /* draw some text */
  pushMatrix();
  camera();
  textSize(16);
  fill(0,102,153,204);
  text(String.format("%.2f computed distance", distance), 10,20);
  popMatrix();
}

public void drawCoordinates(int x)
{
  strokeWeight(x);
  stroke(255,0,0);
  line(0,0,0,400,0,0);
  stroke(0,255,0);
  line(0,0,0,0,400,0);
  stroke(0,0,255);
  line(0,0,0,0,0,400);
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "rot6tcp" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
