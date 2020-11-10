import Foundation

/// The `Resolver` is what provides injected instances of types.
/// Resolver works with the `Inject` and LazyInject property wrappers, or you can use it directly to provide values in initializers.
/// Before the Resolver knows how to provide instances of types, you need to `register` a provider.
/// You can optionally also return different instances for different qualifiers.
public class Resolver {

	enum Error: Swift.Error {
		case missingProvider
		case incorrectType
	}

	private static var entries: [Key: Entry] = [:]

	/// Registers a provider to provide an instance of the given type, optionally restricting to a specific qualifier.
	/// - Parameters:
	///   - qualifier: An optional qualifier which will ensure the provider only gets used when the corresponding qualifier is used.
	///   - provider: The provider to provide an instance of the type. You could return a new instance each time, or a cached/shared instance.
	public static func register<T>(
		_ type: T.Type = T.self,
		qualifiedBy qualifier: Qualifier.Type? = nil,
		_ provider: @escaping () -> T
	) {
		let key = Key(type: T.self, scope: nil, qualifier: qualifier)
		if type is Singleton.Type {
			entries[key] = SingletonEntry(provider: provider)
		} else {
			entries[key] = DefaultEntry(provider: provider)
		}
	}

	public static func register<T: AnyObject>(
		_ type: T.Type = T.self,
		scopedTo scope: Scope.Type,
		qualifiedBy qualifier: Qualifier.Type? = nil,
		_ provider: @escaping () -> T
	) {
		let key = Key(type: type, scope: scope, qualifier: qualifier)
		if type is Singleton.Type || scope is Global.Type {
			entries[key] = SingletonEntry(provider: provider)
		} else {
			entries[key] = ScopedEntry(provider: provider)
		}
	}

	/// Resolves the given type, throwing an error if a provider cannot be found for the type and qualifier (if a qualifier is provided).
	/// An instance must be registered for a specific type before this function is used.
	/// - Parameter qualifier: An optional qualifier to determine which provider is used to return an instance.
	public static func resolve<T>(
		qualifiedBy qualifier: Qualifier.Type? = nil
	) throws -> T {
		try commonResolve(scopedTo: nil, qualifiedBy: qualifier)
	}

	public static func resolve<T: AnyObject>(
		scopedTo scope: Scope.Type,
		qualifiedBy qualifier: Qualifier.Type? = nil
	) throws -> T {
		try commonResolve(scopedTo: scope, qualifiedBy: qualifier)
	}

	/// Clears all registrations. Useful for testing.
	public static func clearAllRegistrations() {
		entries.removeAll()
	}

	public static func clearAllRegistrations<T>(for type: T.Type) {
		while let index = entries.first(where: { $0.key.type == type }) { entries[index.key] = nil }
	}

	public static func clearAllRegistrations(scopedTo scope: Scope.Type) {
		while let index = entries.first(where: { $0.key.scope == scope }) { entries[index.key] = nil }
	}

	public static func clearAllRegistrations(qualifiedBy qualifier: Qualifier.Type) {
		while let index = entries.first(where: { $0.key.qualifier == qualifier }) { entries[index.key] = nil }
	}

	public static func clearAllRegistrations(scopedTo scope: Scope.Type, qualifiedBy qualifier: Qualifier.Type) {
		while let index = entries.first(where: { $0.key.scope == scope && $0.key.qualifier == qualifier }) { entries[index.key] = nil }
	}

	public static func clearRegistration<T>(for type: T.Type = T.self, qualifiedBy qualifier: Qualifier.Type? = nil) {
		let key = Key(type: T.self, scope: nil, qualifier: qualifier)
		entries[key] = nil
	}

	public static func clearRegistration<T: AnyObject>(for type: T.Type = T.self, scopedTo scope: Scope.Type, qualifiedBy qualifier: Qualifier.Type? = nil) {
		let key = Key(type: T.self, scope: scope, qualifier: qualifier)
		entries[key] = nil
	}
}

private extension Resolver {

	struct Key: Hashable {

		let type: Any.Type
		let scope: Scope.Type?
		let qualifier: Qualifier.Type?

		func hash(into hasher: inout Hasher) {
			"\(type)".hash(into: &hasher)
			if let scope = scope { "\(scope)".hash(into: &hasher) }
			if let qualifier = qualifier { "\(qualifier)".hash(into: &hasher) }
		}

		static func == (lhs: Self, rhs: Self) -> Bool {
			lhs.type == rhs.type && lhs.scope == rhs.scope && lhs.qualifier == rhs.qualifier
		}
	}

	struct DefaultEntry: Entry {

		private let provider: () -> Any

		init(provider: @escaping () -> Any) {
			self.provider = provider
		}

		func resolve() -> Any { provider() }
	}

	final class ScopedEntry: Entry {

		private let provider: () -> AnyObject
		private weak var weaklyStoredObject: AnyObject? // The object is created if nil when accessed, and held onto weakly

		init(provider: @escaping () -> AnyObject) {
			self.provider = provider
		}

		func resolve() -> Any { weaklyStoredObject ?? createAndStoreObject() }

		private func createAndStoreObject() -> AnyObject {
			let resolvedObject = provider()
			weaklyStoredObject = resolvedObject
			return resolvedObject
		}
	}

	final class SingletonEntry: Entry {

		private let provider: () -> Any
		private var storedObject: Any?

		init(provider: @escaping () -> Any) {
			self.provider = provider
		}

		func resolve() -> Any { storedObject ?? createAndStoreObject() }

		private func createAndStoreObject() -> Any {
			let resolvedObject = provider()
			storedObject = resolvedObject
			return resolvedObject
		}
	}

	private static func commonResolve<T>(
		scopedTo scope: Scope.Type?,
		qualifiedBy qualifier: Qualifier.Type?
	) throws -> T {
		let key = Key(type: T.self, scope: scope, qualifier: qualifier)
		guard let entry = entries[key] else { throw Error.missingProvider }
		guard let obj = entry.resolve() as? T else { throw Error.incorrectType }
		return obj
	}
}

private protocol Entry {

	func resolve() -> Any
}
