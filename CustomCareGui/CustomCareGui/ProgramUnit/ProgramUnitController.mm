//
//  ProgramUnitController.m
//  CustomCareGui
//
//  Created by Mark Frank on 12/27/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import "ProgramUnitController.h"
#import "PrintController.h"
#import "AppDelegate.h"
#import "Patient.h"
#import "TreatmentProtocol.h"
#import "ProtocolProgram.h"
#import "CCInterface.h"           //Custom care programming interface

@interface ProgramUnitController ()
{
  CCInterface* m_ccInterface;         // Pointer! Will be initialized to NULL by alloc.
  bool         m_printPrograms;       // Print the programs in addition to protocol names
  bool         m_programmingUnit;     // True = still programming
}
@end

@implementation ProgramUnitController
@synthesize     statusText;
@synthesize     batteryVoltage;
@synthesize     batteryVoltText;
@synthesize     programProgress;
@synthesize     patient;

- (void)windowDidLoad
{
  [super           windowDidLoad];
  [programProgress setMinValue:0];
  [programProgress setMaxValue:10];
  [batteryVoltage  setMinValue:0.];
  [batteryVoltage  setMaxValue:9.];   //9 volt battery
}

//********************************************************
// Set the app delegate who owns us
//********************************************************
- (void)setAppDelegate: (id)delegate
{
  appDelegate     = delegate;
  patient         = [delegate selectedPatient];
  if(m_ccInterface == NULL)
    m_ccInterface = new CCInterface();
  [statusText      setStringValue:@"Ready to Check Unit"];
  [batteryVoltText setStringValue:@"Not checked"];
  [batteryVoltage  setDoubleValue:0.];
  NSString *title = @"Programming Unit for ";
  title           = [title stringByAppendingFormat:@"%@%@%@", patient.patientFirstName, @" ",
                                                              patient.patientLastName];
  [[self window] setTitle:title];
}

//********************************************************
// Check the unit
//********************************************************
- (IBAction)checkUnit:  (id)sender
{
  [statusText setStringValue:@"Checking Custom Care Unit"];
  [statusText display];
  if(![self checkUnitStatus])
    return;
  double voltage;
  bool rtnValue         = m_ccInterface->GetBatteryVoltage(voltage);
  if(rtnValue != true)
  {
    [statusText setStringValue:@"Can't check battery voltage\nIs unit turned on, and plugged in?"];
    return;
  }
  NSString *voltString  = [NSString stringWithFormat:@"%3.1f V", voltage];
  [batteryVoltage     setMinValue:0.];
  [batteryVoltage     setMaxValue:9.];
  [batteryVoltage     setDoubleValue:voltage];
  [batteryVoltText    setStringValue:voltString];
}

//********************************************************
// Program the unit
//********************************************************
- (IBAction)programUnit:(id)sender
{
  m_programmingUnit = true;
  [NSThread detachNewThreadSelector:@selector(programmingThread) toTarget:self withObject:nil];
}

//********************************************************
// Cancel the programming
//********************************************************
- (IBAction)cancelProgramUnit:      (id)sender
{
  m_programmingUnit = false;
}


//********************************************************
//Intercept window closing as window delegate
//********************************************************
- (void)windowWillClose:(NSNotification *)notification
{
  delete m_ccInterface;
  m_ccInterface = NULL;
}

//********************************************************
//Exit the programming
//********************************************************
- (IBAction)exitProgramming:(id)sender
{
  [[self window] close];
}

//********************************************************
// Prints the patient's prescription
//********************************************************
- (IBAction)printFullPrescription: (id)sender
{
  m_printPrograms   = true;
  [self               startPrint];
}

//********************************************************
// Prints the patient's prescription
//********************************************************
- (IBAction)printBriefPrescription: (id)sender
{
  m_printPrograms   = false;
  [self               startPrint];
}

//********************************************************
// Returns the text to be printed for the print controller
//********************************************************
- (NSString *) textToPrint
{
  NSString *textToPrint       = [[self patient] getPatientPrescription:m_printPrograms];
  return textToPrint;
}

/////////////////// PRIVATE METHODS /////////////////////

