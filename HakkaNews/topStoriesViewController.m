//
//  topStoriesViewController.m
//  YNews
//
//  Created by John Smith on 12/24/13.
//  Copyright (c) 2013 John Smith. All rights reserved.
//

#import "topStoriesViewController.h"
#import "WebViewController.h"
#import "CommentsViewController.h"
#import "UIColor+Colours.h"
#import "postCell.h"
#import <SafariServices/SafariServices.h>
#import "PocketAPI.h"
#import "UINavigationController+M13ProgressViewBar.h"
#import "LoginVC.h"
#import "SettingsVC.h"
#import "FoldingView.h"
#import "POP/POP.h"

@interface topStoriesViewController () <UIGestureRecognizerDelegate,UIScrollViewDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableArray *comments;

@end

@implementation topStoriesViewController










-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupDelegation];
    [self registerForNotification];
    [self initialUserSetup];
    [self retrieveListofReadPost];
    [self retrieveListofUpvote];
    [self loadDefaultStories];
    [self getStories];
    [self setupTableViewBackgroundColor];
    [self setupRefreshControl];
    self.limitReached=NO;
    [self setupNavigationBarAttributes];
    
}
-(void)setupLoggedIn{
    self.navigationItem.rightBarButtonItem.enabled=YES;
    self.userIsLoggedIn=YES;
}
-(void)setupNotLoggedIn{
    self.navigationItem.rightBarButtonItem.enabled=NO;
    self.userIsLoggedIn=NO;
}

- (void)setupCellContentViewBackgroundColor:(postCell *)cell
{
    cell.contentView.backgroundColor=[UIColor snowColor];
}

- (void)setupCellHighlightedColor:(postCell *)cell
{
    cell.postTitle.highlightedTextColor = [UIColor turquoiseColor];
    cell.postDetail.highlightedTextColor = [UIColor turquoiseColor];
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==self.as.destructiveButtonIndex) {
        HNPost *post=[self.currentPosts objectAtIndex:self.upvoteIndexPath.row];
        self.navigationItem.title = @"Upvoting...";
        [self.navigationController setIndeterminate:YES];
        [[HNManager sharedManager] voteOnPostOrComment:post direction:VoteDirectionUp completion:^(BOOL success) {
            if (success){
                [self.upvote addObject:post.PostId];
                [self saveTheListOfUpvote];
                self.navigationItem.title =@"Upvote Sucessful";
                [self.tableView reloadRowsAtIndexPaths:@[self.upvoteIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                [self.navigationController finishProgress];
                [self setDefaultNavigationTitleWithDelay];
            }
            else {
                self.navigationItem.title = @"Could Not Upvote";
                [self.navigationController finishProgress];
                [self setDefaultNavigationTitleWithDelay];
            }
        }];
    
    }
}

-(UIActionSheet*)as{
    if (!_as) {
        _as=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Upvote" otherButtonTitles:nil];
    }
    return _as;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
     postCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    [self setupCellSelectedBackgroundColor:cell];
    [self setupCellHighlightedColor:cell];
    [self setupCellContentViewBackgroundColor:cell];
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
    UIView *commentView = [self viewWithImageName:@"Comment"];
    UIView *upvoteView=[self viewWithImageName:@"like"];
    [cell setDelegate:self];
    [self setupCellTrigger:cell];
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
                self.navigationItem.title = @"No comment...";
                [self setDefaultNavigationTitleWithDelay];
            }
            else {
                //we add the post to the read post list and segue to comment
                [self.readPost addObject:post.PostId];
                [self performSegueWithIdentifier:@"showComment" sender:self];

            }
            
        }
        else if (post.Type == PostTypeAskHN){
            //we always show the comment because it's askHN
            //askHN always have at least 1 comment
            [self.readPost addObject:post.PostId];
            [self performSegueWithIdentifier:@"showComment" sender:self];

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
                [self performSegueWithIdentifier:@"showComment" sender:self];

            }
            else {
                [self.readPost addObject:post.PostId];
                [self showStory];

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
                //[self performSegueWithIdentifier:@"showPostContent" sender:self];
                [self showStory];
            }
        
        
        }];}
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
HNPost *post=[self.currentPosts objectAtIndex:self.selectedIndexPath.row];
    [self saveTheListOfReadPost];

    if ([segue.identifier isEqualToString:@"showPostContent"]) {
        //[[UIApplication sharedApplication] beginIgnoringInteractionEvents];

            //WebViewController *webView=segue.destinationViewController;
            //the post that we reply to from the webview
            //webView.replyPost = post;
    }
    else if ([segue.identifier isEqualToString:@"showComment"]) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

        CommentsViewController *cvc=segue.destinationViewController;
        //The post that we comment reply to
        cvc.replyPost = post;
    }


@end
