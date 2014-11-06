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

@end

@implementation topStoriesViewController




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





@end
