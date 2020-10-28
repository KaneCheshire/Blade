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

	private static var providers: [Key: () -> Any] = [:]

	/// Registers a provider to provide an instance of the given type, optionally restricting to a specific qualifier.
	/// - Parameters:
	///   - qualifier: An optional qualifier which will ensure the provider only gets used when the corresponding qualifier is used.
	///   - provider: The provider to provide an instance of the type. You could return a new instance each time, or a cached/shared instance.
	public static func register<T>(
		qualifiedBy qualifier: Qualifier.Type? = nil,
		_ provider: @escaping () -> T
	) {
		let key = Key(type: T.self, qualifier: qualifier)
		providers[key] = provider
	}

	public static func register<T>(
		qualifiedBy qualifier: Qualifier.Type? = nil,
		_ provider: @escaping @autoclosure () -> T
	) {
		register(qualifiedBy: qualifier, provider)
	}

	/// Resolves the given type, throwing an error if a provider cannot be found for the type and qualifier (if a qualifier is provided).
	/// An instance must be registered for a specific type before this function is used.
	/// - Parameter qualifier: An optional qualifier to determine which provider is used to return an instance.
	public static func resolve<T>(
		qualifiedBy qualifier: Qualifier.Type? = nil
	) throws -> T {
		let key = Key(type: T.self, qualifier: qualifier)
		guard let provider = providers[key] else { throw Error.missingProvider }
		guard let obj = provider() as? T else { throw Error.incorrectType } // Should never technically be possible.
		return obj
	}

	/// Clears all registrations. Useful for testing.
	public static func clearAllRegistrations() {
		providers = [:]
	}
}

private extension Resolver {

	struct Key: Hashable {

		let type: Any.Type
		let qualifier: Qualifier.Type?

		func hash(into hasher: inout Hasher) {
			"\(type)".hash(into: &hasher)
			if let qualifier = qualifier { "\(qualifier)".hash(into: &hasher) }
		}

		static func == (lhs: Self, rhs: Self) -> Bool {
			lhs.type == rhs.type && lhs.qualifier == rhs.qualifier
		}
	}
}
