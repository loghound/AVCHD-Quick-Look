//
//  BEHelper.m
//  AVHCDQuickLook
//
//  Created by John McLaughlin on 3/21/11.
//  Copyright 2011 Loghound.com. All rights reserved.
//

#import "BEHelper.h"


@implementation BEHelper
-(void) task:(NSTask *)task hasOutputAvailable:(NSString *)outputLine {
	NSLog(@"task %@ has output %@",task,outputLine);
}

/*
 * Sent when the wrapped task completes
 */
-(void) task:(NSTask *)task hasCompletedWithStatus:(int) status {
	NSLog(@"task %@ has completed with status %d",task,status);
	
}
@end
