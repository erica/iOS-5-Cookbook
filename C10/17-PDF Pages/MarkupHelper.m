/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "MarkupHelper.h"
#import "StringHelper.h"

#define BASE_TEXT_SIZE	24.0f
#define STRMATCH(STRING1, STRING2) ([[STRING1 uppercaseString] rangeOfString:[STRING2 uppercaseString]].location != NSNotFound)

@implementation MarkupHelper
+ (NSAttributedString *) stringFromMarkup: (NSString *) inputString
{
    NSString *aString = [inputString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
	// Prepare to scan
	NSScanner *scanner = [NSScanner scannerWithString:aString];
	[scanner setCharactersToBeSkipped:[NSCharacterSet newlineCharacterSet]];
	NSCharacterSet *startSet = [NSCharacterSet characterSetWithCharactersInString:@"<"];
	NSCharacterSet *endSet = [NSCharacterSet characterSetWithCharactersInString:@">"];
	
	// Initialize a string helper
	StringHelper *stringHelper = [StringHelper buildHelper];
	CGFloat fontSize = BASE_TEXT_SIZE;
    
	// Headers, bolding, italics.
	int hlevel = 0;
	BOOL bold = NO, emph = NO;
	
	NSUInteger loc = 0;
	while (loc < aString.length)
	{
		NSString *contentText = nil; // scan to tag
		[scanner scanUpToCharactersFromSet:startSet intoString:&contentText];
		
		// Handle content (non-tag) text here
		if (contentText)
		{
			// Move the next location forward
			scanner.scanLocation = (loc += contentText.length + 1);
            
			// Set the font for the content material
			NSString *fontName = @"Futura-Medium";
			if (hlevel == 0)
			{
				//if (bold && emph) fontName = @"Futura-Medium";
				if (bold) fontName = @"Futura-CondensedExtraBold";
				else if (emph) fontName = @"Futura-MediumItalic";
			}
			
			stringHelper.fontName = fontName;
			stringHelper.fontSize = fontSize;
			[stringHelper appendFormat:contentText];
		}
        
		// Scan for the tag
		NSString *baseTag = nil; 
		[scanner scanUpToCharactersFromSet:endSet intoString:&baseTag];
		if (!baseTag)
		{
			NSLog(@"Unexpected error encountered while scanning! Bailing. Sorry.");
			return stringHelper.string;
		}
		
		// Move the next location forward
		scanner.scanLocation = (loc += baseTag.length + 1);
		
		// Restore standard tag form
		NSString *tagText = [baseTag stringByAppendingString:@">"];
		if (![tagText hasPrefix:@"<"]) 
			tagText = [@"<" stringByAppendingString:tagText];
		
		// -- PROCESS TAGS -- 
		
		// Header Tags
		if (STRMATCH(tagText, @"</h")) // finish any headline
		{
			hlevel = 0;
			[stringHelper appendFormat:@"\n"];
			fontSize = BASE_TEXT_SIZE;
		}
		else if (STRMATCH(tagText, @"<h1>")) hlevel = 1;
		else if (STRMATCH(tagText, @"<h2>")) hlevel = 2;
		else if (STRMATCH(tagText, @"<h3>")) hlevel = 3;
		else hlevel = 0;
		if (hlevel)
			fontSize = BASE_TEXT_SIZE + (8.0f - hlevel) * 2.0f;
		
		// Bold and Italic Tags
		if (STRMATCH(tagText, @"</i>"))			emph = NO;
		else if (STRMATCH(tagText, @"<i>"))		emph = YES;
		else if (STRMATCH(tagText, @"</b>"))	bold = NO;
		else if (STRMATCH(tagText, @"<b>"))		bold = YES;
		
		// Center Tag
		if (STRMATCH(tagText, @"</center>"))
			stringHelper.alignment = @"natural";
		else if (STRMATCH(tagText, @"<center>"))
			stringHelper.alignment = @"center";
		
		// Custom (non-HTML) tag examples: Color and Size
		
		if (STRMATCH(tagText, @"<color red>"))
			stringHelper.foregroundColor = [UIColor redColor];
		if (STRMATCH(tagText, @"<color green>"))
			stringHelper.foregroundColor = [UIColor greenColor];
		if (STRMATCH(tagText, @"<color blue>"))
			stringHelper.foregroundColor = [UIColor blueColor];
		else if (STRMATCH(tagText, @"</color")) // match partial
			stringHelper.foregroundColor = [UIColor blackColor];
		
		if (STRMATCH(tagText, @"<size")) // match partial
		{
			// Scan the value for the new font size
			NSScanner *newScanner = [NSScanner scannerWithString:tagText];
			NSCharacterSet *cs = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
			[newScanner setCharactersToBeSkipped:cs];
			[newScanner scanFloat:&fontSize];
		}
		else if (STRMATCH(tagText, @"</size>"))
			fontSize = BASE_TEXT_SIZE;
		
        
		// Paragraph and line break tags
		if (STRMATCH(tagText, @"<br")) // match all variants
			[stringHelper appendFormat:@"\n"];
		else if (STRMATCH(tagText, @"</p>"))
			[stringHelper appendFormat:@"\n\n"];
		else if (STRMATCH(tagText, @"<p>")) // default paragraph alignment
			stringHelper.alignment = @"natural";
	}
    
    return stringHelper.string;
}

@end
