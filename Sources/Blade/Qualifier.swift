import Foundation

/// Use `Qualifier`s to provide different instances of injected types.
/// To create a new qualifier, just create a struct or enum that conforms to `Qualifier` and pass in the type like `MyQualifier.self`
public protocol Qualifier {}
