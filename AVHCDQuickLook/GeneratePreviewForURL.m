#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import <Foundation/Foundation.h>
#import "helpers.h"
/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */
static BOOL cancelRequest;

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
	if (QLPreviewRequestIsCancelled(preview)|| checkExpire())
        return noErr;
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	NSMutableDictionary *props = [[NSMutableDictionary alloc] init];
	[props setObject:@"UTF-8" forKey:(NSString *)kQLPreviewPropertyTextEncodingNameKey];
	[props setObject:@"text/html" forKey:(NSString *)kQLPreviewPropertyMIMETypeKey];
	[props setObject:[NSNumber numberWithInt:700] forKey:(NSString *)kQLPreviewPropertyWidthKey];
	[props setObject:[NSNumber numberWithInt:500] forKey:(NSString *)kQLPreviewPropertyHeightKey];
        

	cancelRequest=NO;
	NSString *movieFile=makeMovieIfNecessary((NSURL*)url,preview);
	NSLog(@"got a movie path %@, cancel request = %d",movieFile,cancelRequest);
	NSData *data=[NSData dataWithContentsOfMappedFile:movieFile];
	QLPreviewRequestSetDataRepresentation(preview
										  , (CFDataRef)data
										  , kUTTypeMovie
										  , NULL);

	
	
    
	[pool release];
    
	return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    cancelRequest=YES;
	NSLog(@"Got a cancel preview request !!!!!!!!!!!!!!!!!");
}


NSString *makeMovieIfNecessary(NSURL *url,QLPreviewRequestRef preview) {
	NSString *ffmpeg=pathToFFMPEG();
	NSURL *urlToFile=(NSURL*)url;
	NSString *fname=[NSString stringWithFormat:@"/tmp/%@.mov",[[urlToFile path]lastPathComponent]];
	
	NSFileManager *mgr=[NSFileManager defaultManager];
	if ([mgr fileExistsAtPath:fname])
		return fname;
	
	
	NSTask *task = [[[NSTask alloc] init] autorelease];   // BETaskHelper will retain it for us
    [task setLaunchPath:ffmpeg];
	
	// ./ffmpeg -i 00020.MTS      mov.mov
	// used to have -r 60  -s wvga but 60 fps/wvga just don't make sense
	NSArray *args=[NSArray arrayWithObjects:@"-y",@"-i",[urlToFile path],fname,nil];
				
	[task setArguments:args];
	BEHelper *helper=[[BEHelper new]autorelease];
	BETaskHelper *taskHelper=[[[BETaskHelper alloc]initWithDelegate:helper forTask:task]autorelease];
	[taskHelper launchTask];

	NSTimeInterval nowTime=[NSDate timeIntervalSinceReferenceDate];
	NSRunLoop *rl=[NSRunLoop currentRunLoop];
	while ([task isRunning] && !cancelRequest) {
		[rl runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];

	//	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]]; 
		if (QLPreviewRequestIsCancelled(preview))  {
			[taskHelper sendInput:@"q"];
			[task interrupt];
			[task terminate];
			[mgr removeFileAtPath:fname handler:nil];

			cancelRequest=TRUE;
		}
		if (([NSDate timeIntervalSinceReferenceDate]-nowTime)>25) {
			[taskHelper sendInput:@"q"];
			[task waitUntilExit];
			NSLog(@"25 seconds elapsed -- had to manually quit");
			break;
		}
	}
	if (cancelRequest)  {
		[taskHelper sendInput:@"q"];
		[task interrupt];
		[task terminate];
		[mgr removeFileAtPath:fname handler:nil];
	}

	return fname;
	
	
}


BOOL checkExpire (){
	
#define EXPIREAFTERDAYS 27
	
#if EXPIREAFTERDAYS   
	// Idea from Brian Cooke.
	NSString* nowString =
	[NSString stringWithUTF8String:__DATE__];
	NSCalendarDate* nowDate =
	[NSCalendarDate dateWithNaturalLanguageString:nowString];
	NSCalendarDate* expireDate =
	[nowDate dateByAddingTimeInterval:(60*60*24* EXPIREAFTERDAYS)];
	
	if ([expireDate earlierDate:[NSDate date]] == expireDate)
	{
		return YES;
	}
#endif
	return NO;
	
}

