import Foundation

/// Use Scopes to define lifecycles of provided objects.
/// An object created from a scoped provider will be injected/resolved
/// without the provider being re-used, until all objects keeping a reference
/// to the scoped objects are destroyed.
/// 
/// See: https://github.com/kanecheshire/Blade#scopes
public protocol Scope {}
