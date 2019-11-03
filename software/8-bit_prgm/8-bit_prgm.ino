#define CTL_IPH A2
#define CTL_IPL A3
#define CTL_WH A0
#define CTL_WL A1
#define EN 13

#define BPORT PORTE //pins 2-9 on the Mega
#define BDDR DDRE

#define B0 2
#define B1 3
#define B2 4
#define B3 5
#define B4 6
#define B5 7
#define B6 8
#define B7 9

#define PULSE_LEN 500

#include "data.h"

void pulseHigh(int pin) {
  digitalWrite(pin, HIGH);
  delayMicroseconds(PULSE_LEN / 2);
  digitalWrite(pin, LOW);
  delayMicroseconds(PULSE_LEN / 2);
}

void pulseLow(int pin) {
  digitalWrite(pin, LOW);
  delayMicroseconds(PULSE_LEN / 2);
  digitalWrite(pin, HIGH);
  delayMicroseconds(PULSE_LEN / 2);
}

void out(int pin, int data) {
  //BPORT = data & 255;

  digitalWrite(B0, data & 1);
  digitalWrite(B1, (data >> 1) & 1);
  digitalWrite(B2, (data >> 2) & 1);
  digitalWrite(B3, (data >> 3) & 1);
  digitalWrite(B4, (data >> 4) & 1);
  digitalWrite(B5, (data >> 5) & 1);
  digitalWrite(B6, (data >> 6) & 1);
  digitalWrite(B7, (data >> 7) & 1);
  
  if(pin == CTL_IPH || pin == CTL_IPL) {
    pulseHigh(pin);
  } else if(pin == CTL_WH || pin == CTL_WL) {
    pulseLow(pin);
  }
}

void setup() {
  // put your setup code here, to run once:
  pinMode(CTL_IPH, OUTPUT); digitalWrite(CTL_IPH, LOW);
  pinMode(CTL_IPL, OUTPUT); digitalWrite(CTL_IPL, LOW);

  pinMode(CTL_WH, OUTPUT); digitalWrite(CTL_WH, HIGH);
  pinMode(CTL_WL, OUTPUT); digitalWrite(CTL_WL, HIGH);

  pinMode(EN, OUTPUT); digitalWrite(EN, HIGH);

  //BDDR = 255;
  pinMode(B0, OUTPUT);
  pinMode(B1, OUTPUT);
  pinMode(B2, OUTPUT);
  pinMode(B3, OUTPUT);
  pinMode(B4, OUTPUT);
  pinMode(B5, OUTPUT);
  pinMode(B6, OUTPUT);
  pinMode(B7, OUTPUT);
  BPORT = 0;

  digitalWrite(EN, LOW);

  for(int iph = 0; iph <= (dataLen >> 8); iph++) {
    out(CTL_IPH, iph);
    for(int ipl = 0; ipl < 256 && ((iph << 8) | ipl) < dataLen; ipl++) {
      int index = (iph << 8) | ipl;
      out(CTL_IPL, ipl);
      out(CTL_WH, data[index] >> 8);
      out(CTL_WL, data[index] & 255);
    }
  }
  
  digitalWrite(EN, HIGH);
}

void loop() {
  
}
