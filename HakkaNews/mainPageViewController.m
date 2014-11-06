//
//  mainPageViewController.m
//  HakkaNews
//
//  Created by John on 11/5/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "mainPageViewController.h"
#import "CommentsViewController.h"
#import "HNPost.h"
#import "HNManager.h"
#import "POP/POP.h"
#import "FoldingView.h"
#import "UIColor+Colours.h"
#import "postCell.h"

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
@property(nonatomic,strong)NSMutableArray *comments;
@end

@implementation mainPageViewController
- (void)registerForNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupLoggedIn) name:@"userIsLoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupNotLoggedIn) name:@"userIsNotLoggedIn" object:nil];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self initialUserSetup];
    self.tableView.backgroundColor=[UIColor snowColor];
    self.postType=@"Top";
    [self getStories];
    self.limitReached=NO;
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
-(void)setupLoggedIn{
    //setup control for user
    self.userIsLoggedIn=YES;
}
-(void)setupNotLoggedIn{
    //remove control no user
    self.userIsLoggedIn=NO;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    HNPost *post=[self.currentPosts objectAtIndex:self.selectedIndexPath.row];
    [self saveTheListOfReadPost];
    if ([segue.identifier isEqualToString:@"showComment"]) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        CommentsViewController *cvc=segue.destinationViewController;
        //The post that we comment reply to
        cvc.replyPost = post;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //get the indexpath of the selected cell so we can perform segue
    self.selectedIndexPath = indexPath;
    //retrieve the corresponding post
    HNPost *post=[self.currentPosts objectAtIndex:indexPath.row];
    //add it to the the list of read posts
    [self.readPost addObject:post.PostId];
    //if the post is default, we go to the webpage
    if (post.Type == PostTypeDefault){
        //[self performSegueWithIdentifier:@"showPostContent" sender:self];
        [self showStory];
    }
    //if the post is ask, we show the comment because AskHN is always self-post on HN
    else if (post.Type == PostTypeAskHN){
        [self performSegueWithIdentifier:@"showComment" sender:self];
        
    }
    //if it is a job post, we have to load the comment and check to see if it is self post or from a webpage
    else if (post.Type== PostTypeJobs){
        [[HNManager sharedManager] loadCommentsFromPost:post completion:^(NSArray *comments) {
            //getting the first comment and checking if the string is empty
            //the string is NEVER nil
            HNComment *firstComment = [comments firstObject];
            if (![firstComment.Text isEqualToString:@""]) {
                if (self.comments) {
                    self.comments = [comments mutableCopy];}
                else{
                    self.comments = [NSMutableArray arrayWithArray:comments];}
                [self performSegueWithIdentifier:@"showComment" sender:self];}
            else {
                [self showStory];
            }
            
            
        }];}
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    postCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    cell.backgroundColor=[UIColor snowColor];
    cell.postTitle.highlightedTextColor = [UIColor turquoiseColor];
    cell.postDetail.highlightedTextColor = [UIColor turquoiseColor];
    return cell;
}
- (void)configureCell:(postCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    HNPost *post=[self.currentPosts objectAtIndex:indexPath.row];
    //check if the post exist in readPost array and set the postTitle font accordingly
    if ([self.readPost containsObject:post.PostId]) {
        cell.postTitle.font= [UIFont fontWithName:@"AvenirNext-Regular" size:14];
        cell.postTitle.textColor=[UIColor lightGrayColor];
    }
    else{
        cell.postTitle.font= [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
        cell.postTitle.textColor=[UIColor blackColor];
    }
    cell.postTitle.text=post.Title;
    cell.postDetail.text=[NSString stringWithFormat:@"%i points by %@ %@ - %i comments", post.Points, post.Username, post.TimeCreatedString,post.CommentCount];

@end
