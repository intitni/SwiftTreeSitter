import SwiftUI

import SwiftTreeSitter
import TreeSitterDocument
import TreeSitterMarkdown
import TreeSitterMarkdownInline
import TreeSitterSwift

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
		.onAppear {
			do {
				try runTreeSitterTest()
			} catch {
				print("error: ", error)
			}
		}
    }

	func runTreeSitterTest() throws {
		let markdownConfig = try LanguageConfiguration(tsLanguage: tree_sitter_markdown(),
													   name: "Markdown")
		let markdownInlineConfig = try LanguageConfiguration(tsLanguage: tree_sitter_markdown_inline(),
															 name: "MarkdownInline",
															 bundleName: "TreeSitterMarkdown_TreeSitterMarkdownInline")
		let swiftConfig = try LanguageConfiguration(tsLanguage: tree_sitter_swift(), name: "Swift")

		let config = LanguageLayerTree.Configuration(locationTransformer: nil,
													invalidationHandler: nil,
													languageProvider: { name in
			switch name {
			case "markdown":
				return markdownConfig
			case "markdown_inline":
				return markdownInlineConfig
			case "swift":
				return swiftConfig
			default:
				return nil
			}
		})

		let tree = try! LanguageLayerTree(rootLanguageConfig: markdownConfig, configuration: config)

		let source = """
# this is markdown

```swift
func main(a: Int) {
}
```

## also markdown

```swift
let value = "abc"
```
"""

		tree.replaceContent(with: source)

		let fullRange = NSRange(source.startIndex..<source.endIndex, in: source)

		let membershipProvider: Predicate.GroupMembershipProvider = { query, range, _ in
			guard query == "local" else { return false }

			return false
		}

		let context = Predicate.Context(textProvider: source.cursorTextProvider, groupMembershipProvider: membershipProvider)

		let highlights = try tree.highlights(in: fullRange, context: context)

		for namedRange in highlights {
			print("\(namedRange.name): \(namedRange.range)")
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
