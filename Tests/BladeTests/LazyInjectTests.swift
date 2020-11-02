import XCTest
@testable import Blade

final class LazyInjectTests: XCTestCase {

	override func setUp() {
		super.setUp()
		Resolver.clearAllRegistrations()
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

}
