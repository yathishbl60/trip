import Foundation

extension Place {
    public var webURL: URL? {
        guard let website, let scheme = website.scheme?.lowercased(),
              ["http", "https"].contains(scheme), website.host != nil else { return nil }
        return website
    }

    public var phoneURL: URL? {
        guard let phoneNumber else { return nil }
        let allowed = CharacterSet(charactersIn: "+0123456789()-.").union(.whitespaces)
        guard phoneNumber.unicodeScalars.allSatisfy(allowed.contains) else { return nil }
        let digits = phoneNumber.filter { $0.isASCII && $0.isNumber }
        guard !digits.isEmpty else { return nil }
        let prefix = phoneNumber.trimmingCharacters(in: .whitespaces).hasPrefix("+") ? "+" : ""
        return URL(string: "tel:\(prefix)\(digits)")
    }
}
