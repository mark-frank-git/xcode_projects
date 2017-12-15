//
//  TreatmentProtocol.h
//  CustomCareGui
//
//  Created by Mark Frank on 12/22/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreatmentProtocol : NSObject <NSCoding>      // We couldn't just use "Protocol" since this is
                                                        // already defined in Objective-C
@property          int             protocolSequenceNumber;
@property (strong) NSString*       protocolName;
@property (strong) NSString*       protocolNote;        // Line 2 on the Custom care unit
@property (strong) NSString*       protocolType;        // "Standard" or "User"
@property (strong) NSString*       protocolInstructions;
@property          bool            printProtocol;
@property (strong) NSMutableArray* protocolPrograms;    // The set of programs for each protocol


//NSCoding methods in order to do deep copy using archive/unarchive
- (id)initWithCoder:    (NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

//Public Methods
- (NSString*)textDescription:(bool)addPrograms;        // Return a printable text description of protocol

@end
