
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

Box box;
Rot nullrot=new Rot(1,0,0,0,false),
        rot=new Rot(1,0,0,0,false);
PeasyCam pCamera;
PMatrix3D baseMat;

Serial rx;

void setup()
{
  size(1000, 1000, P3D);
  
  rx = new Serial(this, Serial.list()[0], 9600);
  rx.bufferUntil('\n'); 

  box = new Box(this);
  box.setSize(100,50,20);
  baseMat = g.getMatrix(baseMat);
  
  pCamera = new PeasyCam(this, 300);
  pCamera.rotateX(PI/2);
  pCamera.lookAt(0, 0, 0, 280);
}

void keyPressed() {
}

void serialEvent(Serial p)
{
  String msg = "";
  float ts,scalar,x,y,z;
 
 if (p==null)
   return;
 
  msg = p.readString();
  
  if (msg==null)
    return;
    
  //System.out.println(msg);
  
  String[] list;
  msg = msg.trim();
  list = split(msg, '\t');
  
  if (list != null && list.length == 4)
  {
    //ts=Float.parseFloat(list[0]);
    scalar=Float.parseFloat(list[0]);
    x=Float.parseFloat(list[1]);
    y=Float.parseFloat(list[2]);
    z=Float.parseFloat(list[3]);
    rot=new Rot(scalar,x,y,z,true);
    rot=rot.applyInverseTo(nullrot); // calculate inverse
  }
}

void draw()
{
  background(20);
  
 
  
//  // stage lighting
  pushMatrix();
  g.setMatrix(baseMat);
  directionalLight(200, 200, 200, 100, 150, -100);
  ambientLight(160, 160, 160);
  popMatrix();
  
  /* to align the axes of the jNode to the processing world 
   * coordinates, we have to:
   *  (a) mirror the z-axis
   *  (b) use the inverse rotation (which is calculated in clientEvent) */
  scale(1,1,1); // mirror on z-axis
  
  /* apply the rotation */
  rotateX(rot.getAngles(RotOrder.XYZ)[0]);
  rotateY(rot.getAngles(RotOrder.XYZ)[1]);
  rotateZ(rot.getAngles(RotOrder.XYZ)[2]);
  
  drawCoordinates(1);
  box.draw();
}

void drawCoordinates(int x)
{
  strokeWeight(x);
  stroke(255,0,0);
  line(0,0,0,400,0,0);
  stroke(0,255,0);
  line(0,0,0,0,400,0);
  stroke(0,0,255);
  line(0,0,0,0,0,400);
}
