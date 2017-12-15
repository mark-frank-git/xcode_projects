//
//  AppDelegate.mm
//  ExcelReformatter
//
//  Created by Mark Frank on 3/6/16.
//  Copyright © 2016 MarkFrank. All rights reserved.
//

#import "AppDelegate.h"
#import "CsvReader.h"

@interface AppDelegate ()
{
  CsvReader* m_csvReader;
}

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}

//********************************************************
// Reads a single patient info from disk
//********************************************************
- (IBAction)readFile:(id)sender
{
  NSOpenPanel* panel = [NSOpenPanel openPanel];
  // This method displays the panel and returns immediately.
  // The completion handler is called when the user selects an
  // item or cancels the panel.
  [panel beginWithCompletionHandler:^(NSInteger result)
   {
     if (result == NSFileHandlingPanelOKButton)
     {
       NSURL*  urlPtr        = [[panel URLs] objectAtIndex:0];
       NSString*  filePath   = [urlPtr relativePath];
       if(![self loadCsvFrom:filePath])
       {
         [self showAlert:@"Can't open document" inform:filePath];
       }
     }
   }
   ];
}

//********************************************************
// Saves an excel file to disk
//********************************************************
- (IBAction)saveFile:      (id)sender
{
  NSSavePanel* panel  = [NSSavePanel savePanel];
  [panel                setAllowedFileTypes:[NSArray arrayWithObject:@"csv"]];
  [panel                setCanCreateDirectories:YES];
  [panel                runModal];
  NSURL *saveUrl      = [panel directoryURL];
  NSString *filePath  = [saveUrl relativePath];
  NSString *fileName  = [filePath stringByAppendingString:@"/"];
  fileName            = [fileName stringByAppendingString:[panel nameFieldStringValue]];
  if(m_csvReader)
  {
    m_csvReader->writeCsvFile([fileName cStringUsingEncoding:NSUTF8StringEncoding]);
  }
}


/////////////  PRIVATE METHODS /////////////////

//********************************************************
//Load the bank from a file path, return NO on error
//********************************************************
- (BOOL)loadCsvFrom: (NSString*)filePath
{
  if(!m_csvReader)
  {
    m_csvReader         = new CsvReader();
  }
  if(m_csvReader->readCsvFile([filePath cStringUsingEncoding:NSUTF8StringEncoding]))
  {
    return YES;
  }
  else
  {
    return NO;
  }
}

//********************************************************
// Show alert message
//********************************************************
- (void) showAlert:(NSString*) message inform:(NSString*)informMessage
{
  NSAlert *alert      = [[NSAlert alloc] init];
  [alert addButtonWithTitle:@"OK"];
  [alert setMessageText:message];
  [alert setInformativeText:informMessage];
  [alert setAlertStyle:NSWarningAlertStyle];
  [alert runModal];
}

@end
