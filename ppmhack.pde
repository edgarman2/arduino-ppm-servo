#include <ServoTimer2.h>

#define NUM_CHAN    6
unsigned int serinp[NUM_CHAN]; //servo positions

int val;

ServoTimer2 servo1;
ServoTimer2 servo2;

long last_capture = 0L;
uint8_t radio_status = 0; // Radio channel read

void setup_timer1(){
  TCCR1A &= ~( _BV(COM1A0) | _BV(COM1A1) | _BV(COM1B0) | _BV(COM1B1));
  TCCR1A = ((1<<WGM10)|(1<<WGM11));
  TCCR1B = ((1<<WGM13)|(1<<WGM12)|(1<<CS11)|(1<<ICES1));

  OCR1A = 40000; // 0.5us tick => 50hz freq. The input capture routine
                 // assumes this 40000 for TOP.
  // Enable Input Capture interrupt
  TIMSK1 |= (1<<ICIE1);
}

void setup_timer2() {
   servo1.attach( 6 );
   servo2.attach( 9 );   
}

ISR(TIMER1_CAPT_vect){
  static uint16_t prev_icr;
  static uint8_t frame_idx;
  uint16_t icr;
  uint16_t pwidth;

  icr = ICR1;
  // Calculate pulse width assuming timer overflow TOP = 40000
  if ( icr < prev_icr ) {
    pwidth = ( icr + 40000 ) - prev_icr;
  } else {
    pwidth = icr - prev_icr;
  }

  // Was it a sync pulse? If so, reset frame.
  if ( pwidth > 8000 ) {
    frame_idx=0;
  } else {
    // Save pulse into _PWM_RAW array.
    if ( frame_idx < NUM_CHAN ) {
      serinp[ frame_idx++ ] = pwidth;
      if ( frame_idx >= NUM_CHAN ) {
         radio_status = 1;
         last_capture = millis();
      }
    }
  }
  // Save icr for next call.
  prev_icr = icr;

}

void setup() {
  pinMode( 8, INPUT ); //sum
  setup_timer1();
  setup_timer2();
  last_capture = millis();
  val = 1000;
  Serial.begin(57600);
}

void loop() {
   delay( 20 );

  servo1.write( serinp[ 0 ] >> 1 );
  servo2.write( serinp[ 1 ] >> 1 );
  for ( int i = 0; i < NUM_CHAN; i++ ) {
     Serial.print( serinp[ i ] ); 
     Serial.print( "," );
  }
  Serial.println();
}

