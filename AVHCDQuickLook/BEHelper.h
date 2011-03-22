//
//  BEHelper.h
//  AVHCDQuickLook
//
//  Created by John McLaughlin on 3/21/11.
//  Copyright 2011 Loghound.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BETaskHelper.h"


@interface BEHelper : NSObject <BETaskHelperDelegate> {

}
-(void) task:(NSTask *)task hasOutputAvailable:(NSString *)outputLine;

/*
 * Sent when the wrapped task completes
 */
-(void) task:(NSTask *)task hasCompletedWithStatus:(int) status;
@end
