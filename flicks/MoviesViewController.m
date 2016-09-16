//
//  ViewController.m
//  flicks
//
//  Created by Ankur Motreja on 9/12/16.
//  Copyright © 2016 Ankur Motreja. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "MovieCollectionCell.h"
#import "MovieDetailViewController.h"
#import <UIImageView+AFNetworking.h>
#import <MBProgressHUD.h>

@interface MoviesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray* movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property int *layoutType;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *networkErrorView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *layoutSelector;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.layoutType = 0;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self fetchData];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    self.tableView.tableHeaderView = searchBar;
}

- (IBAction)onValueChange:(UISegmentedControl *)sender {
    self.layoutType = self.layoutSelector.selectedSegmentIndex;
    if (self.layoutType == 0) {
        [self.tableView setHidden:false];
        [self.collectionView setHidden:true];
        [self.tableView insertSubview:self.refreshControl atIndex:0];
    } else {
        [self.tableView setHidden:true];
        [self.collectionView setHidden:false];
        [self.collectionView insertSubview:self.refreshControl atIndex:0];
    }
}

- (void)onRefresh {
    [self fetchData];
}

- (void)fetchData {
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *nowPlayingUrlString =
    [@"https://api.themoviedb.org/3/movie/now_playing?api_key=" stringByAppendingString:apiKey];
    NSString *topRatedUrlString =
    [@"https://api.themoviedb.org/3/movie/top_rated?api_key=" stringByAppendingString:apiKey];
    
    NSURL *url = [NSURL URLWithString:nowPlayingUrlString];
    if ([self.endpoint isEqualToString:@"top_rated"]) {
        url = [NSURL URLWithString:topRatedUrlString];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                [self.refreshControl endRefreshing];
                                                [MBProgressHUD hideHUDForView:self.view animated:true];
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    self.movies = responseDictionary[@"results"];
                                                    //[self.networkErrorView setHidden:true];
                                                    [self.tableView reloadData];
                                                    [self.collectionView reloadData];
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                    [self.networkErrorView setHidden:false];
                                                }
                                                [self setContentInset];
                                            }];
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self setContentInset];
}

- (void)setContentInset {
    CGRect rect = self.navigationController.navigationBar.frame;
    float y = rect.size.height + rect.origin.y;
    self.tableView.contentInset = UIEdgeInsetsMake(y, 0, 0, 0);
    self.collectionView.contentInset = UIEdgeInsetsMake(y, 0, 0, 0);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCollectionCell *collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.movies[indexPath.row];
    
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[@"https://image.tmdb.org/t/p/w154/" stringByAppendingString:movie[@"poster_path"]]]];
    
    [collectionCell.image setImageWithURLRequest:urlRequest placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        if (response != nil) {
            collectionCell.image.alpha = 0.0;
            collectionCell.image.image = image;
            [UIView animateWithDuration:0.3 animations:^{
                collectionCell.image.alpha = 1;
            } completion:^(BOOL finished) {
            }];
        } else {
            collectionCell.image.image = image;
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        NSLog(@"An error occurred: %@", error.description);
    }];
    
    return collectionCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    NSDictionary *movie = self.movies[indexPath.row];
    
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[@"https://image.tmdb.org/t/p/w45/" stringByAppendingString:movie[@"poster_path"]]]];
    
    [cell.image setImageWithURLRequest:urlRequest placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        if (response != nil) {
            cell.image.alpha = 0.0;
            cell.image.image = image;
            [UIView animateWithDuration:0.3 animations:^{
                cell.image.alpha = 1;
            } completion:^(BOOL finished) {
            }];
        } else {
            cell.image.image = image;
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        NSLog(@"An error occurred: %@", error.description);
    }];
    
    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *cell = sender;
    UICollectionViewCell *collectionCell = sender;
    NSIndexPath *indexPath;
    
    if (self.layoutType == 0) {
        indexPath = [self.tableView indexPathForCell:cell];
    } else {
        indexPath = [self.collectionView indexPathForCell:collectionCell];
    }
    
    MovieDetailViewController *vc = segue.destinationViewController;
    
    vc.movie = self.movies[indexPath.row];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidScroll just fired. y:%f ; x:%f", self.tableView.contentOffset.y, self.tableView.contentOffset.x);
}

@end
