//
//  ImagePostCell.m
//  my insta
//
//  Created by Alexis Schreier on 01/05/17.
//  Copyright © 2017 MoonSandApps. All rights reserved.
//

#import "Comment.h"
#import "ImagePost.h"
#import "ImagePostCell.h"
#import "User.h"

@interface ImagePostCell ()

@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *postCaptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateCreatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (weak, nonatomic) IBOutlet UITextView *linkTextView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagsLabel;

@end

@implementation ImagePostCell

- (void) performWith: (ImagePost *)item {
    self.postImageView.image = self.post.image;
    NSString *caption = [NSString stringWithFormat: @"%@", self.post.caption];
    self.postCaptionLabel.text = caption;
    self.commentsCountLabel.text = item.commentsCount;
    self.dateCreatedLabel.text = item.dateCreated;
    self.filterLabel.text = item.filter;
    self.likesCountLabel.text = item.likesCount;
    NSMutableAttributedString * linkString = [[NSMutableAttributedString alloc] initWithString:@"Tap here to see your original post!"];
    [linkString addAttribute: NSLinkAttributeName value: item.link range: NSMakeRange(0, linkString.length)];
    self.linkTextView.attributedText = linkString;
    self.locationLabel.text = item.location;
    self.tagsLabel.text = item.tags;
    
    
//    NSMutableString *commentString = [[NSMutableString alloc] init];
//    for (Comment *comment in self.post.comments) {
//        NSString *oneComment = [NSString stringWithFormat: @"%@ %@\n", comment.author.username, comment.text];
//        [commentString appendString: oneComment];
//    }
//    self.postCommentLabel.text = commentString;
}

@end
