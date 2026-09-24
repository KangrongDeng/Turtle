import SwiftUI

struct DialogBoxView: View {
    @State var dialogEngine = DialogEngine()

    @State var isTalking: Bool = false

    @State var userText: String = ""

    @State var text: String = ""
    
    @State var renderedText: String = ""

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                if !renderedText.isEmpty {
                    dialogView
                    exitButton
                        .opacity(isTalking ? 0 : 1)
                        .transition(.opacity)
                        .animation(.linear(duration: 0.2), value: isTalking)
                }
            }
            responseField
                .opacity(dialogEngine.talkingTo != nil && !isTalking && !dialogEngine.isGenerating ? 1 : 0)
                .transition(.opacity)
                .animation(.linear(duration: 0.2), value: isTalking)
        }
        .onChange(of: dialogEngine.nextUtterance) {
            text = dialogEngine.nextUtterance ?? ""
            renderedText = ""
            userText = ""
            typingAnimation()
        }
    }
    @ViewBuilder
    var dialogView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(dialogEngine.talkingTo?.displayName ?? "")
                .fontWeight(.bold)
            HStack {
                Text(LocalizedStringResource(stringLiteral: renderedText))
                    .onChange(of: renderedText, typingAnimation)
                Spacer()
            }
        }
        .frame(maxWidth: 350)
        .modifier(GameBoxStyle())
        .padding()
        .onAppear(perform: typingAnimation)
    }

    @ViewBuilder
    var exitButton: some View {
        Button {
            dialogEngine.endConversation()
        } label: {
            Image(systemName: "xmark")
                .fontWeight(.bold)
                .foregroundStyle(.blue)
                .font(.title2)
        }
        .buttonStyle(.plain)
        .padding()
        .glassEffect(.regular.interactive())
        .padding([.top, .bottom, .trailing])
    }

    @ViewBuilder
    var responseField: some View {
        HStack {
            TextField(
                "Reply",
                text: $userText
            )
            .textFieldStyle(.plain)
            .focused($isFocused)
            .disabled(isTalking)
            .onSubmit {
                userResponds()
            }
            Button {
                userResponds()
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.blue)
                    .font(.title2)
            }
            .buttonStyle(.plain)
            .disabled(isTalking)
        }
        .frame(height: 50)
        .modifier(GameBoxStyle())
        .padding(.horizontal)
        .padding(.bottom)
    }

    func typingAnimation() {
        if renderedText.count < text.count {
            isTalking = true
            Task {
                try? await Task.sleep(for: .seconds(0.025))
                if renderedText.count < text.count {
                    let next = text[renderedText.endIndex]
                    renderedText.append(next)
                } else {
                    isTalking = false
                }
            }
        } else {
            isTalking = false
        }
    }

    func userResponds() {
        isFocused = false
        dialogEngine.respond(userText)
    }
}

struct GameBoxStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .padding(.horizontal)
            .fontDesign(.monospaced)
            .glassEffect(.regular.interactive())
    }
}

#Preview {
    let dialogEngine = DialogEngine()
    let babyTurtle = BabyTurtle()
    let seahorseTrapped = SeahorseTrapped()
    let seahorse = Seahorse()
    let mantaRayTrapped = MantaRayTrapped()
    
    NavigationStack {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            DialogBoxView(dialogEngine: dialogEngine)
                .task {
                    dialogEngine.talkTo(seahorse)
                }
        }
        .toolbar {
            ToolbarItem {
                Button("海龟") {
                    dialogEngine.talkTo(babyTurtle)
                }
            }
            ToolbarItem {
                Button("被困的海马") {
                    dialogEngine.talkTo(seahorseTrapped)
                }
            }
            ToolbarItem {
                Button("海马") {
                    dialogEngine.talkTo(seahorse)
                }
            }
            ToolbarItem {
                Button("被困的魔鬼鱼") {
                    dialogEngine.talkTo(mantaRayTrapped)
                }
            }
        }
    }
}
