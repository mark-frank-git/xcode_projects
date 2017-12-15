//
//  BankEditorController.m
//  CustomCareGui
//
//  Created by Mark Frank on 2/4/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#import "BankEditorController.h"

#import "ProtocolBankController.h"
#import "AppDelegate.h"
#import "TreatmentProtocol.h"
#import "ProtocolProgram.h"
#import "CsvReader.h"
#import "CsvWriter.h"
#import "ProtocolEditorController.h"
#import "PrintController.h"

@interface BankEditorController()
{
  CsvReader* m_csvReader;
  CsvWriter* m_csvWriter;
  bool       m_printPrograms;
  NSString*  m_filePath;
}

@end

@implementation BankEditorController
@synthesize     protocols;
@synthesize     protocolsTableView;

//********************************************************
// Called after window loaded
//********************************************************
- (void)windowDidLoad
{
  [super windowDidLoad];
}

//********************************************************
//Intercept window closing as window delegate
//********************************************************
- (BOOL)windowShouldClose:(id)sender
{
  BOOL shouldClose        = YES;
  if([protocolsTableView tableWasEdited])
  {
    NSString* alertReply  = [self showSaveDiscardCancelAlert];
    if([alertReply isEqualToString:@"Save"])
    {
      [self saveBank:self];
    }
    else if([alertReply isEqualToString:@"Cancel"])
    {
      shouldClose         = NO;
    }
  }
  if(shouldClose)
  {
    [protocolsArrayController removeObjects:protocols];
  }
  return shouldClose;
}

const int kNAME_COLUMN = 0;
//********************************************************
// Set the app delegate who owns us
//********************************************************
- (void)setAppDelegate: (id)delegate
{
  appDelegate     = delegate;
  [self                setProtocolsController];
  [self                setWindowTitle:@"Protocol Bank"];
  [protocolsTableView  deselectAll:self];
  [protocolsTableView  resetEdits:self];
  [protocolsTableView  setController:self];
  [protocolsTableView  setFirstEditableColumn:kNAME_COLUMN];
}

//********************************************************
// Set the the default file path
//********************************************************
- (void)setFilePath: (NSString *)filePath
{
  if(filePath != nil)
  {
    m_filePath  = filePath;
    [self loadBankFrom:m_filePath];
  }
}

//********************************************************
// Set the app delegate who owns us
//********************************************************
- (NSString*)filePathToBank
{
  return m_filePath;
}

//********************************************************
// Adds an empty protocol
//********************************************************
- (IBAction)insertAfterSelected:(id)sender
{
  [self insertNewProtocolAfterSelectedRow:[self getDummyProtocol]];
  [protocolsTableView setWasEdited:self];
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
  [protocolsTableView       setWasEdited:self];
}

//********************************************************
// Deletes the selected protocol
//********************************************************
- (IBAction)deleteProtocol:(id)sender
{
  if([protocols count] > 0)
  {
    NSInteger selectedRow   = [protocolsTableView selectedRow];
    if(selectedRow > -1)
    {
      [protocolsArrayController removeObjectAtArrangedObjectIndex: selectedRow];
    }
    [self reorderSequenceNumbers];
    [protocolsTableView setWasEdited:self];
  }
}

//********************************************************
// Add the protocol from the bank, and return
//********************************************************
- (IBAction)closeWindow:(id)sender
{
  if([self windowShouldClose:sender])
  {
    [[self window]    close];
  }
}

//********************************************************
// Loads a new protocol bank from file
//********************************************************
- (IBAction)loadNewBank:(id)sender
{
  NSOpenPanel* panel = [NSOpenPanel openPanel];
  // This method displays the panel and returns immediately.
  // The completion handler is called when the user selects an
  // item or cancels the panel.
  [panel beginWithCompletionHandler:^(NSInteger result)
   {
     if (result == NSFileHandlingPanelOKButton)
     {
       NSURL*  urlPtr   = [[panel URLs] objectAtIndex:0];
       m_filePath       = [urlPtr relativePath];
       if(![self loadBankFrom:m_filePath])
       {
         [self showAlert:@"Can't open document" inform:m_filePath];
       }
     }
     
   }];
}

//********************************************************
// Print protocols to printer
//********************************************************
- (IBAction)printProtocols:(id)sender
{
  m_printPrograms   = true;
  [self               startPrint];
}

//********************************************************
// Print protocol names to printer
//********************************************************
- (IBAction)printProtocolNames:(id)sender
{
  m_printPrograms   = false;
  [self               startPrint];
}

