//
//  ttrMsgBoardView.m
//  TexTr
//
//  Created by Mohan Kumar on 10/07/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrMsgBoardView.h"
#import "Base64.h"
#import "ttrRESTProxy.h"
#import "ttrCommonUtilities.h"
#import "ttrDefaults.h"

@interface ttrMsgBoardView()<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>
{
    CGFloat _rowHeight;
    CGSize _keyBoardSize;
    CGFloat _txtMsgVwHeight;
    UIButton * _btnAddPicture;
    UIButton * _btnSendText;
    UITextView * _dispTxtView1;
    NSArray * _txtHtConstraints;
    NSMutableParagraphStyle * _txtmsgStyle;
    UIGestureRecognizer * _justGesture;
    CGAffineTransform _rotateTransform;
}

@property (nonatomic,strong) UITableView * messagesTV;

@end


@implementation ttrMsgBoardView

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        [self setBackgroundColor:[UIColor clearColor]];
        _rowHeight = 60.0f;
        _txtMsgVwHeight = 30.0f;
        _txtmsgStyle = [[NSMutableParagraphStyle alloc] init];
        _txtmsgStyle.lineBreakMode = NSLineBreakByCharWrapping;
        _txtmsgStyle.alignment = NSTextAlignmentLeft;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (self.messagesTV)
        return;
    self.messagesTV = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.messagesTV.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.messagesTV];
    self.messagesTV.dataSource = self;
    self.messagesTV.delegate = self;
    [self.messagesTV setSeparatorColor:[UIColor clearColor]];
    [self.messagesTV setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    //[self.messagesTV setBackgroundColor:[UIColor clearColor]];
    [self.messagesTV setBackgroundColor:[UIColor colorWithRed:0.5 green:0.7 blue:0.9 alpha:1.0]];
    self.messagesTV.contentInset = UIEdgeInsetsZero;
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.messagesTV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:1.0],[NSLayoutConstraint constraintWithItem:self.messagesTV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-44.0)],[NSLayoutConstraint constraintWithItem:self.messagesTV attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.messagesTV attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:(-22.0)]]];
    _btnAddPicture = [ttrDefaults getStandardButton];
    [_btnAddPicture setBackgroundColor:[UIColor clearColor]];
    _btnAddPicture.translatesAutoresizingMaskIntoConstraints = NO;
    [_btnAddPicture
     setBackgroundImage:[ttrCommonUtilities getImageForPlusBtn:CGSizeMake(10.0, 10.0)
                                                   withBGColor:[UIColor clearColor]
                                                andStrokeColor:[UIColor grayColor]] forState:UIControlStateNormal];
    [self addSubview:_btnAddPicture];
    [_btnAddPicture addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[bp(25)]" options:0 metrics:nil views:@{@"bp":_btnAddPicture}]];
    [_btnAddPicture addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bp(25)]" options:0 metrics:nil views:@{@"bp":_btnAddPicture}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_btnAddPicture attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.messagesTV attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0]];
    
    _btnSendText = [ttrDefaults getStandardButton];
    [_btnSendText setBackgroundColor:[UIColor clearColor]];
    _btnSendText.translatesAutoresizingMaskIntoConstraints = NO;
    [_btnSendText setTitle:@"Send" forState:UIControlStateNormal];
    [_btnSendText setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _btnSendText.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [self addSubview:_btnSendText];
    [_btnSendText addTarget:self action:@selector(sendTextMessageIntoChat) forControlEvents:UIControlEventTouchUpInside];
    [_btnSendText addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[bs(35)]" options:0 metrics:nil views:@{@"bs":_btnSendText}]];
    [_btnSendText addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bs(18)]" options:0 metrics:nil views:@{@"bs":_btnSendText}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_btnSendText attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.messagesTV attribute:NSLayoutAttributeBottom multiplier:1.0 constant:13.0]];
    
    _dispTxtView1 = [UITextView new];
    _dispTxtView1.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_dispTxtView1];
    _dispTxtView1.text = @"Text Message....";
    _dispTxtView1.textAlignment = NSTextAlignmentLeft;
    _dispTxtView1.textColor = [UIColor grayColor];
    [_dispTxtView1 setBackgroundColor:[UIColor clearColor]];
    _dispTxtView1.delegate = self;
    _dispTxtView1.font = [UIFont systemFontOfSize:15.0f];
    [_dispTxtView1.layer setBorderColor:[UIColor clearColor].CGColor];
    _dispTxtView1.showsVerticalScrollIndicator = NO;
    [_dispTxtView1 setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_dispTxtView1 setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_dispTxtView1.layer setBorderWidth:1.0f];
    _dispTxtView1.layer.cornerRadius = 5.0f;
    [_dispTxtView1.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    _dispTxtView1.layer.masksToBounds=YES;
    
    _txtHtConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dtv1(h)]" options:0 metrics:@{@"h":@(_txtMsgVwHeight)} views:@{@"dtv1":_dispTxtView1}];
    [_dispTxtView1 addConstraints:_txtHtConstraints];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_dispTxtView1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-80.0)],[NSLayoutConstraint constraintWithItem:_dispTxtView1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.messagesTV attribute:NSLayoutAttributeBottom multiplier:1.0 constant:7.0]]];
    
    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|-5-[bp]-5-[dtv1]-5-[bs]"
      options:0
      metrics:nil
      views:@{@"bp":_btnAddPicture,
              @"dtv1":_dispTxtView1,
              @"bs":_btnSendText}]];
    _dispTxtView1.text = @"Text Message....";
    [self layoutIfNeeded];
    _rotateTransform = CGAffineTransformMakeRotation(M_PI);
    self.messagesTV.transform = _rotateTransform;
    _justGesture = [[UIGestureRecognizer alloc] init];
    _justGesture.delegate = self;
    [self addGestureRecognizer:_justGesture];
    
}

