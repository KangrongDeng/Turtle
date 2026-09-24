import SwiftUI
import SpriteKit

let boardBackgroundColor: UIColor = UIColor(red: 154/255, green: 200/255, blue: 205/255, alpha: 1)
let boardBorderColor: UIColor = UIColor(red: 14/255, green: 70/255, blue: 163/255, alpha: 1)
let boardButtonColor: UIColor = UIColor(red: 14/255, green: 70/255, blue: 163/255, alpha: 1)
let boardTintColor: UIColor = UIColor(red: 14/255, green: 70/255, blue: 163/255, alpha: 1)

struct ContentView: View {
    @State private var currentScene: SKScene?
    @State var dialogEngine = DialogEngine()
    
    var body: some View {
        ZStack {
            if let scene = currentScene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            } else {
                SpriteView(scene: createTitleScene())
                    .ignoresSafeArea()
            }
            
            VStack {
                Spacer()
                
                DialogBoxView(dialogEngine: dialogEngine)
            }
        }
        .onAppear {
            setupScene()
            MusicManager.shared.startLoop(filename: "sakartvelo-nocturne-piano-music-334365.mp3")
        }
    }
    
    func setupScene() {
        let title = Titlepage(size: CGSize(width: 1024, height: 768))
        title.dialogEngine = dialogEngine
        title.scaleMode = .aspectFill
        currentScene = title
    }
    
    func createTitleScene() -> SKScene {
        let scene = Titlepage(size: CGSize(width: 1024, height: 768))
        scene.dialogEngine = dialogEngine
        scene.scaleMode = .aspectFill
        return scene
    }
}


#Preview {
    ContentView()
}
