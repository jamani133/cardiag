import processing.serial.*;

Serial port;

void setup(){
    port = new Serial(this, "COMxx", 38400);
    //port.bufferuntil('\r');
    size(1200,900);
    ELMsetup();
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
    print(ELMSend("atz",10000));
    //ELMSend("atl1");
    ELMSend("ate0");
    ELMSend("ats0");
    ELMSend("atsp0");
    ELMSend("0100");
    port.clear();
    print(ELMSend("atdp"));
}

String ELMsend(String command, int timeout = 1000){
    port.print(command);
    int to=0;
    while(1>port.available()){
        delay(1);
        to++;
        if(to > timeout){
            return "timeout";
        }
    }
    return port.readStringUntil(">");
}


void draw(){
    background(0);
    textSize(50);
    text("rpm : "+ELMSend("010c"),0,0);
    delay(500);
}