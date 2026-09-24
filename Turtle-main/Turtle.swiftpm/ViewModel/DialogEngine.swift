import FoundationModels
import SwiftUI

@MainActor
@Observable class DialogEngine {
    
    var talkingTo: (any Character)?
    
    var nextUtterance: String?
    
    var isGenerating: Bool = false
    
    private var session: LanguageModelSession?
    private var currentTask: Task<Void, Never>?

    private var conversations: [UUID: LanguageModelSession] = [:]
    
    func talkTo(_ character: any Character) {
        talkingTo = character
        print("Talking to: \(self.talkingTo?.displayName ?? "No one")")
        
        if conversations[character.id] == nil {
            print("Creating session for \(character.displayName)")
            nextUtterance = character.firstLine
            createNewSession(character, startWith: character.firstLine)
            self.session = conversations[character.id]
        } else {
            self.session = conversations[character.id]
            if !character.resumeConversationLine.isEmpty {
                nextUtterance = character.resumeConversationLine
            } else {
                nextUtterance = character.firstLine
            }
        }
    }
    
    
    private func createNewSession(_ character: any Character, startWith: String) {
        let newSession = LanguageModelSession(instructions: character.instruction)
        newSession.prewarm()
        
        conversations[character.id] = newSession
        self.session = newSession
        print("Session for \(character.displayName) created.")
    }
    
    private func resetSession(_ character: any Character, previouSession: LanguageModelSession) {
        let allEntries = previouSession.transcript
        var condensedEntries = [Transcript.Entry]()
        if let firstEntry = allEntries.first {
            condensedEntries.append(firstEntry)
            if allEntries.count > 1, let lastEntry = allEntries.last {
                condensedEntries.append(lastEntry)
            }
        }
        
        let condensedTranscript = Transcript(entries: condensedEntries)
        let newSession = LanguageModelSession(transcript: condensedTranscript)
        newSession.prewarm()
        conversations[character.id] = newSession
    }
    
    
    func respond(_ userInput: String) {
        nextUtterance = "... ... ..."
        
        guard let character = talkingTo, let session else {
            if let session {
                print("Session: \(String(describing: session))")
            } else {
                print("Error: No session available")
            }
            return
        }
        
        isGenerating = true
        currentTask = Task {
            do {
                let response = try await session.respond(
                    to: userInput
                )
                let dialog = response.content
                
                await MainActor.run {
                    nextUtterance = dialog
                    print("Response: \(dialog)")
                    isGenerating = false
                }
            } catch {
                print("Error in respond: \(error.localizedDescription)")
          
                await MainActor.run {
                    if !character.errorResponse.isEmpty {
                        nextUtterance = character.errorResponse
                    } else if !character.resumeConversationLine.isEmpty {
                        nextUtterance = character.resumeConversationLine
                    } else {
                        nextUtterance = character.hintForTurtle
                    }
                    isGenerating = false
                }
            }
        }
    }
    
    func endConversation() {
        currentTask?.cancel()
        nextUtterance = nil
        if let talkingTo, let previousSession = conversations[talkingTo.id] {
            resetSession(talkingTo, previouSession: previousSession)
            self.session = conversations[talkingTo.id]
        }
        talkingTo = nil
        isGenerating = false
    }
}
