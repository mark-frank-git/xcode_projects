//
//  AppDelegate.h
//  CustomCareGui
//
//  Created by Mark Frank on 12/13/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CppPatientReader.h"
@class ProtocolBankController;
@class PatientEditorController;
@class ProtocolEditorController;
@class BankEditorController;
@class ProgramUnitController;
@class PrintController;
@class Patient;
@class TreatmentProtocol;                                   // We couldn't use just "Protocol" since this
                                                            // is already defined in Objective C
@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate>
{
  ProtocolBankController*     protocolBankController;       // Controller for Protocol bank window
  PatientEditorController*    patientEditorController;      // Controller for patient editor window
  ProtocolEditorController*   protocolEditorController;     // Controller for Protocol editor window
  BankEditorController*       bankEditorController;         // Controller for Protocol Bank editor window
  ProgramUnitController*      programUnitController;        // Controller for program unit window
  PrintController*            printController;              // Controller for printing the output
  IBOutlet NSArrayController* patientsArrayController;      // Controller for list of patients
  IBOutlet NSArrayController* protocolsArrayController;     // Controller for list of Protocols
}
@property (strong) NSMutableArray*        patients;         // The set of patients edited here
@property (strong) NSMutableArray*        protocols;        // The set of protocols for the selected patient
@property (weak)   IBOutlet NSTableView*  protocolTableView;// Table containing the protocols
@property (weak)   IBOutlet NSTableView*  patientTableView; // Table containing the patients
@property (weak)   IBOutlet NSBox*        protocolSurroundingBox; // Box surrounding protocolTableView
@property (weak)   IBOutlet NSButton*     programButton;    // Program custom care button
@property (weak)   IBOutlet NSButton*     modifyButton;     // Modify Protocol Bank button

// Methods responding to menu items
- (IBAction)savePatient:            (id)sender;
- (IBAction)saveAllPatients:        (id)sender;
- (IBAction)readPatient:            (id)sender;               // From File->Open
- (IBAction)readListOfPatients:     (id)sender;

// Methods responding to patient push buttons
- (IBAction)addNewPatient:          (id)sender;
- (IBAction)deletePatient:          (id)sender;
- (IBAction)editPatient:            (id)sender;
- (IBAction)printFullPrescription:  (id)sender;
- (IBAction)printBriefPrescription: (id)sender;

// Methods responding to protocol push buttons
- (IBAction)addProtocolFromBank:    (id)sender;
- (IBAction)addEmptyProtocol:       (id)sender;
- (IBAction)deleteProtocol:         (id)sender;
- (IBAction)editProtocol:           (id)sender;
- (IBAction)moveSelectedUp:         (id)sender;
- (IBAction)moveSelectedDown:       (id)sender;

// Methods responding to program unit push button
- (IBAction)programUnit:            (id)sender;

// Methods responding to protocol bank editor push button
- (IBAction)editProtocolBank:       (id)sender;

// Methods called by Sub-window Controllers
- (Patient *)          selectedPatient;                     // Called by Patient Editor & Program Unit Ctrlrs
- (TreatmentProtocol* )protocolToBeEdited;                  // Called by Protocol Editor Controller
- (void)               insertProtocolFromBank:(TreatmentProtocol *)newProtocol;
- (NSString *)         textToPrint;
- (void)               setNewProtocolBankFile:(NSString *)newFile;

// Private methods
- (Patient  *)         getDummyPatient;
- (NSString *)         getPatientName;
- (TreatmentProtocol *)getDummyProtocol;
- (void)               getNewProtocols;
- (void)               insertPatient:(Patient*)patient after:(NSInteger)row;
- (void)               insertNewProtocolAfterSelectedRow: (TreatmentProtocol*)newProtocol;
- (void)               reorderSequenceNumbers;
- (void)               savePatient:(Patient*)patient toUrl:(NSURL *)url fileName:(NSString *)fileName;
- (void)               saveAllPatientsToFilePath:(NSString *)filePath;
- (Patient *)          readPatientFrom:(NSURL *)openUrl;
- (void)               readListOfPatientsFrom:(NSString *)filePath;
- (void)               copyCppPatients:(vectorOfPatients &)cppPatients
                                    to:(NSArrayController *)listOfPatients at:(NSUInteger)row;
- (void)               startPrint;
- (void)               showAlert:(NSString*) message inform:(NSString*)informMessage;
- (NSString *)         showSaveDiscardCancelAlert;

@end

