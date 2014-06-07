//
//  IBKMInternBookmarkAPIClient.m
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/16.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import "IBKMInternBookmarkAPIClient.h"

static NSString * const kIBKMInternBookmarkAPIBaseURLString = @"http://localhost:3000/";

@implementation IBKMInternBookmarkAPIClient

+ (NSURL *)loginURL
{
    // ログインする URL は /login
    return [[NSURL URLWithString:kIBKMInternBookmarkAPIBaseURLString] URLByAppendingPathComponent:@"login"];
}

+ (instancetype)sharedClient
{
    static IBKMInternBookmarkAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPAdditionalHeaders = @{
                @"Accept" : @"application/json",
        };

        _sharedClient = [[IBKMInternBookmarkAPIClient alloc]
                initWithBaseURL:[NSURL URLWithString:kIBKMInternBookmarkAPIBaseURLString]
           sessionConfiguration:configuration];
    });

    return _sharedClient;
}

/* ログインが必要なとき呼び出すメソッド

処理は `delegate` に回す

@return `delegate` が応答するかどうかの真偽値
*/
- (BOOL)needsLogin
{
    BOOL delegated = [self.delegate respondsToSelector:@selector(APIClientNeedsLogin:)];
    if (delegated) {
        [self.delegate APIClientNeedsLogin:self];
    }
    return delegated;
}

- (void)getBookmarksWithPerPage:(NSUInteger)perPage page:(NSUInteger)page completion:(void (^)(NSDictionary *results, NSError *error))block
{
    [self GET:@"/api/bookmarks"
   parameters:@{
           @"per_page" : @(perPage),
           @"page"     : @(page),
   }
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if (block) block(responseObject, nil);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          // 401 が返ったときログインが必要.
          if (((NSHTTPURLResponse *)task.response).statusCode == 401 && [self needsLogin]) {
              if (block) block(nil, nil);
          }
          else {
              if (block) block(nil, error);
          }
      }];
}

- (void)postBookmarkWithURL:(NSURL *)URL comment:(NSString *)comment completion:(void (^)(NSDictionary *results, NSError *error))block
{
    [self POST:@"/api/bookmark"
    parameters:@{
            @"url"     : [URL absoluteString],
            @"comment" : comment,
    }
       success:^(NSURLSessionDataTask *task, id responseObject) {
           if (block) block(responseObject, nil);
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
           // 401 が返ったときログインが必要.
           if (((NSHTTPURLResponse *)task.response).statusCode == 401 && [self needsLogin]) {
               if (block) block(nil, nil);
           }
           else {
               if (block) block(nil, error);
           }
       }];
}

@end
