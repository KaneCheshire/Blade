import Foundation

@propertyWrapper
public struct WeakInject<T: AnyObject> {

	public init() {
		wrappedValue = try! Resolver.resolve() as T
	}

	public init(_ qualifier: Qualifier.Type) {
		wrappedValue = try! Resolver.resolve(qualifiedBy: qualifier) as T
	}

	public init(_ scope: Scope.Type, _ qualifier: Qualifier.Type? = nil) {
		wrappedValue = try! Resolver.resolve(scopedTo: scope, qualifiedBy: qualifier) as T
	}

	public init(_ resolver: () -> T) {
		wrappedValue = resolver() as T
	}

	public init(_ resolver: @autoclosure () -> T) {
		wrappedValue = resolver() as T
	}

	public weak var wrappedValue: T?
}