- (void)reloadAllChatMessages
{
    [self.messagesTV reloadData];
}

- (void) sendTextMessageIntoChat
{
    if ([_dispTxtView1.text isEqualToString:@"Text Message...."]==NO)
    {
        [self.handlerDelegate sendTextMessage:_dispTxtView1.text];
        _dispTxtView1.text = @"Text Message....";
    }
    [_dispTxtView1 resignFirstResponder];
}

- (void)setDataKeyBoardSize:(CGSize)p_keyboardSize
{
    if (CGSizeEqualToSize(p_keyboardSize, _keyBoardSize)==NO)
    {
        _keyBoardSize = p_keyboardSize;
    }
    if (CGSizeEqualToSize(p_keyboardSize, CGSizeZero))
    {
        [UIView animateWithDuration:0.4
                         animations:^{
                             [self setContentOffset:CGPointMake(0, 0)];
                         }];
        return;
    }
    CGRect l_inputfieldbounds = [_dispTxtView1 convertRect:_dispTxtView1.bounds toView:self];
    CGRect l_superbounds = self.bounds;
    if ((l_inputfieldbounds.origin.y+l_inputfieldbounds.size.height+10.0)>(l_superbounds.size.height-_keyBoardSize.height))
    {
        CGFloat l_offsetheight = (l_inputfieldbounds.origin.y+l_inputfieldbounds.size.height) - (l_superbounds.size.height-_keyBoardSize.height)+10.0;
        if (l_offsetheight!=self.contentOffset.y)
        {
            if ([_dispTxtView1.text isEqualToString:@"Text Message...."])
            {
                [_dispTxtView1 removeConstraints:_txtHtConstraints];
                _txtHtConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dtv1(h)]" options:0 metrics:@{@"h":@(_txtMsgVwHeight)} views:@{@"dtv1":_dispTxtView1}];
                [_dispTxtView1 addConstraints:_txtHtConstraints];
            }
            [UIView
             animateWithDuration:0.2
             animations:^{
                 [self setContentOffset:CGPointMake(0, l_offsetheight)];
                 self.messagesTV.transform = _rotateTransform;
                 _dispTxtView1.transform = CGAffineTransformIdentity;
                 [self layoutIfNeeded];
             }];
        }
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint l_touchPoint = [touch locationInView:self.messagesTV];
    if (self.contentOffset.y!=0)
    {
        if (CGRectContainsPoint(self.messagesTV.frame, l_touchPoint))
        {
            [_dispTxtView1 resignFirstResponder];
        }
    }
    return NO;
}

