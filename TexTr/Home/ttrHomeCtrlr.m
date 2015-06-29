//
//  ttrHomeCtrlr.m
//  TexTr
//
//  Created by Mohan Kumar on 25/06/15.
//  Copyright (c) 2015 Enter key solutions. All rights reserved.
//

#import "ttrHomeCtrlr.h"
#import "ttrHomeStreamsView.h"
#import "ttrRESTProxy.h"

@interface ttrHomeCtrlr ()<UISearchBarDelegate, ttrHomeStreamsViewDelegate>
{
    NSMutableArray * _groupstreams;
}

@property (nonatomic,strong) UISearchBar * itesearchbar;
@property (nonatomic,strong) ttrHomeStreamsView * homestreamsTV;
@end

@implementation ttrHomeCtrlr


- (void)awakeFromNib
{
    self.transitionType = horizontalWithBounce;
    [self.view setBackgroundColor:[UIColor colorWithRed:0.94 green:0.97 blue:1.0 alpha:1.0]];
    _groupstreams = [[NSMutableArray alloc] init];
    [self initializeAllHomeStreams];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDefaultItems];
    [self setupMainViews];
    // Do any additional setup after loading the view.
}

- (void) setUpDefaultItems
{
    [self.navBar setHidden:NO];
    self.navItem.title = @"Home";
    self.navBar.items = @[self.navItem];
    self.navItem.leftBarButtonItem = self.bar_edit_btn;
    self.navItem.rightBarButtonItems = @[self.bar_list_btn, self.bar_logo_btn] ;
}

- (void) setupMainViews
{
    self.homestreamsTV = [ttrHomeStreamsView new];
    self.homestreamsTV.translatesAutoresizingMaskIntoConstraints=NO;
    self.homestreamsTV.handlerDelegate = self;
    [self.view addSubview:self.homestreamsTV];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.homestreamsTV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.homestreamsTV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:(-64.0-38.0)],[NSLayoutConstraint constraintWithItem:self.homestreamsTV attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],[NSLayoutConstraint constraintWithItem:self.homestreamsTV attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:(32.0-19.0)]]];
    [self.view layoutIfNeeded];
}

- (void)initializeAllHomeStreams
{
    [self.view bringSubviewToFront:self.actView];
    [self.actView startAnimating];
    
    NSString * l_userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
    [[ttrRESTProxy alloc]
     initDatawithAPIType:@"GETSTREAMS"
     andInputParams:@{@"userId":l_userId}
     andReturnMethod:^(NSDictionary * p_groupsinfo)
     {
         NSDictionary * l_recdinfo = [NSJSONSerialization
                                      JSONObjectWithData:[p_groupsinfo valueForKey:@"resultdata"]
                                      options:NSJSONReadingMutableLeaves
                                      error:NULL];
         _groupstreams = [NSMutableArray
                          arrayWithArray:[l_recdinfo valueForKey:@"result"]];
         if (self.homestreamsTV)
         {
             [self.homestreamsTV reloadAllTheStreams];
         }
         [self.actView stopAnimating];

     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)editOptionPressed
{
    [self.view bringSubviewToFront:self.actView];
    [self.actView startAnimating];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"createnewgroup" sender:self];
        [self.actView stopAnimating];
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma  search bar customer search string related delegates

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = nil;
}

// called when Search (in our case “Done”) button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma home controller search view delegates

- (NSInteger) getNumberOfStreams
{
    return [_groupstreams count];
}

- (BOOL) checkIfGroupImageAvailable:(NSInteger) p_posnNo
{
    if ([[_groupstreams objectAtIndex:p_posnNo] valueForKey:@"groupimg"])
        return YES;
    else
        return NO;
}

- (NSDictionary*) getStreamDataAtPosn:(NSInteger) p_posnNo
{
    return [_groupstreams objectAtIndex:p_posnNo];
}

@end
