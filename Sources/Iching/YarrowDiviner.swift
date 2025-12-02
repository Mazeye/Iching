import Foundation

/// 大衍之数起卦法模拟器
public class YarrowDiviner {
    
    /// 简单的 Logger 协议
    public typealias Logger = (String) -> Void
    
    /// 可选的日志输出闭包
    public var logger: Logger?
    
    /// 存储最后一次占卜的详细日志
    public private(set) var lastDivinationLog: [String] = []
    
    public init(logger: Logger? = nil) {
        self.logger = logger
    }
    
    /// 内部使用的日志记录方法，同时输出到 logger 和保存到数组
    private func log(_ message: String) {
        lastDivinationLog.append(message)
        logger?(message)
    }
    
    /// 模拟“分二、挂一、揲四、归奇”的一次变过程
    /// - Parameter totalSticks: 当前剩余的策数
    /// - Returns: (本变去掉的策数, 剩余策数)
    private func simulateChange(totalSticks: Int) -> (removed: Int, remaining: Int) {
        // 模拟人手分策：二项分布模拟
        // 每一根策子随机去左边或右边
        var skyCount = 0
        for _ in 0..<totalSticks {
            if Bool.random() { // 50% 概率
                skyCount += 1
            }
        }
        
        // 修正边界：人手分策不可能一只手是空的（至少挂一需要）
        // 如果极端情况导致某堆为0，强制修正
        if skyCount == 0 { skyCount = 1 }
        if skyCount == totalSticks { skyCount = totalSticks - 1 }
        
        let earthCount = totalSticks - skyCount
        
        log(IchingLocalization.log_split(total: totalSticks, sky: skyCount, earth: earthCount))
        
        let hangOne = 1
        let rightAfterHang = earthCount - hangOne
        
        // 揲四 Left (模拟一只手一只手数，每次数4根)
        var currentLeft = skyCount
        while currentLeft > 4 {
            currentLeft -= 4
        }
        let leftRemainder = currentLeft // 最后剩下的 1, 2, 3, 4
        
        // 揲四 Right
        var currentRight = rightAfterHang
        while currentRight > 4 {
            currentRight -= 4
        }
        let rightRemainder = currentRight // 最后剩下的 1, 2, 3, 4
        
        // 归奇 (Left Remainder + Right Remainder + HangOne)
        let totalRemoved = hangOne + leftRemainder + rightRemainder
        let remaining = totalSticks - totalRemoved
        
        return (totalRemoved, remaining)
    }
    
    /// 生成一爻
    /// 经过三变，计算出 6, 7, 8, 9
    private func generateLine(index: Int) -> Yao {
        var currentSticks = 49
        
        log(IchingLocalization.log_startLine(name: IchingLocalization.lineName(index: index)))
        
        // 第一变
        log(IchingLocalization.log_changeHeader(number: IchingLocalization.changeNumber(index: 0)))
        let change1 = simulateChange(totalSticks: currentSticks)
        currentSticks = change1.remaining
        log(IchingLocalization.log_changeResult(removed: change1.removed, remaining: currentSticks))
        
        // 第二变
        log(IchingLocalization.log_changeHeader(number: IchingLocalization.changeNumber(index: 1)))
        let change2 = simulateChange(totalSticks: currentSticks)
        currentSticks = change2.remaining
        log(IchingLocalization.log_changeResult(removed: change2.removed, remaining: currentSticks))
        
        // 第三变
        log(IchingLocalization.log_changeHeader(number: IchingLocalization.changeNumber(index: 2)))
        let change3 = simulateChange(totalSticks: currentSticks)
        currentSticks = change3.remaining
        log(IchingLocalization.log_changeResult(removed: change3.removed, remaining: currentSticks))
        
        // 此时 currentSticks 应该是 24, 28, 32, 36 之一
        // 除以 4 得到 6, 7, 8, 9
        let resultValue = currentSticks / 4
        
        guard let yao = Yao(rawValue: resultValue) else {
            fatalError("Algorithm error: Final sticks count \(currentSticks) / 4 = \(resultValue) is not a valid Yao value.")
        }
        
        log(IchingLocalization.log_finalResult(sticks: currentSticks, value: resultValue, yao: yao.description))
        log("") // 空行分隔
        
        return yao
    }
    
    /// 起卦
    /// - Returns: (本卦, 之卦)
    public func divine() -> (original: Hexagram, transformed: Hexagram) {
        // 清空上一次的日志
        lastDivinationLog.removeAll()
        
        var lines: [Yao] = []
        
        log(IchingLocalization.log_startDivination())
        log(IchingLocalization.log_intro())
        log("")
        
        // 生成六爻，初爻在下，上爻在上
        for i in 0..<6 {
            lines.append(generateLine(index: i))
        }
        
        let originalHexagram = Hexagram(lines: lines)
        let transformedHexagram = originalHexagram.transformed()
        
        log(IchingLocalization.log_endDivination())
        
        return (originalHexagram, transformedHexagram)
    }
}
