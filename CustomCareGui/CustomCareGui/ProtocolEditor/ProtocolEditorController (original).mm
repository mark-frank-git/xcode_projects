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
  NSString        *defaultWaveshapeType;    //Set by user for inserting new programs
  NSString        *defaultPolarityType;
  NSMutableArray  *copiedPrograms;          //Copied programs
}
@synthesize     tableView;
@synthesize     waveShapes;
@synthesize     polarities;
@synthesize     programs;

//********************************************************
//Initialize the ProtocolEditorController
//********************************************************
- (void)windowDidLoad
{
  [super windowDidLoad];
    
  // Create the arrays we're going to store stuff in
  waveShapes    = [[NSMutableArray alloc] init];
  polarities    = [[NSMutableArray alloc] init];
  programs      = [[NSMutableArray alloc] init];
  
  // Create some objects we want to use to populate the popup button value for waveshape
  // These all go into the waveShapes array
  Waveshape* wave1 = [[Waveshape alloc] init];
  [wave1 setType:@"Gentle"];
  [waveShapes addObject:wave1];
  
  Waveshape* wave2 = [[Waveshape alloc] init];
  [wave2 setType:@"Mild"];
  [waveShapes addObject:wave2];
  
  Waveshape* wave3 = [[Waveshape alloc] init];
  [wave3 setType:@"Sharp"];
  [waveShapes addObject:wave3];
  
  Waveshape* wave4 = [[Waveshape alloc] init];
  [wave4 setType:@"Pulse"];
  [waveShapes addObject:wave4];
  
  // Create some objects we want to use to populate the popup button value for polarity
  // These all go into the polarities array
  Polarity* pol1 = [[Polarity alloc] init];
  [pol1 setType:@"Negative"];
  [polarities addObject:pol1];
  
  Polarity* pol2 = [[Polarity alloc] init];
  [pol2 setType:@"Positive"];
  [polarities addObject:pol2];
  
  Polarity* pol3 = [[Polarity alloc] init];
  [pol3 setType:@"Alternating"];
  [polarities addObject:pol3];
  
  // The waveShape and polarity properties are set by the popup buttons in the table view
  defaultWaveshapeType  = @"Gentle";
  defaultPolarityType   = @"Negative";
}

//********************************************************
//Intercept window closing as window delegate
//********************************************************
- (void)windowWillClose:(NSNotification *)notification
{
  [self saveProtocol:self];
  [programsArrayController removeObjects:programs];
}

//********************************************************
// Attempt to handle tab at last column?
//********************************************************
-(BOOL)control:(NSControl *)control textView:(NSTextView *)textView
                         doCommandBySelector:(SEL)commandSelector
{
  if(commandSelector == @selector(insertTab:) )
  {
    // Do your thing
    return YES;
  }
  else
  {
    return NO;
  }
}

//********************************************************
// Set the app delegate who owns us, this is called on
// initialization by the app delegate.
//********************************************************
- (void)setAppDelegate: (id)delegate
{
  appDelegate           = delegate;
  protocolToBeEdited    = [delegate protocolToBeEdited];
  [self setProgramsController];
  [self setWindowTitleEditing];
  [tableView deselectAll:self];
  
}

//********************************************************
//Insert a program before selected program
//********************************************************
- (IBAction)insertBeforeSelected:(id)sender
{
  [self setWindowTitle:@"Editing "];
  NSInteger selectedRow = [tableView selectedRow];
  [self insertNewProgramBefore:selectedRow];
}

//********************************************************
//Insert a program after selected program
//********************************************************
- (IBAction)insertAfterSelected:(id)sender
{
  [self setWindowTitle:@"Editing "];
  NSInteger selectedRow = [tableView selectedRow];
  [self insertNewProgramAfter:selectedRow];
}

//********************************************************
//Delete the selected program
//********************************************************
- (IBAction)deleteSelected:(id)sender
{
  [self setWindowTitle:@"Editing "];
  if([programs count] > 0)
  {
    NSInteger selectedRow = [tableView selectedRow];
    [programsArrayController removeObjectAtArrangedObjectIndex: selectedRow];
    [self reorderSequenceNumbers];
  }
}

//********************************************************
//Sets the default wave shape insert type
//********************************************************
- (IBAction)insertWaveShapeType:(id)sender
{
  defaultWaveshapeType  = [sender titleOfSelectedItem];
}

//********************************************************
//Sets the default polarity insert type
//********************************************************
- (IBAction)insertPolarityType: (id)sender
{
  defaultPolarityType   = [sender titleOfSelectedItem];
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
  [protocolToBeEdited.protocolPrograms removeAllObjects];
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
  //Note: the saving will happen in windowWillClose
  [[self window]           close];
}

/////////////  PRIVATE METHODS /////////////////

//********************************************************
//Sets the array controller for the programs
//********************************************************
- (void) setProgramsController
{
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
  [newProgram setProgramWaveShape:     defaultWaveshapeType];
  [newProgram setProgramPolarity:      defaultPolarityType];
  if([programs count]>0 && index<[programs count])
  {
    ProtocolProgram* oldProgram = [programs objectAtIndex:index];
    [newProgram setProgramFreq1:   oldProgram.programFreq1];
    [newProgram setProgramFreq2:   oldProgram.programFreq2];
    [newProgram setProgramDuration:oldProgram.programDuration];
    [newProgram setProgramCurrent: oldProgram.programCurrent];
  }
  else
  {
    [newProgram setProgramFreq1:   @"100"];
    [newProgram setProgramFreq2:   @"200"];
    [newProgram setProgramDuration:@"2"];
    [newProgram setProgramCurrent: @"100"];
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
}

//********************************************************
//Inserts a new dummy program after the given row
//********************************************************
- (void) insertNewProgramAfter: (NSInteger)row
{
  ProtocolProgram* program  = [self getCopyProgramFrom:row];
  [programsArrayController insertObject:program atArrangedObjectIndex: (row+1)];
  [self reorderSequenceNumbers];
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


@end