//********************************************************
// Save protocols to file
//********************************************************
- (IBAction)saveBank:(id)sender
{
  NSSavePanel* panel    = [NSSavePanel savePanel];
  NSString* filePath    = [m_filePath  stringByDeletingLastPathComponent];
  NSString* oldFile     = [m_filePath  lastPathComponent];
  NSString* oldFileName = [oldFile     stringByDeletingPathExtension];
  [panel                setDirectoryURL:[NSURL fileURLWithPath:filePath]];
  [panel                setNameFieldStringValue:oldFileName];
  [panel                setAllowedFileTypes:[NSArray arrayWithObject:@"csv"]];
  [panel                setCanCreateDirectories:YES];
  [panel                runModal];
  NSURL *saveUrl        = [panel directoryURL];
  NSString *fileName    = [panel nameFieldStringValue];
  if([self saveBankToUrl:saveUrl fileName:fileName])
  {
    NSString* filePath  = [saveUrl path];
    filePath            = [filePath stringByAppendingFormat:@"%@%@",@"/", fileName];
    [appDelegate           setNewProtocolBankFile:filePath];
  }
  [protocolsTableView    resetEdits:self];
}

//********************************************************
// Returns the selected protocol
//********************************************************
- (Protocol* )protocolToBeEdited
{
  NSInteger selectedRow = [protocolsTableView selectedRow];
  NSInteger index       = MAX(0, (selectedRow));
  if([protocols count] > 0)
    return [protocols objectAtIndex:index];
  else
    return nil;
}

//********************************************************
// Returns the text to be printed
//********************************************************
- (NSString *) textToPrint
{
  NSString *textToPrint       = [[NSString alloc] init];
  TreatmentProtocol* protocol = [[TreatmentProtocol alloc] init];
  for(protocol in protocols)
  {
    textToPrint               = [textToPrint stringByAppendingString:[protocol textDescription:m_printPrograms]];
  }
  return textToPrint;
}


/////////////  PRIVATE METHODS /////////////////

//********************************************************
//Load the bank from a file path, return NO on error
//********************************************************
- (bool)loadBankFrom: (NSString*)filePath
{
  if(!m_csvReader)
  {
    m_csvReader       = new CsvReader();
  }
  if(m_csvReader->readCsvFile([filePath cStringUsingEncoding:NSUTF8StringEncoding]))
  {
    [protocols    removeAllObjects];  //Avoid double loads
    vectorOfStrings protocolNames       = m_csvReader->protocolNames();
    for(int i=0; i<protocolNames.size(); i++)
    {
      NSString *protocolName            = [NSString stringWithCString:protocolNames[i].c_str()
                                                             encoding:[NSString defaultCStringEncoding]];
      TreatmentProtocol *protocol       = [[TreatmentProtocol alloc] init];
      CppProtocol cppProtocol           = m_csvReader->getProtocolAtIndex(i);
      protocol.protocolName             = protocolName;
      protocol.protocolInstructions     = @"New Instruct";
      protocol.protocolNote             = @"New Note";
      protocol.protocolType             = [NSString stringWithCString:cppProtocol.m_protocolType.c_str()
                                                             encoding:[NSString defaultCStringEncoding]];
      protocol.printProtocol            = true;
      protocol.protocolSequenceNumber   = i+1;
      protocol.protocolPrograms         = [[NSMutableArray alloc] init];
      //Load the programs from the given protocol
      vectorOfPrograms programs         = cppProtocol.m_programs;
      for(int j=0; j<programs.size(); j++)
      {
        ProtocolProgram *program      = [[ProtocolProgram alloc] init];
        program.programSequenceNumber = j+1;
        program.programFreq1          = [NSString stringWithCString:programs[j].m_freq1.c_str()
                                                           encoding:[NSString defaultCStringEncoding]];
        program.programFreq2          = [NSString stringWithCString:programs[j].m_freq2.c_str()
                                                           encoding:[NSString defaultCStringEncoding]];
        program.programCurrent        = [NSString stringWithCString:programs[j].m_current.c_str()
                                                           encoding:[NSString defaultCStringEncoding]];
        program.programDuration       = [NSString stringWithCString:programs[j].m_duration.c_str()
                                                           encoding:[NSString defaultCStringEncoding]];
        program.programWaveShape      = [NSString stringWithCString:programs[j].m_waveShape.c_str()
                                                           encoding:[NSString defaultCStringEncoding]];
        program.programPolarity       = [NSString stringWithCString:programs[j].m_polarity.c_str()
                                                           encoding:[NSString defaultCStringEncoding]];
        [protocol.protocolPrograms addObject:program];
      }
      [protocolsArrayController addObject:protocol];
    }
  }
  else
  {
    return NO;
  }
  return YES;
}