#define DRIVER_LOCN "/System/Library/Extensions/ProlificUsbSerial.kext"
#define DEV_LOCN    "/dev/cu.KeySerial1"
//********************************************************
//Check unit status
//********************************************************
- (bool)checkUnitStatus
{
  [statusText setStringValue:@"Checking Custom Care Unit"];
  eErrorCodes errorCode = m_ccInterface->init();
  switch(errorCode)
  {
    case  eNoError:                  //!< No error when init() is run
      [statusText setStringValue:@"Unit is Ready to Program"];
      return YES;
    case ePortNotReady:             //!< Serial port not ready either driver not installed
                                    //   or usb not plugged in
    {
      bool driverInstalled  = [[NSFileManager defaultManager] fileExistsAtPath:@DRIVER_LOCN];
      if(!driverInstalled)
      {
        [statusText setStringValue:@"Tripplite driver not installed.\nGo to Tripplite.com, go to the \nsupport page, search for USA-19HS. Download\nthe driver for MacOS X 10.9 to 10.11"];
      }
      else
      {
        bool driverOk       = [[NSFileManager defaultManager] fileExistsAtPath:@DEV_LOCN];
        if(!driverOk)
        {
          [statusText setStringValue:@"Tripplite driver corrupt. Go to \nTripplite.com, go to the support page,\nsearch for USA-19HS. Download\nthe driver for MacOS X 10.9 to 10.11"];
        }
        else
        {
          [statusText setStringValue:@"Can't communicate with Custom Care\nUnit.  Is the USB cable plugged into\nyour Mac?"];
        }
      }
      m_ccInterface->closePort();
      return NO;
    }
    case eCustomCareNotReady:       //!< CustomCare not ready (e.g., went to sleep)
      [statusText setStringValue:@"Custom Care is not responding.\nIs it turned on, and plugged in?"];
      m_ccInterface->closePort();
      return NO;
    default:
      return NO;
  }
}


//********************************************************
// Program the unit
//********************************************************
- (void)programmingThread
{
  [self performSelectorOnMainThread:@selector(setStatusTextTo:)  withObject:@"Checking Custom Care Unit"
                                                                 waitUntilDone:true];
  if(![self checkUnitStatus])
    return;
  [self performSelectorOnMainThread:@selector(setProgressBarTo:) withObject:@0.5 waitUntilDone:true];
  [self performSelectorOnMainThread:@selector(setStatusTextTo:)  withObject:@"Setting Date and Times"
                                                                 waitUntilDone:true];
  if(![self programDateAndTimesFor:patient])
  {
    [self performSelectorOnMainThread:@selector(setStatusTextTo:)  withObject:@"Couldn't set date and time on unit.\nIs it still plugged in?"
                                                                   waitUntilDone:true];
  }
  if(!m_programmingUnit)    // We got aborted
  {
    [self performSelectorOnMainThread:@selector(setStatusTextTo:)  withObject:@"Programming Cancelled"
                                                                   waitUntilDone:true];
    return;
  }
  [self performSelectorOnMainThread:@selector(setProgressBarTo:) withObject:@1.0 waitUntilDone:true];
  [self performSelectorOnMainThread:@selector(setStatusTextTo:)  withObject:@"Clearing old Treatments"
                                                                 waitUntilDone:true];
  if(![self         clearTreatments])
  {
    [self performSelectorOnMainThread:@selector(setStatusTextTo:)  withObject:@"Couldn't clear old treatments.\nIs it still plugged in?"
                        waitUntilDone:true];
    return;
  }
  if(!m_programmingUnit)    // We got aborted
  {
    [self performSelectorOnMainThread:@selector(setStatusTextTo:)  withObject:@"Programming Cancelled"
                                                                   waitUntilDone:true];
    return;
  }
  long numberProtocols  = [patient.patientListOfProtocols count];
  int protocolIndex     = 1;
  for(long i=0; i<numberProtocols; i++)
  {
    TreatmentProtocol* currentProtocol = [patient.patientListOfProtocols objectAtIndex:i];
    NSString* progressString           = [NSString stringWithFormat:@"%@%@",@"Programming: ",
                                          currentProtocol.protocolName];
    NSNumber* progressNumber           = [NSNumber numberWithFloat:2.0+8.*i/numberProtocols];
    [self performSelectorOnMainThread:@selector(setProgressBarTo:) withObject:progressNumber
                                          waitUntilDone:true];

    [self performSelectorOnMainThread:@selector(setStatusTextTo:) withObject:progressString
                                          waitUntilDone:true];
    if([self  programProtocol:currentProtocol index:protocolIndex])
    {
      protocolIndex++;
    }
    if(!m_programmingUnit)    // We got aborted
    {
      [self performSelectorOnMainThread:@selector(setStatusTextTo:)  withObject:@"Programming Cancelled"
                                                                     waitUntilDone:true];
      return;
    }
  }
  [self performSelectorOnMainThread:@selector(setProgressBarTo:) withObject:@10.
                      waitUntilDone:true];
  [self performSelectorOnMainThread:@selector(setStatusTextTo:) withObject:@"Programming Finished"
                      waitUntilDone:true];
}

