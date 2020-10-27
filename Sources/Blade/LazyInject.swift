import Foundation

///
/// Use a `LazyInject` property wrapper with `@LazyInject` on any property.
/// Unlike the `Inject` property  wrapper, the value is only resolved when first accessing the
/// property's value (analgous to using `lazy var` when declaring a regular property).
///
@propertyWrapper
public struct LazyInject<T> {

	private let lazyResolver: () -> T

	/// Creates a property wrapper, using the default Resolver with no qualifiers.
	/// You must have registered an unqualified type before accessing this injected property.
	public init() {
		lazyResolver = { try! Resolver.resolve() }
	}

	/// Creates a property wrapper, using the default Resolver with a specified qualifier.
	/// You must have registered a qualified type before accessing this injected property.
	public init(_ qualifier: Qualifier.Type) {
		lazyResolver = { try! Resolver.resolve(qualifiedBy: qualifier) }
	}

	/// Creates a property wrapper, where you're responsible for providing a value when the closure is called
	/// by the property wrapper.
	/// Since this is a LazyInject, this closure will only be called when you first access the value of the wrapped property.
	public init(_ resolver: @escaping () -> T) {
		lazyResolver = resolver
	}

	/// Creates a property wrapper, where you're responsible for providing a value when the closure is called
	/// by the property wrapper. Since this is an autoclosure, you can omit the `{}`,
	/// and since this is a LazyInject, this closure will only be called when you first access the value of the wrapped property.
	public init(_ resolver: @autoclosure @escaping () -> T) {
		lazyResolver = resolver
	}

	public lazy var wrappedValue: T = lazyResolver()
}
