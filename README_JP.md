# Iching - 純粋なSwiftによる大衍の数（易経）シミュレーションライブラリ

[中文](README.md) | [English](README_EN.md)

**Iching** は、デジタル世界において伝統的な『易経』の「大衍の数」（蓍亀占い）の儀式性を**忠実に再現**することを目的とした Swift パッケージです。

一般的な乱数生成器とは異なり、本プロジェクトは物理的な占筮の数学モデルと操作の細部を深く研究し、「分二（二つに分ける）」「掛一（一本掛ける）」「揲四（四本ずつ数える）」「帰奇（余りを戻す）」の各ステップをコードロジック内で再現することに努めています。

## 主な特徴：究極のシミュレーション

神秘学的な意味での「誠」と儀式感を追求するため、本ライブラリはアルゴリズム設計において以下の工夫を凝らしています：

1.  **物理レベルのステップ再現**：
    *   単に確率を計算するだけでなく、内部で実際に「三変」のプロセスを実行します。
    *   各変において、策（竹の棒）を分け、一本を取り出し、四本ずつ数えて取り除く過程を完全にシミュレートしています。
    *   **近道の拒否**：物理的な動作との整合性を保つため、`% 4` 演算子による剰余計算を安易に使用せず、意図的に `while count > 4 { count -= 4 }` ループを使用して、手作業で策を数える過程を模倣しています。

2.  **人間味のあるランダム性**：
    *   **二項分布シミュレーション**：「信手分二（無心に二つに分ける）」をシミュレートする際、コンピュータで一般的な一様分布（Uniform Distribution）ではなく、**二項分布**（Binomial Distribution）を採用しました。
    *   人間が実際に束になった棒を掴んで分けるときのように、左右の束の数は完全なランダムではなく、半分ずつに近い正規分布曲線を描く傾向があります。これにより、最終的な 6/7/8/9 の出現確率分布が、実際の物理的な占筮結果により近づくように微調整されています。

3.  **詳細な儀式ログ**：
    *   占筮プロセスの詳細なログ出力をサポートし、各ステップで手に残っている策の数の変化を記録します。
    *   ログは **繁体字中国語**、**簡体字中国語**、**日本語**、**英語** に対応しており、格調高い文言で提供されます。

## インストール

`Package.swift` に依存関係を追加してください：

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Iching.git", from: "1.0.0")
]
```

## 使い方

### 1. 基本的な占筮

```swift
import Iching

// 占筮器を初期化
let diviner = YarrowDiviner()

// 占筮を実行
let result = diviner.divine()

// 本卦と之卦（変卦）を取得
print("本卦：\(result.original.name)") // 例：乾
print(result.original)

print("之卦：\(result.transformed.name)") // 例：姤
print(result.transformed)
```

### 2. 詳細ログの取得

UI上で占筮の過程を一行ずつ表示するような演出に最適です。

```swift
// 言語を切り替え（.traditionalChinese, .simplifiedChinese, .japanese, .english をサポート）
IchingLocalization.currentLanguage = .japanese

let diviner = YarrowDiviner()
let _ = diviner.divine()

// 占筮プロセスの完全なログ配列を取得
for logLine in diviner.lastDivinationLog {
    print(logLine)
}

/* 出力例：
=== 大衍の数による占筮を開始 ===
大衍の数は五十、その用は四十九なり。

--- 初の爻を生成開始 ---
【第一変】
無心に49策を二つに分かち、両儀を象る。左手に23策、右手に26策。
掛一と帰奇で合計 5 策を除き、残り 44 策。
...
*/
```

### 3. 辞書検索補助：爻題の取得

結果に基づいて『易経』の原文を参照しやすいように、各爻の題（「初九」「六二」など）を取得する便利なプロパティを提供しています。

```swift
let originalHex = result.original
let lineNames = originalHex.lineNames // ["初九", "六二", "六三", "九四", "九五", "上九"]

for (index, line) in originalHex.lines.enumerated() {
    // 変爻（老陰/老陽）のみ、爻辞を調べる必要があります
    if line.isChanging {
        let key = lineNames[index]
        print("変爻の位置：\(key)。『易経』の\(originalHex.name)卦、\(key)の辞を参照してください。")
    }
}
```

## ライセンス

MIT License

