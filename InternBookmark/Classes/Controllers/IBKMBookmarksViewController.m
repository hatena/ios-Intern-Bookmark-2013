//
//  IBKMBookmarksViewController.m
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/16.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import "IBKMBookmarksViewController.h"

#import "IBKMBookmarkManager.h"
#import "IBKMBookmark.h"
#import "IBKMEntry.h"
#import "IBKMBookmarkViewController.h"

@interface IBKMBookmarksViewController ()

@end

@implementation IBKMBookmarksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // KVO で `IBKMBookmarkManager` の `bookmarks` を監視する.
    [[IBKMBookmarkManager sharedManager] addObserver:self
                                          forKeyPath:@"bookmarks"
                                             options:NSKeyValueObservingOptionNew
                                             context:nil];

    // 引っ張って更新.
    [self.refreshControl addTarget:self action:@selector(refreshBookmarks:) forControlEvents:UIControlEventValueChanged];

    [self refreshBookmarks:self];
}

- (void)dealloc
{
    [[IBKMBookmarkManager sharedManager] removeObserver:self forKeyPath:@"bookmarks"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* KVO で変更があったとき呼ばれる */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [IBKMBookmarkManager sharedManager] && [keyPath isEqualToString:@"bookmarks"]) {
        // 配列が変更された場所のインデックス.
        NSIndexSet *indexSet = change[NSKeyValueChangeIndexesKey];
        // 変更の種類.
        NSKeyValueChange changeKind = (NSKeyValueChange)[change[NSKeyValueChangeKindKey] integerValue];

        // 配列に詰め替え.
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }];

        // `bookmarks` の変更の種類に合わせて TableView を更新.
        [self.tableView beginUpdates]; // 更新開始.
        if (changeKind == NSKeyValueChangeInsertion) {
            // 新しく追加されたとき.
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else if (changeKind == NSKeyValueChangeRemoval) {
            // 取り除かれたとき.
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else if (changeKind == NSKeyValueChangeReplacement) {
            // 値が更新されたとき.
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tableView endUpdates]; // 更新終了.
    }
}

/* 引っぱって更新 */
- (void)refreshBookmarks:(id)sender
{
    [self.refreshControl beginRefreshing];

    [[IBKMBookmarkManager sharedManager] reloadBookmarksWithBlock:^(NSError *error) {
        if (error) {
            NSLog(@"error = %@", error);
        }
        [self.refreshControl endRefreshing];
    }];
}

/* 画面遷移の準備 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"IBKMNewBookmarkSegue"]) {
        IBKMBookmarkViewController *bookmarkViewController = segue.destinationViewController;
    }
    else if ([segue.identifier isEqualToString:@"IBKMOpenBookmarkSegue"]) {
        IBKMBookmarkViewController *bookmarkViewController = segue.destinationViewController;
        // 選択されたブックマークを引き渡す.
        bookmarkViewController.bookmark = [self selectedBookmark];
    }
}

/* 選択されているブックマークを得る */
- (IBKMBookmark *)selectedBookmark
{
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    NSArray *bookmarks = [IBKMBookmarkManager sharedManager].bookmarks;

    return bookmarks[(NSUInteger) selectedIndexPath.row];
}

#pragma mark - UITableViewDataSource

/* セルの個数を返す */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[IBKMBookmarkManager sharedManager].bookmarks count];
}

/* セルを返す */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IBKMBookmarkCell" forIndexPath:indexPath];

    IBKMBookmark *bookmark = [IBKMBookmarkManager sharedManager].bookmarks[(NSUInteger) indexPath.row];
    if (!bookmark) return cell; // 万一ブックマークがなかったら空のセルを返す.

    cell.textLabel.text = bookmark.entry.title;
    cell.detailTextLabel.text = bookmark.comment;

    return cell;
}

#pragma mark - UIScrollViewDelegate

/* Scroll View のスクロール状態に合わせて */
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint offset = *targetContentOffset;
    offset.y += self.tableView.bounds.size.height - 1.0; // offset は表示領域の上端なので, 下端にするため `tableView` の高さを付け足す. このとき 1.0 引くことであとで必ずセルのある座標になるようにしている.

    // offset 位置のセルの `NSIndexPath`.
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:offset];

    IBKMBookmarkManager *bookmarkManager = [IBKMBookmarkManager sharedManager];
    // 下端に表示されているセルが, 最後のブックマークであるとき.
    if (indexPath.row >= bookmarkManager.bookmarks.count - 1) {
        // もっと読み込む.
        [bookmarkManager loadMoreBookmarksWithBlock:^(NSError *error) {
            if (error) {
                NSLog(@"error = %@", error);
            }
        }];
    }
}

#pragma mark - IBAction

/* ログイン画面から戻ったとき呼ばれる */
- (IBAction)closeLoginSegue:(UIStoryboardSegue *)segue
{
    // ログインから戻ったら再読込する.
    [self refreshBookmarks:self];
}

@end
