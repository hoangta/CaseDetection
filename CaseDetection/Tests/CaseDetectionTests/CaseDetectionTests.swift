import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(CaseDetectionMacros)
import CaseDetectionMacros

let testMacros: [String: Macro.Type] = [
    "CaseDetection": CaseDetectionMacro.self,
]
#endif

final class CaseDetectionTests: XCTestCase {
    func testMacroNotEnum() throws {
        #if canImport(CaseDetectionMacros)
        assertMacroExpansion(
            """
            @CaseDetection
            struct Direction {}
            """,
            expandedSource: """
            struct Direction {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "@CaseDetection can only be applied to an enum.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacro1() throws {
        #if canImport(CaseDetectionMacros)
        assertMacroExpansion(
            """
            @CaseDetection
            enum Test {
                case a
            }
            """,
            expandedSource: """
            enum Test {
                case a

                var isA: Bool {
                  if case .a = self {
                    return true
                  }
                  return false
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacro2() throws {
        #if canImport(CaseDetectionMacros)
        assertMacroExpansion(
            """
            @CaseDetection
            enum Direction {
                case south, north
            }
            """,
            expandedSource: """
            enum Direction {
                case south, north

                var isSouth: Bool {
                  if case .south = self {
                    return true
                  }
                  return false
                }

                var isNorth: Bool {
                  if case .north = self {
                    return true
                  }
                  return false
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
