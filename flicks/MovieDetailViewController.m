//
//  MovieDetailViewController.m
//  flicks
//
//  Created by Ankur Motreja on 9/13/16.
//  Copyright © 2016 Ankur Motreja. All rights reserved.
//

#import "MovieDetailViewController.h"
#import <UIImageView+AFNetworking.h>

@interface MovieDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *movieTitle;
@property (weak, nonatomic) IBOutlet UILabel *releaseDate;
@property (weak, nonatomic) IBOutlet UILabel *vote;
@property (weak, nonatomic) IBOutlet UILabel *movieLength;
@property (weak, nonatomic) IBOutlet UILabel *synopsis;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@property NSInteger *runtime1;

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    
    NSString *urlString = [@"https://api.themoviedb.org/3/movie/" stringByAppendingFormat:@"%@?api_key=%@", self.movie[@"id"], apiKey];
    
    NSLog(@"urlString: %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    int runtime = [responseDictionary[@"runtime"] intValue];
                                                    
                                                    int hours = runtime / 60;
                                                    int minutes = runtime % 60;
                                                    self.movieLength.text = [NSString stringWithFormat:@"%d hr %d mins", hours, minutes];
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                            }];
    [task resume];
    
    
    NSInteger vote = [self.movie[@"vote_average"] floatValue] * 10;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *releaseDate = [dateFormatter dateFromString:self.movie[@"release_date"]];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    
    self.movieTitle.text = self.movie[@"title"];
    self.releaseDate.text = [dateFormatter stringFromDate:releaseDate];
    self.vote.text = [NSString stringWithFormat:@"%d", vote];
    self.movieLength.text = @"Runtime";
    
    self.synopsis.text = self.movie[@"overview"];
    [self.synopsis sizeToFit];
    
    CGRect frame = self.infoView.frame;
    frame.size.height = self.synopsis.frame.size.height + self.synopsis.frame.origin.y + 10;
    self.infoView.frame = frame;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 60 + self.infoView.frame.origin.y + self.infoView.frame.size.height);
    
    [self.backgroundImage setImageWithURL:[NSURL URLWithString:[@"https://image.tmdb.org/t/p/w342/" stringByAppendingString:self.movie[@"poster_path"]]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
