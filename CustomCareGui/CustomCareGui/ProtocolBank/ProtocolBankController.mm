//
//  ProtocolBankController.m
//  CustomCareGui
//
//  Created by Mark Frank on 1/2/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#import "ProtocolBankController.h"
#import "AppDelegate.h"
#import "TreatmentProtocol.h"
#import "ProtocolProgram.h"
#import "CsvReader.h"
#import "Patient.h"

@interface ProtocolBankController ()
{
  CsvReader* m_csvReader;
  NSString*  m_filePath;
}

@end

@implementation ProtocolBankController
@synthesize     protocols;
@synthesize     protocolsTableView;

- (void)windowDidLoad
{
    [super windowDidLoad];
}

//********************************************************
// Set the app delegate who owns us
//********************************************************
- (void)setAppDelegate: (id)delegate
{
  appDelegate     = delegate;
  [self      setProtocolsController];
  NSString* title = @"Adding Protocol for ";
  Patient *patient=  [delegate selectedPatient];
  if(patient != nil)
  {
    if(patient.patientFirstName)
      title         = [title stringByAppendingString:patient.patientFirstName];
    title           = [title stringByAppendingString:@" "];
    if(patient.patientLastName)
      title         = [title stringByAppendingString:patient.patientLastName];
  }
  [self setWindowTitle:title];
}

//********************************************************
// Set the the default file path
//********************************************************
- (void)setFilePath: (NSString *)filePath
{
  if(filePath != nil)
  {
    m_filePath  = filePath;
    if(![self loadBankFrom:m_filePath])
    {
      [self showAlert:@"Can't open document" inform:m_filePath];
    }
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
// Add the protocol from the bank
//********************************************************
- (IBAction)addProtocol:(id)sender
{
  NSInteger selectedRow             = [protocolsTableView selectedRow];
  if(selectedRow > -1 && selectedRow < ([protocols count]) && m_csvReader!=NULL && appDelegate!=nil)
  {
    CppProtocol protocol            = m_csvReader->getProtocolAtIndex(selectedRow);
    TreatmentProtocol *objCProtocol = [[TreatmentProtocol alloc] init];
    objCProtocol.protocolName       = [NSString stringWithCString:protocol.m_protocolName.c_str()
                                                         encoding:[NSString defaultCStringEncoding]];
    objCProtocol.protocolPrograms   = [[NSMutableArray alloc] init];
    //Load the programs from the given protocol
    vectorOfPrograms programs       = protocol.m_programs;
    for(int i=0; i<programs.size(); i++)
    {
      ProtocolProgram *program      = [[ProtocolProgram alloc] init];
      program.programSequenceNumber = i+1;
      program.programFreq1          = [NSString stringWithCString:programs[i].m_freq1.c_str()
                                                         encoding:[NSString defaultCStringEncoding]];
      program.programFreq2          = [NSString stringWithCString:programs[i].m_freq2.c_str()
                                                         encoding:[NSString defaultCStringEncoding]];
      program.programCurrent        = [NSString stringWithCString:programs[i].m_current.c_str()
                                                         encoding:[NSString defaultCStringEncoding]];
      program.programDuration       = [NSString stringWithCString:programs[i].m_duration.c_str()
                                                         encoding:[NSString defaultCStringEncoding]];
      program.programWaveShape      = [NSString stringWithCString:programs[i].m_waveShape.c_str()
                                                         encoding:[NSString defaultCStringEncoding]];
      program.programPolarity       = [NSString stringWithCString:programs[i].m_polarity.c_str()
                                                         encoding:[NSString defaultCStringEncoding]];
      [objCProtocol.protocolPrograms addObject:program];
    }
    objCProtocol.protocolNote         = @"Protocol from Bank";
    objCProtocol.protocolInstructions = @" ";
    objCProtocol.protocolType         = @"Standard";
    objCProtocol.printProtocol        = true;
    [appDelegate insertProtocolFromBank:objCProtocol];
  }
}

//********************************************************
// Add the protocol from the bank, and return
//********************************************************
- (IBAction)closeWindow:(id)sender
{
  [[self window]    close];
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
      NSURL*  urlPtr        = [[panel URLs] objectAtIndex:0];
      m_filePath            = [urlPtr relativePath];
      if(![self loadBankFrom:m_filePath])
      {
        [self showAlert:@"Can't open document" inform:m_filePath];
      }
    }    
  }
  ];
}

/////////////  PRIVATE METHODS /////////////////

//********************************************************
//Load the bank from a file path, return NO on error
//********************************************************
- (BOOL)loadBankFrom: (NSString*)filePath
{
  if(!m_csvReader)
  {
    m_csvReader         = new CsvReader();
  }
  if(m_csvReader->readCsvFile([filePath cStringUsingEncoding:NSUTF8StringEncoding]))
  {
    [protocols    removeAllObjects];
    vectorOfStrings protocolNames       = m_csvReader->protocolNames();
    for(int i=0; i<protocolNames.size(); i++)
    {
      NSString *protocolName            = [NSString stringWithCString:protocolNames[i].c_str()
                                                             encoding:[NSString defaultCStringEncoding]];
      TreatmentProtocol *protocol       = [[TreatmentProtocol alloc] init];
      protocol.protocolName             = protocolName;
      protocol.protocolSequenceNumber   = i+1;
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
  if(protocols == nil)
  {
    protocols = [[NSMutableArray alloc] init];
  }
  else
  {
    [protocols   removeAllObjects];
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

@end
