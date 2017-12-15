//
//  ProtocolBankController.h
//  CustomCareGui
//
//  Created by Mark Frank on 1/2/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TreatmentProtocol;
@class ProtocolProgram;
@interface ProtocolBankController : NSWindowController <NSApplicationDelegate, NSWindowDelegate>
{
  id                             appDelegate;                 // Pointer to the app delegate who owns us
  TreatmentProtocol*             selectedProtocol;            // The protocol we are going to select
  IBOutlet NSArrayController*    protocolsArrayController;    // Controller for list of protocols
}
@property (strong) NSMutableArray*        protocols;          // List of protocols (each row in table view)
@property (weak)   IBOutlet NSTableView*  protocolsTableView; // The protocol table (table of protocols)

//Actions
- (IBAction)addProtocol:        (id)sender;
- (IBAction)closeWindow:        (id)sender;
- (IBAction)loadNewBank:        (id)sender;

//Setters
- (void)setAppDelegate:         (id)delegate;
- (void)setFilePath:            (NSString *)filePath;

//Getters
- (NSString*)filePathToBank;

//Private/Local methods
- (BOOL)loadBankFrom:           (NSString*)filePath;
- (void)setProtocolsController;
- (void)setWindowTitle:         (NSString*)titleStart;
- (void)showAlert:              (NSString*) message inform:(NSString*)informMessage;

@end