#pragma textview delegates to enable disable keyboard notifications

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Text Message...."])
    {
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSString * l_enteredText = textView.text;
    l_enteredText = [l_enteredText stringByReplacingOccurrencesOfString:@"Text Message...." withString:@""];
    l_enteredText = [l_enteredText stringByReplacingOccurrencesOfString:@" " withString:@""];
    l_enteredText = [l_enteredText stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if ([l_enteredText length]==0)
    {
        textView.text = @"Text Message....";
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGRect l_reqdrect = [textView.text boundingRectWithSize:CGSizeMake(textView.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textView.font,NSParagraphStyleAttributeName:_txtmsgStyle} context:nil];
    if (l_reqdrect.size.height>=textView.bounds.size.height)
    {
        NSInteger l_reqdfactor = l_reqdrect.size.height / _txtMsgVwHeight;
        if (l_reqdfactor*_txtMsgVwHeight<l_reqdrect.size.height)
            l_reqdfactor++;
        [_dispTxtView1 removeConstraints:_txtHtConstraints];
        _txtHtConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dtv1(h)]" options:0 metrics:@{@"h":@(l_reqdfactor*_txtMsgVwHeight)} views:@{@"dtv1":_dispTxtView1}];
        [_dispTxtView1 addConstraints:_txtHtConstraints];
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.messagesTV.transform = CGAffineTransformConcat(_rotateTransform,                              CGAffineTransformTranslate(CGAffineTransformIdentity, 0, (_txtMsgVwHeight - l_reqdfactor*_txtMsgVwHeight)));
                             _dispTxtView1.transform =
                             CGAffineTransformTranslate(CGAffineTransformIdentity, 0, (_txtMsgVwHeight - l_reqdfactor*_txtMsgVwHeight));
                             [self layoutIfNeeded];
                         }];
    }
}

#pragma tableview delegates

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.handlerDelegate getNumberOfBoardMessages];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * l_leftcellid = @"leftside_cell";
    static NSString * l_rightcellid = @"rightside_cell";
    static NSString * l_reloadcellid = @"reload_cell";
    NSString * l_reqdcellid = l_leftcellid;
    NSInteger l_halfno = indexPath.row / 2;
    if (l_halfno*2==indexPath.row)
        l_reqdcellid = l_rightcellid;
    NSDictionary * l_dispDict = [self.handlerDelegate getBoardMessageDictAtPosn:indexPath.row];
    if (!l_dispDict)
        l_reqdcellid = l_reloadcellid;
    ttrMsgBoardViewCell * l_newcell = [tableView dequeueReusableCellWithIdentifier:l_reqdcellid];
    if (l_newcell==nil)
    {
        l_newcell = [[ttrMsgBoardViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:l_reqdcellid];
        [l_newcell setBackgroundColor:[UIColor clearColor]];
    }
    [l_newcell setDisplayDict:l_dispDict itemPosnNo:indexPath.row];
    if (!l_dispDict)
    {
        [self.handlerDelegate fetchOldMessages];
    }
    return l_newcell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     
     */
}


@end


@interface ttrMsgBoardViewCell()
{
    UIImageView * _profileView;
    NSDictionary * _displayDict;
    NSInteger _itemPosnNo;
    ttrMsgBoardViewCellMsgView * _messageDisp;
    UIView * _mainContainer;
    NSArray * _txtWidthCnsrts;
    BOOL _reloadOnlyCell;
    UIActivityIndicatorView * _reloadView;
}

//@property (nonatomic,strong) UILabel * message;


@end

