PROGRAM Start_Stop
  VAR
    PB1 AT %QX1.1 : BOOL := FALSE;
    PB2 AT %QX1.2 : BOOL := FALSE;
    PB3 AT %QX1.3 : BOOL := FALSE;
    MIST AT %QX1.5 : BOOL;
    PB4 AT %QX1.4 : BOOL := FALSE;
    DHP AT %QX1.0 : BOOL;
    LEDOutput AT %QX0.0 : BOOL;
    DutyCycle AT %MW3 : INT := 0;
    pwmcounter AT %MW4 : INT := 0;
  END_VAR
  VAR
    _TMP_LT21_OUT : BOOL;
    _TMP_GE22_OUT : BOOL;
  END_VAR

  DHP := NOT(PB2) AND (DHP OR PB1);
  MIST := NOT(PB4) AND (MIST OR PB3);
  _TMP_LT21_OUT := LT(pwmcounter, DutyCycle);
  LEDOutput := _TMP_LT21_OUT;
  _TMP_GE22_OUT := GE(pwmcounter, DutyCycle);
  LEDOutput := NOT(_TMP_GE22_OUT);
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : Start_Stop;
  END_RESOURCE
END_CONFIGURATION
