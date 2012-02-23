/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "ModalAlertDelegate.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define RECTCENTER(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))

#define DATAFROMSTRING(_STRING_) [_STRING_ dataUsingEncoding:NSUTF8StringEncoding]
#define STRINGFROMDATA(_DATA_) [[NSString alloc] initWithData:_DATA_ encoding:NSUTF8StringEncoding]


#define GKBEGINNER   @"com.sadun.cookbook.beginner"
#define GKROLLFORFIRST  @"Roll for First"

void showAlert(id formatstring,...);

@interface TestBedViewControllerSuper : UIViewController <UINavigationControllerDelegate, GKMatchDelegate, GKMatchmakerViewControllerDelegate>
{
    GKLocalPlayer *player;
    GKPlayer *opponent;
    GKMatch *match;
    
    BOOL matchStarted;
}
@property (readonly) NSString *opponentName;
- (void) addInvitationHandler;

- (void) finishMatch;
- (void) startMatch;

// Please customize these
- (void) cleanupGUI;
- (void) activateGameGUI;
- (void)match:(GKMatch *) aMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
@end
