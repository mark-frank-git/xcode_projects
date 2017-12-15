//
//  ProtocolEditorController.m
//  CustomCareGui
//
//  Created by Mark Frank on 12/13/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import "ProtocolEditorController.h"
#import "AppDelegate.h"
#import "TreatmentProtocol.h"
#import "ProtocolProgram.h"


@implementation ProtocolEditorController
{
  NSMutableArray  *copiedPrograms;          //Copied programs
  bool             m_protocolEdited;
  bool             m_protocolWasEdited;
}
@synthesize     tableView;
@synthesize     waveShapes;
@synthesize     polarities;
@synthesize     programs;
@synthesize     totalHours;
@synthesize     totalMinutes;

//********************************************************
//Initialize the ProtocolEditorController
//********************************************************
- (void)windowDidLoad
{
  [super windowDidLoad];
  
  m_protocolEdited    = false;
  m_protocolWasEdited = false;
  
  // Create the arrays we're going to store stuff in
  waveShapes    = [[NSMutableArray alloc] init];
  polarities    = [[NSMutableArray alloc] init];
  programs      = [[NSMutableArray alloc] init];
  
  // Create some objects we want to use to populate the popup button value for waveshape
  // These all go into the waveShapes array
  Waveshape* wave1 = [[Waveshape alloc] init];
  [wave1 setType:@"Gentle"];
  [waveShapeArrayController addObject:wave1];
  
  Waveshape* wave2 = [[Waveshape alloc] init];
  [wave2 setType:@"Mild"];
  [waveShapeArrayController addObject:wave2];
  
  Waveshape* wave3 = [[Waveshape alloc] init];
  [wave3 setType:@"Sharp"];
  [waveShapeArrayController addObject:wave3];
  
  Waveshape* wave4 = [[Waveshape alloc] init];
  [wave4 setType:@"Pulse"];
  [waveShapeArrayController addObject:wave4];
  
  
  // Create some objects we want to use to populate the popup button value for polarity
  // These all go into the polarities array
  Polarity* pol1 = [[Polarity alloc] init];
  [pol1 setType:@"Negative"];
  [polarityArrayController addObject:pol1];
  
  Polarity* pol2 = [[Polarity alloc] init];
  [pol2 setType:@"Positive"];
  [polarityArrayController addObject:pol2];
  
  Polarity* pol3 = [[Polarity alloc] init];
  [pol3 setType:@"Alternating"];
  [polarityArrayController addObject:pol3];
}

//********************************************************
//Intercept window closing as window delegate
//********************************************************
- (BOOL)windowShouldClose:(id)sender
{
  BOOL shouldClose        = YES;
  if([tableView tableWasEdited] || m_protocolEdited)
  {
    NSString* alertReply  = [self showSaveDiscardCancelAlert];
    if([alertReply isEqualToString:@"Save"])
    {
      [self saveProtocol:self];
    }
    else if([alertReply isEqualToString:@"Cancel"])
    {
      shouldClose         = NO;
    }
    else if([alertReply isEqualToString:@"Discard"])
    {
      m_protocolEdited    = false;
    }
  }
  if(shouldClose)
  {
    [programsArrayController removeObjects:programs];
  }
  return shouldClose;
}

const int kFREQ1_COLUMN = 2;
//********************************************************
// Set the app delegate who owns us, this is called on
// initialization by the app delegate.
//********************************************************
- (void)setAppDelegate: (id)delegate
{
  appDelegate           = delegate;
  protocolToBeEdited    = [delegate protocolToBeEdited];
  m_protocolEdited      = false;
  m_protocolWasEdited   = true;
  [self      setProgramsController];
  [self      setWindowTitleEditing];
  [tableView deselectAll:self];
  [tableView resetEdits:self];
  [tableView setController:self];
  [tableView setFirstEditableColumn:kFREQ1_COLUMN];
  [self      findTotalDuration:self];
}

//********************************************************
//Insert a program before selected program
//********************************************************
- (IBAction)insertBeforeSelected:(id)sender
{
  m_protocolEdited      = YES;
  [self setWindowTitle:@"Editing "];
  NSInteger selectedRow = [tableView selectedRow];
  [self insertNewProgramBefore:selectedRow];
}

//********************************************************
//Insert a program after selected program
//********************************************************
- (IBAction)insertAfterSelected:(id)sender
{
  m_protocolEdited      = YES;
  [self setWindowTitle:@"Editing "];
  NSInteger selectedRow = [tableView selectedRow];
  [self insertNewProgramAfter:selectedRow];
}

//********************************************************
//Delete the selected program
//********************************************************
- (IBAction)deleteSelected:(id)sender
{
  m_protocolEdited        = YES;
  [self setWindowTitle:@"Editing "];
  if([programs count] > 0)
  {
    NSInteger selectedRow = [tableView selectedRow];
    [programsArrayController removeObjectAtArrangedObjectIndex: selectedRow];
    [self reorderSequenceNumbers];
  }
}

//********************************************************
//Select all rows in the table view
//********************************************************
- (IBAction)selectAll: (id)sender
{
  [tableView selectAll:self];
}

//********************************************************
//Copy the selection of programs for eventual pasting
//********************************************************
- (IBAction)copySelection:(id)sender
{
  if(!copiedPrograms)
  {
    copiedPrograms  = [[NSMutableArray alloc] init];
  }
  [copiedPrograms removeAllObjects];
  NSIndexSet* selection = [tableView selectedRowIndexes];
  NSUInteger index      = [selection firstIndex];
  while(index != NSNotFound)
  {
    [copiedPrograms addObject:[programs objectAtIndex:index]];
    index                   = [selection indexGreaterThanIndex: index];
  }
}

