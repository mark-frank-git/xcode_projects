//
//  AppDelegate.h
//  ExcelReformatter
//
//  Created by Mark Frank on 3/6/16.
//  Copyright © 2016 MarkFrank. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
// Methods responding to menu items
- (IBAction)readFile:               (id)sender;               // From File->Open
- (IBAction)saveFile:               (id)sender;

//Private/Local methods
- (BOOL)loadCsvFrom:            (NSString*)filePath;
- (void)showAlert:              (NSString*) message inform:(NSString*)informMessage;


@end

