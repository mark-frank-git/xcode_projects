//
//  ProtocolProgram.h
//  CustomCareGui
//
//  Created by Mark Frank on 12/15/14.
//  Copyright (c) 2014 MarkFrank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProtocolProgram : NSObject <NSCoding>
{
}
//Note: needed to make some of the properties below strings instead of numbers, so that we
//      don't get exceptions if the user enters a blank in the table view
@property          int       programSequenceNumber;
@property (strong) NSString* programWaveShape;      //!< "Gentle", "Mild", "Sharp", "Pulse"
@property (strong) NSString* programFreq1;          //!< First frequency in Hertz
@property (strong) NSString* programFreq2;          //!< Second frequency in Hertz
@property (strong) NSString* programCurrent;        //!< Current in micro amperes
@property (strong) NSString* programDuration;       //!< Duration in minutes
@property (strong) NSString* programPolarity;       //!< "Negative", "Positive", "Alternating"


//NSCoding methods in order to do deep copy using archive/unarchive
- (id)initWithCoder:    (NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder*) encoder;

//Public methods
- (NSString *)textDescription;

@end
