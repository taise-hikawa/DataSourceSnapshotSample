# DataSourceSnapshotSample

NSDiffableDataSourceSnapshotの差分検知の仕組みを確認するためのリポジトリです。

## 概要

このプロジェクトでは、`NSDiffableDataSource`がどのように差分を検知し、UIの更新を行うのかを検証しています。特に、`Hashable`プロトコルの`hash`関数と等価性演算子（`==`）がそれぞれどのように差分検知に関与するかを調査しています。

## 実装バリエーション

以下の4つのバリエーションを実装し、アイテムの追加・削除時の挙動を比較検証しています：

| Version | Section構造 | hash実装 | ==実装 | アイテム追加時の挙動 | 説明 |
|---------|-------------|----------|--------|------------------|------|
| V1 | シンプル（itemsなし） | id, title | id, title | ✅ 増分更新 | 従来の方法。セクションとアイテムを独立管理 |
| V2 | items プロパティ含む | id, title, **items** | id, title, **items** | ❌ セクション全体更新 | セクションにitemsを含めた場合の検証 |
| V3 | items プロパティ含む | id, title | id, title, **items** | ❌ セクション全体更新 | hashからitemsを除外した場合の検証 |
| V4 | items プロパティ含む | id, title | id, title | ✅ 増分更新 | hash、等価性の両方からitemsを除外 |

## 検証結果

### V1 (通常)
```swift
struct Section: Hashable {
    let id: String
    let title: String
}
```
- セクションとアイテムが独立
- `insertItems`、`deleteItems`等の精密な操作が可能
- **結果**: アイテムの増分更新のみ

### V2 (items付き)
```swift
struct SectionV2: Hashable {
    // items を hash と == の両方に含める
    func hash(into hasher: inout Hasher) {
        hasher.combine(items)  // 含める
    }
    static func == (lhs: SectionV2, rhs: SectionV2) -> Bool {
        return lhs.items == rhs.items  // 含める
    }
}
```
- **結果**: アイテム1つの追加でもセクション全体がリロード

### V3 (Hash除外)
```swift
struct SectionV3: Hashable {
    // items を hash から除外、== には含める
    func hash(into hasher: inout Hasher) {
        // items は含めない
    }
    static func == (lhs: SectionV3, rhs: SectionV3) -> Bool {
        return lhs.items == rhs.items  // 含める
    }
}
```
- **結果**: hashが同じでも、等価性比較でfalse → セクション全体がリロード

### V4 (両方除外)
```swift
struct SectionV4: Hashable {
    // items を hash と == の両方から除外
    func hash(into hasher: inout Hasher) {
        // items は含めない
    }
    static func == (lhs: SectionV4, rhs: SectionV4) -> Bool {
        // items は含めない
    }
}
```
- **結果**: アイテムの増分更新のみ

## 結論

**`NSDiffableDataSource`はhash値だけでなく、等価性演算子（`==`）も差分検知に使用している**

## 使い方

アプリを起動すると、上部のセグメンテッドコントロールでV1〜V4を切り替えることができます。各バージョンで「+」ボタンを押してアイテムを追加し、アニメーションの違いを確認してください。