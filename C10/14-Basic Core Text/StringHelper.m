/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "StringHelper.h"
#import <CoreText/CoreText.h>

#define MATCHSTART(STRING1, STRING2) ([[STRING1 uppercaseString] hasPrefix:[STRING2 uppercaseString]])

@implementation StringHelper
@synthesize string;
@synthesize fontName, fontSize;
@synthesize foregroundColor;
@synthesize alignment, breakMode;

- (id) init
{
	if (!(self = [super init])) return self;
	
	string = [[NSMutableAttributedString alloc] init];
	fontName = @"Helvetica";
	fontSize = 12.0f;

	return self;
}

+ (id) buildHelper
{
	return [[self alloc] init];
}

- (uint8_t) ctAlignment
{
	if (!alignment) return kCTNaturalTextAlignment;
	if (MATCHSTART(alignment, @"n")) return kCTNaturalTextAlignment;
	if (MATCHSTART(alignment, @"l")) return kCTLeftTextAlignment;
	if (MATCHSTART(alignment, @"c")) return kCTCenterTextAlignment;
	if (MATCHSTART(alignment, @"r")) return kCTRightTextAlignment;
	if (MATCHSTART(alignment, @"j")) return kCTJustifiedTextAlignment;
	return kCTNaturalTextAlignment;
}

- (uint8_t) ctBreakMode
{
	if (!breakMode) return kCTLineBreakByWordWrapping;
	if (MATCHSTART(breakMode, @"word")) return kCTLineBreakByWordWrapping;
	if (MATCHSTART(breakMode, @"char")) return kCTLineBreakByCharWrapping;
	if (MATCHSTART(breakMode, @"clip")) return kCTLineBreakByClipping;
	if (MATCHSTART(breakMode, @"head")) return kCTLineBreakByTruncatingHead;
	if (MATCHSTART(breakMode, @"tail")) return kCTLineBreakByTruncatingTail;
	if (MATCHSTART(breakMode, @"mid")) return kCTLineBreakByTruncatingMiddle;	
	return kCTLineBreakByWordWrapping;
}

- (CTParagraphStyleRef) newParagraphStyle
{
	int addedTraits = 0;
	if (alignment) addedTraits++;
	if (breakMode) addedTraits++;
	if (!addedTraits) return nil;
	
	uint8_t theAlignment = [self ctAlignment];
	CTParagraphStyleSetting alignSetting = {
		kCTParagraphStyleSpecifierAlignment,
		sizeof(uint8_t),
		&theAlignment};
	
	uint8_t theLineBreak = [self ctBreakMode];
	CTParagraphStyleSetting wordBreakSetting = {
		kCTParagraphStyleSpecifierLineBreakMode,
		sizeof(uint8_t),
		&theLineBreak};
	
	CTParagraphStyleSetting settings[2] = {alignSetting, wordBreakSetting};
	CTParagraphStyleRef paraStyle = CTParagraphStyleCreate(settings, 2);

	return paraStyle;
}

- (void) appendFormat: (NSString *) formatstring, ...
{
    if (!formatstring) return;
    
	va_list arglist;
	va_start(arglist, formatstring);
	NSString *outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	
	CTFontRef basicFontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, fontSize, NULL);
	NSMutableDictionary *basicFontAttr = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										  (__bridge id) basicFontRef, (__bridge NSString *) kCTFontAttributeName, 
										  nil];
	CFRelease(basicFontRef);

	if (foregroundColor)
		[basicFontAttr setObject:(__bridge id) foregroundColor.CGColor forKey:(__bridge NSString *)kCTForegroundColorAttributeName];
	
	CTParagraphStyleRef style = [self newParagraphStyle];
	if (style)
    {
		[basicFontAttr setObject:(__bridge id)style forKey:(__bridge NSString *)kCTParagraphStyleAttributeName];
        CFRelease(style);
    }    
	
	NSAttributedString *newString = [[NSAttributedString alloc] initWithString:outstring attributes:basicFontAttr];
	[self.string appendAttributedString:newString];
}

@end
