import Foundation

enum ProductPageImageExtractor {
    static func bestProductImageURL(for productURL: URL) async -> URL? {
        guard productURL.scheme?.hasPrefix("http") == true else { return nil }

        do {
            var request = URLRequest(url: productURL)
            request.timeoutInterval = 12
            request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")

            let (data, _) = try await URLSession.shared.data(for: request)
            guard let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
                return nil
            }

            return bestImageURL(in: html, baseURL: productURL)
        } catch {
            return nil
        }
    }

    static func bestImageURL(in html: String, baseURL: URL) -> URL? {
        let candidates = imageCandidates(in: html, baseURL: baseURL)
        return candidates
            .map { ($0, score($0)) }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 {
                    return lhs.0.sourceOrder < rhs.0.sourceOrder
                }
                return lhs.1 > rhs.1
            }
            .first?
            .0
            .url
    }

    private static func imageCandidates(in html: String, baseURL: URL) -> [ImageCandidate] {
        var candidates: [ImageCandidate] = []
        var sourceOrder = 0

        for content in metaContents(named: "og:image", in: html) {
            appendCandidate(content, context: "og:image", baseURL: baseURL, order: &sourceOrder, to: &candidates)
        }
        for content in metaContents(named: "og:image:secure_url", in: html) {
            appendCandidate(content, context: "og:image:secure_url", baseURL: baseURL, order: &sourceOrder, to: &candidates)
        }
        for content in metaContents(named: "twitter:image", in: html) {
            appendCandidate(content, context: "twitter:image", baseURL: baseURL, order: &sourceOrder, to: &candidates)
        }

        let imgPattern = #"<img[^>]+>"#
        for tag in matches(pattern: imgPattern, in: html) {
            let context = tag
            for attribute in ["src", "data-src", "data-original", "data-zoom", "data-image"] {
                if let value = attributeValue(attribute, in: tag) {
                    appendCandidate(value, context: context, baseURL: baseURL, order: &sourceOrder, to: &candidates)
                }
            }

            if let srcset = attributeValue("srcset", in: tag) {
                for value in srcsetImageURLs(srcset) {
                    appendCandidate(value, context: context, baseURL: baseURL, order: &sourceOrder, to: &candidates)
                }
            }
        }

        for image in jsonLDImages(in: html) {
            appendCandidate(image, context: "json-ld image", baseURL: baseURL, order: &sourceOrder, to: &candidates)
        }

        var seen = Set<URL>()
        return candidates.filter { candidate in
            guard !seen.contains(candidate.url) else { return false }
            seen.insert(candidate.url)
            return true
        }
    }

    private static func appendCandidate(
        _ rawValue: String,
        context: String,
        baseURL: URL,
        order: inout Int,
        to candidates: inout [ImageCandidate]
    ) {
        guard let url = normalizedImageURL(rawValue, baseURL: baseURL) else { return }
        candidates.append(ImageCandidate(url: url, context: context, sourceOrder: order))
        order += 1
    }

    private static func normalizedImageURL(_ rawValue: String, baseURL: URL) -> URL? {
        var value = rawValue
            .htmlDecoded
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !value.isEmpty else { return nil }
        guard !value.contains("("), !value.contains(")") else { return nil }

        if value.hasPrefix("//") {
            value = "https:\(value)"
        }

        let resolvedURL = URL(string: value, relativeTo: baseURL)?.absoluteURL
        guard var components = resolvedURL.flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false) }),
              let scheme = components.scheme,
              scheme.hasPrefix("http") else {
            return nil
        }

        if components.scheme == "http" {
            components.scheme = "https"
        }

        guard let url = components.url,
              let scheme = url.scheme,
              scheme.hasPrefix("http") else {
            return nil
        }

        let lower = url.absoluteString.lowercased()
        let looksLikeImage = lower.contains(".jpg")
            || lower.contains(".jpeg")
            || lower.contains(".png")
            || lower.contains(".webp")
            || lower.contains("/cdn/shop/")
        guard looksLikeImage else {
            return nil
        }

        return url
    }

    private static func score(_ candidate: ImageCandidate) -> Int {
        let text = "\(candidate.url.absoluteString) \(candidate.context)"
            .lowercased()
            .replacingOccurrences(of: "%20", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")

        var score = 0

        if text.contains("og:image") { score += 36 }
        if text.contains("twitter:image") { score += 18 }
        if text.contains("json-ld") { score += 30 }
        if text.contains("/products/") || text.contains("/product/") { score += 30 }
        if text.contains("/cdn/shop/files/") || text.contains("/cdn/shop/products/") { score += 24 }
        if text.contains("product") { score += 22 }
        if text.contains("main") || text.contains("primary") || text.contains("hero") || text.contains("featured") { score += 22 }
        if text.contains("front") || text.contains("front facing") || text.contains("straight") { score += 34 }
        if text.contains("packshot") || text.contains("pdp") || text.contains("plp") { score += 18 }
        if text.contains("white") || text.contains("studio") || text.contains("transparent") { score += 18 }
        if text.contains("800x800") || text.contains("1000x1000") || text.contains("1200x1200") || text.contains("2048x2048") { score += 14 }
        if text.contains("zoom") { score += 10 }

        if text.contains("model") || text.contains("worn") || text.contains("lifestyle") || text.contains("scene") { score -= 42 }
        if text.contains("video") || text.contains("cinemagraph") || text.contains("gif") { score -= 18 }
        if text.contains("logo") || text.contains("icon") || text.contains("sprite") || text.contains("placeholder") { score -= 60 }
        if text.contains("thumb") || text.contains("thumbnail") || text.contains("small") { score -= 18 }
        if text.contains("banner") || text.contains("collection") || text.contains("social") { score -= 24 }

        return score
    }

    private static func metaContents(named name: String, in html: String) -> [String] {
        let escaped = NSRegularExpression.escapedPattern(for: name)
        let patterns = [
            #"<meta[^>]+(?:property|name)=["']\#(escaped)["'][^>]+content=["']([^"']+)["'][^>]*>"#,
            #"<meta[^>]+content=["']([^"']+)["'][^>]+(?:property|name)=["']\#(escaped)["'][^>]*>"#
        ]

        return patterns.flatMap { pattern in
            capturedGroups(pattern: pattern, in: html)
        }
    }

    private static func jsonLDImages(in html: String) -> [String] {
        let scriptPattern = #"<script[^>]+type=["']application/ld\+json["'][^>]*>(.*?)</script>"#
        return matches(pattern: scriptPattern, in: html, dotMatchesLineSeparators: true).flatMap { script in
            capturedGroups(pattern: #""image"\s*:\s*(?:"([^"]+)"|\[\s*"([^"]+)")"#, in: script)
        }
    }

    private static func srcsetImageURLs(_ srcset: String) -> [String] {
        srcset
            .split(separator: ",")
            .compactMap { entry in
                entry
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .split(separator: " ")
                    .first
                    .map(String.init)
            }
    }

    private static func attributeValue(_ attribute: String, in tag: String) -> String? {
        let escaped = NSRegularExpression.escapedPattern(for: attribute)
        return capturedGroups(pattern: #"\#(escaped)=["']([^"']+)["']"#, in: tag).first
    }

    private static func capturedGroups(pattern: String, in text: String) -> [String] {
        matches(pattern: pattern, in: text).compactMap { match in
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
                return nil
            }
            let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
            guard let result = regex.firstMatch(in: match, options: [], range: NSRange(match.startIndex..<match.endIndex, in: match)) else {
                return nil
            }

            for index in 1..<result.numberOfRanges {
                let range = result.range(at: index)
                guard range.location != NSNotFound,
                      let swiftRange = Range(range, in: match) else { continue }
                return String(match[swiftRange]).htmlDecoded
            }

            _ = nsRange
            return nil
        }
    }

    private static func matches(pattern: String, in text: String, dotMatchesLineSeparators: Bool = false) -> [String] {
        var options: NSRegularExpression.Options = [.caseInsensitive]
        if dotMatchesLineSeparators {
            options.insert(.dotMatchesLineSeparators)
        }

        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return []
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.matches(in: text, options: [], range: range).compactMap { result in
            guard let swiftRange = Range(result.range, in: text) else { return nil }
            return String(text[swiftRange])
        }
    }
}

private struct ImageCandidate {
    let url: URL
    let context: String
    let sourceOrder: Int
}

private extension String {
    var htmlDecoded: String {
        replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }
}
