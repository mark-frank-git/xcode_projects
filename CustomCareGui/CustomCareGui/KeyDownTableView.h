//
//  KeyDownTableView.h
//  A sub-class of NSTableView that handles key down events
//
//  Created by Mark Frank on 12/13/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KeyDownTableView : NSTableView
{
  id        m_tableController;             // Pointer to the controller who owns us
}

//Public methods
-(void)resetEdits:            (id)sender;
-(void)setController:         (id)sender;
-(void)setFirstEditableColumn:(int)column;
-(void)setWasEdited:          (id)sender;
-(BOOL)tableWasEdited;

@end

