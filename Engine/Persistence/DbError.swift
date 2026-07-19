enum DbError: Error {
    case unableToCreateUuid
    case serverError(statusCode: Int)
}
