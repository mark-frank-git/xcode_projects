//
//  PatientEditorController.h
//  CustomCareGui
//
//  Created by Mark Frank on 12/23/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KeyDownTableView.h"

@class PatientNote;
@class Patient;

@interface PatientEditorController : NSWindowController <NSApplicationDelegate, NSWindowDelegate>
{
  IBOutlet NSArrayController*    notesArrayController;              // Controller for list of notes
  id                             appDelegate;                       // Pointer to our app delegate
  Patient*                       patient;                           // Patient being edited
}
@property (weak)   IBOutlet KeyDownTableView*  notesTableView;      // The notes table (table of notes)
@property (weak)   IBOutlet NSTextField*  patientNumberText;        // The output patient number
@property (weak)   IBOutlet NSTextField*  patientFirstNameText;     // The output patient first name
@property (weak)   IBOutlet NSTextField*  patientLastNameText;      // The output patient last name
@property (weak)   IBOutlet NSTextField*  patientZipCodeText;       // The output patient zip code
@property (weak)   IBOutlet NSTextField*  patientStreetAddressText; // The output patient address
@property (weak)   IBOutlet NSTextField*  patientCityNameText;      // The output patient city
@property (weak)   IBOutlet NSTextField*  patientStateNameText;     // The output patient state
@property (weak)   IBOutlet NSTextField*  patientHomePhoneText;     // The output patient home #
@property (weak)   IBOutlet NSTextField*  patientCellPhoneText;     // The output patient cell #
@property (weak)   IBOutlet NSTextField*  patientWorkPhoneText;     // The output patient work #
@property (weak)   IBOutlet NSTextField*  patientDoctorNameText;    // The output patient Doctor's name
@property (weak)   IBOutlet NSDatePicker* patientExpirationDate;    // The output expiration date

@property (strong) NSMutableArray*        notes;            // List of notes (each row in table view)

//Setters
- (void)    setAppDelegate:                 (id)delegate;
- (IBAction)setPatientNoExpiration:         (id)sender;
- (IBAction)setPatientEdited:               (id)sender;

//Adding notes
- (IBAction)insertAfterSelected: (id)sender;

//Saving Patient
- (IBAction)savePatient:         (id)sender;
- (IBAction)saveAndClose:        (id)sender;

//Private/Local methods
- (void) setPatientTextFields;
- (void) getPatientTextFields;
- (void) setPatientNotesController;
- (void) setWindowTitleEditing;
- (PatientNote *)getCopyNoteFrom:(NSUInteger)index;
- (void)insertNewNoteAfter:      (NSInteger)row;
- (void)setWindowTitle:          (NSString*)titleStart;
- (NSString *)                   showSaveDiscardCancelAlert;

@end
