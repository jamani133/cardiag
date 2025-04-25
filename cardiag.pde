import processing.serial.*;

Serial port;
int rpm = 0;
int vel = 0;
void setup(){
    port = new Serial(this, "COM3", 38400);
    //port.bufferuntil('\r');
    size(1200,900);
    ELMsetup();
}

String elmsend(String command){
    port.write(command);
    int to=0;
    delay(100);
    while(1>port.available()){
        delay(1);
        to++;
        if(to > 5000){
            return "timeout";
        }
    }
    return port.readString();
}

void ELMsetup(){
    //atz restart and preitn version
    //atl1 enable linefeed
    //atrv get voltage
    //ate0 echo off
    //atsp0 auto detect protoccol
    //0100 get some data
    //atdp get protocol name
    //010c get rpm (2byte 4*rpm)
    //010d get velocity (1byte speed)
    //ats0 spaces off

    //atz atl1 ate0 ats0 atsp0 0100 atdp
    //print(elmsend("atz"));
    //elmsend("atl1");
    //elmsend("ate0");
    //elmsend("ats0");
    //elmsend("atsp0");
    //elmsend("0100");
    //port.clear();
    //print(elmsend("atdp"));
}


int getrpm(){
  String ret = elmsend("010c");
  //println(ret.substring(0,min(ret.length(),6)));
  if(ret.substring(0,min(ret.length(),6)).equals("41 0C ")){
    String hexS = ( ret.substring(6,8)+ret.substring(9,11));
    
    rpm= unhex(hexS)/4 ;
    
  }
  return rpm;
}
int getvel(){
  String ret = elmsend("010d");
  //println(ret.substring(0,min(ret.length(),6)));
  if(ret.substring(0,min(ret.length(),6)).equals("41 0D ")){
    String hexS = ( ret.substring(6,8));
    
    vel= unhex(hexS) ;
    
  }
  return vel;
}

void draw(){
    background(0);
    textSize(50);
    noStroke();
    fill(255);
    //text("rpm : "+getrpm(),50,50);
    //text("rpm : "+getvel(),50,50);

    drawGauge(300,300,map(rpm,0,6000,0,1));


    delay(50);
}

void drawGauge(float posx, float posy, float val){
    strokeWeight(10);
    float angle = map(val,0,1,PI+0.5,-0.5);
    stroke(255,255,255);
    fill(40);
    strokeWeight(5);
    arc(posx,posy,580,580,PI-0.7,2*PI+0.7,PIE);
    
    stroke(255,0,0);
    line(posx,posy,250*cos(angle)+(posx),-250*sin(angle)+(posy));
}