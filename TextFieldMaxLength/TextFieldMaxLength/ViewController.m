//
//  ViewController.m
//  TextFieldMaxLength
//
//  Created by KentarOu on 2014/09/07.
//  Copyright (c) 2014年 KentarOu. All rights reserved.
//
//  謝辞: iOS で文字数制限つきのテキストフィールドをちゃんと作るのは難しいという話 http://blog.niw.at/post/92806309874
//


#import "ViewController.h"

#define MAX_LENGTH 10

@interface ViewController ()<UITextFieldDelegate>
{
    NSString *_previousText;
    NSRange _lastReplaceRange;
    NSString *_lastReplacementString;
}

@property (weak, nonatomic) IBOutlet UITextField *textField1;
@property (weak, nonatomic) IBOutlet UITextField *textField2;

@end

@implementation ViewController
            
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:_textField2];
    
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSLog(@"range.location = %ld,range.length = %ld",range.location,range.length);
    NSLog(@"replacementString = %@",string);
    
    // 通常のMax lengthを使った処理
    if (textField.tag == 1)
    {
        return [[textField.text stringByReplacingCharactersInRange:range withString:string] length] <= MAX_LENGTH;
    }
    
    
    // 日本語入力の変換中に対応するための変数に代入
    if (textField.tag == 2)
    {
        _previousText = textField.text;
        _lastReplaceRange = range;
        _lastReplacementString = string;
    }
    
    return YES;
}


- (void)_textFieldDidChange:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    
    if (textField.markedTextRange) {
        return;
    }
    
    // 日本語入力の変換中が確定した時の処理(文字数オーバー時)
    if ([textField.text length] > MAX_LENGTH) {
        NSInteger offset = MAX_LENGTH - [textField.text length];
        
        NSString *replacementString = [_lastReplacementString substringToIndex:([_lastReplacementString length] + offset)];
        NSString *text = [_previousText stringByReplacingCharactersInRange:_lastReplaceRange withString:replacementString];
        
        UITextPosition *position = [textField positionFromPosition:textField.selectedTextRange.start offset:offset];
        UITextRange *selectedTextRange = [textField textRangeFromPosition:position toPosition:position];
        
        textField.text = text;
        textField.selectedTextRange = selectedTextRange;
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
