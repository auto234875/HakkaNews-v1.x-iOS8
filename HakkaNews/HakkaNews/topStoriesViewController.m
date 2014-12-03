//
//  topStoriesViewController.m
//  YNews
//
//  Created by John Smith on 12/24/13.
//  Copyright (c) 2013 John Smith. All rights reserved.
//

#import "topStoriesViewController.h"
#import "CommentsViewController.h"
#import "UIColor+Colours.h"
#import "postCell.h"
#import "LoginVC.h"
#import "FBShimmeringLayer.h"
#import "FoldingView.h"
#import <pop/POP.h>
#import "HNManager.h"
@interface topStoriesViewController () <UIGestureRecognizerDelegate,UIScrollViewDelegate,UIActionSheetDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray *readPost;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong)NSIndexPath *selectedIndexPath;
@property(nonatomic)BOOL userIsLoggedIn;
@property (nonatomic, strong)NSIndexPath *upvoteIndexPath;
@property(strong,nonatomic)NSMutableArray *upvote;
@property(strong,nonatomic)FBShimmeringLayer *loadingLayer;
@property(strong,nonatomic)UICollectionView *tableView;
@end
@implementation topStoriesViewController
#define postTitlePadding 15
static NSString *CellIdentifier = @"Cell";
-(UICollectionView*)tableView{
    if (!_tableView) {
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        _tableView=[[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _tableView.delegate=self;
        _tableView.dataSource=self;
       [self.view addSubview:_tableView];
    }
    return _tableView;
}
/*-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HNPost *post=[self.currentPosts objectAtIndex:indexPath.row];
    NSString *postDetailText=[NSString stringWithFormat:@"%i points by %@ %@ - %i comments", post.Points, post.Username, post.TimeCreatedString,post.CommentCount];
    CGSize postDetailSize= [postDetailText sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Regular" size:11]}];
    if ([self.readPost containsObject:post.PostId]) {
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
        CGFloat cellWidth= self.tableView.frame.size.width-30;
        CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGSize textSize = [post.Title boundingRectWithSize:boundingSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName : textFont }
                                                   context:nil].size;
        return textSize.height + postDetailSize.height+postTitlePadding*3;
    }
    else{
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
        CGFloat cellWidth= self.tableView.frame.size.width-30;
        CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGSize textSize = [post.Title boundingRectWithSize:boundingSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName : textFont }
                                                   context:nil].size;
        return textSize.height + postDetailSize.height+postTitlePadding*3;
    }
}*/
-(NSMutableArray*)readPost{
    if (!_readPost) {
        _readPost = [[NSMutableArray alloc] init];
    }
    return _readPost;
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
- (void)retrieveListofReadPost {
    self.readPost= [[[NSUserDefaults standardUserDefaults] objectForKey:@"listOfReadPosts"] mutableCopy];
}
- (void)retrieveListofUpvote {
    self.upvote= [[[NSUserDefaults standardUserDefaults] objectForKey:@"listOfUpvote"] mutableCopy];
}
- (void)initialUserSetup {
    if ([[HNManager sharedManager]userIsLoggedIn]) {
        self.userIsLoggedIn=YES;
    }
    else{
        self.userIsLoggedIn=NO;

    }
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self initialUserSetup];
    [self retrieveListofReadPost];
    [self retrieveListofUpvote];
    self.postType=@"Top";
    [self getStories];
    self.tableView.backgroundColor=[UIColor snowColor];
    self.limitReached=NO;
    self.tableView.tag=1;
    self.loadingLayer=[FBShimmeringLayer layer];
    self.loadingLayer.frame=CGRectMake(0,0, self.view.bounds.size.width, 3);
    CALayer *layer=[CALayer layer];
    layer.frame=self.loadingLayer.bounds;
    layer.backgroundColor=[UIColor redColor].CGColor;
    self.loadingLayer.contentLayer=layer;
    self.loadingLayer.shimmering=YES;
    [self.view.layer addSublayer:self.loadingLayer];
}
/*-(void)getBestStories{
    self.postType=@"Best";
    [self getStories];
}
-(void)getAskStories{
    self.postType=@"Ask";
    [self getStories];
}
-(void)getTopStories{
    self.postType=@"Top";
    [self getStories];
}
-(void)getNewStories{
    self.postType=@"New";
    [self getStories];
}*/
-(void)setupLoggedIn{
    self.userIsLoggedIn=YES;
    [self.tableView reloadData];
}
-(void)setupNotLoggedIn{
    self.userIsLoggedIn=NO;
    [self.tableView reloadData];
}
-(void)turnOffShimmeringLayer{
    self.loadingLayer.shimmering=NO;
    self.loadingLayer.opacity=0.0;
}
-(void)turnOnShimmeringLayer{
    self.loadingLayer.shimmering=YES;
    self.loadingLayer.opacity=0.8;
}
- (void)getStories {
    [self turnOnShimmeringLayer];
    if ([self.postType isEqualToString:@"Top"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeTop completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                [self.tableView reloadData];
                [self turnOffShimmeringLayer];
                }
            else{
                //stop loading animation
            }
        }];
    }
    else if ([self.postType isEqualToString:@"New"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeNew completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                [self.tableView reloadData];
                [self turnOffShimmeringLayer];
            }
            else{
                //stop loading animation
            }
        }];
    }
    else if ([self.postType isEqualToString:@"Best"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeBest completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                [self.tableView reloadData];
                [self turnOffShimmeringLayer];
            }
            else{
                //stop loading animation
            }
        }];
    }
    else if ([self.postType isEqualToString:@"Ask"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeAsk completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                [self.tableView reloadData];
                [self turnOffShimmeringLayer];
            }
            else{
                //stop loading animation
            }
        }];
    }
    else if ([self.postType isEqualToString:@"Jobs"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeJobs completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                [self.tableView reloadData];
                [self turnOffShimmeringLayer];
            }
            else{
                //stop loading animation
            }
        }];
    }
    [self scrollToTopOfTableView];
}
- (void)scrollToTopOfTableView {
    self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.currentPosts.count;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HNPost *post=[self.currentPosts objectAtIndex:indexPath.row];
    [collectionView registerClass:[postCell class] forCellWithReuseIdentifier:CellIdentifier];
    postCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.postTitle.highlightedTextColor = [UIColor turquoiseColor];
    cell.postDetail.highlightedTextColor = [UIColor turquoiseColor];
    cell.contentView.backgroundColor=[UIColor redColor];
    cell.backgroundColor=[UIColor whiteColor];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    if ([self.readPost containsObject:post.PostId]) {
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
        CGFloat cellWidth= self.tableView.frame.size.width-postTitlePadding*2;
        CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGSize textSize = [post.Title boundingRectWithSize:boundingSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName : textFont }
                                                   context:nil].size;
        cell.postTitle.frame=CGRectMake(15, 15, textSize.width, textSize.height);
    }
    else{
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
        CGFloat cellWidth= self.tableView.frame.size.width-postTitlePadding*2;
        CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGSize textSize = [post.Title boundingRectWithSize:boundingSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName : textFont }
                                                   context:nil].size;
        cell.postTitle.frame=CGRectMake(15, 15, textSize.width, textSize.height);
    }
    CGSize postDetailSize= [cell.postDetail.text sizeWithAttributes:@{NSFontAttributeName:cell.postDetail.font}];
    cell.postDetail.frame=CGRectMake(15, cell.postTitle.frame.size.height+postTitlePadding*2, postDetailSize.width, postDetailSize.height);
    return cell;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    HNPost *post=[self.currentPosts objectAtIndex:indexPath.row];
    NSString *postDetailText=[NSString stringWithFormat:@"%i points by %@ %@ - %i comments", post.Points, post.Username, post.TimeCreatedString,post.CommentCount];
    CGSize postDetailSize= [postDetailText sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Regular" size:11]}];
    if ([self.readPost containsObject:post.PostId]) {
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
        CGFloat cellWidth= self.tableView.frame.size.width-30;
        CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGSize textSize = [post.Title boundingRectWithSize:boundingSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName : textFont }
                                                   context:nil].size;
        CGSize cellSize=CGSizeMake(self.view.bounds.size.width, textSize.height+postDetailSize.height+postTitlePadding*3);
        return cellSize;
    }
    else{
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
        CGFloat cellWidth= self.tableView.frame.size.width-30;
        CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGSize textSize = [post.Title boundingRectWithSize:boundingSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName : textFont }
                                                   context:nil].size;
        CGSize cellSize=CGSizeMake(self.view.bounds.size.width, textSize.height + postDetailSize.height+postTitlePadding*3);
        return cellSize;
    }
    
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
    cell.postDetail.text=[NSString stringWithFormat:@"%i points ∙ %i comments", post.Points, post.CommentCount];


}
/*- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    HNPost *post=[self.currentPosts objectAtIndex:indexPath.row];

    [tableView registerClass:[postCell class] forCellReuseIdentifier:CellIdentifier];
    postCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
     cell=[[postCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
     }
    [self setupCellSelectedBackgroundColor:cell];
    cell.postTitle.highlightedTextColor = [UIColor turquoiseColor];
    cell.postDetail.highlightedTextColor = [UIColor turquoiseColor];    cell.contentView.backgroundColor=[UIColor snowColor];
    if ([self.readPost containsObject:post.PostId]) {
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
        CGFloat cellWidth= self.tableView.frame.size.width-postTitlePadding*2;
        CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGSize textSize = [post.Title boundingRectWithSize:boundingSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName : textFont }
                                                   context:nil].size;
        cell.postTitle.frame=CGRectMake(15, 15, textSize.width, textSize.height);
    }
    else{
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
        CGFloat cellWidth= self.tableView.frame.size.width-postTitlePadding*2;
        CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGSize textSize = [post.Title boundingRectWithSize:boundingSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName : textFont }
                                                   context:nil].size;
        cell.postTitle.frame=CGRectMake(15, 15, textSize.width, textSize.height);
    }
    CGSize postDetailSize= [cell.postDetail.text sizeWithAttributes:@{NSFontAttributeName:cell.postDetail.font}];
    cell.postDetail.frame=CGRectMake(15, cell.postTitle.frame.size.height+postTitlePadding*2, postDetailSize.width, postDetailSize.height);
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
   //cell.postDetail.text=[NSString stringWithFormat:@"%i points by %@ %@ - %i comments", post.Points, post.Username, post.TimeCreatedString,post.CommentCount];
    cell.postDetail.text=[NSString stringWithFormat:@"%i points ∙ %i comments", post.Points, post.CommentCount];
    
   
   //setting up the vote view
    if (self.userIsLoggedIn) {
        //[HNManager sharedManager]hasVotedOnObject:post
        if (![self.upvote containsObject:post.PostId]) {
        if (post.Type == PostTypeDefault || post.Type==PostTypeAskHN) {
        [cell setSwipeGestureWithView:upvoteView color:[UIColor ghostWhiteColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            self.upvoteIndexPath=indexPath;
            [self.as showInView:self.tableView];}];}}}
    
[cell setSwipeGestureWithView:commentView color:[UIColor whiteColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
    self.selectedIndexPath = indexPath;
        if (post.Type==PostTypeDefault) {
            //if there is no comment, we don't segue
            if (post.CommentCount==0){
                //show animation
            }
            else {
                //we add the post to the read post list and segue to comment
                [self.readPost addObject:post.PostId];
                [self showComment];

            }
            
        }
        else if (post.Type == PostTypeAskHN){
            //we always show the comment because it's askHN
            //askHN always have at least 1 comment
            [self.readPost addObject:post.PostId];
            [self showComment];

        }
        //Job Post, check to see if it's a self post or webpage by loading the first comment and checking the string
        else if (post.Type == PostTypeJobs){[[HNManager sharedManager] loadCommentsFromPost:post completion:^(NSArray *comments) {
            HNComment *firstComment = [comments firstObject];
            if (![firstComment.Text isEqualToString:@""]) {
                if (self.comments) {
                    self.comments = [comments mutableCopy];}
                else{
                    self.comments = [NSMutableArray arrayWithArray:comments];
                }
                [self.readPost addObject:post.PostId];
                [self showComment];

            }
            else {
                [self.readPost addObject:post.PostId];
                [self showStoryOfPost:post];

            }
            
        }];}
        }];

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
        [self showStoryOfPost:post];

    }
    //if the post is ask, we show the comment because AskHN is always self-post on HN
    else if (post.Type == PostTypeAskHN){
        [self showComment];

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
                [self showComment];
            }
            else {
                [self showStoryOfPost:post];
            }
        
        
        }];}
}
-(void)showComment{
    HNPost *post=[self.currentPosts objectAtIndex:self.selectedIndexPath.row];
    CommentsViewController *cvc=[[CommentsViewController alloc] init];
    //The post that we comment reply to
    cvc.replyPost = post;
    [self presentViewController:cvc animated:YES completion:nil];
}

-(void)showStoryOfPost:(HNPost*)post{
    [self saveTheListOfReadPost];
    [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:NO];
    [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
     self.tableView.scrollEnabled=NO;
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:post.UrlString]];
    CGRect frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    FoldingView *foldView = [[FoldingView alloc] initWithFrame:frame request:request];
    [foldView captureSuperViewScreenShot:self.view afterScreenUpdate:YES];
    [self.view addSubview:foldView];
   POPSpringAnimation *segueAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    segueAnimation.toValue=[NSValue valueWithCGRect:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height)];
    segueAnimation.springBounciness=5.0f;
    segueAnimation.springSpeed=20.0f;
    [foldView pop_addAnimation:segueAnimation forKey:nil];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Displaying the last cell, so we will load more stories
   if(indexPath.row == [self.currentPosts count] - 1){
           if (self.limitReached==NO) {
           if (![self.postType isEqualToString:@"Jobs"]){
               //loading more stories
               //start loading animation
        [[HNManager sharedManager] loadPostsWithUrlAddition:[[HNManager sharedManager] postUrlAddition] completion:^(NSArray *posts, NSString *urlAddition) {
            if (posts) {
                [self.currentPosts addObjectsFromArray:posts];
                [self.tableView reloadData];
                //stop loading animation
                if ([posts count]==0) {
                    self.limitReached=YES;
                    //no mo story
                    //stop loading animation

                }
            }
            
        }];
        }}}

    

}*/
@end
