//
//  AppDelegate.m
//  CustomCareGui
//
//  Created by Mark Frank on 12/13/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import "AppDelegate.h"
#import "Patient.h"
#import "CppPatientWriter.h"
#import "TreatmentProtocol.h"
#import "ProtocolProgram.h"
#import "ProtocolBankController.h"
#import "PatientEditorController.h"
#import "ProtocolEditorController.h"
#import "BankEditorController.h"
#import "ProgramUnitController.h"
#import "PrintController.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
{
  bool          m_printPrograms;        //Print the programs in addition to protocol names
  bool          m_patientsEdited;       //List of patients has been modified
  NSString*     m_patientsFilePath;     //File path to list of patients
  NSString*     m_protocolBankFilePath; //File path to protocol bank
}
@synthesize     patients;
@synthesize     protocols;
@synthesize     patientTableView;
@synthesize     protocolTableView;
@synthesize     protocolSurroundingBox;
@synthesize     programButton;
@synthesize     modifyButton;

//********************************************************
// Called after application finished launching
//********************************************************
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  //Allocate the patients and protocols arrays
  patients              = [[NSMutableArray alloc] init];
  protocols             = [[NSMutableArray alloc] init];
  
  // Get the user defaults
  NSUserDefaults *defaults  = [NSUserDefaults standardUserDefaults];
  m_patientsFilePath        = [defaults objectForKey:@"patientsFilePath"];
  m_protocolBankFilePath    = [defaults objectForKey:@"protocolBankFilePath"];
  if(m_patientsFilePath != nil)
  {
    [self readListOfPatientsFrom:m_patientsFilePath];
  }
  // Set edited to NO
  m_patientsEdited          = NO;
  
  // Modify the buttons:
  [programButton               setBordered:NO];
  [modifyButton                setBordered:NO];
}

//********************************************************
// Delegate method called when patient selection changes
//********************************************************
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
  //Set the title on the box
  NSString *title           = @"Protocols for Patient: ";
  title                     = [title stringByAppendingString:[self getPatientName]];
  [protocolSurroundingBox   setTitle:title];

  //Save the old protocols, and get the protocols from the new patient
  [self                     getNewProtocols];
}

//********************************************************
// Called to see if application should terminate
//********************************************************
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
  NSApplicationTerminateReply reply   = NSTerminateNow;
  //Send alert to see if we should terminate
  bool protocolEdited                 = false;
  if(protocolEditorController != nil)
  {
    protocolEdited                    = [protocolEditorController wasProtocolEdited];
  }
  if(m_patientsEdited || protocolEdited)
  {
    NSString* alertReply              = [self showSaveDiscardCancelAlert];
    if([alertReply isEqualToString:@"Save"])
    {
      [self saveAllPatients:self];
    }
    else if([alertReply isEqualToString:@"Cancel"])
    {
      reply   = NSTerminateCancel;
    }
  }
  return reply;
}

//********************************************************
// Called when application is about to terminate
//********************************************************
- (void)applicationWillTerminate:(NSNotification *)aNotification
{
  NSUserDefaults *defaults  = [NSUserDefaults standardUserDefaults];
  [defaults setObject:m_patientsFilePath     forKey:@"patientsFilePath"];
  NSString* filePath        = [protocolBankController filePathToBank];
  if(filePath != nil)
  {
    m_protocolBankFilePath  = filePath;
  }
  else
  {
    filePath                = [bankEditorController filePathToBank];
    if(filePath != nil)
    {
      m_protocolBankFilePath= filePath;
    }
  }
  [defaults setObject:m_protocolBankFilePath forKey:@"protocolBankFilePath"];
}

