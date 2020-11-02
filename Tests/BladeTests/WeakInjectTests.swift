import XCTest
@testable import Blade

final class WeakInjectTests: XCTestCase {

	override func setUp() {
		super.setUp()
		Resolver.clearAllRegistrations()
	}

	func test_weakInject_storesWeakly() {
		var mock: MockObj? = MockObj()
		Resolver.register { mock! }
		let weakInject = WeakInject<MockObj>()
		XCTAssertNotNil(weakInject.wrappedValue)
		XCTAssertNotNil(weakInject.wrappedValue === mock)
		mock = nil
		XCTAssertNil(weakInject.wrappedValue)
	}

	func test_weakInject_scoped() {
		let mock = MockObj()
		Resolver.register(scopedTo: MockScopeA.self) { mock }
		let weakInject = WeakInject<MockObj>(MockScopeA.self)
		XCTAssertNotNil(weakInject.wrappedValue)
		XCTAssertNotNil(weakInject.wrappedValue === mock)
	}

	func test_weakInject_qualified() {
		let mock = MockObj()
		Resolver.register(qualifiedBy: MockQualifierA.self) { mock }
		let weakInject = WeakInject<MockObj>(MockQualifierA.self)
		XCTAssertNotNil(weakInject.wrappedValue)
		XCTAssertNotNil(weakInject.wrappedValue === mock)
	}

	func test_weakInject_scopedAndQualified() {
		let mock = MockObj()
		Resolver.register(scopedTo: MockScopeA.self, qualifiedBy: MockQualifierA.self) { mock }
		let weakInject = WeakInject<MockObj>(MockScopeA.self, MockQualifierA.self)
		XCTAssertNotNil(weakInject.wrappedValue)
		XCTAssertNotNil(weakInject.wrappedValue === mock)
	}

	func test_weakInject_customResolver() {
		let mock = MockObj()
		let weakInject = WeakInject<MockObj> { mock }
		XCTAssertNotNil(weakInject.wrappedValue)
		XCTAssertNotNil(weakInject.wrappedValue === mock)
	}

	func test_weakInject_customResolver_autoclosure() {
		let mock = MockObj()
		let weakInject = WeakInject<MockObj>(mock)
		XCTAssertNotNil(weakInject.wrappedValue)
		XCTAssertNotNil(weakInject.wrappedValue === mock)
	}
}
