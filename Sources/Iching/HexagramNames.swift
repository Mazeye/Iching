/// 六十四卦卦名映射
public struct HexagramNames {
    
    /// 获取卦名
    /// - Parameter hexagram: 卦象
    /// - Returns: 卦名（根据 IchingLocalization.currentLanguage 返回）
    public static func getName(for hexagram: Hexagram) -> String {
        // 将卦象转换为二进制字符串 (初爻为低位，上爻为高位)
        // 阴(0, value 6/8), 阳(1, value 7/9)
        
        var key = 0
        for (i, line) in hexagram.lines.enumerated() {
            let bit: Int
            switch line {
            case .oldYin, .youngYin: bit = 0
            case .youngYang, .oldYang: bit = 1
            }
            // 初爻是最低位 (2^0)，上爻是最高位 (2^5)
            key |= (bit << i)
        }
        
        let keyName = nameMap[key] ?? "Unkown"
        
        // 多语言映射
        switch IchingLocalization.currentLanguage {
        case .traditionalChinese:
            return keyName
        case .simplifiedChinese:
            // 简繁转换映射
            return simplify(keyName)
        case .japanese:
            // 日语汉字通常与繁体类似，但有异体字
            return japaneseVariant(keyName)
        case .english:
            // 返回拼音或英文意译
            return englishName(for: key)
        }
    }
    
    // MARK: - Helper Maps
    
    private static func simplify(_ tc: String) -> String {
        // 简单的繁简对照表（仅列出常见的卦名差异）
        // 已清理重复键值
        let map: [String: String] = [
            "乾": "乾", "坤": "坤", "屯": "屯", "蒙": "蒙", "需": "需", "訟": "讼", "師": "师", "比": "比",
            "小畜": "小畜", "履": "履", "泰": "泰", "否": "否", "同人": "同人", "大有": "大有", "謙": "谦", "豫": "豫",
            "隨": "随", "蠱": "蛊", "臨": "临", "觀": "观", "噬嗑": "噬嗑", "賁": "贲", "剝": "剥", "復": "复",
            "無妄": "无妄", "大畜": "大畜", "頤": "颐", "大過": "大过", "坎": "坎", "離": "离", "咸": "咸", "恆": "恒",
            "遯": "遁", "大壯": "大壮", "晉": "晋", "明夷": "明夷", "家人": "家人", "睽": "睽", "蹇": "蹇", "解": "解",
            "損": "损", "益": "益", "夬": "夬", "姤": "姤", "萃": "萃", "升": "升", "困": "困", "井": "井",
            "革": "革", "鼎": "鼎", "震": "震", "艮": "艮", "漸": "渐", "歸妹": "归妹", "豐": "丰", "旅": "旅",
            "巽": "巽", "兌": "兑", "渙": "涣", "節": "节", "中孚": "中孚", "小過": "小过", "既濟": "既济", "未濟": "未济",
            // 补充可能遗漏的 - 已移除重复项
            "壯": "壮", "過": "过", "濟": "济", "歸": "归"
        ]
        // 如果是单字或双字，尝试完全匹配
        if let simplified = map[tc] {
            return simplified
        }
        
        // 如果没有直接匹配（极少情况），尝试逐字替换（虽然对于卦名来说上面的表应该覆盖了）
        var result = ""
        for char in tc {
            let str = String(char)
            result += map[str] ?? str
        }
        return result
    }
    
    private static func japaneseVariant(_ tc: String) -> String {
        // 繁体中文到日文汉字的转换
        let map: [String: String] = [
            "訟": "訟", "師": "師", "謙": "謙", "隨": "随", "蠱": "蠱", "臨": "臨", "觀": "観", "賁": "賁",
            "剝": "剥", "無妄": "無妄", "頤": "頤", "大過": "大過", "離": "離", "恆": "恒", "遯": "遯", "大壯": "大壮",
            "晉": "晋", "睽": "睽", "蹇": "蹇", "損": "損", "夬": "夬", "歸妹": "帰妹", "豐": "豊", "兌": "兌",
            "渙": "渙", "節": "節", "既濟": "既済", "未濟": "未済"
        ]
        return map[tc] ?? tc
    }
    
