import XCTest
@testable import SwiftTreeSitter

class PredicateTests: XCTestCase {
    func testParseEqTwoArgs() throws {
        let steps: [QueryPredicateStep] = [
            .string("eq?"),
            .capture("@a"),
            .string("thing"),
            .done
        ]

        let predicates = try PredicateParser().parse(steps)

        let expectedPredicates = [
            Predicate.eq(["thing"], ["@a"]),
        ]

        XCTAssertEqual(predicates, expectedPredicates)
    }

    func testParseEqFourArgs() throws {
        let steps: [QueryPredicateStep] = [
            .string("eq?"),
            .capture("@a"),
            .capture("@b"),
            .capture("@c"),
            .capture("@d"),
            .done
        ]

        let predicates = try PredicateParser().parse(steps)

        let expectedPredicates = [
            Predicate.eq([], ["@a", "@b", "@c", "@d"]),
        ]

        XCTAssertEqual(predicates, expectedPredicates)
    }

    func testParseTwoEqTwoArgs() throws {
        let steps: [QueryPredicateStep] = [
            .string("eq?"),
            .capture("@a"),
            .string("thing"),
            .done,
            .string("eq?"),
            .capture("@b"),
            .string("thing"),
            .done
        ]

        let predicates = try PredicateParser().parse(steps)

        let expectedPredicates = [
            Predicate.eq(["thing"], ["@a"]),
            Predicate.eq(["thing"], ["@b"]),
        ]

        XCTAssertEqual(predicates, expectedPredicates)
    }

    func testParseMatch() throws {
        let steps: [QueryPredicateStep] = [
            .string("match?"),
            .capture("@a"),
            .string("^(a|b|c)$"),
            .done
        ]

        let predicates = try PredicateParser().parse(steps)

        let expectedPredicates = [
            Predicate.match(try NSRegularExpression(pattern: "^(a|b|c)$", options: []), ["@a"])
        ]

        XCTAssertEqual(predicates, expectedPredicates)
    }

    func testParseIsNotLocal() throws {
        let steps: [QueryPredicateStep] = [
            .string("is-not?"),
            .string("local"),
            .done
        ]

        let predicates = try PredicateParser().parse(steps)

        let expectedPredicates = [
            Predicate.isNot("local")
        ]

        XCTAssertEqual(predicates, expectedPredicates)
    }
}