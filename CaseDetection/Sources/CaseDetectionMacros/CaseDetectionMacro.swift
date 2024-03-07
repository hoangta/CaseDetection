import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

enum CaseDetectionDiagnostic: String, DiagnosticMessage {
    case notAsEnum

    var message: String {
        "@CaseDetection can only be applied to an enum."
    }

    var diagnosticID: MessageID {
        MessageID(domain: "CaseDetection", id: rawValue)
    }

    var severity: DiagnosticSeverity {
        .error
    }
}

public enum CaseDetectionMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.as(EnumDeclSyntax.self) != nil else {
            let structError = Diagnostic(
                node: node,
                message: CaseDetectionDiagnostic.notAsEnum
            )
            context.diagnose(structError)
            return []
        }

        return declaration.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .flatMap { $0.elements }
            .map { ($0.name, $0.name.initialUppercased) }
            .map { original, uppercased in
                """
                var is\(raw: uppercased): Bool {
                  if case .\(raw: original) = self {
                    return true
                  }
                  return false
                }
                """
            }
    }
}

extension TokenSyntax {
  fileprivate var initialUppercased: String {
    let name = self.text
    guard let initial = name.first else {
      return name
    }

    return "\(initial.uppercased())\(name.dropFirst())"
  }
}

@main
struct CaseDetectionPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CaseDetectionMacro.self,
    ]
}
