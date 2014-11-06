//
//  mainPageViewController.m
//  HakkaNews
//
//  Created by John on 11/5/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "mainPageViewController.h"
#import "HNPost.h"
#import "HNManager.h"
#import "POP/POP.h"
#import "FoldingView.h"

@interface mainPageViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic)NSMutableArray *readPost;
@property(strong,nonatomic)NSMutableArray *currentPosts;
@property(strong,nonatomic)NSString *postType;
@property(strong,nonatomic)NSMutableArray *upvote;
@property(strong,nonatomic)UIRefreshControl *refreshControl;
@property(nonatomic)BOOL userIsLoggedIn;
@property(nonatomic)BOOL limitReached;
@property (nonatomic, strong)NSIndexPath *selectedIndexPath;
@property (nonatomic, strong)NSIndexPath *upvoteIndexPath;
@end

@implementation mainPageViewController
- (void)setupTableViewBackgroundColor {
    self.tableView.backgroundColor=[UIColor snowColor];
}
- (void)registerForNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupLoggedIn) name:@"userIsLoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupNotLoggedIn) name:@"userIsNotLoggedIn" object:nil];
}
-(void)setupLoggedIn{
    
}
-(void)setupNotLoggedIn{
    
}
-(void)viewDidLoad{
    [super viewDidLoad];
    self.postType=@"Top";
    [self.tableView reloadData];
}
- (void)initialUserSetup {
    if ([[HNManager sharedManager]userIsLoggedIn]) {
        self.userIsLoggedIn=YES;
    }
    else{
        self.userIsLoggedIn=NO;
        
    }
}
- (void)retrieveListofReadPost {
    self.readPost= [[[NSUserDefaults standardUserDefaults] objectForKey:@"listOfReadPosts"] mutableCopy];
}
- (void)retrieveListofUpvote {
    self.upvote= [[[NSUserDefaults standardUserDefaults] objectForKey:@"listOfUpvote"] mutableCopy];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HNPost *post=[self.currentPosts objectAtIndex:indexPath.row];
    if ([self.readPost containsObject:post.PostId]) {
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
        CGFloat cellWidth= self.tableView.frame.size.width-30;
        CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGSize textSize = [post.Title boundingRectWithSize:boundingSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName : textFont }
                                                   context:nil].size;
        return textSize.height + 52;
    }
    else{
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
        CGFloat cellWidth= self.tableView.frame.size.width-30;
        CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGSize textSize = [post.Title boundingRectWithSize:boundingSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName : textFont }
                                                   context:nil].size;
        return textSize.height + 52;
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.currentPosts count];
}
- (void)scrollToTopOfTableView {
    self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);
}
-(NSMutableArray*)readPost{
    if (!_readPost) {
        _readPost = [[NSMutableArray alloc] init];
    }
    return _readPost;
}
- (void)getStories {
    if ([self.postType isEqualToString:@"Top"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeTop completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                self.navigationItem.title = self.postType;
                [self.tableView reloadData];
                
            }
            else{
                
            }
        }];
    }
    
    else if ([self.postType isEqualToString:@"New"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeNew completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                
                [self.tableView reloadData];
                
                
            }
            else{
                self.navigationItem.title = @"Could not retrieve posts..";
                
            }
        }];
    }
    
    else if ([self.postType isEqualToString:@"Best"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeBest completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                
                [self.tableView reloadData];
                
                
            }
            else{
                
                
            }
        }];
    }
    
    else if ([self.postType isEqualToString:@"Ask"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeAsk completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                
                [self.tableView reloadData];
                
                
            }
            else{
                
                
            }
        }];
    }
    
    else if ([self.postType isEqualToString:@"Jobs"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeJobs completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                [self.tableView reloadData];
            }
            else{
                
            }
        }];
    }
    [self scrollToTopOfTableView];
}
-(NSMutableArray*)upvote{
    if (!_upvote) {
        _upvote = [[NSMutableArray alloc] init];
    }
    return _upvote;
}
- (void)saveTheListOfReadPost {
    [[NSUserDefaults standardUserDefaults] setObject:self.readPost forKey:@"listOfReadPosts"];
}
- (void)saveTheListOfUpvote {
    [[NSUserDefaults standardUserDefaults] setObject:self.upvote forKey:@"listOfUpvote"];
}
- (void)setupRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor blackColor]];
    [self.refreshControl addTarget:self action:@selector(loadStories) forControlEvents:UIControlEventValueChanged];
}
-(void)loadStories{
    
}
-(void)showStory{
    HNPost *post=[self.currentPosts objectAtIndex:self.selectedIndexPath.row];
    [self saveTheListOfReadPost];
    CGRect frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
    FoldingView *foldingView=[[FoldingView alloc] initWithFrame:frame];
    foldingView.replyPost=post;
    [foldingView captureSuperViewScreenShot:self.view afterScreenUpdate:NO];
    [self.view addSubview:foldingView];
    POPSpringAnimation *segueAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    segueAnimation.toValue=[NSValue valueWithCGRect:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [foldingView pop_addAnimation:segueAnimation forKey:@"segueAnimation"];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Displaying the last cell, so we will load more stories
    if(indexPath.row == [self.currentPosts count] - 1){
        if (self.limitReached==NO) {
            if (![self.postType isEqualToString:@"Jobs"]){
                ////show loading status while loading more stories
                [[HNManager sharedManager] loadPostsWithUrlAddition:[[HNManager sharedManager] postUrlAddition] completion:^(NSArray *posts, NSString *urlAddition) {
                    if (posts) {
                        [self.currentPosts addObjectsFromArray:posts];
                        [self.tableView reloadData];
                        //show finished status
                        if ([posts count]==0) {
                            self.limitReached=YES;
                            
                            
                        }
                    }
                    
                }];
            }}}
    
    
    
}

@end
