import Iching

public enum IchingWasmLanguage: Int32 {
    case traditionalChinese = 0
    case simplifiedChinese = 1
    case japanese = 2
    case english = 3

    var runtimeLanguage: IchingLanguage {
        switch self {
        case .traditionalChinese: return .traditionalChinese
        case .simplifiedChinese: return .simplifiedChinese
        case .japanese: return .japanese
        case .english: return .english
        }
    }
}

@_cdecl("iching_divine_once")
public func iching_divine_once(_ languageRaw: Int32) -> UnsafeMutablePointer<CChar>? {
    let language = IchingWasmLanguage(rawValue: languageRaw) ?? .traditionalChinese
    IchingLocalization.currentLanguage = language.runtimeLanguage

    let diviner = YarrowDiviner()
    let result = diviner.divine()
    let payload = makePayload(
        originalName: result.original.name,
        transformedName: result.transformed.name,
        originalLines: result.original.originalLines,
        transformedLines: result.transformed.originalLines,
        lineNames: result.original.lineNames,
        logs: diviner.lastDivinationLog
    )

    let utf8 = Array(payload.utf8CString)
    let pointer = UnsafeMutablePointer<CChar>.allocate(capacity: utf8.count)
    pointer.initialize(from: utf8, count: utf8.count)
    return pointer
}

@_cdecl("iching_free_string")
public func iching_free_string(_ pointer: UnsafeMutablePointer<CChar>?) {
    guard let pointer else { return }
    pointer.deallocate()
}

private func makePayload(
    originalName: String,
    transformedName: String,
    originalLines: [Int],
    transformedLines: [Int],
    lineNames: [String],
    logs: [String]
) -> String {
    let originalLinesJson = originalLines.map(String.init).joined(separator: ",")
    let transformedLinesJson = transformedLines.map(String.init).joined(separator: ",")
    let lineNamesJson = lineNames.map { "\"\(escapeJSONString($0))\"" }.joined(separator: ",")
    let logsJson = logs.map { "\"\(escapeJSONString($0))\"" }.joined(separator: ",")

    return "{" +
        "\"originalName\":\"\(escapeJSONString(originalName))\"," +
        "\"transformedName\":\"\(escapeJSONString(transformedName))\"," +
        "\"originalLines\":[\(originalLinesJson)]," +
        "\"transformedLines\":[\(transformedLinesJson)]," +
        "\"lineNames\":[\(lineNamesJson)]," +
        "\"logs\":[\(logsJson)]" +
    "}"
}

private func escapeJSONString(_ value: String) -> String {
    var out = ""
    out.reserveCapacity(value.count)

    for scalar in value.unicodeScalars {
        switch scalar.value {
        case 0x22: out.append("\\\"")
        case 0x5C: out.append("\\\\")
        case 0x08: out.append("\\b")
        case 0x0C: out.append("\\f")
        case 0x0A: out.append("\\n")
        case 0x0D: out.append("\\r")
        case 0x09: out.append("\\t")
        case 0x00...0x1F:
            let hex = String(scalar.value, radix: 16, uppercase: true)
            out.append("\\u")
            out.append(String(repeating: "0", count: max(0, 4 - hex.count)))
            out.append(hex)
        default:
            out.append(String(scalar))
        }
    }

    return out
}
