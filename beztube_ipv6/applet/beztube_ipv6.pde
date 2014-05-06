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

PMatrix3D baseMat;
PeasyCam pcam;
BezTube tubes[];
Box box;
JpcapCaptor rx;

LinkedHashMap<String,Rot> map = new LinkedHashMap<String,Rot>();

static final float RADIUS=5, HALFR=50;
static int i=0;

Rot nullrot=new Rot(1,0,0,0,false);

void setup()
{
  size(600,600,P3D);
  
  try {
  jpcap.NetworkInterface device = JpcapCaptor.getDeviceList()[1];
  rx = JpcapCaptor.openDevice(device,65535,false,1);
  //rx.setFilter("src port 2020", false);
  System.out.println(device.name);
  } catch (Exception e) {
    System.out.println(e);
    System.exit(-1);
  }
  
  //map.put("a", new Rot(RotOrder.XYZ, PI/4,0,0));
  //map.put("b", new Rot(RotOrder.XYZ, PI/4,0,0));
  //map.put("c", new Rot(RotOrder.XYZ, PI/4,0,0));
  
  baseMat=g.getMatrix(baseMat);
  pcam = new PeasyCam(this,300);
  pcam.rotateY(PI/2-PI/5);
  pcam.lookAt(0,0,0,280);
}

public static String toHexString(byte[]bytes) {
    StringBuilder sb = new StringBuilder(bytes.length*2);
    for(byte b: bytes)
      sb.append(Integer.toHexString(b+0x800).substring(1));
    return sb.toString();
}

// ClientEvent message is generated when the server 
// sends data to an existing client.
void rxpacket()
{
  Packet p;
  String msg = "", addr = "";
  float ts,q0,q1,q2,q3;
  
  while ((p=rx.getPacket())!=null) {
    if (p.data.length<10)
      continue;

    // strip UDP header and extract data
    msg = new String(Arrays.copyOfRange(p.data, 8,p.data.length-1));
    addr = toHexString(Arrays.copyOfRange(p.header,22,38));
  }
  
  String[] list;
  msg = msg.trim();
  list = split(msg, ' ');
  Rot rot;

  if (list.length >= 5)
  {
    ts=Float.parseFloat(list[0]);
    q0=Float.parseFloat(list[1]);
    q1=Float.parseFloat(list[2]);
    q2=Float.parseFloat(list[3]);
    q3=Float.parseFloat(list[4]);
    rot=new Rot(q0,q1,q2,q3,true);
    //rot=rot.applyInverseTo(nullrot); // calculate inverse
    
    map.put(addr,rot);
  }

  if (msg!="") {
//    System.out.print(addr);
//    System.out.print(" ");
//    System.out.println(msg);
  }
}

void draw()
{
  background(20);
  
  rxpacket();
  
  // stage lighting
  pushMatrix();
  g.setMatrix(baseMat);
  directionalLight(200, 200, 200, 100, 150, -100);
  ambientLight(160, 160, 160);
  popMatrix();
  
  PVector cpts[] = makeTriPts(map.values().toArray(new Rot[0]));
  updateTubes(cpts);
 
  Rot meh[] = map.values().toArray(new Rot[0]);
  float angles[] = meh[0].getAngles(RotOrder.XYZ);
  System.out.print(angles[0]);
  System.out.print(" ");
  System.out.print(angles[1]);
  System.out.print(" ");
  System.out.print(angles[2]);
  System.out.println();
 
  for (BezTube tube : tubes )
    tube.draw();

  // draw lines  
  stroke(color(0,255,0));
  noFill();
  beginShape();
  for (PVector cp : cpts) {
    vertex(cp.x,cp.y,cp.z);
  }
  endShape();
  
  // points
  stroke(color(255,0,0));
  noFill();
  beginShape(POINTS);
  for (PVector cp : cpts) {
    pushMatrix();
    translate(cp.x,cp.y,cp.z);
    sphere(2);
    popMatrix();
  }
  endShape();
}

PVector[] makeTriPts(Rot rots[])
{
  List<PVector> p = new ArrayList<PVector>();
  PVector cur = new PVector(0, 0,0),
            r = new PVector(0,HALFR,0);
  
  for (Rot rot : rots)
  {
    p.add(cur);
    cur = PVector.add(cur,r);
    p.add(cur);
    r = rot.applyTo(r);
    cur = PVector.add(cur,r);
    p.add(cur);
  }
  
  return (PVector[]) p.toArray(new PVector[0]);
}

void updateTubes(PVector[] ctrlpts)
{
  updateTubes(ctrlpts,3);
}

static int oldlen=0;

void updateTubes(PVector[] ctrlpts, int n)
{
  if (tubes==null || oldlen!=ctrlpts.length) {
    tubes = new BezTube[ctrlpts.length/n];
    oldlen=ctrlpts.length;
  }
    
  if (ctrlpts.length%n!=0)
    System.out.println("need controlpoint array %3==0");
  
  PVector[] list = null;
  for (int i=0; i<ctrlpts.length; i++) {
    if (i%n==0) list = new PVector[n];
    list[i%n] = ctrlpts[i];
    if (i%n==(n-1)) {
      if (tubes[i/n]==null)
        tubes[i/n] = new BezTube(this,new Bezier3D(list,list.length),RADIUS,30,30);
      else
        tubes[i/n].setBez(new Bezier3D(list,list.length));
    }
  }
}
