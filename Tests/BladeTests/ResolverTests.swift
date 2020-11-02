import XCTest
@testable import Blade

final class ResolverTests: XCTestCase {

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

	func test_clearAllForType() {
		XCTAssertThrowsError(try Resolver.resolve() as MockObj) { error in XCTAssertEqual(error as? Resolver.Error, .missingProvider) }
		Resolver.register { MockObj() }

		XCTAssertThrowsError(try Resolver.resolve(scopedTo: MockScopeA.self) as MockObj) { error in XCTAssertEqual(error as? Resolver.Error, .missingProvider) }
		Resolver.register(scopedTo: MockScopeA.self) { MockObj() }

		XCTAssertThrowsError(try Resolver.resolve(qualifiedBy: MockQualifierA.self) as MockObj) { error in XCTAssertEqual(error as? Resolver.Error, .missingProvider) }
		Resolver.register(qualifiedBy: MockQualifierA.self) { MockObj() }

		XCTAssertThrowsError(try Resolver.resolve(scopedTo: MockScopeA.self, qualifiedBy: MockQualifierA.self) as MockObj) { error in XCTAssertEqual(error as? Resolver.Error, .missingProvider) }
		Resolver.register(scopedTo: MockScopeA.self, qualifiedBy: MockQualifierA.self) { MockObj() }

		XCTAssertThrowsError(try Resolver.resolve() as MockObjB) { error in XCTAssertEqual(error as? Resolver.Error, .missingProvider) }
		Resolver.register { MockObjB() }

		XCTAssertNoThrow(try Resolver.resolve() as MockObj)
		XCTAssertNoThrow(try Resolver.resolve(scopedTo: MockScopeA.self) as MockObj)
		XCTAssertNoThrow(try Resolver.resolve(qualifiedBy: MockQualifierA.self) as MockObj)
		XCTAssertNoThrow(try Resolver.resolve(scopedTo: MockScopeA.self, qualifiedBy: MockQualifierA.self) as MockObj)
		XCTAssertNoThrow(try Resolver.resolve() as MockObjB)
		Resolver.clearAllRegistrations(for: MockObj.self)

		XCTAssertThrowsError(try Resolver.resolve() as MockObj) { error in XCTAssertEqual(error as? Resolver.Error, .missingProvider) }
		XCTAssertThrowsError(try Resolver.resolve(scopedTo: MockScopeA.self) as MockObj) { error in XCTAssertEqual(error as? Resolver.Error, .missingProvider) }
		XCTAssertThrowsError(try Resolver.resolve(qualifiedBy: MockQualifierA.self) as MockObj) { error in XCTAssertEqual(error as? Resolver.Error, .missingProvider) }
		XCTAssertThrowsError(try Resolver.resolve(scopedTo: MockScopeA.self, qualifiedBy: MockQualifierA.self) as MockObj) { error in XCTAssertEqual(error as? Resolver.Error, .missingProvider) }
		XCTAssertNoThrow(try Resolver.resolve() as MockObjB)

		Resolver.clearAllRegistrations(for: MockObjB.self)
		XCTAssertThrowsError(try Resolver.resolve() as MockObjB) { error in XCTAssertEqual(error as? Resolver.Error, .missingProvider) }
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

	func test_scopes() throws {
		var wasFirstProviderCalled = false
		Resolver.register(MockObj.self, scopedTo: MockScopeA.self) {
			wasFirstProviderCalled = true
			return MockObj()
		}
		var resolveCount = 0
		Resolver.register(MockObj.self, scopedTo: MockScopeA.self) {
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
		XCTAssertFalse(wasFirstProviderCalled)
	}
}
