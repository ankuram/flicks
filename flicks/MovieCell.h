//
//  MovieCell.h
//  flicks
//
//  Created by Ankur Motreja on 9/12/16.
//  Copyright © 2016 Ankur Motreja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end
