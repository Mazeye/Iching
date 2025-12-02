import XCTest
@testable import Iching

final class IchingTests: XCTestCase {
    
    func testYaoValues() {
        XCTAssertEqual(Yao.oldYin.value, 6)
        XCTAssertEqual(Yao.youngYang.value, 7)
        XCTAssertEqual(Yao.youngYin.value, 8)
        XCTAssertEqual(Yao.oldYang.value, 9)
    }
    
    func testYaoChange() {
        // Old changes to Young of opposite polarity
        XCTAssertEqual(Yao.oldYin.changed(), .youngYang)
        XCTAssertEqual(Yao.oldYang.changed(), .youngYin)
        
        // Young remains Young
        XCTAssertEqual(Yao.youngYang.changed(), .youngYang)
        XCTAssertEqual(Yao.youngYin.changed(), .youngYin)
    }
    
    func testYaoProperties() {
        XCTAssertTrue(Yao.oldYin.isChanging)
        XCTAssertTrue(Yao.oldYang.isChanging)
        XCTAssertFalse(Yao.youngYang.isChanging)
        XCTAssertFalse(Yao.youngYin.isChanging)
    }
    
    func testHexagramTransformation() {
        // Create a specific hexagram: [6, 7, 8, 9, 6, 7]
        // 6 -> 7
        // 7 -> 7
        // 8 -> 8
        // 9 -> 8
        // 6 -> 7
        // 7 -> 7
        let lines: [Yao] = [.oldYin, .youngYang, .youngYin, .oldYang, .oldYin, .youngYang]
        let hexagram = Hexagram(lines: lines)
        let transformed = hexagram.transformed()
        
        let expectedValues = [7, 7, 8, 8, 7, 7]
        XCTAssertEqual(transformed.originalLines, expectedValues)
    }
    
    func testDivinationBasic() {
        let diviner = YarrowDiviner()
        let result = diviner.divine()
        
        // Verify we have 6 lines
        XCTAssertEqual(result.original.lines.count, 6)
        XCTAssertEqual(result.transformed.lines.count, 6)
        
        // Verify lines are valid 6,7,8,9
        for line in result.original.lines {
            XCTAssertTrue([6, 7, 8, 9].contains(line.value))
        }
    }
    
    func testDivinationDistribution() {
        // Run a statistically significant number of simulations to check distribution
        // Based on physical simulation with uniform random split (1..<Total-1):
        // P(6) ≈ 0.052
        // P(7) ≈ 0.289
        // P(8) ≈ 0.448
        // P(9) ≈ 0.211
        
        let diviner = YarrowDiviner()
        var counts: [Int: Int] = [6:0, 7:0, 8:0, 9:0]
        let iterations = 50000 // Increased iterations for better stability
        
        for _ in 0..<iterations {
            let result = diviner.divine()
            for line in result.original.lines {
                counts[line.value]! += 1
            }
        }
        
        let totalLines = Double(iterations * 6)
        let prob6 = Double(counts[6]!) / totalLines
        let prob7 = Double(counts[7]!) / totalLines
        let prob8 = Double(counts[8]!) / totalLines
        let prob9 = Double(counts[9]!) / totalLines
        
        // Expected values from physical simulation
        let expected6 = 0.0517
        let expected7 = 0.2886
        let expected8 = 0.4483
        let expected9 = 0.2111
        
        print("Distribution: 6: \(prob6), 7: \(prob7), 8: \(prob8), 9: \(prob9)")
        
        XCTAssertEqual(prob6, expected6, accuracy: 0.01)
        XCTAssertEqual(prob7, expected7, accuracy: 0.01)
        XCTAssertEqual(prob8, expected8, accuracy: 0.01)
        XCTAssertEqual(prob9, expected9, accuracy: 0.01)
    }
}
