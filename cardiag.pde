import processing.serial.*;

Serial port;
int rpm = 0;
int vel = 0;
float fuelRate = 0;
void setup(){
    port = new Serial(this, "COM3", 38400);
    //port.bufferuntil('\r');
    size(1600,900);
    //ELMsetup();
}

String elmsend(String command){
    port.clear();
    port.write(command);
   // print("\nsending: "+command+"    got : ");
    String ans = "";
    int to = 0;
    while(port.available() == 0){
      to++;
      if (to > 5000){
        print ("timeout");
        return "TO";
      }
      delay(1);
    }
    to = 0;
    int c = 0;
    while(to < 100){
      if(port.available() > 0){
        char next = char(port.read());
        if (c>command.length()){ 
          ans = ans+next;
        }
        c++;
        to = 0;
      }
      delay(1);
      to++;
      
    }
    
    port.clear();
    //print(ans);
    return ans;
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
    
    
    /*
    04 engine load 0-255
    05 temp   A-40
    0B intake pressure kPa 0-255
    0D speed 0-255 km/h
    11 throttle 0-255
    2F fuel tank level input 0-255
    42 control module voltage 2byte mV
    5E fuel rate 2byte/20 L/h
    61 demanded torque A-125  %
    62 actual torque A-125  %
    
    */

    //atz atl1 ate0 ats0 atsp0 0100 atdp
    print(elmsend("atz"));
    
    //elmsend("atl1");
    elmsend("ate0");
    //elmsend("ats0");
    //elmsend("atsp0");
    //elmsend("0100");

    print(elmsend("atdp"));
}


int getrpm(){
  String ret =""+elmsend("010c");
  //println(ret.substring(0,min(ret.length(),6)));
  if(ret.substring(0,min(ret.length(),6)).equals("41 0C ")){
    String hexS = ( ret.substring(6,8)+ret.substring(9,11));
    
    rpm= unhex(hexS)/4 ;
    
  }
  return rpm;
}
float getfuelRate(){
  String ret =""+elmsend("0142");
  //println(ret.substring(0,min(ret.length(),6)));
  if(ret.substring(0,min(ret.length(),6)).equals("41 0C ")){
    String hexS = ( ret.substring(6,8)+ret.substring(9,11));
    
    fuelRate= unhex(hexS)/1000 ;
    
  }
  return fuelRate;
}
int getvel(){
  String ret = ""+elmsend("010d");
  //println(ret.substring(0,min(ret.length(),6)));
  if(ret.substring(0,min(ret.length(),6)).equals("41 0D ")){
    String hexS = ret.substring(6,8);
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
    //text("vel : "+getvel(),50,100);
    

    drawGauge(300,500,map(rpm,0,6000,0,1));
    drawGauge(1100,500,map(vel,0,180,0,1));

    

    delay(50);
}

void keyPressed(){
  float trpm = getrpm();
  float tvel = getvel();
  
  print(key);
  print(" ");
  print(trpm);
  print(" ");
  print(tvel);
  print(" ");
  println(trpm / tvel);
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