//********************************************************
// Saves a patient info to disk
//********************************************************
- (IBAction)savePatient:      (id)sender
{
  NSSavePanel* panel  = [NSSavePanel savePanel];
  [panel                setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
  [panel                setCanCreateDirectories:YES];
  [panel                runModal];
  NSURL *saveUrl      = [panel directoryURL];
  NSString *fileName  = [panel nameFieldStringValue];
  [self savePatient:[self selectedPatient] toUrl:saveUrl fileName:fileName];
}

//********************************************************
// Saves all patients to disk
//********************************************************
- (IBAction)saveAllPatients:  (id)sender
{
  NSSavePanel* panel    = [NSSavePanel savePanel];
  NSString* filePath    = NSHomeDirectory();
  NSString* oldFileName = @"";
  if(m_patientsFilePath != nil)
  {
    filePath            = [m_patientsFilePath stringByDeletingLastPathComponent];
    NSString* oldFile   = [m_patientsFilePath lastPathComponent];
    oldFileName         = [oldFile            stringByDeletingPathExtension];
  }
  [panel                setDirectoryURL:[NSURL fileURLWithPath:filePath]];
  [panel                setNameFieldStringValue:oldFileName];
  [panel                setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
  [panel                setCanCreateDirectories:YES];
  [panel                runModal];
  NSURL *saveUrl      = [panel directoryURL];
  NSString *fileName  = [panel nameFieldStringValue];
  m_patientsFilePath  = [saveUrl path];
  m_patientsFilePath  = [m_patientsFilePath stringByAppendingFormat:@"%@%@",@"/", fileName];
  [self saveAllPatientsToFilePath:m_patientsFilePath];
  m_patientsEdited    = false;
}

//********************************************************
// Reads a single patient info from disk
//********************************************************
- (IBAction)readPatient:(id)sender
{
  m_patientsEdited    = YES;
  NSOpenPanel* panel  = [NSOpenPanel openPanel];
  [panel                setCanChooseFiles:YES];
  [panel                setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
  if([panel runModal] == NSModalResponseOK)
  {
    NSURL *openUrl        = [panel URL];
    Patient *newPatient   = [NSKeyedUnarchiver unarchiveObjectWithData:
                             [NSKeyedArchiver archivedDataWithRootObject:[self readPatientFrom:openUrl]]];
    NSInteger selectedRow = [patientTableView selectedRow];
    [self insertPatient:newPatient after:selectedRow];
    [self getNewProtocols];
  }
}

//********************************************************
// Reads a single patient info from disk
//********************************************************
- (IBAction)readListOfPatients:(id)sender
{
  NSOpenPanel* panel  = [NSOpenPanel openPanel];
  [panel                setCanChooseFiles:YES];
  [panel                setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
  if([panel runModal] == NSModalResponseOK)
  {
    NSURL *openUrl        = [panel URL];
    NSString* filePath    = [openUrl path];
    [self readListOfPatientsFrom:filePath];
  }
}

//********************************************************
// Adds a new patient
//********************************************************
- (IBAction)addNewPatient:    (id)sender
{
  m_patientsEdited          = YES;
  NSInteger selectedRow     = [patientTableView selectedRow];
  Patient* newPatient       = [NSKeyedUnarchiver unarchiveObjectWithData:
                              [NSKeyedArchiver archivedDataWithRootObject:[self getDummyPatient]]];
  [self insertPatient:newPatient after:selectedRow];
}

//********************************************************
// Deletes the current selected patient
//********************************************************
- (IBAction)deletePatient:    (id)sender
{
  if([patients count] > 0)
  {
    m_patientsEdited      = YES;
    NSInteger selectedRow = [patientTableView selectedRow];
    if(selectedRow > -1)
    {
      [patientsArrayController removeObjectAtArrangedObjectIndex: selectedRow];
    }
  }
}

//********************************************************
// Edits the patient's properties
//********************************************************
- (IBAction)editPatient:      (id)sender
{
  m_patientsEdited          = YES;
  if(!patientEditorController)
  {
    patientEditorController = [[PatientEditorController alloc]
                               initWithWindowNibName:@"PatientEditorController"];
  }
  [patientEditorController showWindow:self];
  [patientEditorController setAppDelegate:self];
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
// Adds a new protocol from the protocol bank
//********************************************************
- (IBAction)addProtocolFromBank:(id)sender
{
  if(!protocolBankController)
  {
    protocolBankController  = [[ProtocolBankController alloc]
                              initWithWindowNibName:@"ProtocolBankController"];
  }
  [protocolBankController showWindow:self];
  [protocolBankController setAppDelegate:self];
  [protocolBankController setFilePath:m_protocolBankFilePath];
}

//********************************************************
// Adds an empty protocol
//********************************************************
- (IBAction)addEmptyProtocol:(id)sender
{
  m_patientsEdited    = YES;
  [self insertNewProtocolAfterSelectedRow:[self getDummyProtocol]];
}

//********************************************************
// Shows the protocol editor window
//********************************************************
- (IBAction)editProtocol:(id)sender
{
  if(!protocolEditorController)
  {
    protocolEditorController  = [[ProtocolEditorController alloc] initWithWindowNibName:@"ProtocolWindow"];
  }
  [protocolEditorController showWindow:self];
  [protocolEditorController setAppDelegate:self];
}

//********************************************************
// Deletes the selected protocol
//********************************************************
- (IBAction)deleteProtocol:(id)sender
{
  if([protocols count] > 0)
  {
    m_patientsEdited        = YES;
    NSInteger selectedRow   = [protocolTableView selectedRow];
    if(selectedRow > -1)
    {
      [protocolsArrayController removeObjectAtArrangedObjectIndex: selectedRow];
    }
    [self reorderSequenceNumbers];
  }
}

//********************************************************
// Moves the selected protocol up a row
//********************************************************
- (IBAction)moveSelectedUp:(id)sender
{
  if([protocols count] > 0)
  {
    m_patientsEdited      = YES;
    NSInteger selectedRow = [protocolTableView selectedRow];
    if(selectedRow > 0)
    {
      Protocol* previousProtocol  = [protocols objectAtIndex:(selectedRow-1)];
      [protocolsArrayController removeObjectAtArrangedObjectIndex:(selectedRow-1)];
      [protocolsArrayController insertObject:previousProtocol atArrangedObjectIndex:selectedRow];
      [self reorderSequenceNumbers];
      NSIndexSet* rowSet  = [NSIndexSet indexSetWithIndex:(selectedRow-1)];
      [protocolTableView selectRowIndexes:rowSet byExtendingSelection:false];
    }
  }
}

//********************************************************
// moves the selected protocol down a row
//********************************************************
- (IBAction)moveSelectedDown:(id)sender
{
  if([protocols count] > 0)
  {
    m_patientsEdited      = YES;
    NSInteger selectedRow = [protocolTableView selectedRow];
    if(selectedRow > -1 && selectedRow < ([protocols count]-1))
    {
      Protocol* selectedProtocol  = [protocols objectAtIndex:selectedRow];
      [protocolsArrayController removeObjectAtArrangedObjectIndex:selectedRow];
      [protocolsArrayController insertObject:selectedProtocol atArrangedObjectIndex:selectedRow+1];
      [self reorderSequenceNumbers];
    }
  }
}

//********************************************************
// Shows the program unit window
//********************************************************
- (IBAction)programUnit:(id)sender
{
  if(!programUnitController)
  {
    programUnitController  = [[ProgramUnitController alloc] initWithWindowNibName:@"ProgramUnitController"];
  }
  [programUnitController showWindow:self];
  [programUnitController setAppDelegate:self];
}

//********************************************************
// Shows the protocol bank editor
//********************************************************
- (IBAction)editProtocolBank: (id)sender
{
  if(!bankEditorController)
  {
    bankEditorController  = [[BankEditorController alloc] initWithWindowNibName:@"BankEditorController"];
  }
  [bankEditorController showWindow:self];
  [bankEditorController setAppDelegate:self];
  [bankEditorController setFilePath:m_protocolBankFilePath];
}

//********************************************************
// Returns the selected patient
//********************************************************
- (Patient* )selectedPatient
{
  if([patients count] > 0)
  {
    NSInteger selectedRow = [patientTableView selectedRow];
    NSInteger index       = MAX(0, (selectedRow));
    if([patients count] > 0)
      return [patients objectAtIndex:index];
    else
      return nil;
  }
  return nil;
}

//********************************************************
// Returns the selected protocol
//********************************************************
- (Protocol* )protocolToBeEdited
{
  NSInteger selectedRow = [protocolTableView selectedRow];
  NSInteger index       = MAX(0, (selectedRow));
  if([protocols count] > 0)
    return [protocols objectAtIndex:index];
  else
    return nil;
}

//********************************************************
// Inserts a protocol from the bank into the list of protocols
//********************************************************
- (void) insertProtocolFromBank:(TreatmentProtocol *)newProtocol
{
  m_patientsEdited            = YES;
  [self insertNewProtocolAfterSelectedRow:newProtocol];
}

//********************************************************
// Returns the text to be printed for the print controller
//********************************************************
- (NSString *) textToPrint
{
  Patient* selPatient         = [self selectedPatient];
  if(selPatient == nil)
  {
    [self showAlert:@"Can't print with no patient" inform:@"Add a patient first"];
    return nil;
  }
  NSString *textToPrint       = [[self selectedPatient] getPatientPrescription:m_printPrograms];
  return textToPrint;
}

//********************************************************
// Called by the bank editor controller when there is a new file
// to load
//********************************************************
- (void)setNewProtocolBankFile:(NSString *)newFile
{
  m_protocolBankFilePath  = newFile;
}


/////////////////// PRIVATE METHODS /////////////////////

//********************************************************
// Gets a new dummy patient
//********************************************************
- (Patient *) getDummyPatient
{
  Patient* newPatient       = [[Patient alloc] init];
  [newPatient setPatientLastName:@"Last"];
  [newPatient setPatientFirstName:@"First"];
  [newPatient setPatientNote:@"Note"];
  return newPatient;
}

//********************************************************
// Gets the name of the selected patient
//********************************************************
- (NSString*) getPatientName
{
  NSString *name  = @" ";
  if([patients count] > 0)
  {
    NSInteger selectedRow = [patientTableView selectedRow];
    if(selectedRow > -1)
    {
      NSArray*  pArray  = [patientsArrayController arrangedObjects];
      Patient*  patient = [pArray objectAtIndex:selectedRow];
      name              = [patient patientFirstName];
      name              = [name stringByAppendingFormat:@"%@%@",@" ", [patient patientLastName]];
    }
  }
  return name;
}

//********************************************************
// Gets a new dummy protocol
//********************************************************
- (TreatmentProtocol *) getDummyProtocol
{
  TreatmentProtocol* newProtocol  = [[TreatmentProtocol alloc] init];
  // Add the programs (1 in this case) to the newProtocol
  ProtocolProgram* newProgram     = [[ProtocolProgram alloc] init];
  [newProgram setProgramSequenceNumber:1];
  [newProgram setProgramWaveShape:     @"Gentle"];
  [newProgram setProgramPolarity:      @"Positive"];
  [newProgram setProgramFreq1:         @"100"];
  [newProgram setProgramFreq2:         @"200"];
  [newProgram setProgramDuration:      @"2"];
  [newProgram setProgramCurrent:       @"100"];
  NSMutableArray *programs        = [[NSMutableArray alloc] init];
  [programs    addObject:newProgram];
  [newProtocol setProtocolName:         @"New Name"];
  [newProtocol setProtocolInstructions: @"Add Instruction"];
  [newProtocol setProtocolNote:@"Add a note"];
  [newProtocol setProtocolPrograms:programs];
  return newProtocol;
}

//********************************************************
//Save the protocols for the old patient, and load the protocols for
//the new selected patient
//********************************************************
- (void) getNewProtocols
{
  //Copy the protocols from the selected patient
  if([protocols count] > 0)
  {
    //Remove the protocols from the array controller
    [protocolsArrayController     removeObjects:protocols];
    [protocols                    removeAllObjects];
  }
  Patient* selectedPatient  = [self selectedPatient];
  [protocolsArrayController   addObjects:selectedPatient.patientListOfProtocols];
  [self                       reorderSequenceNumbers];
  NSIndexSet* indexSet      = [NSIndexSet indexSetWithIndex:0];
  [protocolTableView          selectRowIndexes:indexSet byExtendingSelection:false];
}

//********************************************************
//Inserts a new dummy patient after the given row
//********************************************************
- (void) insertPatient:(Patient*)patient after:(NSInteger)row
{
  [patientsArrayController insertObject:patient atArrangedObjectIndex: (row+1)];
}

//********************************************************
//Inserts a new dummy program after the given row
//********************************************************
- (void) insertNewProtocolAfterSelectedRow: (TreatmentProtocol*)newProtocol
{
  NSInteger selectedRow = [protocolTableView selectedRow];
  [protocolsArrayController insertObject:newProtocol atArrangedObjectIndex: (selectedRow+1)];
  Patient *selPatient   = [self selectedPatient];
  if(selPatient == nil)
  {
    [self showAlert:@"Can't insert protocol with no patient" inform:@"Add a patient first"];
    return;
  }
  [selPatient.patientListOfProtocols addObject:newProtocol];
  [self reorderSequenceNumbers];
  [protocolTableView scrollRowToVisible:(selectedRow +1)];
}

//********************************************************
//Re-orders the sequence numbers of the objects
//********************************************************
- (void) reorderSequenceNumbers
{
  int sequenceNumber                = 1;
  NSMutableArray* patientProtocols  = [[self selectedPatient] patientListOfProtocols];
  [patientProtocols removeAllObjects];
  for(TreatmentProtocol* object in protocols)
  {
    object.protocolSequenceNumber  = sequenceNumber++;
    [patientProtocols addObject:object];
  }
}

//********************************************************
// Save patient to url location
//********************************************************
- (void)savePatient:(Patient*)patient toUrl:(NSURL *)url fileName:(NSString *)fileName
{
  if(![fileName isEqualToString:@""])
  {
    NSString* filePath  = [url path];
    filePath            = [filePath stringByAppendingFormat:@"%@%@",@"/", fileName];
    if(patient == nil)
    {
      [self showAlert:@"No patient exists to save" inform:@"Add a patient first"];
      return;
    }
    [patient savePatientToFilePath:filePath];
  }
}

//********************************************************
// Save patient to file path location
//********************************************************
- (void)saveAllPatientsToFilePath:(NSString *)filePath
{
  if(![filePath isEqualToString:@""] && [patients count] > 0)
  {
    //Load the patients into an array of C++ patients
    std::vector<CppPatient> cppPatients;
    for(Patient* patient in patients)
    {
      CppPatient cppPatient;
      [patient copyPatientToCppPatient:&cppPatient];
      cppPatients.push_back(cppPatient);
    }
    CppPatientWriter writer;
    if(!writer.writePatientsToFile(cppPatients, [filePath cStringUsingEncoding:NSUTF8StringEncoding]))
    {
      [self showAlert:@"Can't write to the file.  Is it locked?" inform:@""];
    }
  }
}

//********************************************************
// Read patient from location
//********************************************************
- (Patient*)readPatientFrom:(NSURL *)openUrl
{
  Patient *newPatient   = [[Patient alloc] init];
  NSString* filePath    = [openUrl path];
  if(![newPatient readPatientFromFilePath:filePath])
  {
    [self showAlert:@"Can't open the file.  Is it a single patient file?"
             inform:@"Multiple patient files can not be opened using, Add Patient from File."];
  }
  return newPatient;
}

//********************************************************
// Read list of patient from location
//********************************************************
- (void) readListOfPatientsFrom:(NSString *)filePath
{
  CppPatientReader  reader;
  CppPatient        patient;
  //Read into C++ patient
  vectorOfPatients cppPatients;
  if(!reader.readPatientsFromFile(cppPatients,
                           [filePath cStringUsingEncoding:NSUTF8StringEncoding]))
  {
    [self showAlert:@"Can't open the file.  Is it a multiple patient file?"
             inform:@"Single patient files can not be opened using, Open -> List of Patients"];
  }
  NSUInteger lastRow    = [patients count];
  [self copyCppPatients:cppPatients to:patientsArrayController at:lastRow];
}

//********************************************************
// Copy patients from C++ vector to Obj-C array
//********************************************************
- (void)copyCppPatients:(vectorOfPatients &)cppPatients
                     to:(NSArrayController *)listOfPatients at:(NSUInteger)row
{
  for(int i=0; i<cppPatients.size(); i++)
  {
    Patient* objcPatient  = [[Patient alloc] init];
    [objcPatient copyCppToSelf:&cppPatients[i]];
    [listOfPatients insertObject:objcPatient atArrangedObjectIndex: row];
    row++;
  }
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
// Show alert message
//********************************************************
- (void) showAlert:(NSString*) message inform:(NSString*)informMessage
{
  NSAlert *alert      = [[NSAlert alloc] init];
  [alert addButtonWithTitle:@"OK"];
  [alert setMessageText:message];
  [alert setInformativeText:informMessage];
  [alert setAlertStyle:NSWarningAlertStyle];
  [alert runModal];
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
  [alert setMessageText:@"Application About to Close"];
  [alert setInformativeText:@"Do you want to save list of patients"];
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
