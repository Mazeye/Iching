/// 支持的语言
public enum IchingLanguage {
    case traditionalChinese // 繁体中文 (默认)
    case simplifiedChinese  // 简体中文
    case japanese           // 日语
    case english            // 英语
}

/// 本地化管理器
public class IchingLocalization {
    
    // 使用 @MainActor 或简单的非隔离全局状态（如果是命令行工具或不涉及并发）
    // 为了 Swift 6 兼容性，我们将其标记为 nonisolated(unsafe) 或者使其线程安全
    // 简单起见，在单线程 Demo 中直接使用 nonisolated(unsafe) 是可行的，
    // 但更好的做法是封装在类实例中，或者使用 Actor。
    // 这里为了全局访问方便，使用 nonisolated(unsafe) var 
    nonisolated(unsafe) public static var currentLanguage: IchingLanguage = .traditionalChinese
    
    // MARK: - Localized Strings Keys
    
    // YarrowDiviner Logs
    static func log_startDivination() -> String {
        switch currentLanguage {
        case .traditionalChinese: return "=== 大衍之數起卦開始 ==="
        case .simplifiedChinese: return "=== 大衍之数起卦开始 ==="
        case .japanese: return "=== 大衍の数による占筮を開始 ==="
        case .english: return "=== Yarrow Stalk Divination Start ==="
        }
    }
    
    static func log_intro() -> String {
        switch currentLanguage {
        case .traditionalChinese: return "大衍之數五十，其用四十有九。"
        case .simplifiedChinese: return "大衍之数五十，其用四十有九。"
        case .japanese: return "大衍の数は五十、その用は四十九なり。"
        case .english: return "The number of the Great Expansion is fifty, of which forty-nine are used."
        }
    }
    
    static func log_endDivination() -> String {
        switch currentLanguage {
        case .traditionalChinese: return "=== 起卦結束 ==="
        case .simplifiedChinese: return "=== 起卦结束 ==="
        case .japanese: return "=== 占筮終了 ==="
        case .english: return "=== Divination End ==="
        }
    }
    
    static func log_startLine(name: String) -> String {
        switch currentLanguage {
        case .traditionalChinese: return "--- 開始生成\(name)爻 ---"
        case .simplifiedChinese: return "--- 开始生成\(name)爻 ---"
        case .japanese: return "--- \(name)の爻を生成開始 ---"
        case .english: return "--- Generating \(name) Line ---"
        }
    }
    
    static func log_changeHeader(number: String) -> String {
        switch currentLanguage {
        case .traditionalChinese: return "【第\(number)變】"
        case .simplifiedChinese: return "【第\(number)变】"
        case .japanese: return "【第\(number)変】"
        case .english: return "[Change \(number)]"
        }
    }
    
    static func log_split(total: Int, sky: Int, earth: Int) -> String {
        switch currentLanguage {
        case .traditionalChinese: return "信手分\(total)策為二，以象兩儀。左手\(sky)策，右手\(earth)策。"
        case .simplifiedChinese: return "信手分\(total)策为二，以象两仪。左手\(sky)策，右手\(earth)策。"
        case .japanese: return "無心に\(total)策を二つに分かち、両儀を象る。左手に\(sky)策、右手に\(earth)策。"
        case .english: return "Randomly split \(total) stalks into two to symbolize the Two Primal Forces. Left hand: \(sky), Right hand: \(earth)."
        }
    }
    
    static func log_changeResult(removed: Int, remaining: Int) -> String {
        switch currentLanguage {
        case .traditionalChinese: return "掛一與歸奇共去掉 \(removed) 策，剩餘 \(remaining) 策。"
        case .simplifiedChinese: return "挂一与归奇共去掉 \(removed) 策，剩余 \(remaining) 策。"
        case .japanese: return "掛一と帰奇で合計 \(removed) 策を除き、残り \(remaining) 策。"
        case .english: return "Removed \(removed) stalks (Hang One + Remainder), remaining \(remaining) stalks."
        }
    }
    
    static func log_finalResult(sticks: Int, value: Int, yao: String) -> String {
        switch currentLanguage {
        case .traditionalChinese: return "三變完成，最終剩餘 \(sticks) 策。\(sticks)/4 = \(value)。得爻：\(yao)"
        case .simplifiedChinese: return "三变完成，最终剩余 \(sticks) 策。\(sticks)/4 = \(value)。得爻：\(yao)"
        case .japanese: return "三変完了、最終残り \(sticks) 策。\(sticks)/4 = \(value)。得爻：\(yao)"
        case .english: return "Three changes complete. Final remaining: \(sticks). \(sticks)/4 = \(value). Result Line: \(yao)"
        }
    }
    
    // Line Names
    static func lineName(index: Int) -> String {
        switch currentLanguage {
        case .english:
            let names = ["1st (Bottom)", "2nd", "3rd", "4th", "5th", "6th (Top)"]
            return names[index]
        default: // CN / JP share similar characters for line positions
            let names = ["初", "二", "三", "四", "五", "上"]
            return names[index]
        }
    }
    
    // Change Numbers
    static func changeNumber(index: Int) -> String {
        switch currentLanguage {
        case .english:
            return ["1", "2", "3"][index]
        case .japanese:
            return ["一", "二", "三"][index]
        case .simplifiedChinese, .traditionalChinese:
            return ["一", "二", "三"][index]
        }
    }
}
