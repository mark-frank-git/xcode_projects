//
//  BankEditorController.h
//  CustomCareGui
//
//  Created by Mark Frank on 2/4/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KeyDownTableView.h"

@class TreatmentProtocol;
@class ProtocolProgram;
@class ProtocolEditorController;
@class PrintController;
@interface BankEditorController : NSWindowController <NSApplicationDelegate, NSWindowDelegate>
{
  id                             appDelegate;                 // Pointer to the app delegate who owns us
  TreatmentProtocol*             selectedProtocol;            // The protocol we are going to select
  IBOutlet NSArrayController*    protocolsArrayController;    // Controller for list of protocols
  ProtocolEditorController*      protocolEditorController;    // Controller for Protocol editor window
  PrintController*               printController;             // Controller for printing the output
}
@property (strong) NSMutableArray*            protocols;          // List of protocols (each row in table view)
@property (weak)   IBOutlet KeyDownTableView* protocolsTableView; // The protocol table (table of protocols)

//Actions
- (IBAction)insertAfterSelected:  (id)sender;
- (IBAction)deleteProtocol:       (id)sender;
- (IBAction)editProtocol:         (id)sender;
- (IBAction)closeWindow:          (id)sender;
- (IBAction)loadNewBank:          (id)sender;
- (IBAction)printProtocols:       (id)sender;
- (IBAction)printProtocolNames:   (id)sender;
- (IBAction)saveBank:             (id)sender;

//Setters
- (void)setAppDelegate:           (id)delegate;
- (void)setFilePath:              (NSString *)filePath;

//Getters
- (NSString*)filePathToBank;

// Methods called by Sub-window Controllers
- (TreatmentProtocol* )         protocolToBeEdited;           // Called by Protocol Editor Controller
- (NSString *)                  textToPrint;

//Private/Local methods
- (bool)loadBankFrom:           (NSString*)filePath;
- (void)setProtocolsController;
- (void)setWindowTitle:         (NSString*)titleStart;
- (TreatmentProtocol *)         getDummyProtocol;
- (void)                        insertNewProtocolAfterSelectedRow: (TreatmentProtocol*)newProtocol;
- (void)                        reorderSequenceNumbers;
- (bool)                        saveBankToUrl:(NSURL *)url fileName:(NSString *)fileName;
- (void)                        startPrint;
- (void)                        showAlert:(NSString*) message inform:(NSString*)informMessage;
- (NSString *)                  showSaveDiscardCancelAlert;

@end
