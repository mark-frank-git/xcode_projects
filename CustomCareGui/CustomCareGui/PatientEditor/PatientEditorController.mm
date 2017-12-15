//
//  PatientEditorController.m
//  CustomCareGui
//
//  Created by Mark Frank on 12/23/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import "PatientEditorController.h"
#import "AppDelegate.h"
#import "Patient.h"
#import "PatientNote.h"

@implementation PatientEditorController
{
  bool          m_patientEdited;
}
@synthesize     notesTableView;
@synthesize     patientNumberText;
@synthesize     patientFirstNameText;
@synthesize     patientLastNameText;
@synthesize     patientZipCodeText;
@synthesize     patientStreetAddressText;
@synthesize     patientCityNameText;
@synthesize     patientStateNameText;
@synthesize     patientHomePhoneText;
@synthesize     patientCellPhoneText;
@synthesize     patientWorkPhoneText;
@synthesize     patientDoctorNameText;
@synthesize     patientExpirationDate;

@synthesize     notes;

//********************************************************
//Initialize the PatientEditorController
//********************************************************
- (void)windowDidLoad
{
  [super windowDidLoad];
  // Create the arrays we're going to store stuff in
  notes           = [[NSMutableArray alloc] init];
  m_patientEdited = false;
}

//********************************************************
//Intercept window closing as window delegate
//********************************************************
- (BOOL)windowShouldClose:(id)sender
{
  BOOL shouldClose        = YES;
  if([notesTableView tableWasEdited] || m_patientEdited)
  {
    NSString* alertReply  = [self showSaveDiscardCancelAlert];
    if([alertReply isEqualToString:@"Save"])
    {
      [self savePatient:self];
    }
    else if([alertReply isEqualToString:@"Cancel"])
    {
      shouldClose         = NO;
    }
  }
  return shouldClose;
}

//********************************************************
// Attempt to handle tab at last column?
//********************************************************
-(BOOL)control:(NSControl *)control textView:(NSTextView *)textView
                         doCommandBySelector:(SEL)commandSelector
{
  if(commandSelector == @selector(insertTab:) )
  {
    return YES;
  }
  else
  {
    return NO;
  }
}

//********************************************************
// Set the app delegate who owns us
//********************************************************
- (void)setAppDelegate: (id)delegate
{
  appDelegate =   delegate;
  patient     =  [delegate selectedPatient];
  [self           setPatientTextFields];
  [self           setPatientNotesController];
  [self           setWindowTitleEditing];
  [notesTableView deselectAll:self];
}

const double kLONG_TIME = 32472144000.0;
//********************************************************
// Set the max expiration date
//********************************************************
- (IBAction)setPatientNoExpiration:(id)sender
{
  if([sender state] == NSOnState)
  {
    patient.patientExpirationDate = [NSDate dateWithTimeIntervalSince1970: kLONG_TIME];
  }
  else
  {
    patient.patientExpirationDate = [NSDate dateWithTimeIntervalSinceNow: 0.];
  }
  [patientExpirationDate    setDateValue:patient.patientExpirationDate];
  m_patientEdited                 = true;
}

//********************************************************
//Sets the patient edited flag
//********************************************************
- (IBAction)setPatientEdited:(id)sender
{
  m_patientEdited = true;
}

//********************************************************
//Insert a note after selected program
//********************************************************
- (IBAction)insertAfterSelected:(id)sender
{
  NSInteger selectedRow = [notesTableView selectedRow];
  [self                    insertNewNoteAfter:selectedRow];
}

//********************************************************
//Save the patient (notes)
//********************************************************
- (IBAction)savePatient:(id)sender
{
  [self setWindowTitle:@"Done Editing "];
  [self getPatientTextFields];
  [patient.patientListOfNotes removeAllObjects];
  //Copy out the notes:
  for(PatientNote *object in notes)
  {
    [patient.patientListOfNotes addObject:object];
  }
  m_patientEdited = false;
}

//********************************************************
//Save the patient and close
//********************************************************
- (IBAction)saveAndClose:(id)sender
{
  //Note: the saving will happen in: windowWillClose
  [[self window] close];
}


/////////////  PRIVATE METHODS /////////////////