//********************************************************
//Set the current date and time and the expiration dates
//********************************************************
- (bool)programDateAndTimesFor:(Patient*)currentPatient
{
  NSDateComponents* comps = [self componentsFromDate:[NSDate date]];
  int year                = (int)[comps year] - 2000;
  int month               = (int)[comps month];
  int day                 = (int)[comps day];
  int dayOfWeek           = (int)[comps weekday];
  int hour                = (int)[comps hour];
  int minute              = (int)[comps minute];
  int second              = (int)[comps second];
  bool rtnValue           = m_ccInterface->SetDateAndTime(year, month, day, dayOfWeek, hour, minute, second);
  if(!rtnValue)
    return false;
  comps                   = [self componentsFromDate:currentPatient.patientExpirationDate];
  year                    = (int)[comps year] - 2000;
  month                   = (int)[comps month];
  day                     = (int)[comps day];
  rtnValue                = m_ccInterface->SetExpirationDate(year, month, day);
  if(!rtnValue)
    return false;
  rtnValue                = m_ccInterface->SetMaximumTreatmentTime(currentPatient.patientMaxTreatmentHours);
  return rtnValue;
}

//********************************************************
//Erase old programs
//********************************************************
- (bool)clearTreatments
{
  bool rtnValue      = m_ccInterface->ClearTreatments();
  return rtnValue;
}

const int kMAX_CHARS    = 33;
const int kMAX_PROGRAMS = 99;
//********************************************************
//Program a single protocol
//********************************************************
- (bool)programProtocol:(TreatmentProtocol *)protocol index:(long)index
{
  //The name and instructions are each a maximum of 16 characters
  char nameAndInstr[kMAX_CHARS];
  strncpy(nameAndInstr,      [protocol.protocolName cStringUsingEncoding:NSUTF8StringEncoding], 16);
  for(int i=0; i<16; i++)
  {
    if(nameAndInstr[i] == '\0')
      nameAndInstr[i] = ' ';
  }
  if(protocol.protocolInstructions != nil)
    strncpy(&nameAndInstr[16], [protocol.protocolInstructions cStringUsingEncoding:NSUTF8StringEncoding], 16);
  long numberPrograms = [protocol.protocolPrograms count];
  if(numberPrograms == 0)
  {
    [self performSelectorOnMainThread:@selector(showNoProgramsAlert) withObject:nil
                        waitUntilDone:true];
    return false;
  }
  if(numberPrograms > kMAX_PROGRAMS)
  {
    [self performSelectorOnMainThread:@selector(showTooManyProgramsAlert) withObject:nil
                        waitUntilDone:true];
  }
  bool rtnValue       = m_ccInterface->SetModeAndTitle((int)index, nameAndInstr);
  for(long i=0; i<numberPrograms; i++)
  {
    if(![self programProgram:[protocol.protocolPrograms objectAtIndex:i] index:i+1])
    {
      rtnValue        = NO;
      break;
    }
  }
  return rtnValue;
}