    private static func englishName(for key: Int) -> String {
        let map: [Int: String] = [
             0: "The Receptive (Kun)", 63: "The Creative (Qian)",
             3: "Approach (Lin)", 59: "Treading (Lv)", 11: "The Marrying Maiden (Gui Mei)", 19: "Limitation (Jie)", 27: "The Joyous (Dui)", 35: "Decrease (Sun)", 43: "Breakthrough (Kuai)", 51: "Inner Truth (Zhong Fu)",
             4: "Modesty (Qian)", 60: "Retreat (Dun)", 12: "Preponderance of the Small (Xiao Guo)", 20: "Obstruction (Jian)", 28: "Influence (Xian)", 36: "Keeping Still (Gen)", 44: "The Wanderer (Lv)", 52: "Development (Jian)",
             5: "Darkening of the Light (Ming Yi)", 61: "Fellowship with Men (Tong Ren)", 13: "Abundance (Feng)", 21: "After Completion (Ji Ji)", 29: "Revolution (Ge)", 37: "Grace (Bi)", 45: "The Clinging (Li)", 53: "The Family (Jia Ren)",
             2: "The Army (Shi)", 58: "Conflict (Song)", 10: "Deliverance (Jie)", 18: "The Abysmal (Kan)", 26: "Oppression (Kun)", 34: "Youthful Folly (Meng)", 42: "Before Completion (Wei Ji)", 50: "Dispersion (Huan)",
             6: "Pushing Upward (Sheng)", 62: "Coming to Meet (Gou)", 14: "Duration (Heng)", 22: "The Well (Jing)", 30: "Preponderance of the Great (Da Guo)", 38: "Work on What Has Been Spoiled (Gu)", 46: "The Cauldron (Ding)", 54: "The Gentle (Xun)",
             1: "Return (Fu)", 57: "Innocence (Wu Wang)", 9: "The Arousing (Zhen)", 17: "Difficulty at the Beginning (Tun)", 25: "Following (Sui)", 33: "The Corners of the Mouth (Yi)", 41: "Biting Through (Shi He)", 49: "Increase (Yi)",
             7: "Peace (Tai)", 15: "The Power of the Great (Da Zhuang)", 23: "Waiting (Xu)", 31: "Resoluteness (Guai)", 39: "The Taming of the Power of the Great (Da Chu)", 47: "Possession in Great Measure (Da You)", 55: "The Taming of the Power of the Small (Xiao Chu)", 56: "Standstill (Pi)", 
             8: "Enthusiasm (Yu)", 16: "Holding Together (Bi)", 24: "Gathering Together (Cui)", 32: "Splitting Apart (Bo)", 40: "Progress (Jin)", 48: "Contemplation (Guan)"
        ]
        return map[key] ?? "Unknown"
    }
    
    // 卦名表 (使用繁体中文作为基础 Key)
    private static let nameMap: [Int: String] = [
        0: "坤", 63: "乾",
        7: "泰", 15: "大壯", 23: "需", 31: "夬", 39: "大畜", 47: "大有", 55: "小畜",
        56: "否", 8: "豫", 16: "比", 24: "萃", 32: "剝", 40: "晉", 48: "觀",
        1: "復", 57: "無妄", 9: "震", 17: "屯", 25: "隨", 33: "頤", 41: "噬嗑", 49: "益",
        6: "升", 62: "姤", 14: "恆", 22: "井", 30: "大過", 38: "蠱", 46: "鼎", 54: "巽",
        2: "師", 58: "訟", 10: "解", 18: "坎", 26: "困", 34: "蒙", 42: "未濟", 50: "渙",
        5: "明夷", 61: "同人", 13: "豐", 21: "既濟", 29: "革", 37: "賁", 45: "離", 53: "家人",
        4: "謙", 60: "遯", 12: "小過", 20: "蹇", 28: "咸", 36: "艮", 44: "旅", 52: "漸",
        3: "臨", 59: "履", 11: "歸妹", 19: "節", 27: "兌", 35: "損", 43: "睽", 51: "中孚"
    ]
}
