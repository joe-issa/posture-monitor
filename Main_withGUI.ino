//Flex Sensor Pin
const int flex = A0;    

//Motor Driver Pins
const int ENA = 10;
const int IN1 = 8;
const int IN2 = 9;

//Buzzer Pin
const int buzzer = 12;

//Code constants
const int threshold = 88;
const int good_max = 104;
const int bad_time = 10; // consecutive seconds of bad posture that trigger the buzzer
const int too_long = 20; // consecutive seconds of sitting in the same place (confined posture range) that trigger the buzzer
const int relief = 15;  // consecutive seconds of sitting in the same place (confined posture range) that trigger a 5 second massage
const float scale[] = {130.8128,  146.8324,  164.8138,  174.6141,  195.9977,  220.0000,  246.9417,  261.6256};

//Code variables
int counter = 0;
int how_long = 0;
String mode = "monitor";
int user_state = 0; //0: good posture. 1:bad posture. 2:long sit. 3:massage mode.

void setup() {
  Serial.begin(9600);
  Serial.println(String(threshold) + "," + String(good_max) + "," + String(bad_time) + "," + String(too_long));
  pinMode(flex, INPUT);
  
  pinMode(ENA, OUTPUT);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);

  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);

  pinMode(buzzer,OUTPUT);

  delay(1000);
}



void loop() {

//GUI Input
  if(Serial.available()){  //If Serial gets an input
    char message = Serial.read();
    //Serial.println(message);
    if(message == 'a'){      
      //Serial.println("Massage mode activated");
      mode = "massage";
      counter = 0;
      how_long = 0;
      user_state = 3;
      startMotor();
      }
    if(message == 'o'){       
      //Serial.println("Monitor mode activated");
      mode = "monitor";
      counter = 0;
      how_long = 0;
      user_state = 0;
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, LOW);
      }
    }

int flex_ADC = analogRead(flex);
//Core Code
  if(mode=="monitor") {
     //Serial.print("ADC value: ");
     //Serial.println(flex_ADC);      

    if (flex_ADC < threshold) {
      counter += 1;
}

    if (flex_ADC > threshold && counter>0) {
      counter = 0;
      user_state = 0;
}

    if (flex_ADC > threshold && flex_ADC < good_max ) {
      how_long += 1;      
}
else {
      how_long = 0;
      user_state = 0;
  }

    //Serial.println("Bad posture for: " + String(counter) + " seconds");
    //Serial.println("Same Posture for: " + String(how_long) + " seconds");
    
    if (counter >= bad_time) {
      int i = counter-10;
      int f = constrain(i, 0, 7);
      tone(buzzer,scale[f]);
      delay(500);
      noTone(buzzer);
      delay(500);     
      user_state = 1;   
     }

    if (how_long >= too_long ) {
      tone(buzzer,110);
      delay(500);
      noTone(buzzer);
      delay(500);        
      user_state = 2;
     }

    if ( (how_long%relief) == 0 && how_long != 0 && how_long != too_long ) {
      startMotor();
      user_state = 3;
      Serial.println(String(user_state) + "," + String(flex_ADC) + "," + String(counter) + "," + String(how_long));
      massage(5000); 
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, LOW);      
      user_state = 0;
     }
    
  delay(1000);
     
  }

  if(mode=="massage"){
    massage(1000);
    }

    Serial.println(String(user_state) + "," + String(flex_ADC) + "," + String(counter) + "," + String(how_long));
    //Serial.println(user_state);
    //Serial.println(flex_ADC);
    //Serial.println(counter);
    //Serial.println(how_long);
}

void startMotor(){
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  for (int i = 0; i < 256; i++) {
    analogWrite(ENA, i);
    delay(4);
}
}

void massage(int i) {
    analogWrite(ENA, 255); //Not needed but safer
    //Serial.println("Massaging...");
    delay(i);
  }
    
