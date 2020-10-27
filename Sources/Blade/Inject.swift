import Foundation

///
/// Use a `Inject` property wrapper with `@Inject` on any property.
/// Unlike the `LazyInject` property  wrapper, the value is resolved as soon as the property wrapper is created,
/// rather than when the property is first accessed.
///
@propertyWrapper
public struct Inject<T> {

	/// Creates a property wrapper, using the default Resolver with no qualifiers.
	/// You must have registered an unqualified type before creating this property wrapper.
	public init() {
		wrappedValue = try! Resolver.resolve()
	}

	/// Creates a property wrapper, using the default Resolver with a specified qualifier.
	/// You must have registered a qualified type before creating this property wrapper.
	public init(_ qualifier: Qualifier.Type) {
		wrappedValue = try! Resolver.resolve(qualifiedBy: qualifier)
	}

	/// Creates a property wrapper, where you're responsible for providing a value when the closure is called
	/// by the property wrapper.
	/// Since this is not a LazyInject, this closure will be called immediately when creating this property wrapper.
	public init(_ resolver: () -> T) {
		wrappedValue = resolver()
	}

	/// Creates a property wrapper, where you're responsible for providing a value when the closure is called
	/// by the property wrapper. Since this is an autoclosure, you can omit the `{}`,
	/// and since this is not a LazyInject, this closure will be called immediately when creating this property wrapper.
	public init(_ resolver: @autoclosure () -> T) {
		wrappedValue = resolver()
	}

	public let wrappedValue: T
}
