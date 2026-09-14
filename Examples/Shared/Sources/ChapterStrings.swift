import Foundation

struct ChapterStrings {
    let resolve: (String) -> String

    func callAsFunction(_ key: ChapterKey) -> String {
        resolve(key.rawValue)
    }

    static func bundled(locale: String, in resources: Bundle) -> ChapterStrings {
        let normalized = locale.replacingOccurrences(of: "_", with: "-")
        let components = normalized.split(separator: "-")
        let chain = stride(from: components.count, through: 1, by: -1).map {
            components.prefix($0).joined(separator: "-")
        } + ["en"]
        let bundles = chain.compactMap { resources.path(forResource: $0, ofType: "lproj") }
            .compactMap(Bundle.init(path:))
        return ChapterStrings { key in
            for bundle in bundles {
                let value = bundle.localizedString(forKey: key, value: key, table: "Localizable")
                if value != key { return value }
            }
            return key
        }
    }
}
