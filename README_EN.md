# Iching - Authentic Swift Yarrow Stalk Divination Package

[中文](README.md) | [日本語](README_JP.md)

**Iching** is a Swift Package dedicated to **authentically recreating** the traditional *I Ching* (Book of Changes) divination method using Yarrow Stalks (Da Yan Zhi Shu).

Unlike standard random number generators, this project delves deep into the mathematical models and physical nuances of the ancient ritual, striving to reproduce every step of "Divide by Two," "Hang One," "Count by Four," and "Return Remainder" within the code logic.

## Core Features: Authentic Simulation

To achieve "sincerity" and ritual fidelity in the digital realm, this library implements the following design choices:

1.  **Physical-Grade Step Simulation**:
    *   The code doesn't just calculate probabilities; it executes the actual "Three Changes" (San Bian) process.
    *   Every change simulates splitting the stalks, removing one, and counting them off by fours.
    *   **No Shortcuts**: We intentionally avoid the modulo operator (`% 4`) and instead use a `while count > 4 { count -= 4 }` loop to simulate the manual counting process, maintaining consistency with the physical action.

2.  **Human-Like Randomness**:
    *   **Binomial Distribution**: When simulating the "random split" of stalks between two hands, we reject the uniform distribution common in computing. Instead, we simulate a **Binomial Distribution**.
    *   Just like a human grabbing a bundle of sticks, the split is naturally biased towards the center (equal halves) rather than being purely random. This subtly corrects the probability distribution of the final 6/7/8/9 results, aligning them closer to real-world physical divination.

3.  **Detailed Ritual Logs**:
    *   Supports outputting a detailed log of the divination, recording the remaining stalk count at every step.
    *   Logs are available in **Traditional Chinese**, **Simplified Chinese**, **Japanese**, and **English**, featuring carefully crafted, dignified text.

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Iching.git", from: "1.0.0")
]
```

## Usage

### 1. Basic Divination

```swift
import Iching

// Initialize
let diviner = YarrowDiviner()

// Perform divination
let result = diviner.divine()

// Get Original and Transformed (Zhi) Hexagrams
print("Original: \(result.original.name)") // e.g., "The Creative (Qian)"
print(result.original)

print("Transformed: \(result.transformed.name)") // e.g., "Coming to Meet (Gou)"
print(result.transformed)
```

### 2. Accessing Divination Logs

Perfect for UIs that want to display the process line-by-line (like a typewriter effect).

```swift
// Switch Language (Supports .traditionalChinese, .simplifiedChinese, .japanese, .english)
IchingLocalization.currentLanguage = .english

let diviner = YarrowDiviner()
let _ = diviner.divine()

// Access the full log array
for logLine in diviner.lastDivinationLog {
    print(logLine)
}

/* Output Example:
=== Yarrow Stalk Divination Start ===
The number of the Great Expansion is fifty, of which forty-nine are used.

--- Generating 1st (Bottom) Line ---
[Change 1]
Randomly split 49 stalks into two to symbolize the Two Primal Forces. Left hand: 23, Right hand: 26.
Removed 5 stalks (Hang One + Remainder), remaining 44 stalks.
...
*/
```

### 3. Helper: Line Titles

The library provides convenient properties to get line titles (e.g., "Nine at the beginning", "Six in the second place"), making it easy to look up the original *I Ching* texts.

```swift
let originalHex = result.original
// Returns array like ["初九", "六二"...] or localized equivalents
let lineNames = originalHex.lineNames 

for (index, line) in originalHex.lines.enumerated() {
    // Only changing lines (Old Yin/Old Yang) need text lookup
    if line.isChanging {
        let key = lineNames[index]
        print("Changing line at \(key). Please refer to the text for \(key) in \(originalHex.name).")
    }
}
```

## WASM (Separated from the Core Library API)

To avoid impacting existing downstream users, this repository adds a separate module `IchingWasm`. The original `Iching` API remains unchanged.

- Core library: `import Iching`
- WASM wrapper: `import IchingWasm` (C ABI exports)

Exported functions:

- `iching_divine_once(language: Int32) -> UnsafeMutablePointer<CChar>?`
- `iching_free_string(pointer)`

`language` enum values:

- `0`: traditionalChinese
- `1`: simplifiedChinese
- `2`: japanese
- `3`: english

`iching_divine_once` returns a JSON string. Call `iching_free_string` after consuming the pointer.

Build WASM (Swift version must match the WASI SDK major/minor, e.g. 6.2.x + 6.2-RELEASE-wasm32-unknown-wasip1):

```bash
# Build only the WASM wrapper target
swiftly run swift build +6.2.0 --swift-sdk 6.2-RELEASE-wasm32-unknown-wasip1 -c release --target IchingWasm

# Build executable wasm output (example: IchingDemo.wasm)
swiftly run swift build +6.2.0 --swift-sdk 6.2-RELEASE-wasm32-unknown-wasip1 -c release --product IchingDemo
```

Generate a minimal browser demo:

```bash
./scripts/generate_web_demo.sh
```

This creates `web-demo/` with `index.html`, `main.js`, and `IchingDemo.wasm`.

Because of browser security restrictions, serve it over HTTP (do not open `index.html` directly):

```bash
cd web-demo && python3 -m http.server 8000
```

Then open `http://127.0.0.1:8000`.

## License

MIT License
