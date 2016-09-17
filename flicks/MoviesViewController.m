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

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MoviesViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSArray* movies;
@property (nonatomic, strong) NSMutableArray* searchMovies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property int layoutType; // 0 = table view, 1 = collection view
@property int mode; // 0 = normal list, 1 = search
@property int searchBarStatus; // 0 = hidden, 1 = fading, 2 = appearing, 3 = visible, 4 = active

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *networkErrorView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *layoutSelector;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.layoutType = 0;
    self.searchBarStatus = 0;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.searchBar.delegate = self;
    
    [self fetchData];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    //UISearchBar *searchBar = [[UISearchBar alloc] init];
    //self.tableView.tableHeaderView = searchBar;
    
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    searchField.textColor = [UIColor blackColor];
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
    if (self.mode == 0) {
        return self.movies.count;
    } else {
        return self.searchMovies.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCollectionCell *collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    
    NSDictionary *movie;
    if (self.mode == 0) {
        movie = self.movies[indexPath.row];
    } else {
        movie = self.searchMovies[indexPath.row];
    }
    
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
    if (self.mode == 0) {
        return self.movies.count;
    } else {
        return self.searchMovies.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    NSDictionary *movie;
    
    if (self.mode == 0) {
        movie = self.movies[indexPath.row];
    } else {
        movie = self.searchMovies[indexPath.row];
    }
    
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
    
    if (self.mode == 0) {
        vc.movie = self.movies[indexPath.row];
    } else {
        vc.movie = self.searchMovies[indexPath.row];
    }
    
    
    [self visibleSearch];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //[self visibleSearch];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self visibleSearch];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"search begin editing");
    [self activeSearch];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"search text: %@", searchText);
    self.searchMovies = [[NSMutableArray alloc] init];
    self.mode = 1;
    
    if ([searchText isEqual:@""]) {
        self.mode = 0;
    }
        
    for (NSDictionary *movie in self.movies) {
        NSRange textRange = [movie[@"title"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if(textRange.location != NSNotFound) {
            [self.searchMovies addObject:movie];
        }
    }
    
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"search cancel clicked");
    self.mode = 0;
    [self visibleSearch];
    
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    searchField.text = @"";
    
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self visibleSearch];
}

- (IBAction)onTap:(UITapGestureRecognizer *)sender {
    NSLog(@"tap");
    [self visibleSearch];
}

- (void)activeSearch {
    NSLog(@"activeSearch");
    self.searchBarStatus = 4;
    [self.searchBar setBackgroundColor:UIColorFromRGB(0xF1B344)];
}

- (void)hiddenSearch {
    if (self.searchBarStatus != 3 && self.searchBarStatus != 2) {
        return;
    }

    if (self.mode == 1) {
        return;
    }
    
    NSLog(@"hiddenSearch");
    
    self.searchBarStatus = 1;
    [self.view endEditing:YES];
    [self.searchBar resignFirstResponder];
    
    [self.searchBar setAlpha:1.0];
    [UIView animateWithDuration:1.0 animations:^{
        self.searchBar.alpha = 0;
    } completion:^(BOOL finished) {
        NSLog(@"hiddenSearch completed");
        self.searchBarStatus = 0;
        [self.searchBar setHidden:true];
    }];
}

- (void)visibleSearch {
    if (self.searchBarStatus != 0 && self.searchBarStatus != 1 && self.searchBarStatus != 4) {
        return;
    }
    NSLog(@"visibleSearch");
    
    //[self.searchBar setBackgroundColor:nil];
    [self.view endEditing:YES];
    [self.searchBar resignFirstResponder];
    
    if (self.searchBarStatus == 0 || self.searchBarStatus == 1) {
        [self.searchBar setAlpha:0.0];
        [self.searchBar setHidden:false];
    }
    
    if (self.searchBarStatus == 4) {
        [self.searchBar setBackgroundColor:UIColorFromRGB(0xF1B344)];
    }
    
    self.searchBarStatus = 2;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        if (self.mode == 1) {
            self.searchBar.alpha = 0.75;
        } else {
            self.searchBar.alpha = 1;
        }
        self.searchBar.backgroundColor = nil;
    } completion:^(BOOL finished) {
        NSLog(@"visibleSearch completed");
        self.searchBarStatus = 3;
        [self performSelector:@selector(hiddenSearch) withObject:nil afterDelay:3.0 ];
    }];
}

@end