//********************************************************
//Sets the array controller for the programs
//********************************************************
- (void) setProtocolsController
{
  if(!protocols)
  {
    protocols             = [[NSMutableArray alloc] init];
  }
  else
  {
    [protocols removeAllObjects];
  }
}

//********************************************************
//Sets the title for the window
//********************************************************
- (void) setWindowTitle: (NSString*)title
{
  [[self window] setTitle:title];
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
  [newProtocol setProtocolName:         @"New Protocol"];
  [newProtocol setProtocolInstructions: @"Patient Instrcts"];
  [newProtocol setProtocolNote:         @"Special Notes for Protocol"];
  [newProtocol setProtocolType:         @"User Defined"];
  [newProtocol setPrintProtocol:        true];
  [newProtocol setProtocolPrograms:programs];
  return newProtocol;
}

//********************************************************
//Inserts a new dummy program after the given row
//********************************************************
- (void) insertNewProtocolAfterSelectedRow: (TreatmentProtocol*)newProtocol
{
  NSInteger selectedRow = [protocolsTableView selectedRow];
  [protocolsArrayController insertObject:newProtocol atArrangedObjectIndex: (selectedRow+1)];
  [self reorderSequenceNumbers];
  [protocolsTableView scrollRowToVisible:(selectedRow +1)];
}

//********************************************************
//Re-orders the sequence numbers of the objects
//********************************************************
- (void) reorderSequenceNumbers
{
  int sequenceNumber        = 1;
  for(TreatmentProtocol* object in protocols)
  {
    object.protocolSequenceNumber  = sequenceNumber++;
  }
}

//********************************************************
// Save patient to url location
//********************************************************
- (bool)saveBankToUrl:(NSURL *)url fileName:(NSString *)fileName
{
  if(![fileName isEqualToString:@""] && [protocols count] > 0)
  {
    NSString* filePath  = [url path];
    filePath            = [filePath stringByAppendingFormat:@"%@%@",@"/", fileName];
    if(!m_csvWriter)
    {
      m_csvWriter       = new CsvWriter();
    }
    //Copy the protocols to C++
    vectorOfProtocols cppProtocols;
    TreatmentProtocol* protocol;
    for(protocol in protocols)
    {
      CppProtocol cppProtocol;
      cppProtocol.SetProtocolName([protocol.protocolName cStringUsingEncoding:NSUTF8StringEncoding]);
      cppProtocol.SetProtocolInstructions([protocol.protocolInstructions cStringUsingEncoding:NSUTF8StringEncoding]);
      cppProtocol.SetProtocolNote([protocol.protocolNote cStringUsingEncoding:NSUTF8StringEncoding]);
      cppProtocol.SetProtocolType([protocol.protocolType cStringUsingEncoding:NSUTF8StringEncoding]);
      ProtocolProgram* program        = [[ProtocolProgram alloc] init];
      for(program in protocol.protocolPrograms)
      {
        CppProgram cppProgram;
        cppProgram.m_freq1            = [program.programFreq1     cStringUsingEncoding:NSUTF8StringEncoding];
        cppProgram.m_freq2            = [program.programFreq2     cStringUsingEncoding:NSUTF8StringEncoding];
        cppProgram.m_current          = [program.programCurrent   cStringUsingEncoding:NSUTF8StringEncoding];
        cppProgram.m_duration         = [program.programDuration  cStringUsingEncoding:NSUTF8StringEncoding];
        cppProgram.m_waveShape        = [program.programWaveShape cStringUsingEncoding:NSUTF8StringEncoding];
        cppProgram.m_polarity         = [program.programPolarity  cStringUsingEncoding:NSUTF8StringEncoding];
        cppProtocol.AddNewProgram(cppProgram);
      }
      cppProtocols.push_back(cppProtocol);
    }
    m_csvWriter->writeCsvFile([filePath cStringUsingEncoding:NSUTF8StringEncoding], cppProtocols);
    return true;
  }
  else
  {
    return false;
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
  [alert setMessageText:@"Protocol Editor About to Close"];
  [alert setInformativeText:@"Do you want to save edited protocol"];
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
