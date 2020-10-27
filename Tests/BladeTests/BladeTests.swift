import XCTest
@testable import Blade

final class BladeTests: XCTestCase {

	class MockObj {}
	enum MockQualifierA: Qualifier {}
	enum MockQualifierB: Qualifier {}

	override func setUp() {
		super.setUp()
		Resolver.clearAllRegistrations()
	}

	func test_clearAllRegistrations() throws {
		XCTAssertThrowsError(try Resolver.resolve() as MockObj) { error in
			XCTAssertEqual(error as? Resolver.Error, .missingProvider)
		}
		Resolver.register(MockObj())
		XCTAssertNoThrow(try Resolver.resolve() as MockObj)
		XCTAssertNoThrow(try Resolver.resolve() as MockObj) // Ensures resolving doesn't clear
		Resolver.clearAllRegistrations()
		XCTAssertThrowsError(try Resolver.resolve() as MockObj) { error in
			XCTAssertEqual(error as? Resolver.Error, .missingProvider)
		}
	}

    func test_registrations() throws {
		let unqualifiedObj = MockObj()
		Resolver.register { unqualifiedObj }

		let qualifiedObj = MockObj()
		Resolver.register(qualifiedBy: MockQualifierA.self) { qualifiedObj }
		let a: MockObj = try Resolver.resolve()
		let b: MockObj = try Resolver.resolve(qualifiedBy: MockQualifierA.self)

		XCTAssert(a === unqualifiedObj)
		XCTAssert(b === qualifiedObj)
		XCTAssertThrowsError(try Resolver.resolve(qualifiedBy: MockQualifierB.self) as MockObj) { error in
			XCTAssertEqual(error as? Resolver.Error, .missingProvider)
		}

		let reregisteredObj = MockObj()
		Resolver.register { reregisteredObj }
		let c: MockObj = try Resolver.resolve()
		XCTAssert(c === reregisteredObj)

		let reregisteredQualifiedObj = MockObj()
		Resolver.register(qualifiedBy: MockQualifierA.self) { reregisteredQualifiedObj }
		let d: MockObj = try Resolver.resolve(qualifiedBy: MockQualifierA.self)
		XCTAssert(d === reregisteredQualifiedObj)
    }

	func test_injectPropertyWrapper() {
		let mockA = MockObj()
		let mockB = MockObj()
		let mockC = MockObj()
		var hasDBeenResolved = false
		let _mockD = MockObj()
		var mockD: MockObj {
			hasDBeenResolved = true
			return _mockD
		}

		Resolver.register(mockA)
		let a = Inject<MockObj>()
		Resolver.register(qualifiedBy: MockQualifierA.self, mockB)
		let b = Inject<MockObj>(MockQualifierA.self)
		var hasCBeenResolved = false
		let c = Inject<MockObj> {
			hasCBeenResolved = true
			return mockC
		}
		XCTAssertTrue(hasCBeenResolved)
		XCTAssertFalse(hasDBeenResolved)
		let d = Inject<MockObj>(mockD)
		XCTAssertTrue(hasDBeenResolved)
		XCTAssert(a.wrappedValue === mockA)
		XCTAssert(b.wrappedValue === mockB)
		XCTAssert(c.wrappedValue === mockC)
		XCTAssert(d.wrappedValue === _mockD)
	}

	func test_lazyInjectPropertyWrapper() {
		let mockA = MockObj()
		let mockB = MockObj()
		let mockC = MockObj()
		var hasDBeenResolved = false
		let _mockD = MockObj()
		var mockD: MockObj {
			hasDBeenResolved = true
			return _mockD
		}

		var a = LazyInject<MockObj>()
		var b = LazyInject<MockObj>(MockQualifierA.self)
		var hasCBeenResolved = false
		var c = LazyInject<MockObj> {
			hasCBeenResolved = true
			return mockC
		}
		var d = LazyInject<MockObj>(mockD)

		Resolver.register(mockA) // Can be registered after creating since it's lazily resolved
		Resolver.register(qualifiedBy: MockQualifierA.self, mockB)
		XCTAssert(a.wrappedValue === mockA)
		XCTAssert(b.wrappedValue === mockB)
		XCTAssertFalse(hasCBeenResolved)
		XCTAssert(c.wrappedValue === mockC)
		XCTAssertTrue(hasCBeenResolved)
		XCTAssertFalse(hasDBeenResolved)
		XCTAssert(d.wrappedValue === _mockD)
		XCTAssertTrue(hasDBeenResolved)
	}
}
