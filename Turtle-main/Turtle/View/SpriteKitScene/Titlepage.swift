import SpriteKit

class Titlepage: SKScene {

    var dialogEngine: DialogEngine!
    var showOceanBookButton: Bool = false
    var lastPhotoTexture: SKTexture?

    private let backgroundName = "title page"

    private var backgroundNode: SKSpriteNode!
    private var panelNode: SKShapeNode!
    private var titleLabel: SKLabelNode!
    private var subtitleLabel: SKLabelNode!
    private var oceanBookButton: SKNode?

    override func didMove(to view: SKView) {
        setupBackground()
        setupPanel()
        if showOceanBookButton {
            setupOceanBookButton()
        }
    }

    private func setupBackground() {
        let tex = SKTexture(imageNamed: backgroundName)
        backgroundNode = SKSpriteNode(texture: tex)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.zPosition = -1
        let scale = max(size.width / tex.size().width,
                        size.height / tex.size().height)
        backgroundNode.setScale(scale)
        addChild(backgroundNode)
    }

    private func setupPanel() {
        let panelWidth = size.width * 0.55
        let panelHeight = size.height * 0.3
        let rectSize = CGSize(width: panelWidth, height: panelHeight)

        let panel = SKShapeNode(rectOf: rectSize, cornerRadius: 28)
        panel.fillColor = boardBackgroundColor
        panel.strokeColor = boardBorderColor
        panel.lineWidth = 4
        panel.zPosition = 10
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.5)

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.text = "Turtle"
        title.fontSize = 80
        title.fontColor = boardTintColor
        title.horizontalAlignmentMode = .center
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: panelHeight * 0.1)
        panel.addChild(title)
        titleLabel = title

        let subtitle = SKLabelNode(fontNamed: "Menlo-Bold")
        subtitle.text = "(Press anywhere to start...)"
        subtitle.fontSize = 20
        subtitle.fontColor = SKColor.black
        subtitle.horizontalAlignmentMode = .center
        subtitle.verticalAlignmentMode = .center
        subtitle.position = CGPoint(x: 0, y: -panelHeight * 0.12)
        panel.addChild(subtitle)
        subtitleLabel = subtitle

        addChild(panel)
        panelNode = panel
    }

    private func setupOceanBookButton() {
        oceanBookButton?.removeFromParent()

        let button = SKNode()
        button.zPosition = 20
        button.name = "oceanBookButton"

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "📖 Ocean Book"
        label.fontSize = 20
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center

        let paddingX: CGFloat = 28
        let paddingY: CGFloat = 12
        let bubbleSize = CGSize(width: label.frame.width + paddingX,
                                height: label.frame.height + paddingY)

        let rect = SKShapeNode(rectOf: bubbleSize, cornerRadius: 18)
        rect.fillColor = SKColor.white.withAlphaComponent(0.25)
        rect.strokeColor = .black
        rect.lineWidth = 2
        rect.zPosition = -1

        button.addChild(rect)
        button.addChild(label)

        button.position = CGPoint(x: size.width / 2,
                                  y: size.height * 0.3)
        addChild(button)
        oceanBookButton = button
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        _ = touch.location(in: self)

        if let button = oceanBookButton,
           button.contains(touch.location(in: button.parent ?? self)) {
            let book = PictureBookScene(size: size)
            book.scaleMode = scaleMode
            book.fromTitlepage = true
            book.endPhotoTexture = lastPhotoTexture
            view?.presentScene(book, transition: .fade(withDuration: 0.6))
            return
        }

        let beach = BeachScene(size: size)
        beach.dialogEngine = dialogEngine
        beach.scaleMode = scaleMode
        view?.presentScene(beach, transition: .fade(withDuration: 0.6))
    }
}



import SwiftUI
#Preview {
    SpriteView(scene: Titlepage(size: CGSize(width: 1024, height: 768)))
        .ignoresSafeArea()
}
