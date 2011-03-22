#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <QuickLook/QuickLook.h>
#import <Foundation/Foundation.h>
#import "BETaskHelper.h"
#import "helpers.h"
/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */



OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
	if (checkExpire())
        return noErr;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	NSMutableDictionary *props = [[NSMutableDictionary alloc] init];
	[props setObject:@"UTF-8" forKey:(NSString *)kQLPreviewPropertyTextEncodingNameKey];
	[props setObject:@"text/html" forKey:(NSString *)kQLPreviewPropertyMIMETypeKey];
	[props setObject:[NSNumber numberWithInt:700] forKey:(NSString *)kQLPreviewPropertyWidthKey];
	[props setObject:[NSNumber numberWithInt:500] forKey:(NSString *)kQLPreviewPropertyHeightKey];
    

	NSString *fname=makeThumbnailIfNecessary((NSURL*)url);
	

    
	
	//  kUTTypeJPEG
	QLThumbnailRequestSetImageWithData(
										  thumbnail,
										  (CFDataRef)[NSData dataWithContentsOfFile:fname],
										  (CFDictionaryRef)props);
    
	[pool release];
    
	return noErr;
	
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
    // implement only if supported
}


NSString *makeThumbnailIfNecessary(NSURL *url) {
	NSString *ffmpeg=pathToFFMPEG();
	NSURL *urlToFile=(NSURL*)url;
	NSString *fname=[NSString stringWithFormat:@"/tmp/%@.jpg",[[urlToFile path]lastPathComponent]];
	
	
	NSTask *task = [[[NSTask alloc] init] autorelease];   // BETaskHelper will retain it for us
    [task setLaunchPath:ffmpeg];
	
	// ./ffmpeg -vframes 1 -i 00020.MTS  -vcodec mjpeg meu%d.jpg
	NSArray *args=[NSArray arrayWithObjects:@"-vframes", @"1", @"-i",[urlToFile path], 
				   @"-vcodec", @"mjpeg", fname
				   , nil];
	
	[task setArguments:args];
	
	[task launch];
	[task waitUntilExit];

	return fname;
	
	
}

NSString *pathToFFMPEG() {
	NSBundle *thisBundle=[NSBundle bundleWithIdentifier:@"com.loghound.AVHCDQuickLook"];
	NSString *ret=[thisBundle pathForResource:@"ffmpeg" ofType:@""];
	return ret;

}