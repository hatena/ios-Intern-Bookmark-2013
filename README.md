# セットアップ

## サーバー

https://github.com/hatena/Intern-Bookmark-2013

`http://localhost:3000/` で動いている前提

## CocoaPods

外部モジュール管理ツールです

### CocoaPods のインストール

```
$ [sudo] gem install cocoapods
$ pod setup
```

### 外部モジュールセットアップ

```
$ pod install
```

# アプリ起動

Xcode で **Run**

# ドキュメント生成

`appledoc` でドキュメント生成します

```
$ brew install appledoc
$ script/build-docs
```