//********************************************************
//Paste the selection of programs
//********************************************************
- (IBAction)pasteSelection:(id)sender
{
  if(copiedPrograms)
  {
    m_protocolEdited                = YES;
    ProtocolProgram *nextProgram;
    NSInteger selectedRow           = [tableView selectedRow];
    for(nextProgram in copiedPrograms)
    {
      selectedRow++;
      ProtocolProgram* copyProgram  = [NSKeyedUnarchiver unarchiveObjectWithData:
                                      [NSKeyedArchiver archivedDataWithRootObject:nextProgram]];
      [programsArrayController insertObject:copyProgram atArrangedObjectIndex:selectedRow];
    }
    [self reorderSequenceNumbers];
  }
}

//********************************************************
//Save the protocol
//********************************************************
- (IBAction)saveProtocol:(id)sender
{
  [self setWindowTitle:@"Done Editing "];
  [tableView            resetEdits:self];
  [protocolToBeEdited.protocolPrograms removeAllObjects];
  protocolToBeEdited.protocolType  = @"User Defined";
  //Copy out the programs:
  for(ProtocolProgram *object in programs)
  {
    [protocolToBeEdited.protocolPrograms addObject:object];
  }
}

//********************************************************
//Save the protocol and close
//********************************************************
- (IBAction)saveAndClose:(id)sender
{
  [self                    saveProtocol:self];
  [[self window]           close];
}

//********************************************************
//Tell owner that we were edited
//********************************************************
- (bool)wasProtocolEdited
{
  return m_protocolWasEdited;
}

//********************************************************
//Find the total duration in hours and minutes
//********************************************************
- (IBAction)findTotalDuration:(id)sender
{
  int totalDurationMinutes  = 0;
  for(ProtocolProgram *object in programs)
  {
    totalDurationMinutes  += [object.programDuration intValue];
  }
  int totalDurationHours   = 0;
  while(totalDurationMinutes > 60)
  {
    totalDurationHours++;
    totalDurationMinutes   -= 60;
  }
  [totalHours   setIntegerValue:totalDurationHours];
  [totalMinutes setIntegerValue:totalDurationMinutes];
}


/////////////  PRIVATE METHODS /////////////////

//********************************************************
//Sets the array controller for the programs
//********************************************************
- (void) setProgramsController
{
  //Remove any old programs
  [programsArrayController removeObjects:programs];
  [programsArrayController addObjects:protocolToBeEdited.protocolPrograms];
}

//********************************************************
//Sets the window title to Editing - protocol
//********************************************************
- (void) setWindowTitleEditing
{
  NSString* title = @"Editing ";
  if(protocolToBeEdited)
  {
    NSString* protocolName  = protocolToBeEdited.protocolName;
    title               = [title stringByAppendingString:protocolName];
  }
  [[self window] setTitle:title];
}

//********************************************************
//Returns a copy of the current selected program
//********************************************************
- (ProtocolProgram *) getCopyProgramFrom:(NSUInteger)index
{
  ProtocolProgram* newProgram   = [[ProtocolProgram alloc] init];
  [newProgram setProgramSequenceNumber:1];
  if([programs count]>0 && index<[programs count])
  {
    ProtocolProgram* oldProgram = [programs objectAtIndex:index];
    [newProgram setProgramWaveShape:oldProgram.programWaveShape];
    [newProgram setProgramPolarity: oldProgram.programPolarity];
    [newProgram setProgramFreq1:    oldProgram.programFreq1];
    [newProgram setProgramFreq2:    oldProgram.programFreq2];
    [newProgram setProgramDuration: oldProgram.programDuration];
    [newProgram setProgramCurrent:  oldProgram.programCurrent];
  }
  else
  {
    [newProgram setProgramWaveShape:  @"Sharp"];
    [newProgram setProgramPolarity:   @"Alternating"];
    [newProgram setProgramFreq1:      @"100"];
    [newProgram setProgramFreq2:      @"200"];
    [newProgram setProgramDuration:   @"2"];
    [newProgram setProgramCurrent:    @"100"];
  }
  return newProgram;
}

//********************************************************
//Inserts a new dummy program before the given row
//********************************************************
- (void) insertNewProgramBefore: (NSInteger)row
{
  row                       = MAX((row), 0);
  ProtocolProgram* program  = [self getCopyProgramFrom:row];
  [programsArrayController insertObject:program atArrangedObjectIndex:row];
  [self reorderSequenceNumbers];
  [tableView               scrollRowToVisible:row];
}

//********************************************************
//Inserts a new dummy program after the given row
//********************************************************
- (void) insertNewProgramAfter: (NSInteger)row
{
  ProtocolProgram* program  = [self getCopyProgramFrom:row];
  [programsArrayController insertObject:program atArrangedObjectIndex: (row+1)];
  [self reorderSequenceNumbers];
  [tableView               scrollRowToVisible:row+1];
}

//********************************************************
//Sets the title for the window
//********************************************************
- (void) setWindowTitle: (NSString*)titleStart
{
  if(protocolToBeEdited)
  {
    NSString* protocolName  = protocolToBeEdited.protocolName;
    NSString *title         = [titleStart stringByAppendingString:protocolName];
    [[self window] setTitle:title];
  }
  else
  {
    [[self window] setTitle:titleStart];
  }
}

//********************************************************
//Re-orders the sequence numbers of the objects
//********************************************************
- (void) reorderSequenceNumbers
{
  int sequenceNumber  = 1;
  for(ProtocolProgram *object in programs)
  {
    object.programSequenceNumber  = sequenceNumber++;
  }
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
  [alert setInformativeText:@"Do you want to save edited protocol?"];
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
