//
//  PatientNote.h
//  CustomCareGui
//
//  Created by Mark Frank on 12/24/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PatientNote : NSObject <NSCoding>

@property (strong) NSString*      patientNote;            // The note
@property (strong) NSString*      patientNoteAddedDate;   // Date that note was added
@property (strong) NSString*      patientNoteAddedBy;     // Name of person who added note

//NSCoding methods in order to do deep copy using archive/unarchive
- (id)initWithCoder:    (NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder*) encoder;

@end
