import XCTest
@testable import Blade

final class BladeTests: XCTestCase {

	class MockObj {}
	enum MockQualifierA: Qualifier {}
	enum MockQualifierB: Qualifier {}
	enum MockScopeA: Scope {}
	enum MockScopeB: Scope {}

	override func setUp() {
		super.setUp()
		Resolver.clearAllRegistrations()
	}

	func test_clearAllRegistrations() throws {
		XCTAssertThrowsError(try Resolver.resolve() as MockObj) { error in
			XCTAssertEqual(error as? Resolver.Error, .missingProvider)
		}
		Resolver.register { MockObj() }
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

		Resolver.register { mockA }
		let a = Inject<MockObj>()
		Resolver.register(qualifiedBy: MockQualifierA.self) { mockB }
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


		Resolver.register { mockA } // Can be registered after creating since it's lazily resolved
		XCTAssert(a.wrappedValue === mockA)
		Resolver.register(qualifiedBy: MockQualifierA.self) {
			mockB
		}
		XCTAssert(b.wrappedValue === mockB)
		XCTAssertFalse(hasCBeenResolved)
		XCTAssert(c.wrappedValue === mockC)
		XCTAssertTrue(hasCBeenResolved)
		XCTAssertFalse(hasDBeenResolved)
		XCTAssert(d.wrappedValue === _mockD)
		XCTAssertTrue(hasDBeenResolved)

		let mockE = MockObj()
		var eResolveCallCount = 0
		Resolver.register(MockObj.self, scopedTo: MockScopeA.self) {
			eResolveCallCount += 1
			return mockE
		}
		var lazyInjectE = LazyInject<MockObj>(MockScopeA.self)
		XCTAssertEqual(eResolveCallCount, 0)
		XCTAssert(lazyInjectE.wrappedValue === mockE)
		XCTAssertEqual(eResolveCallCount, 1)
		var lazyInjectD = LazyInject<MockObj>(MockScopeA.self)
		XCTAssert(lazyInjectD.wrappedValue === lazyInjectE.wrappedValue)
		XCTAssertEqual(eResolveCallCount, 1)
	}

	func test_scopes() throws {
		var resolveCount = 0
		Resolver.register(scopedTo: MockScopeA.self) { () -> MockObj in
			resolveCount += 1
			return MockObj()
		}
		XCTAssertEqual(resolveCount, 0)
		var resolvedA: MockObj? = try Resolver.resolve(scopedTo: MockScopeA.self)
		XCTAssertEqual(resolveCount, 1)
		var resolvedB: MockObj? = try Resolver.resolve(scopedTo: MockScopeA.self)
		XCTAssertEqual(resolveCount, 1)
		XCTAssertNotNil(resolvedA)
		XCTAssertNotNil(resolvedB)
		XCTAssert(resolvedA === resolvedB)
		resolvedA = nil
		resolvedB = nil
		let _: MockObj = try Resolver.resolve(scopedTo: MockScopeA.self)
		XCTAssertEqual(resolveCount, 2)
		XCTAssertThrowsError(try Resolver.resolve(scopedTo: MockScopeB.self) as MockObj) { error in
			XCTAssertEqual(error as? Resolver.Error, .missingProvider)
		}
	}
}
