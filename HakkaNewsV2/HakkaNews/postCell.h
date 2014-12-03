//
//  postCell.h
//  YNews
//
//  Created by John Smith on 1/23/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "MCSwipeTableViewCell.h"
@class MCFireworksButton;

@interface postCell : UITableViewCell
@property (strong, nonatomic) UILabel *postTitle;
@property (strong, nonatomic) UIButton *postDetail;
@property(strong,nonatomic)MCFireworksButton *likeButton;
@property(strong,nonatomic)UIButton *actionButton;
@end