@implementation ttrMsgBoardViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        if ([reuseIdentifier rangeOfString:@"reload"].location!=NSNotFound)
        {
            _reloadOnlyCell = YES;
            [self setAccessoryType:UITableViewCellAccessoryNone];
        }
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (_reloadOnlyCell)
    {
        [self drawReLoadViewCell];
        return;
    }
    if (_messageDisp) {
        [self displaySettings];
        return;
    }
    _mainContainer = [UIView new];
    _mainContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_mainContainer];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_mainContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_mainContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_mainContainer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_mainContainer attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

    _profileView = [UIImageView new];
    _profileView.image = [UIImage imageNamed:@"nophoto"];
    _profileView.translatesAutoresizingMaskIntoConstraints = NO;
    [_mainContainer addSubview:_profileView];
    [_profileView.layer setBorderWidth:1.0f];
    _profileView.layer.cornerRadius = 5.0f;
    [_profileView.layer setBorderColor:[UIColor clearColor].CGColor];
    _profileView.layer.masksToBounds=YES;
    
    [_profileView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[pv(30)]" options:0 metrics:nil views:@{@"pv":_profileView}]];
    [_profileView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pv(30)]" options:0 metrics:nil views:@{@"pv":_profileView}]];
    if ([self.reuseIdentifier rangeOfString:@"left"].location!=NSNotFound)
    {
        [_mainContainer addConstraint:[NSLayoutConstraint constraintWithItem:_profileView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_mainContainer attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0]];
        [_mainContainer addConstraint:[NSLayoutConstraint constraintWithItem:_profileView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_mainContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0]];
    }
    else
    {
        [_mainContainer addConstraint:[NSLayoutConstraint constraintWithItem:_profileView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_mainContainer attribute:NSLayoutAttributeRight multiplier:1.0 constant:(-10.0)]];
        [_mainContainer addConstraint:[NSLayoutConstraint constraintWithItem:_profileView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_mainContainer attribute:NSLayoutAttributeBottom multiplier:1.0 constant:(-10.0)]];
    }

    if ([self.reuseIdentifier rangeOfString:@"left"].location!=NSNotFound)
        _messageDisp = [[ttrMsgBoardViewCellMsgView alloc] initWithArrowDirn:@"L"];
    else
        _messageDisp = [[ttrMsgBoardViewCellMsgView alloc] initWithArrowDirn:@"R"];
    _messageDisp.translatesAutoresizingMaskIntoConstraints = NO;
    [_mainContainer addSubview:_messageDisp];
    [_mainContainer addConstraint:[NSLayoutConstraint constraintWithItem:_messageDisp attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_mainContainer attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-10.0)]];
    [_mainContainer addConstraint:[NSLayoutConstraint constraintWithItem:_messageDisp attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_mainContainer attribute:NSLayoutAttributeWidth multiplier:1.0 constant:(-60.0)]];
    [_mainContainer addConstraint:[NSLayoutConstraint constraintWithItem:_messageDisp attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_mainContainer attribute:NSLayoutAttributeCenterY multiplier:(1.0) constant:(0.0)]];
    if ([self.reuseIdentifier rangeOfString:@"left"].location!=NSNotFound)
    {
        [_mainContainer addConstraint:[NSLayoutConstraint constraintWithItem:_messageDisp attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_mainContainer attribute:NSLayoutAttributeLeft multiplier:1.0 constant:(50.0)]];
    }
    else
    {
        [_mainContainer addConstraint:[NSLayoutConstraint constraintWithItem:_messageDisp attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_mainContainer attribute:NSLayoutAttributeRight multiplier:1.0 constant:(-50.0)]];
    }
    [self layoutIfNeeded];
    _mainContainer.transform = CGAffineTransformMakeRotation(-M_PI);
    [self displaySettings];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void) drawReLoadViewCell
{
    if (_reloadView) {
        [_reloadView startAnimating];
        return;
    }
    _reloadView = [UIActivityIndicatorView new];
    _reloadView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    _reloadView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_reloadView];
    [_reloadView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[reload(20)]" options:0 metrics:nil views:@{@"reload":_reloadView}]];
    [_reloadView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[reload(20)]" options:0 metrics:nil views:@{@"reload":_reloadView}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_reloadView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_reloadView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    _reloadView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    [_reloadView startAnimating];
}

- (void) setDisplayDict:(NSDictionary*) p_displayDict itemPosnNo:(NSInteger) p_itemNo
{
    if (_reloadOnlyCell) {
        [_reloadView startAnimating];
        return;
    }
    _displayDict = p_displayDict;
    _itemPosnNo = p_itemNo;
    if (_messageDisp) {
        [self displaySettings];
    }
}

- (void) displaySettings
{
    //_messageDisp.text = [_displayDict valueForKey:@"message"];
    [_messageDisp setdisplayText:[_displayDict valueForKey:@"message"]];
    if ([_displayDict valueForKey:@"userprofile"])
    {
        [[ttrRESTProxy alloc]
         initDatawithAPIType:@"GETFILE"
         andInputParams:@{@"filename":[_displayDict valueForKey:@"userprofile"]}
         andReturnMethod:^(NSDictionary * p_imgfileinfo)
         {
             _profileView.image = [UIImage imageWithData:[p_imgfileinfo valueForKey:@"resultdata"]];
         }];
    }
}

@end

@interface ttrMsgBoardViewCellMsgView()
{
    NSString * _arrowDirn;
    UILabel * _dispLabel;
    CAShapeLayer * _reqdLayer; //, * _reqdLayer2;
    NSMutableParagraphStyle * _txtmsgStyle;
    NSString * _dispText;
}

@end

@implementation ttrMsgBoardViewCellMsgView

- (instancetype) initWithArrowDirn:(NSString*) p_arrowDirn
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        _arrowDirn = p_arrowDirn;
        /*if ([_arrowDirn isEqualToString:@"L"])
            [self setTextAlignment:NSTextAlignmentLeft];
        else
            [self setTextAlignment:NSTextAlignmentRight];*/
        [self setBackgroundColor:[UIColor clearColor]];
        //self.numberOfLines = 0;
        //
        _txtmsgStyle = [[NSMutableParagraphStyle alloc] init];
        _txtmsgStyle.lineBreakMode = NSLineBreakByCharWrapping;
        _txtmsgStyle.alignment = NSTextAlignmentLeft;
        
    }
    return self;
}

