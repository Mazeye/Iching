# Iching - 纯 Swift 实现的大衍之数蓍草占卜库

[English](README_EN.md) | [日本語](README_JP.md)

**Iching** 是一个致力于在数字世界中**真实还原**传统《易经》大衍之数（蓍草占卜）仪式感的 Swift Package。

不同于普通的随机数生成器，本项目深入研究了物理占卜的数学模型和操作细节，力求在代码逻辑中重现“分二、挂一、揲四、归奇”的每一个步骤。

## 核心特点：极致的模拟还原

为了追求神秘学意义上的“诚”与仪式感，本库在算法设计上做出了以下努力：

1.  **物理级步骤还原**：
    *   代码内部不仅仅是简单计算概率，而是真实执行了三变过程。
    *   每一次变易，都完整模拟了将蓍草分堆、取出一根、四根四根数掉的过程。
    *   **拒绝取模捷径**：代码中特意使用 `while count > 4 { count -= 4 }` 循环来模拟人工数策的过程，而非直接使用 `% 4` 运算，以保持与物理动作的一致性。

2.  **拟人化的随机分布**：
    *   **二项分布模拟**：在模拟“信手分二”时，我们没有使用计算机常用的均匀分布（Uniform Distribution），而是使用了**二项分布**（Binomial Distribution）。
    *   这意味着，就像真实的人手分一大把棍子一样，两堆的数量大概率会接近一半对一半，呈现正态分布曲线，而非完全随机。这微小地修正了最终 6/7/8/9 的概率分布，使其更接近真实的物理占卜结果。

3.  **详尽的仪式日志**：
    *   支持输出详细的占卜日志，记录了每一步手中剩余的策数变化。
    *   日志支持 **繁体中文**、**简体中文**、**日文** 和 **英文**，文案考究，古风盎然。

## 安装

在 `Package.swift` 中添加依赖：

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Iching.git", from: "1.0.0")
]
```

## 使用方法

### 1. 快速起卦

```swift
import Iching

// 初始化占卜器
let diviner = YarrowDiviner()

// 开始起卦
let result = diviner.divine()

// 获取本卦与之卦（变卦）
print("本卦：\(result.original.name)") // 例如：乾
print(result.original)

print("之卦：\(result.transformed.name)") // 例如：姤
print(result.transformed)
```

### 2. 获取占卜详情与日志

适合用于开发 UI，展示逐行打印的占卜过程效果。

```swift
// 切换语言（支持 .traditionalChinese, .simplifiedChinese, .japanese, .english）
IchingLocalization.currentLanguage = .simplifiedChinese

let diviner = YarrowDiviner()
let _ = diviner.divine()

// 获取完整的占卜过程日志数组
for logLine in diviner.lastDivinationLog {
    print(logLine)
    // 可以在 UI 上模拟打字机效果逐行显示
}

/* 输出示例：
=== 大衍之数起卦开始 ===
大衍之数五十，其用四十有九。

--- 开始生成初爻 ---
【第一变】
信手分49策为二，以象两仪。左手23策，右手26策。
挂一与归奇共去掉 5 策，剩余 44 策。
...
*/
```

### 3. 查表辅助：获取爻题

库提供了方便的属性来获取每一爻的题（如“初九”、“六二”），方便您根据结果去查询《易经》原文。

```swift
let originalHex = result.original
let lineNames = originalHex.lineNames // ["初九", "六二", "六三", "九四", "九五", "上九"]

for (index, line) in originalHex.lines.enumerated() {
    // 只有变爻（老阴/老阳）才需要查爻辞
    if line.isChanging {
        let key = lineNames[index]
        print("变爻位置：\(key)，请查阅《易经》\(originalHex.name)卦\(key)爻辞。")
    }
}
```

## WASM（与原库接口分离）

为了不影响现有下游用户，项目新增了独立模块 `IchingWasm`，原有 `Iching` API 保持不变。

- 原库：`import Iching`
- WASM 包装层：`import IchingWasm`（提供 C ABI 导出函数）

导出函数：

- `iching_divine_once(language: Int32) -> UnsafeMutablePointer<CChar>?`
- `iching_free_string(pointer)`

`language` 枚举值：

- `0`: traditionalChinese
- `1`: simplifiedChinese
- `2`: japanese
- `3`: english

`iching_divine_once` 返回 JSON 字符串（调用后请用 `iching_free_string` 释放内存），结构示例：

```json
{
  "originalName": "乾",
  "transformedName": "姤",
  "originalLines": [7, 9, 7, 7, 8, 7],
  "transformedLines": [7, 8, 7, 7, 8, 7],
  "lineNames": ["初九", "九二", "九三", "九四", "六五", "上九"],
  "logs": ["=== 大衍之數起卦開始 ===", "..."]
}
```

构建 WASM（需要 Swift WASI SDK；`swift` 主版本需与 SDK 对齐，例如 6.2.x + 6.2-RELEASE-wasm32-unknown-wasip1）：

```bash
# 仅编译 WASM 包装目标（验证导出层可编译）
swiftly run swift build +6.2.0 --swift-sdk 6.2-RELEASE-wasm32-unknown-wasip1 -c release --target IchingWasm

# 产出可执行 wasm 文件（示例：IchingDemo.wasm）
swiftly run swift build +6.2.0 --swift-sdk 6.2-RELEASE-wasm32-unknown-wasip1 -c release --product IchingDemo
```

最小网页 Demo 生成脚本：

```bash
./scripts/generate_web_demo.sh
```

脚本会生成 `web-demo/`（包含 `index.html`、`main.js`、`IchingDemo.wasm`）。

由于浏览器安全策略，需用静态服务器打开（不能直接双击 `index.html`）：

```bash
cd web-demo && python3 -m http.server 8000
```

然后访问：`http://127.0.0.1:8000`

## 许可证

MIT License
