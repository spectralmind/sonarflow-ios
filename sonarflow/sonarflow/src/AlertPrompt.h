//
//  AlertPrompt.h
//  Sonarflow
//
//  Created by Raphael Charwot on 30.10.10.
//  Parts by Jeff LaMarche on 2/26/09.
//  Copyright 2010 Charwot. All rights reserved.

#import <Foundation/Foundation.h>

@interface AlertPrompt : UIAlertView <UITextFieldDelegate> {
    UITextField *textField;
	CGRect keyboardFrame;
}

@property (nonatomic, strong) UITextField *textField;
@property (weak, nonatomic, readonly) NSString *enteredText;

- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle textFieldPlaceholder:(NSString *)placeholder;

@end