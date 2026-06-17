import Foundation

enum AppError: LocalizedError, Equatable {
    case configurationRequired(String)
    case invalidEmail
    case invalidURL
    case missingRequiredField(String)
    case notFound
    case unavailable(String)

    var errorDescription: String? {
        switch self {
        case .configurationRequired(let service):
            "\(service) is not configured yet."
        case .invalidEmail:
            "Enter a valid email address."
        case .invalidURL:
            "Enter a valid product link."
        case .missingRequiredField(let field):
            "\(field) is required."
        case .notFound:
            "We could not find that item."
        case .unavailable(let message):
            message
        }
    }
}

