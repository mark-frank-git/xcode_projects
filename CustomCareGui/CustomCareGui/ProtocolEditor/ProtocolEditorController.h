//
//  ProtocolEditorController.h
//  CustomCareGui
//
//  Created by Mark Frank on 12/13/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Polarity.h"
#import "Waveshape.h"
#import "KeyDownTableView.h"

@class TreatmentProtocol;
@class ProtocolProgram;
@interface ProtocolEditorController : NSWindowController <NSApplicationDelegate, NSWindowDelegate,
                                                          NSTableViewDelegate>
{
  IBOutlet NSArrayController*    waveShapeArrayController;  // The list of wave shapes
  IBOutlet NSArrayController*    polarityArrayController;   // The list polarities
  IBOutlet NSArrayController*    programsArrayController;   // Controller for list of programs
  id                             appDelegate;               // Pointer to the app delegate who owns us
  TreatmentProtocol*             protocolToBeEdited;        // The protocol we are going to edit
}
@property (weak)   IBOutlet KeyDownTableView*  tableView;   // The protocol table (table of programs)
@property (weak)   IBOutlet NSTextField*  totalHours;       // Total duration hours part
@property (weak)   IBOutlet NSTextField*  totalMinutes;     // Total duration minutes part
@property (strong) NSMutableArray*        waveShapes;       // Array of wave shapes for pop up button
@property (strong) NSMutableArray*        polarities;       // Array of polarities for pop up button
@property (strong) NSMutableArray*        programs;         // List of programs (each row in table view)

//Setters
- (void)setAppDelegate:          (id)delegate;

//Adding and deleting programs
- (IBAction)insertBeforeSelected:(id)sender;
- (IBAction)insertAfterSelected: (id)sender;
- (IBAction)deleteSelected:      (id)sender;

//Copying and pasting
- (IBAction)selectAll:           (id)sender;
- (IBAction)copySelection:       (id)sender;
- (IBAction)pasteSelection:      (id)sender;

//Saving Protocol
- (IBAction)saveProtocol:        (id)sender;
- (IBAction)saveAndClose:        (id)sender;

//Checking on edited
- (bool)wasProtocolEdited;

//Calculating total duration
- (IBAction)findTotalDuration:   (id)sender;

//Private/Local methods
- (void)              setProgramsController;
- (void)              setWindowTitleEditing;
- (ProtocolProgram *) getCopyProgramFrom:     (NSUInteger)index;
- (void)              insertNewProgramBefore: (NSInteger)row;
- (void)              insertNewProgramAfter:  (NSInteger)row;
- (void)              setWindowTitle:         (NSString*)titleStart;
- (void)              reorderSequenceNumbers;
- (NSString *)        showSaveDiscardCancelAlert;

@end
