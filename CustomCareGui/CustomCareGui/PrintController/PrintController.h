//
//  PrintController.h
//  CustomCareGui
//
//  Created by Mark Frank on 2/8/15.
//  Copyright (c) 2015 MarkFrank. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PrintController : NSWindowController <NSApplicationDelegate, NSWindowDelegate>
{
  id                             appDelegate;                 // Pointer to the app delegate who owns us
}
@property (strong)   IBOutlet NSTextView*  textView;            // The text view for printing

//Actions
- (IBAction)printText:        (id)sender;
- (IBAction)closeWindow:      (id)sender;

//Setters
- (void)setAppDelegate:       (id)delegate;


@end
