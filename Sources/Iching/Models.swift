/// 爻 (Yao)
/// Representing the lines of a Hexagram (Gua).
public enum Yao: Int, CustomStringConvertible, CaseIterable {
    /// 老阴 (Old Yin) - 6
    /// Changing Yin line. Becomes Yang in the transformed hexagram.
    case oldYin = 6
    
    /// 少阳 (Young Yang) - 7
    /// Static Yang line. Remains Yang in the transformed hexagram.
    case youngYang = 7
    
    /// 少阴 (Young Yin) - 8
    /// Static Yin line. Remains Yin in the transformed hexagram.
    case youngYin = 8
    
    /// 老阳 (Old Yang) - 9
    /// Changing Yang line. Becomes Yin in the transformed hexagram.
    case oldYang = 9
    
    /// The numeric value associated with the Yao (6, 7, 8, 9).
    public var value: Int {
        return self.rawValue
    }
    
    /// Indicates if this line is changing (Old Yin or Old Yang).
    public var isChanging: Bool {
        return self == .oldYin || self == .oldYang
    }
    
    /// Returns the resulting Yao after change.
    /// - Old Yin (6) -> Young Yang (7)
    /// - Old Yang (9) -> Young Yin (8)
    /// - Young Yang (7) -> Young Yang (7)
    /// - Young Yin (8) -> Young Yin (8)
    public func changed() -> Yao {
        switch self {
        case .oldYin: return .youngYang
        case .oldYang: return .youngYin
        case .youngYang: return .youngYang
        case .youngYin: return .youngYin
        }
    }
    
    /// 判断该爻是阴还是阳 (用于确定爻题的九/六)
    /// 6, 8 为阴 (Six); 7, 9 为阳 (Nine)
    public var isYang: Bool {
        return self == .youngYang || self == .oldYang
    }
    
    /// A textual representation of the Yao.
    public var description: String {
        switch self {
        case .oldYin: return "- - x"
        case .youngYang: return "---"
        case .youngYin: return "- -"
        case .oldYang: return "--- o"
        }
    }
}

/// 卦 (Hexagram)
/// Composed of 6 lines (Yao), from bottom to top.
public struct Hexagram: CustomStringConvertible {
    /// The lines of the hexagram, from bottom (index 0) to top (index 5).
    public let lines: [Yao]
    
    /// The numeric values of the lines.
    public var originalLines: [Int] {
        return lines.map { $0.value }
    }
    
    /// 获取卦名 (e.g., "乾", "屯")
    public var name: String {
        return HexagramNames.getName(for: self)
    }
    
    /// 获取每一爻的爻题数组 (从初爻到上爻)
    /// 例如：["初九", "九二", "六三", "六四", "九五", "上六"]
    public var lineNames: [String] {
        var names: [String] = []
        for (index, line) in lines.enumerated() {
            let isYang = line.isYang
            
            // 爻题规则：
            // 阳爻称“九”，阴爻称“六”
            // 初爻：初九 / 初六
            // 二爻：九二 / 六二
            // 三爻：九三 / 六三
            // 四爻：九四 / 六四
            // 五爻：九五 / 六五
            // 上爻：上九 / 上六
            
            // 多语言支持逻辑 (可以后续扩展到 IchingLocalization，目前实现基础中文逻辑)
            // 如果是英文，通常叫 "Nine at the beginning", "Six in the second place" 等，这里暂按中文习惯生成
            
            let yinYangChar = isYang ? "九" : "六"
            
            if index == 0 {
                // 初爻：位置在前，数字在后
                names.append("初\(yinYangChar)")
            } else if index == 5 {
                // 上爻：位置在前，数字在后
                names.append("上\(yinYangChar)")
            } else {
                // 中间四爻：数字在前，位置在后
                let posChar: String
                switch index {
                case 1: posChar = "二"
                case 2: posChar = "三"
                case 3: posChar = "四"
                case 4: posChar = "五"
                default: posChar = "?"
                }
                names.append("\(yinYangChar)\(posChar)")
            }
        }
        return names
    }
    
    /// Initialize a Hexagram with an array of Yao.
    /// - Parameter lines: Must contain exactly 6 Yao.
    public init(lines: [Yao]) {
        guard lines.count == 6 else {
            fatalError("A Hexagram must consist of exactly 6 lines.")
        }
        self.lines = lines
    }
    
    /// Returns the transformed hexagram (Zhi Gua).
    /// Changing lines are converted to their opposites. Static lines remain the same.
    public func transformed() -> Hexagram {
        let newLines = lines.map { $0.changed() }
        return Hexagram(lines: newLines)
    }
    
    public var description: String {
        var result = ""
        // 使用 lines.reversed() 直接获得从上爻到初爻的序列
        for line in lines.reversed() {
            result += "\(line.description)\n"
        }
        return result
    }
}
