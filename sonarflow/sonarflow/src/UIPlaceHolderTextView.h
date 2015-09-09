//
//  UIPlaceHolderTextView.h
//
//  Created by bcd and Jason George

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, strong) UILabel *placeHolderLabel;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;

- (void)textChanged:(NSNotification*)notification;

@end
