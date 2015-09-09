//
//  AlertPrompt.m
//  Sonarflow
//
//  Created by Raphael Charwot on 30.10.10.
//  Parts by Jeff LaMarche on 2/26/09.
//  Copyright 2010 Charwot. All rights reserved.

#import "AlertPrompt.h"

#define kHPadding 12
#define kTextFieldHeight 25

#define kKeyboardWillShowAnimation @"kKeyboardWillShowAnimation"

@interface AlertPrompt ()

- (void)keyboardWillShow:(NSNotification *)note;
- (void)keyboardWillHide:(NSNotification *)note;

- (void)adjustCenterAnimated:(BOOL)animated;

@end


@implementation AlertPrompt

@synthesize textField;
- (void)setCenter:(CGPoint)newCenter {
	[super setCenter:newCenter];
	[self adjustCenterAnimated:NO];
}

- (void)setFrame:(CGRect)newFrame {
	[super setFrame:newFrame];
	[self adjustCenterAnimated:NO];
}

- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle textFieldPlaceholder:(NSString *)placeholder {
    if(self = [super initWithTitle:title message:@" \n " delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil]) {
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectZero];
		theTextField.borderStyle = UITextBorderStyleRoundedRect;
		theTextField.placeholder = placeholder;
		theTextField.delegate = self;
        [self addSubview:theTextField];
        self.textField = theTextField;

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification
												   object:nil];		
    }

    return self;
}

- (void)show {
    [textField becomeFirstResponder];
    [super show];
}

- (NSString *)enteredText {
    return textField.text;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGSize outerSize = self.bounds.size;
	CGRect textFrame = CGRectMake(kHPadding, outerSize.height * 0.5 - kTextFieldHeight,
								  outerSize.width - 2 * kHPadding, kTextFieldHeight);
	self.textField.frame = textFrame;
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self dismissWithClickedButtonIndex:self.firstOtherButtonIndex animated:YES];

	return YES;
}

#pragma mark -
#pragma mark Private Methods

- (void)keyboardWillShow:(NSNotification *)note {
	//!!!: iOS >3.2
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
	
	[self adjustCenterAnimated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note {
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];

	[self adjustCenterAnimated:YES];
}

- (void)adjustCenterAnimated:(BOOL)animated {
	if(self.superview != nil && self.window != nil) {
		CGRect localKeyboardFrame = [self.window convertRect:keyboardFrame fromWindow:nil];
		CGFloat keyboardStart = localKeyboardFrame.origin.y;
		CGSize parentSize = self.superview.bounds.size;
		CGFloat height = (keyboardStart == 0 ? parentSize.height : keyboardStart);
		CGPoint newCenter = CGPointMake(parentSize.width * 0.5,
										height * 0.5);

		if(animated &&
		   (self.center.x != 0 || self.center.y != 0)) { //Prevent "fly in from outside the screen" animation
			[UIView beginAnimations:kKeyboardWillShowAnimation context:nil];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDuration:0.3f];
		}
		[super setCenter:newCenter];
		if(animated) {
			[UIView commitAnimations];
		}
	}
}

@end