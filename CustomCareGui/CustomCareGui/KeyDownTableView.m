  //
//  KeyDownTableView.m
//  CustomCareGui
//
//  Created by Mark Frank on 12/13/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import "KeyDownTableView.h"
#import "ProtocolEditorController.h"

@implementation KeyDownTableView
{
  bool          m_tableWasEdited;         //Table was edited
  int           m_firstEditableColumn;    //First column to edit (after tab)
}

//********************************************************
// Reset the editing
//********************************************************
- (void) resetEdits:(id)sender
{
  m_tableWasEdited            = NO;
}

//********************************************************
// Set the controller
//********************************************************
- (void) setController:(id)sender
{
  m_tableController           = sender;
}

//********************************************************
// Set the controller
//********************************************************
- (void) setFirstEditableColumn:(int)column
{
  m_firstEditableColumn       = column;
}

//********************************************************
// Returns whether editing occurred
//********************************************************
- (BOOL)tableWasEdited
{
  return m_tableWasEdited;
}

const int kLEFT_ARROW = 37;
//********************************************************
// Over ride the key down method.  For some reason this only
// seems to intercept the tab in the last column?
//********************************************************
- (void)keyDown:(NSEvent *)keyEvent
{
  int inputChar  = [[keyEvent characters] characterAtIndex:0];
  switch(inputChar)
  {
    case NSTabCharacter:
      m_tableWasEdited        = YES;
      NSInteger editedRow     = [self selectedRow];
      if(editedRow >= [self numberOfRows]-1)
      {
        //If at the end of the rows, insert a new one
        [m_tableController insertAfterSelected:self];
      }
      [self selectRowIndexes:[NSIndexSet indexSetWithIndex:(editedRow+1)] byExtendingSelection:NO];
      [self editColumn:m_firstEditableColumn row:editedRow+1 withEvent:nil select:YES];
      break;
    case kLEFT_ARROW:
      m_tableWasEdited        = YES;
      break;
    default:
      break;
  }
  [super keyDown:keyEvent];
}

//********************************************************
// Set the edit flag
//********************************************************
-(void)setWasEdited:(id)sender
{
  m_tableWasEdited  = YES;
}

//********************************************************
// Over ride the key down method
//********************************************************
- (void)mouseDown:(NSEvent *)mouseEvent
{
  m_tableWasEdited  = YES;
  [super mouseDown:mouseEvent];
}

@end
