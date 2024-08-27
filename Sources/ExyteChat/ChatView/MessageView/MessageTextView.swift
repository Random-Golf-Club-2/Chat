//
//  SwiftUIView.swift
//
//
//  Created by Alex.M on 07.07.2022.
//

import SwiftUI

struct MessageTextView: View {
    let text: String?
    let messageUseMarkdown: Bool

    private let dataDetector: NSDataDetector = {
        let types: NSTextCheckingResult.CheckingType = [.link, .phoneNumber]
        return try! .init(types: types.rawValue)
    }()

    var body: some View {
        if let text = text, !text.isEmpty {
            textView(text)
        }
    }

    @ViewBuilder
    private func textView(_ text: String) -> some View {
        if messageUseMarkdown,
           let attributed = try? AttributedString(markdown: text, options: String.markdownOptions) {
            Text(attributed)
        } else {
            if let attrString = attributedString(from: text) {
                Text(attrString)
            } else {
                Text(text)
            }
        }
    }

    private func attributedString(from text: String) -> AttributedString? {
        var attributed = AttributedString(text)
        let fullRange = NSMakeRange(0, text.count)
        let matches = dataDetector.matches(in: text, options: [], range: fullRange)
        guard !matches.isEmpty else { return nil }

        for result in matches {
            guard let range = Range<AttributedString.Index>(result.range, in: attributed) else {
                continue
            }

            switch result.resultType {
            case .phoneNumber:
                guard
                    let phoneNumber = result.phoneNumber,
                    let url = URL(string: "sms://\(phoneNumber)")
                else {
                    break
                }
                attributed[range].link = url

            case .link:
                guard let url = result.url else {
                    break
                }
                attributed[range].link = url

            default:
                break
            }
        }

        return attributed
    }
}

struct MessageTextView_Previews: PreviewProvider {
    static var previews: some View {
        MessageTextView(text: "Hello world!", messageUseMarkdown: false)
    }
}
