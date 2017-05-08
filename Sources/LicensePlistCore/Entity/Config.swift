import Foundation
import LoggerAPI

struct Config {
    let githubs: [GitHub]
    let excludes: [String]

    func excluded(name: String) -> Bool {
        if excludes.contains(name) {
            return true
        }
        for text in excludes {
            if let pattern = type(of: self).extractRegex(text), let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let nsName = name as NSString
                let matches = regex.matches(in: name, options: [], range: NSRange(location: 0, length: nsName.length))
                assert(matches.count <= 1)
                if !matches.isEmpty {
                    return true
                }
            }
        }
        return false
    }

    static func extractRegex(_ text: String) -> String? {
        let nsText = text as NSString
        let regex = try! NSRegularExpression(pattern: "^/(.+)/$", options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))
        if matches.count > 1 {
            Log.warning("\(text) contains multiple regex pattern(sandwitched by `/`), but those are ignored except for first one.")
        }
        guard let match = matches.first else {
            return nil
        }
        let numberOfRanges = match.numberOfRanges
        guard numberOfRanges == 2 else {
            assert(false, "maybe invalid regular expression to: \(nsText.substring(with: match.range))")
            return nil
        }
        return nsText.substring(with: match.rangeAt(1))
    }
}

extension Config: Equatable {
    public static func==(lhs: Config, rhs: Config) -> Bool {
        return lhs.githubs == rhs.githubs && lhs.excludes == rhs.excludes
    }
}
