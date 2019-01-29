//
//  ASDViewController.m
//  ASDebugger
//
//  Created by square on 03/09/2016.
//  Copyright (c) 2016 利伽. All rights reserved.
//

#import "ASDViewController.h"
#import "ASIHTTPRequest.h"
#import "AFNetworking.h"
#import "SDWebImageManager.h"

static NSString *kAPI = @"https://itunes.apple.com/search?term=square&country=gb&media=software&limit=10";

static NSArray *NetworkSDKType ()
{
    return @[@"NSURLSession", @"AFNetworking", @"SDWebImage"];
}

@interface ASDViewController ()

@end

@implementation ASDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"kCellIdentifier"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return NetworkSDKType().count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kCellIdentifier" forIndexPath:indexPath];
    
    cell.textLabel.text = NetworkSDKType()[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            NSURL *URL = [NSURL URLWithString:kAPI];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                    completionHandler:
                                          ^(NSData *data, NSURLResponse *response, NSError *error) {
                                              if (!error) {
                                                  [self showAlert:@"The request and response has been tracked, let's check it on the website!"];
                                              } else {
                                                  [self showAlert:error.localizedDescription];
                                              }
                                          }];
            
            [task resume];
        }
            break;
        case 1:
        {            
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            [manager GET:kAPI parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

                [self showAlert:@"The request and response has been tracked, let's check it on the website!"];
                NSLog(@"<INFO> response bytes received: %lld", [task countOfBytesReceived]);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

                [self showAlert:error.localizedDescription];
                NSLog(@"<ERROR> error: %@", error);
            }];
            break;
        }
        case 2:
        {
            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:@"https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png"] options:SDWebImageRefreshCached progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                if (!error) {
                    [self showAlert:@"The image data has been tracked, let's check it on the website!"];
                    NSLog(@"%@", image);
                } else {
                    [self showAlert:error.localizedDescription];
                }
            }];
        }
        default:
            break;
    }
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
}

- (void)showAlert:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* vc = [UIAlertController alertControllerWithTitle:@"Message" message:msg preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:vc animated:YES completion:nil];
    });
}

@end
