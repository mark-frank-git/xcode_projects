#ifndef CustomCare_CCCmdStrings_h
#define CustomCare_CCCmdStrings_h
/************************************************************************
 *                                                                      *
 * This header files has the definitions of the command strings that    *
 * can be sent to the CustomCare unit.                                  *
 *                                                                      *
 * File:CCCmdStrings.h                                                  *
 *                                                                      *
 * Revision history:                                                    *
 *  1. Sept. 01, 2014 - Started.                                        *
 ************************************************************************/
// Get command strings
char kGetStrings[eSizeOfGets][3]  = {"M\r","G\r","J\r","Q\r","V\r","Z\r","S\r","D\r","B\r","?\r"};

// Command terminator string
char kTerminatorCmdStr[2]         = "\r";


// Set command strings
char kWakeUpCmdStr[1]             = "";
char kSetCurrentModeStr[2]        = "M";  // Note: This needs to be followed by mode number
char kSetCurrentModeTitleStr[2]   = "G";  // Note: this needs to be followed by mode title=string
char kSetMaxTreatmentMinsStr[3]   = "R="; // Note: this needs to be followed by number of minutes
char kSetTreatmentParameterStr[2] = "T";  // Note: this needs to be followed by treatment number=W,F1,F2,
                                          // C,T,P,A, where W='G','M','S', or 'P' (gentle, mild, sharp,
                                          // pulse), F1= 10xfreq1, F2 = 10xfreq2, C is current in uA from
                                          // 20 to 720 by 10s.  T= time in minutes from 1 to 999.  P is
                                          // is polarity and can be, 'N','P', or 'A'.  A = 'A' for auto.
char kSetDateAndTimeStr[3]        = "Q="; // This needs to be followed by yymmddwwhhmmss, where ww =
                                          // day of week
char kSetExpirationDateStr[3]     = "X="; // This needs to be followed by yymmdd
char kSetDirectionsStr[2]         = "Z";  // This needs to be followed by direction number (1 to 9?), then
                                          // "=40characters_of_text"
char kClearDirectionsStr[3]       = "Z=";     // clear out all directions
char kClearTreatmentsStr[3]       = "K=";     // clear out all treatments
char kSetEnableUnitStr[6]         = "!=mct";  // This needs to be followed by the serial number of the unit
char kSetLockUnitStr[3]           = "L\r";
char kSetToggleEchoStr[2]         = "E";
char kSetResetIdleTimeStr[3]      = "Y\r";




#endif
