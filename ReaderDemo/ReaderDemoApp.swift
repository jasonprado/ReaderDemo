//
//  ReaderDemoApp.swift
//  ReaderDemo
//
//  Created by Jason Prado on 8/26/23.
//

import SwiftUI
import Speech

let fullText = """
In an article devoted to the Young Marx, I have already stressed the ambiguity of the idea of ‘inverting Hegel’. It seemed to me that strictly speaking this expression suited Feuerbach perfectly; the latter did, indeed, ‘turn speculative philosophy back on to its feet’, but the only result was to arrive with implacable logic at an idealist anthropology. But the expression cannot be applied to Marx, at least not to the Marx who had grown out of this ‘anthropological’ phase.

I could go further, and suggest that in the well-known passage: ‘With (Hegel, the dialectic) is standing on its head. It must be turned right side up again, if you would discover the rational kernel within the mystical shell’, this ‘turning right side up again’ is merely gestural, even metaphorical, and it raises as many questions as it answers.

Let us look a little closer. As soon as the dialectic is removed from its idealistic shell, it becomes ‘the direct opposite of the Hegelian dialectic’. Does this mean that for Marx, far from dealing with Hegel’s sublimated, inverted world, it is applied to the real world? This is certainly the sense in which Hegel was ‘the first consciously to expose its general forms of movement in depth’. We could therefore take over the dialectic from him and apply it to life rather than to the Idea. The ‘inversion’ would then be an ‘inversion’ of the ‘sense-of the dialectic. But such an inversion in sense would in fact leave the dialectic untouched.
"""

@main
struct ReaderDemoApp: App {
    @StateObject var speechToTextViewModel = SpeechToTextViewModel(fullText: fullText)
    
    var body: some Scene {
        WindowGroup {
            HighlightedTextView(entireText: fullText)
                .environmentObject(speechToTextViewModel)
                .onAppear() {
                    speechToTextViewModel.setupSpeechRecognition()
                }
        }
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