/*- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    bounds.origin.x += 45.0;
    bounds.size.width -= 30.0;
    numberOfLines = 0;
    return bounds;
}
*/


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    /*if ([_arrowDirn isEqualToString:@"L"])
        [self drawLeftArrowed:self.frame];
    else
        [self drawRightArrowed:self.frame];*/
    if (_dispLabel) {
        return;
    }
    _dispLabel = [ttrDefaults getStandardLabelWithText:@""];
    _dispLabel.numberOfLines =0;
    [_dispLabel sizeToFit];
    _dispLabel.translatesAutoresizingMaskIntoConstraints=YES;
    [self addSubview:_dispLabel];
    if ([_arrowDirn isEqualToString:@"L"])
        [_dispLabel setTextAlignment:NSTextAlignmentLeft];
    else
        [_dispLabel setTextAlignment:NSTextAlignmentRight];
    [self setdisplayText:_dispText];
}

- (void) setdisplayText:(NSString*) p_dispText
{
    _dispText = p_dispText;
    if (!_dispLabel) {
        return;
    }
    [_dispLabel setText:p_dispText];
    CGRect l_reqdrect = [[p_dispText copy] boundingRectWithSize:CGSizeMake((self.bounds.size.width-30), self.bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_dispLabel.font,NSParagraphStyleAttributeName:_txtmsgStyle} context:nil];
    if (l_reqdrect.size.height<30.0)
    {
        l_reqdrect.size.height = 30.0f;
    }
    /*if (l_reqdrect.size.width<self.bounds.size.width/2.0)
    {
        l_reqdrect.size.width = self.bounds.size.width/2.0;
    }*/
    
    if (_reqdLayer) {
        [_reqdLayer removeFromSuperlayer];
        //[_reqdLayer2 removeFromSuperlayer];
    }
    _reqdLayer = [[CAShapeLayer alloc] init];
    //_reqdLayer2 = [[CAShapeLayer alloc] init];
    if ([_arrowDirn isEqualToString:@"L"])
    {
        _reqdLayer.path = [self getLeftArrowPathWithRect:CGRectMake(0, 0, l_reqdrect.size.width+30, l_reqdrect.size.height)].CGPath;
        [UIView animateWithDuration:0.1 animations:^{
            [_dispLabel setFrame:CGRectMake(30, 1, l_reqdrect.size.width, l_reqdrect.size.height)];
        }];
    }
    else
    {
        _reqdLayer.path = [self getRightArrowPathWithRect:CGRectMake(self.bounds.size.width-l_reqdrect.size.width-30, 1, l_reqdrect.size.width+30, l_reqdrect.size.height)].CGPath;
        [_reqdLayer setFrame:CGRectMake(self.bounds.size.width-l_reqdrect.size.width-30, 1, l_reqdrect.size.width+30, l_reqdrect.size.height)];
        [UIView animateWithDuration:0.1 animations:^{
            [_dispLabel setFrame:CGRectMake(self.bounds.size.width-l_reqdrect.size.width-30.0, 1, l_reqdrect.size.width, l_reqdrect.size.height)];
        }];
    }

    [_reqdLayer setFillColor:[ttrDefaults getColorRandomly:(int) [_dispText length] withAlpha:0.9].CGColor];
    /*[_reqdLayer setFillColor:[UIColor clearColor].CGColor];
    [_reqdLayer setBorderColor:[ttrDefaults getColorRandomly:l_reqdrect.size.width withAlpha:0.9].CGColor];
    [_reqdLayer setBorderWidth:1.0f];*/
    //[self.layer setBorderColor:[UIColor clearColor].CGColor];
    //[_reqdLayer1 addSublayer:_reqdLayer2];
    [self.layer addSublayer:_reqdLayer];
    [self bringSubviewToFront:_dispLabel];
}

