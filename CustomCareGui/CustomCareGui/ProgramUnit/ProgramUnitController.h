//
//  ProgramUnitController.h
//  CustomCareGui
//
//  Created by Mark Frank on 12/27/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Patient;
@class TreatmentProtocol;
@class PrintController;
@class ProtocolProgram;

@interface ProgramUnitController : NSWindowController <NSWindowDelegate>
{
  id                          appDelegate;               // Pointer to the app delegate who owns us
  PrintController*            printController;           // Controller for printing the output
}
//Outlets
@property(weak) IBOutlet NSTextField*   statusText;       // Table containing the protocols
@property(weak) IBOutlet NSSlider*      batteryVoltage;   // Table containing the patients
@property(weak) IBOutlet NSTextField*   batteryVoltText;  // The text field for battery voltage
@property(weak) IBOutlet NSSlider*      programProgress;  // Progress progamming the unit

@property (strong) Patient*             patient;          // Patient info for the program

//Setters
- (void)setAppDelegate:       (id)delegate;

//IB actions
- (IBAction)checkUnit:              (id)sender;
- (IBAction)programUnit:            (id)sender;
- (IBAction)cancelProgramUnit:      (id)sender;
- (IBAction)exitProgramming:        (id)sender;
- (IBAction)printFullPrescription:  (id)sender;
- (IBAction)printBriefPrescription: (id)sender;
- (NSString *)textToPrint;


//Private methods
- (bool)checkUnitStatus;
- (void)programmingThread;
- (bool)programDateAndTimesFor:(Patient*)currentPatient;
- (bool)clearTreatments;
- (bool)programProtocol: (TreatmentProtocol *)protocol index: (long)index;
- (bool)programProgram:  (ProtocolProgram   *)program  index: (long)index;
- (void)setProgressBarTo:(double             )value    string:(NSString *)textString;
- (void)setProgressBarTo:(NSNumber *)value;
- (void)setStatusTextTo: (NSString *)textString;
- (void)startPrint;
- (void)showTooManyProgramsAlert;
- (void)showNoProgramsAlert;

- (NSDateComponents *)componentsFromDate:(NSDate*)date;

@end
