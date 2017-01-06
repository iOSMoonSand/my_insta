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
@property (weak, nonatomic) IBOutlet UILabel *postCommentLabel;

@end

@implementation ImagePostCell

- (void) performWith: (ImagePost *)item {
    NSString *caption = [NSString stringWithFormat: @"%@ %@", self.post.user.username, self.post.caption];
    self.postCaptionLabel.text = caption;
    NSMutableString *commentString = [[NSMutableString alloc] init];
    for (Comment *comment in self.post.comments) {
        NSString *oneComment = [NSString stringWithFormat: @"%@ %@\n", comment.author.username, comment.text];
        [commentString appendString: oneComment];
    }
    self.postCommentLabel.text = commentString;
    self.postImageView.image = self.post.image;
}

@end
