//
//  UIAlertView+NSError.m
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/18.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import "UIAlertView+NSError.h"

@implementation UIAlertView (NSError)

- (id)initWithError:(NSError *)error
{
    self = [super init];
    if (self) {
        self.title = [error localizedDescription];
        self.message = [[NSArray arrayWithObjects:[error localizedFailureReason], [error localizedRecoverySuggestion], nil] componentsJoinedByString:@"\n"];
        NSArray *optionTitles = [error localizedRecoveryOptions];
        for (NSString *title in optionTitles) {
            [self addButtonWithTitle:title];
        }
    }
    return self;
}

@end
