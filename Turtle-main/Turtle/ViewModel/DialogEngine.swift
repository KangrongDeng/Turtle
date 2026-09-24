//
//  DialogEngine.swift
//  Turtle
//
//  Created by Heyya on 1/27/26.
//

import FoundationModels
import SwiftUI

@MainActor
@Observable class DialogEngine {
    
    /// 指明当前说话的Character
    var talkingTo: (any Character)?
    
    /// 下一话的内容
    var nextUtterance: String?
    
    /// 是否在生成对话内容
    var isGenerating: Bool = false
    
    /// 与语言模型进行交互的会话对象
    private var session: LanguageModelSession?
    private var currentTask: Task<Void, Never>?
    
    /// 存储与不同角色的会话，以角色的uuid记录相应的session
    private var conversations: [UUID: LanguageModelSession] = [:]
    
    /// 与指定角色进行对话
    func talkTo(_ character: any Character) {
        talkingTo = character
        print("Talking to: \(self.talkingTo?.displayName ?? "No one")")
        
        if conversations[character.id] == nil {     // 如果不存在与该角色的历史会话，则创建该会话
            print("Creating session for \(character.displayName)")
            nextUtterance = character.firstLine
            createNewSession(character, startWith: character.firstLine)
            // 确保 session 被正确设置
            self.session = conversations[character.id]
        } else {
            // 恢复已有会话
            self.session = conversations[character.id]
            if !character.resumeConversationLine.isEmpty {
                nextUtterance = character.resumeConversationLine
            } else {
                nextUtterance = character.firstLine
            }
        }
    }
    
    
    /// 初始化模型
    private func createNewSession(_ character: any Character, startWith: String) {
        
        // 对模型生成内容的指导文本，提前设定模型的行为，例如所代表角色的名字、性格、作出的反应等
        let instructions = """
            A multi-turn conversation between a game character and the player of this game. \
            You are \(character.displayName) in the ocean. Refer to \(character.displayName) in the 1st person \
            (like "I" or "me").
            
            Keep your response short and positive. With background: "\(character.background)", your goal is help the player(The TURTLE) to find HIS mother, with giving \
            him the hint of \(character.hintForTurtle.uppercased()).
            
            You just said: "\(character.firstLine)"
            """
        
        let newSession = LanguageModelSession(instructions: instructions)
        newSession.prewarm() // 将该会话提前载入到内存中，减少延迟
        
        conversations[character.id] = newSession // 将与该角色的对话添加到记录中
        self.session = newSession
        print("Session for \(character.displayName) created.")
    }
    
    /// 重置对话
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
    
    
    /// 作出回复
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
                // 如果出现错误（如 Safety guardrails），使用角色的 errorResponse 或 resumeConversationLine
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
            // 更新当前 session
            self.session = conversations[talkingTo.id]
        }
        talkingTo = nil
        isGenerating = false
    }
}
