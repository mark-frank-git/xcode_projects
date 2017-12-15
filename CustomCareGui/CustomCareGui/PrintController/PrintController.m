//
//  PrintController.m
//  CustomCareGui
//
//  Created by Mark Frank on 2/8/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#import "PrintController.h"
#import "BankEditorController.h"

@interface PrintController ()

@end

@implementation PrintController
@synthesize     textView;

- (void)windowDidLoad
{
  [super windowDidLoad];
    
    // Set the default font:
  NSFont* font = [NSFont fontWithName:@"Courier" size:11.];
  [textView setFont: font];
}

//********************************************************
// Set the app delegate who owns us
//********************************************************
- (void)setAppDelegate: (id)delegate
{
  appDelegate           = delegate;
  //First erase old text
  [textView selectAll:self];
  [textView delete:self];
  [textView usesFontPanel];
  NSString* textToPrint = [delegate textToPrint];
  [textView insertText:textToPrint];
}

//********************************************************
// Print the text
//********************************************************
- (void)printText:(id)sender
{
  NSPrintOperation *printOperation;
  printOperation  = [NSPrintOperation printOperationWithView:textView];
  [printOperation    runOperation];
}

//********************************************************
// Print the text to PDF
//********************************************************
- (IBAction)closeWindow:(id)sender
{
  [[self window]    close];
}

@end
