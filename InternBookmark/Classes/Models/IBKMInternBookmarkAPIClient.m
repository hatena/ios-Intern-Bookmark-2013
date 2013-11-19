//
//  IBKMInternBookmarkAPIClient.m
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/16.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import "IBKMInternBookmarkAPIClient.h"

#import "AFJSONRequestOperation.h"

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
        _sharedClient = [[IBKMInternBookmarkAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kIBKMInternBookmarkAPIBaseURLString]];
    });

    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }

    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];

    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    [self setDefaultHeader:@"Accept" value:@"application/json"];

    return self;
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
    [self getPath:@"/api/bookmarks"
       parameters:@{
               @"per_page" : @(perPage),
               @"page"     : @(page),
       }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if (block) block(responseObject, nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              // 401 が返ったときログインが必要.
              if (operation.response.statusCode == 401 && [self needsLogin]) {
                  if (block) block(nil, nil);
              }
              else {
                  if (block) block(nil, error);
              }
          }];
}

- (void)postBookmarkWithURL:(NSURL *)URL comment:(NSString *)comment comletion:(void (^)(NSDictionary *results, NSError *error))block
{
    [self postPath:@"/api/bookmark"
        parameters:@{
                @"url"     : [URL absoluteString],
                @"comment" : comment,
        }
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               if (block) block(responseObject, nil);
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               // 401 が返ったときログインが必要.
               if (operation.response.statusCode == 401 && [self needsLogin]) {
                   if (block) block(nil, nil);
               }
               else {
                   if (block) block(nil, error);
               }
           }];
}

@end
