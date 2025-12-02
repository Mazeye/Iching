import Iching

func runDemo(language: IchingLanguage, langName: String) {
    // 设置全局语言
    IchingLocalization.currentLanguage = language
    
    print("\n\n###################################################")
    print("### 演示语言 / Demo Language: \(langName)")
    print("###################################################\n")
    
    let diviner = YarrowDiviner()
    let result = diviner.divine()
    
    // 打印详细日志
    for log in diviner.lastDivinationLog {
        print(log)
    }
    print("")
    
    let originalName = result.original.name
    let transformedName = result.transformed.name
    
    // 获取本卦的所有爻题 (例如 ["初九", "九二", "六三"...])
    let lineNames = result.original.lineNames
    
    // 打印卦名和卦象
    switch language {
    case .english:
        print("Original Hexagram Name: \(originalName)")
        print("Line Names (Bottom to Top): \(lineNames)")
        print(result.original)
        
        print("Transformed Hexagram Name: \(transformedName)")
        print(result.transformed)
    case .japanese:
        print("本卦卦名：\(originalName)")
        print("爻題（初〜上）：\(lineNames)")
        print(result.original)
        
        print("之卦卦名：\(transformedName)")
        print(result.transformed)
    default:
        print("本卦卦名：\(originalName)")
        print("爻題（初～上）：\(lineNames)")
        print(result.original)
        
        print("之卦卦名：\(transformedName)")
        print(result.transformed)
    }
    
    // 演示：如何通过这些变量获取数据
    if language == .traditionalChinese || language == .simplifiedChinese {
        print("\n[模擬查表演示]")
        print("正在查詢 \(originalName)卦 的辭...")
        for (index, line) in result.original.lines.enumerated() {
            if line.isChanging {
                let yaoTi = lineNames[index]
                print("检测到变爻：\(yaoTi) -> 查询《易经》\(originalName)卦\(yaoTi)爻辞")
            }
        }
        if !result.original.lines.contains(where: { $0.isChanging }) {
            print("无变爻 -> 查询《易经》\(originalName)卦卦辞")
        }
    }
}

// 1. 默认繁体中文演示
runDemo(language: .traditionalChinese, langName: "繁體中文 (Traditional Chinese)")

// 2. 简体中文演示
// runDemo(language: .simplifiedChinese, langName: "简体中文 (Simplified Chinese)")

// 3. 日语演示
// runDemo(language: .japanese, langName: "日本語 (Japanese)")

// 4. 英语演示
// runDemo(language: .english, langName: "English")
