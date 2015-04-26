#include <avr/sleep.h>

#define IR_SENSOR 2
#define LED 3
#define LED2 4
#define TRIGGER_COUNT 170
#define DIT_LENGTH 350

volatile byte inputState = 0;
volatile unsigned long lastPulse = 0;
volatile unsigned pulseCounter = 0;

void setup(void) {
  pinMode(IR_SENSOR, INPUT);  
  pinMode(LED, OUTPUT);      
  pinMode(LED2, OUTPUT); 

  attachInterrupt(0, irStateChange, LOW);

  set_sleep_mode(SLEEP_MODE_PWR_SAVE); // PWR_SAVE keeps timers running
  sleep_enable();
}

void loop(void) {
  sleep_mode();
  sleep_disable();

  if(inputState) {
    detachInterrupt(0);

    startSignal();

    morse("... --- ... ");

    inputState = 0;
    delay(1000);
    attachInterrupt(0, irStateChange, CHANGE);
  } 

  sleep_mode();
  sleep_disable();
}

void irStateChange() {
  unsigned long now = millis();
  unsigned long timeDiff = now - lastPulse;

  if(timeDiff < 1000) {
    pulseCounter++;
  }
  else {
    pulseCounter = 1;
  }

  if(pulseCounter > TRIGGER_COUNT) {      
    inputState = 1;      
    pulseCounter = 0;      
  }

  lastPulse = now;
}

void startSignal(void) {
  for(int i=0; i<100; i++) {
    digitalWrite(LED2, HIGH);
    delay(50);
    digitalWrite(LED2, LOW);
    delay(20);
  }
  delay(200);
}


void morse(String text) {
  const int length = text.length();

  char prev = '*';
  for(int i=0; i<length; i++) {

    const char c = text[i];

    switch(c) {
    case '.':
      dit(); 
      pause(1);
      break;
    case '-':
    case '_':
      dah();
      pause(1);
      break;
    case '/':
      if(prev == ' ')
        pause(2);
      else
        pause(6);
      break;
    case ' ':
      pause(2);
    }
    prev = c;
  }  
  pause(6);
}


void dit(void) {
  digitalWrite(LED, HIGH);
  pause(1);
  digitalWrite(LED, LOW);
}

void pause(int dits) {
  for(int i=0; i<dits; i++) {
    delay(DIT_LENGTH);
  }
}

void dah(void) {
  digitalWrite(LED, HIGH);
  pause(3);
  digitalWrite(LED, LOW);
}