const float kScaleFactor  = 10.;    //Not sure why this is needed, wants it in 10ths of Hertz?
const int   kMinFrequency = 1;
const int   kMaxFrequency = 9999;
const int   kMinCurrent   = 20;
const int   kMaxCurrent   = 720;
const int   kMinTime      = 1;
const int   kMaxTime      = 999;
//********************************************************
//Program a single program
//********************************************************
- (bool)programProgram:(ProtocolProgram *)program index:(long)index
{
  DataTreatment treatment;
  if([program.programWaveShape isEqualToString:@"Gentle"])
    strcpy(treatment.m_waveShape, "G");
  else if([program.programWaveShape isEqualToString:@"Mild"])
    strcpy(treatment.m_waveShape, "M");
  else if([program.programWaveShape isEqualToString:@"Sharp"])
    strcpy(treatment.m_waveShape, "S");
  else
    strcpy(treatment.m_waveShape, "P");
  if([program.programPolarity isEqualToString:@"Negative"])
    strcpy(treatment.m_polarity,  "N");
  else if([program.programPolarity isEqualToString:@"Positive"])
    strcpy(treatment.m_polarity,  "P");
  else
    strcpy(treatment.m_polarity,  "A");
  treatment.m_f1      = MAX(kMinFrequency,
                            (round(kScaleFactor*[program.programFreq1 doubleValue])));
  treatment.m_f1      = MIN(kMaxFrequency,treatment.m_f1);
  treatment.m_f2      = MAX(kMinFrequency,
                            (round(kScaleFactor*[program.programFreq2 doubleValue])));
  treatment.m_f2      = MIN(kMaxFrequency,treatment.m_f2);
  treatment.m_current = MAX(kMinCurrent, ([program.programCurrent  intValue]));
  treatment.m_current = MIN(kMaxCurrent, (treatment.m_current));
  treatment.m_time    = MAX(kMinTime,    ([program.programDuration intValue]));
  treatment.m_time    = MIN(kMaxTime,    (treatment.m_time));
  bool rtnValue       = m_ccInterface->SetTreatmentData((int)index, treatment);
  //For debugging:
  if(rtnValue == false)
    return false;
  return rtnValue;
}

//********************************************************
//Set the progress bar
//********************************************************
- (void)setProgressBarTo:(double)value string:(NSString *)textString
{
  [programProgress  setDoubleValue:value];
  [programProgress  display];
  [statusText       setStringValue:textString];
  [statusText       display];
}

//********************************************************
//Set the progress bar
//********************************************************
- (void)setProgressBarTo:(NSNumber *)value
{
  [programProgress  setDoubleValue:[value floatValue]];
  [programProgress  display];
}

//********************************************************
//Set the progress bar
//********************************************************
- (void)setStatusTextTo:(NSString *)textString
{
  [statusText       setStringValue:textString];
  [statusText       display];
}

//********************************************************
//Starts the print operation
//********************************************************
- (void) startPrint
{
  if(!printController)
  {
    printController  = [[PrintController alloc] initWithWindowNibName:@"PrintController"];
  }
  [printController showWindow:self];
  //This will cause the print controller to call back to textToPrint
  [printController setAppDelegate:self];
}

//********************************************************
// Show alert message for Too Many Programs
//********************************************************
- (void) showTooManyProgramsAlert
{
  NSAlert *alert      = [[NSAlert alloc] init];
  [alert addButtonWithTitle:@"OK"];
  [alert setMessageText:@"Custom Care accepts a maximum of 99 programs"];
  [alert setInformativeText:@"Only the first 99 programs will be saved"];
  [alert setAlertStyle:NSWarningAlertStyle];
  [alert runModal];
}

//********************************************************
// Show alert message for No Programs
//********************************************************
- (void) showNoProgramsAlert
{
  NSAlert *alert      = [[NSAlert alloc] init];
  [alert addButtonWithTitle:@"OK"];
  [alert setMessageText:@"No programs for this protocol"];
  [alert setInformativeText:@"This protocol will be skipped"];
  [alert setAlertStyle:NSWarningAlertStyle];
  [alert runModal];
}

//********************************************************
//Set the current date and time and the expiration dates
//********************************************************
- (NSDateComponents *)componentsFromDate:(NSDate*)date
{
  NSCalendar *calendar    = [NSCalendar currentCalendar];
  NSDateComponents *comps = [calendar components:NSCalendarUnitYear   |
                                                 NSCalendarUnitMonth  |
                                                 NSCalendarUnitDay    |
                                                 NSCalendarUnitHour   |
                                                 NSCalendarUnitMinute |
                                                 NSCalendarUnitSecond |
                                                 NSCalendarUnitWeekday
                                        fromDate:date];
  return comps;
}


@end
