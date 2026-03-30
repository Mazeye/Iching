#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TOOLCHAIN="${TOOLCHAIN:-6.2.0}"
SWIFT_SDK="${SWIFT_SDK:-6.2-RELEASE-wasm32-unknown-wasip1}"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/web-demo}"
WASM_PATH="$ROOT_DIR/.build/wasm32-unknown-wasip1/release/IchingDemo.wasm"

echo "[1/3] Building IchingDemo.wasm with swiftly +${TOOLCHAIN} ..."
swiftly run swift build "+${TOOLCHAIN}" --swift-sdk "$SWIFT_SDK" -c release --product IchingDemo

echo "[2/3] Preparing web demo files in $OUT_DIR ..."
mkdir -p "$OUT_DIR"
cp "$WASM_PATH" "$OUT_DIR/IchingDemo.wasm"

cat > "$OUT_DIR/index.html" <<'HTML'
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Iching WASM Demo</title>
  <style>
    body { font-family: ui-sans-serif, system-ui, sans-serif; max-width: 760px; margin: 32px auto; padding: 0 16px; }
    h1 { margin: 0 0 12px; }
    .hint { color: #555; margin-bottom: 16px; }
    button { padding: 8px 14px; cursor: pointer; }
    pre { background: #111; color: #e8e8e8; padding: 12px; border-radius: 8px; min-height: 200px; white-space: pre-wrap; word-break: break-word; }
  </style>
</head>
<body>
  <h1>Iching WASI Web Demo</h1>
  <p class="hint">点击按钮运行 <code>IchingDemo.wasm</code>，输出将显示在下方。</p>
  <button id="runBtn">Run Demo</button>
  <pre id="output"></pre>

  <script type="module" src="./main.js"></script>
</body>
</html>
HTML

cat > "$OUT_DIR/main.js" <<'JS'
import { WASI, File, OpenFile, ConsoleStdout, PreopenDirectory } from "https://cdn.jsdelivr.net/npm/@bjorn3/browser_wasi_shim@0.4.1/+esm";

const output = document.getElementById("output");
const runBtn = document.getElementById("runBtn");

function appendLine(text) {
  output.textContent += `${text}\n`;
}

runBtn.addEventListener("click", async () => {
  runBtn.disabled = true;
  output.textContent = "";

  try {
    const fds = [
      new OpenFile(new File([])),
      ConsoleStdout.lineBuffered((msg) => appendLine(msg)),
      ConsoleStdout.lineBuffered((msg) => appendLine(`[stderr] ${msg}`)),
      new PreopenDirectory(".", []),
    ];

    const wasi = new WASI(["IchingDemo.wasm"], [], fds);
    const wasm = await WebAssembly.compileStreaming(fetch("./IchingDemo.wasm"));
    const instance = await WebAssembly.instantiate(wasm, {
      wasi_snapshot_preview1: wasi.wasiImport,
    });

    wasi.start(instance);
  } catch (error) {
    appendLine(`Failed: ${String(error)}`);
  } finally {
    runBtn.disabled = false;
  }
});
JS

echo "[3/3] Done"
echo "Open with a static server (example):"
echo "  cd \"$OUT_DIR\" && python3 -m http.server 8000"
echo "Then visit: http://127.0.0.1:8000"
