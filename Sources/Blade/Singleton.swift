import Foundation

/// Objects registered that conform to Singleton are automatically registered as singletons,
/// meaning after they are only resolved using the registered provider once (unless the resolver is cleared).
///
/// If you register a Singleton with a qualifier and a Singleton without a qualifier, the providers will both be called the
/// first time each are needed.
///
/// You can also achieve a Singleton (with or without qualifiers) by using the built-in Global scope.
public protocol Singleton: AnyObject {}
