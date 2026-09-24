import SpriteKit

enum ProgressStage: Int, CaseIterable {
    case egg = 0
    case seahorse = 1
    case mantaRay = 2
    case motherTurtle = 3
    case home = 4
}


class ProgressNode: SKNode {

    private let iconNames = ["egg", "seahorse", "Manta Ray", "mother_turtle", "home"]
    private let iconSizeMultipliers: [CGFloat] = [0.65, 0.65, 1.25, 1.0, 1.0]
    private var iconNodes: [SKSpriteNode] = []
    private var currentStage: ProgressStage

    init(sceneSize: CGSize, stage: ProgressStage) {
        self.currentStage = stage
        super.init()

        name = "progressNode"
        zPosition = 200

        let baseSize: CGFloat = min(sceneSize.width, sceneSize.height) * 0.055
        let spacing: CGFloat = baseSize * 0.6
        let padding: CGFloat = baseSize * 0.8
        let cellStep = baseSize + spacing
        var x = padding + baseSize / 2 + spacing / 2
        let y = sceneSize.height - padding - baseSize / 2

        for (index, imageName) in iconNames.enumerated() {
            let node = SKSpriteNode(imageNamed: imageName)
            let mult = index < iconSizeMultipliers.count ? iconSizeMultipliers[index] : 1.0
            let iconSize = baseSize * mult
            let texW = max(node.size.width, 1)
            let scale = iconSize / texW
            node.setScale(scale)
            node.position = CGPoint(x: x, y: y)
            node.zPosition = 1
            iconNodes.append(node)
            applyStage(to: node, index: index)
            addChild(node)
            x += cellStep
        }
    }

    private func applyStage(to node: SKSpriteNode, index: Int) {
        if index <= currentStage.rawValue {
            node.colorBlendFactor = 0
            node.alpha = 1.0
        } else {
            node.colorBlendFactor = 1.0
            node.color = .black
            node.alpha = 0.9
        }
    }


    func updateStage(_ stage: ProgressStage) {
        currentStage = stage
        for (index, node) in iconNodes.enumerated() {
            applyStage(to: node, index: index)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
