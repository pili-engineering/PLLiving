//
//  LDAgreementsViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/27.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDAgreementsViewController.h"

@implementation LDAgreementsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"F6F6F6"];
    
    [self.navigationItem setTitleView:({
        UILabel *label = [[UILabel alloc] init];
        label.text = LDString("Agreements");
        label.textColor = [UIColor colorWithHexString:@"030303"];
        label.font = [UIFont systemFontOfSize:14];
        [label sizeToFit];
        label;
    })];
    
    ({
        UITextView *textView = [[UITextView alloc] init];
        [self.view addSubview:textView];
        [textView setBackgroundColor:[UIColor clearColor]];
        [textView setEditable:NO];
        [textView setScrollEnabled:YES];
        [textView setAttributedText:[self _createAgreementsText]];
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(22);
            make.bottom.equalTo(self.view).with.offset(-22);
            make.left.equalTo(self.view).with.offset(32);
            make.right.equalTo(self.view).with.offset(-32);
        }];
    });
}

- (void)_text:(NSMutableAttributedString *)text addTitle:(NSString *)title
{
    NSDictionary<NSString *, id> * attrs = @{
       NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
       NSForegroundColorAttributeName: [UIColor colorWithHexString:@"5E5E5E"]
    };
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:attrs]];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n" attributes:attrs]];
}

- (void)_text:(NSMutableAttributedString *)text addParagraph:(NSString *)paragraph
{
    NSDictionary<NSString *, id> * attrs = @{
        NSFontAttributeName : [UIFont systemFontOfSize:12],
        NSForegroundColorAttributeName: [UIColor colorWithHexString:@"5E5E5E"]
    };
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:paragraph attributes:attrs]];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n" attributes:attrs]];
}

- (NSAttributedString *)_createAgreementsText
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    
    [self _text:text addTitle:@"App用户协议"];
    
    [self _text:text addParagraph:@"请仔细阅读本协议，LIVING App 平台将依据以下条件和条款为您提供服务。"];
    [self _text:text addParagraph:@"欢迎阅读 LIVING App平台用户协议(下称“本协议”)。本协议阐述之条款和条件适用于您使用 LIVING App平台所提供的各种工具和服务(下称“服务”)。"];
    
    [self _text:text addTitle:@"1．服务条款的确认"];
    [self _text:text addParagraph:@"LIVING 平台根据本服务条款及对该条款的修改向用户提供服务。本服务条款具有合同法上的法律效力。"];
    [self _text:text addTitle:@"如果您对协议的任何条款表示异议，您可以选择不注册，一旦您点选“注册”并通过注册程序，即表示您自愿接受本协议之所有条款，并已成为注册用户。用户在使用 LIVING 平台的同时，同意接受平台注册用户服务提供的各类信息服务。"];
    [self _text:text addTitle:@"LIVING 有权根据互联网的发展和中华人民共和国有关法律、法规的变化，不断地完善服务质量并依此修改本用户协议条款。用户的权利以及义务的表述，均以最新的服务条款为准。服务条款一旦发生变动，将会在重要页面上提示修改内容。如用户仍继续在服务期内使用该软件即视为自动接受服务条款的变动。"];
    [self _text:text addTitle:@"注册用户承诺遵守法律法规、社会主义制度、国家利益、公民合法权益、公共秩序、社会道德风尚和信息真实性等七条底线。"];
    [self _text:text addTitle:@"快看漫画App平台的注册用户承诺其注册的互联网账号名称不含以下情况："];
    [self _text:text addTitle:@"违反宪法或法律法规规定的；"];
    
    [self _text:text addTitle:@"反危害国家安全，泄露国家秘密，颠覆国家政权，破坏国家统一的；"];
    
    return text;
}

@end
