import Speech
import AVFoundation

class SpeechToTextViewModel: ObservableObject {
    private var speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    
    @Published var highlightRange: NSRange?
   var fullText: String
    
    init(fullText: String) {
        self.fullText = fullText
    }
    
    // A function to initialize and configure the speech recognizer
    func setupSpeechRecognition() {
        // Check if speech recognition is available
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    do {
                        try self.startRecording()
                    } catch let error {
                        print("There was a problem starting recording: \(error.localizedDescription)")
                    }
                case .denied:
                    print("Speech recognition authorization denied")
                case .restricted:
                    print("Not available on this device")
                case .notDetermined:
                    print("Not determined")
                @unknown default:
                    print("Unknown authorization status")
                }
            }
        }
    }

    // Function to start recording and recognition
    func startRecording() throws {
        // Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Initialize recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Could not create request instance")
        }
        recognitionRequest.shouldReportPartialResults = true  // Enable partial results
        
        // Setup audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { result, error in
            if let result = result {
                let spokenText = result.bestTranscription.formattedString
                self.updateHighlightRange(for: spokenText)
                // TODO: Highlight the spoken text in the view
                print("Spoken Text: \(spokenText)")
            }
            
            if error != nil {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        // Tap audio input for buffer recognition request
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    func updateHighlightRange(for spokenText: String) {
        highlightRange = findClosestMatchingRange(fullText: fullText.lowercased(), candidateText: spokenText.lowercased(), startingPoint: highlightRange?.location ?? 0)
        // Search for the spokenText range within the fullText
//        if let range = fullText.lowercased().range(of: spokenText.lowercased()) {
//            let nsRange = NSRange(range, in: fullText)
//            highlightRange = nsRange
//        }
    }
    
    func findClosestMatchingRange(fullText: String, candidateText: String, startingPoint: Int) -> NSRange? {
        let candidateLength = candidateText.count
        let fullTextLength = fullText.count
        var minDistance = Int.max
        var bestMatchRange: NSRange?

        if candidateLength > fullTextLength { return nil }
        
        let start = startingPoint > 0 ? startingPoint : 0
        let end = min(startingPoint > 0 ? startingPoint + 1000 : fullTextLength - candidateLength, fullTextLength - candidateLength)
        
        for i in start...end {
            let start = fullText.index(fullText.startIndex, offsetBy: i)
            let end = fullText.index(start, offsetBy: candidateLength)
            let substring = String(fullText[start..<end])
            
            let distance = levenshtein(a: substring, b: candidateText)
            
            if distance < minDistance {
                minDistance = distance
                bestMatchRange = NSRange(location: i, length: candidateLength)
                
                if minDistance == 0 {
                    break // Exact match found, no need to continue
                }
            }
        }
        
        return bestMatchRange
    }

    
    func levenshtein(a: String, b: String) -> Int {
        let a = Array(a)
        let b = Array(b)
        var dp = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)

        for i in 0...a.count {
            for j in 0...b.count {
                if i == 0 {
                    dp[i][j] = j
                } else if j == 0 {
                    dp[i][j] = i
                } else {
                    dp[i][j] = min(
                        dp[i-1][j] + 1,
                        dp[i][j-1] + 1,
                        dp[i-1][j-1] + (a[i-1] == b[j-1] ? 0 : 1)
                    )
                }
            }
        }

        return dp[a.count][b.count]
    }

}