//********************************************************
//Sets the values of the text fields for the patient
//********************************************************
- (void) setPatientTextFields
{
  if(patient != nil)
  {
    [patientNumberText        setIntValue:patient.patientNumber];
    [patientFirstNameText     setStringValue:patient.patientFirstName];
    [patientLastNameText      setStringValue:patient.patientLastName];
    [patientZipCodeText       setStringValue:patient.patientZipCode];
    [patientStreetAddressText setStringValue:patient.patientStreetAddress];
    [patientCityNameText      setStringValue:patient.patientCityName];
    [patientStateNameText     setStringValue:patient.patientStateName];
    [patientHomePhoneText     setStringValue:patient.patientHomePhone];
    [patientCellPhoneText     setStringValue:patient.patientCellPhone];
    [patientWorkPhoneText     setStringValue:patient.patientWorkPhone];
    [patientDoctorNameText    setStringValue:patient.patientDoctorName];
    [patientExpirationDate    setDateValue:patient.patientExpirationDate];
  }
}

//********************************************************
//Sets the values of the text fields for the patient
//********************************************************
- (void) getPatientTextFields
{
  if(patient != nil)
  {
    patient.patientNumber         = [patientNumberText      intValue];
    patient.patientFirstName      = [patientFirstNameText   stringValue];
    patient.patientLastName       = [patientLastNameText    stringValue];
    patient.patientZipCode        = [patientZipCodeText     stringValue];
    patient.patientStreetAddress  = [patientZipCodeText     stringValue];
    patient.patientCityName       = [patientCityNameText    stringValue];
    patient.patientStateName      = [patientStateNameText   stringValue];
    patient.patientHomePhone      = [patientHomePhoneText   stringValue];
    patient.patientCellPhone      = [patientCellPhoneText   stringValue];
    patient.patientWorkPhone      = [patientWorkPhoneText   stringValue];
    patient.patientDoctorName     = [patientDoctorNameText  stringValue];
    patient.patientExpirationDate = [patientExpirationDate  dateValue];
  }
}

//********************************************************
//Sets the array controller for the notes
//********************************************************
- (void) setPatientNotesController
{
  [notesArrayController addObjects:patient.patientListOfNotes];
}

//********************************************************
//Sets the window title to Editing - patient name
//********************************************************
- (void) setWindowTitleEditing
{
  NSString* title = @"Editing ";
  if(patient.patientFirstName)
    title         = [title stringByAppendingString:patient.patientFirstName];
  title           = [title stringByAppendingString:@" "];
  if(patient.patientLastName)
    title         = [title stringByAppendingString:patient.patientLastName];
  [self setWindowTitle:title];
}

//********************************************************
//Returns a copy of the current selected program
//********************************************************
- (PatientNote *) getCopyNoteFrom:(NSUInteger)index
{
  PatientNote* newNote   = [[PatientNote alloc] init];
  if([notes count]>0 && index<[notes count])
  {
    PatientNote* oldNote = [notes objectAtIndex:index];
    [newNote setPatientNote:            oldNote.patientNote];
    [newNote setPatientNoteAddedDate:   oldNote.patientNoteAddedDate];
    [newNote setPatientNoteAddedBy:     oldNote.patientNoteAddedBy];
  }
  else
  {
    [newNote setPatientNote:            @"New Note"];
    NSDateFormatter *dateFormatter      = [[NSDateFormatter alloc] init];
    [dateFormatter                        setDateStyle:NSDateFormatterShortStyle];
    NSString* dateString                = [dateFormatter stringFromDate:[NSDate date]];
    [newNote setPatientNoteAddedDate:   dateString];
    [newNote setPatientNoteAddedBy:     @"Myself"];
  }
  return newNote;
}

//********************************************************
//Inserts a new dummy program after the given row
//********************************************************
- (void) insertNewNoteAfter: (NSInteger)row
{
  PatientNote* note  = [self getCopyNoteFrom:row];
  [notesArrayController insertObject:note atArrangedObjectIndex: (row+1)];
}

//********************************************************
//Sets the title for the window
//********************************************************
- (void) setWindowTitle: (NSString*)titleStart
{
  [[self window] setTitle:titleStart];
}

//********************************************************
// Show alert message for "Save", "Discard", "Cancel"
//********************************************************
- (NSString *) showSaveDiscardCancelAlert
{
  NSAlert *alert      = [[NSAlert alloc] init];
  [alert addButtonWithTitle:@"Save"];
  [alert addButtonWithTitle:@"Discard Changes"];
  [alert addButtonWithTitle:@"Cancel Close"];
  [alert setMessageText:@"Patient Editor About to Close"];
  [alert setInformativeText:@"Do you want to save edited patient?"];
  [alert setAlertStyle:NSWarningAlertStyle];
  NSString* returnString  = @"Cancel";
  long alertReturn        = [alert runModal];
  if(alertReturn == NSAlertFirstButtonReturn)
  {
    returnString          = @"Save";
  }
  else if(alertReturn == NSAlertSecondButtonReturn)
  {
    returnString          = @"Discard";
  }
  return returnString;
}



@end
