import SwiftUI

struct HighlightedTextView: View {
    // The entire text that will be displayed
    let entireText: String
    @EnvironmentObject var speechToTextViewModel: SpeechToTextViewModel
    
    var body: some View {
            ScrollView {
                let brokenText = breakTextByHighlightRange(text: entireText, highlightRange: speechToTextViewModel.highlightRange)

                VStack(alignment: .leading) {
                    Text(brokenText.before) .font(.system(size: 20)) +
                    Text(brokenText.highlight).foregroundColor(.purple).underline(true, color: Color.black) .font(.system(size: 20)) +
                        Text(brokenText.after) .font(.system(size: 20))
                }
                .frame(maxWidth: 600) // Set maximum width to 600 pixels
            }
            .padding(.vertical, 60)
            .background(Color.white)
            .ignoresSafeArea()
        }

    func breakTextByHighlightRange(text: String, highlightRange: NSRange?) -> (before: String, highlight: String, after: String) {
        guard let highlightRange = highlightRange else {
            return (text, "", "")
        }

        let nsString = text as NSString
        let beforeRange = NSRange(location: 0, length: highlightRange.location)
        let afterRange = NSRange(location: highlightRange.location + highlightRange.length, length: nsString.length - highlightRange.location - highlightRange.length)

        let beforeText = nsString.substring(with: beforeRange)
        let highlightText = nsString.substring(with: highlightRange)
        let afterText = nsString.substring(with: afterRange)

        return (beforeText, highlightText, afterText)
    }

}

