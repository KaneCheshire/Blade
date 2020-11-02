import XCTest
@testable import Blade

final class InjectTests: XCTestCase {

	override func setUp() {
		super.setUp()
		Resolver.clearAllRegistrations()
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
}
