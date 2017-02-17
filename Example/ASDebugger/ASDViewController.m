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
    return @[@"NSURLConnection", @"NSURLSession", @"ASIHTTPRequest", @"AFNetworking", @"SDWebImage"];
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
            
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                       
                                   }];
        }
            break;
        case 1:
        {
            NSURL *URL = [NSURL URLWithString:kAPI];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                    completionHandler:
                                          ^(NSData *data, NSURLResponse *response, NSError *error) {
                                              // ...
                                          }];
            
            [task resume];
        }
            break;
        case 2:
        {
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:kAPI]];
            [request setCompletionBlock:^{
                NSLog(@"it completed");
            }];            
            request.delegate = self;
            
            [request startAsynchronous];
        }
            break;
        case 3:
        {            
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            [manager GET:kAPI parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                NSLog(@"<INFO> responseObject: %@", responseObject);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                NSLog(@"<ERROR> error: %@", error);
                
            }];
            break;
        }
        case 4:
        {
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:@"https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png"] options:SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                NSLog(@"%@", image);
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

@end