- (UIBezierPath*) getLeftArrowPathWithRect:(CGRect) p_reqdRect
{
    UIBezierPath * l_polygonpath = [UIBezierPath bezierPath];
    [l_polygonpath moveToPoint:CGPointMake(1.0f, 15.0f)];
    [l_polygonpath addLineToPoint:CGPointMake(21.0f, p_reqdRect.size.height/2.0-6.0)];
    [l_polygonpath addLineToPoint:CGPointMake(21.0f, 1.0f)];
    [l_polygonpath addLineToPoint:CGPointMake(p_reqdRect.size.width - 1.0f, 1.0f)];
    [l_polygonpath addLineToPoint:CGPointMake(p_reqdRect.size.width - 1.0f, p_reqdRect.size.height- 1.0f)];
    [l_polygonpath addLineToPoint:CGPointMake(21.0f, p_reqdRect.size.height- 1.0f)];
    [l_polygonpath addLineToPoint:CGPointMake(21.0f, p_reqdRect.size.height/2.0+6.0)];
    [l_polygonpath closePath];
    return l_polygonpath;
}

- (UIBezierPath*) getRightArrowPathWithRect:(CGRect) p_reqdRect
{
    UIBezierPath * l_polygonpath = [UIBezierPath bezierPath];
    [l_polygonpath moveToPoint:CGPointMake(p_reqdRect.size.width-1.0,p_reqdRect.size.height - 15.0f)];
    [l_polygonpath addLineToPoint:CGPointMake(p_reqdRect.size.width-21.0f, p_reqdRect.size.height - 21.0f)];
    [l_polygonpath addLineToPoint:CGPointMake(p_reqdRect.size.width-21.0f, 1.0f)];
    [l_polygonpath addLineToPoint:CGPointMake(1.0f, 1.0f)];
    [l_polygonpath addLineToPoint:CGPointMake(1.0f, p_reqdRect.size.height - 1.0f)];
    [l_polygonpath addLineToPoint:CGPointMake(p_reqdRect.size.width-21.0f, p_reqdRect.size.height - 1.0f)];
    [l_polygonpath addLineToPoint:CGPointMake(p_reqdRect.size.width-21.0f, p_reqdRect.size.height - 9.0f)];
    [l_polygonpath closePath];
    return l_polygonpath;
}

@end