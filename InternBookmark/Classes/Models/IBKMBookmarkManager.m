//
//  IBKMBookmarkManager.m
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/16.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import "IBKMBookmarkManager.h"

#import "IBKMInternBookmarkAPIClient.h"
#import "IBKMBookmark.h"
#import "IBKMEntry.h"

@interface IBKMBookmarkManager ()

@property (nonatomic) NSMutableArray *bookmarks;
@property (nonatomic) NSUInteger nextPage;

@end

static NSUInteger const kIBKMBookmarkManagerBookmarksPerPage = 20;

@implementation IBKMBookmarkManager

+ (IBKMBookmarkManager *)sharedManager
{
    static IBKMBookmarkManager *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.bookmarks = [NSMutableArray array];
        self.nextPage = 1;
    }

    return self;
}

- (void)saveBookmark:(IBKMBookmark *)bookmark withBlock:(void (^)(NSError *error))block
{
    [[IBKMInternBookmarkAPIClient sharedClient]
            postBookmarkWithURL:bookmark.entry.URL
                        comment:bookmark.comment
                      completion:^(NSDictionary *results, NSError *error) {
                          if (results && [results isKindOfClass:[NSDictionary class]]) {
                              NSDictionary *bookmarkDictionary = results[@"bookmark"];

                              if ([bookmarkDictionary isKindOfClass:[NSDictionary class]]) {
                                  NSArray *bookmarks = @[ [[IBKMBookmark alloc] initWithJSONDictionary:bookmarkDictionary] ];
                                  // 編集されていたときここで update される.
                                  NSArray *newBookmarks = [self updateBookmarks:bookmarks];

                                  // 新しいページをブックマークしたとき `newBookmarks` は空じゃないはず.
                                  // KVO 発火のため `mutableArrayValueForKey:` を介して insert する.
                                  [[self mutableArrayValueForKey:@"bookmarks"]
                                          insertObjects:newBookmarks atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newBookmarks.count)]];
                              }
                          }

                          if (block) block(error);
                      }
    ];
}

- (void)reloadBookmarksWithBlock:(void (^)(NSError *error))block
{
    [self loadBookmarksWithPage:1 // 最初のページ固定
                     completion:^(NSArray *bookmarks, NSUInteger nextPage, NSError *error) {
                         if (bookmarks) {
                             // `bookmarks` 全てを置き換える.
                             // KVO 発火のため `mutableArrayValueForKey:` を介して replace する.
                             [[self mutableArrayValueForKey:@"bookmarks"]
                                     replaceObjectsInRange:NSMakeRange(0, self.bookmarks.count)
                                      withObjectsFromArray:bookmarks];
                         }
                         if (nextPage)
                             self.nextPage = nextPage;

                         if (block) block(error);
                     }];
}

- (void)loadMoreBookmarksWithBlock:(void (^)(NSError *error))block
{
    [self loadBookmarksWithPage:self.nextPage // 次のページを読み込む.
                     completion:^(NSArray *bookmarks, NSUInteger nextPage, NSError *error) {
                         if (bookmarks) {
                             NSArray *newBookmarks = [self updateBookmarks:bookmarks];
                             // 次のページは下に追加.
                             // KVO 発火のため `mutableArrayValueForKey:` を介して add する.
                             [[self mutableArrayValueForKey:@"bookmarks"]
                                     addObjectsFromArray:newBookmarks];
                         }
                         if (nextPage)
                             self.nextPage = nextPage;

                         if (block) block(error);
                     }];
}

/* ブックマークを読み込む

`reloadBookmarksWithBlock:` や `loadMoreBookmarksWithBlock:` から呼び出される.

@param page 読み込むページ.
@param block 完了時に呼び出される blocks.
@see reloadBookmarksWithBlock:
@see loadMoreBookmarksWithBlock:
*/

- (void)loadBookmarksWithPage:(NSUInteger)page completion:(void (^)(NSArray *bookmarks, NSUInteger nextPage, NSError *error))block
{
    [[IBKMInternBookmarkAPIClient sharedClient]
            getBookmarksWithPerPage:kIBKMBookmarkManagerBookmarksPerPage
                               page:page
                         completion:^(NSDictionary *results, NSError *error) {
                             NSArray *bookmarks;
                             NSUInteger nextPage = 0;

                             if (results && [results isKindOfClass:[NSDictionary class]]) {

                                 // ブックマーク.
                                 NSArray *bookmarksJSON = results[@"bookmarks"];
                                 if ([bookmarksJSON isKindOfClass:[NSArray class]]) {
                                     bookmarks = [self parseBookmarks:bookmarksJSON];
                                 }

                                 // 次のページ.
                                 NSNumber *nextPageNumber = results[@"next_page"];
                                 if ([nextPageNumber isKindOfClass:[NSNumber class]]) {
                                     nextPage = [nextPageNumber unsignedIntegerValue];
                                 }
                             }

                             if (block) block(bookmarks, nextPage, error);
                         }
    ];
}

/* ブックマークの情報が保存された `JSON` 辞書を `IBKMBookmark` にパースする

@param bookmarks ブックマークを表す `NSDictionary` の配列.
@return `IBKMBookmark` の配列.
*/
- (NSArray *)parseBookmarks:(NSArray *)bookmarks
{
    NSMutableArray *mutableBookmarks = [NSMutableArray array];

    [bookmarks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {

            IBKMBookmark *bookmark = [[IBKMBookmark alloc] initWithJSONDictionary:obj];
            [mutableBookmarks addObject:bookmark];

        }
    }];

    return [mutableBookmarks copy];
}

/* `bookmarks` に存在するブックマークを新しいものに置き換える

`bookmarks` に存在するブックマークを新しいもので置き換え, いままで存在しなかったものを返すメソッド. 返された新しいブックマークを `bookmark` に追加するのは呼び出し元の責任.

@param bookmarks 置き換えたい `IBKMBookmark` の配列.
@return `bookmarks` に存在しなかった、新しいブックマークの配列が返る.
*/
- (NSArray *)updateBookmarks:(NSArray *)bookmarks
{
    NSMutableArray *newBookmarks = [NSMutableArray array];
    NSMutableArray *updatedBookmarks = [NSMutableArray array];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];

    [bookmarks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger index = [self.bookmarks indexOfObject:obj];
        if (index == NSNotFound) {
            // 見つからないときは新しいブックマーク.
            [newBookmarks addObject:obj];
        }
        else {
            // 見つかったときは置き換える.
            [indexSet addIndex:index];
            [updatedBookmarks addObject:obj];
        }
    }];

    // KVO 発火のため `mutableArrayValueForKey:` を介して replace する.
    [[self mutableArrayValueForKey:@"bookmarks"]
            replaceObjectsAtIndexes:indexSet withObjects:updatedBookmarks];

    // return remain bookmarks
    return newBookmarks;
}

@end
