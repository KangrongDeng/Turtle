import SpriteKit

class OceanScene2: SKScene {

    var dialogEngine: DialogEngine!
    let trappedCharacter: any Character = MantaRayTrapped()
    let freedCharacter: any Character = MantaRayFreed()
    let cleanedCharacter: any Character = MantaRayCleaned()
    
    private let backgroundName = "Manta Ray habitat"
    private let mantaRayName = "Manta Ray"
    private let netNames = ["net1", "net2", "net3"]
    private let knotName = "knot"
    private let cleanFishName = "clean fish"
    private let cleanStationName = "clean station"
    private let riverName = "river"

   
    private var backgroundNode: SKSpriteNode!
    private var turtle: SKSpriteNode!
    private var mantaRay: SKSpriteNode!
    private var netNode: SKSpriteNode!
    private var knotNodes: [SKSpriteNode] = []
    private var hintLabels: [SKLabelNode] = []
    private var backgroundSwimmers: [SKSpriteNode] = []
    private var cleanStations: [SKSpriteNode] = []
   
    private var cleanButton: SKLabelNode?
    private var riverNode: SKSpriteNode?

   
    private var currentNetIndex = 0
    private var knotsVisible = false
    private var knotsUntied = [false, false, false]
    private var isDraggingKnot = false
    private var draggedKnotIndex: Int?
    private var knotStartPositions: [CGPoint] = []
    private var knotDragDistances: [CGFloat] = [0, 0, 0]
    private let knotDragThreshold: CGFloat = 150
    private let mantaRayTriggerDistance: CGFloat = 100
    private var mantaFreed = false
    private var isDraggingManta = false
    private var hasGoneToOcean3 = false
    private var hasTalkedToManta = false
    private var mantaCleaned = false
    private var touchBeganOnMantaRay = false
    private var touchStartLocation: CGPoint = CGPoint.zero
    private let dragThreshold: CGFloat = 15


    private var narratorNode: SKNode?
    private var narratorLabel: SKLabelNode?
    private var narratorHistory: [String] = []
    private var hasShownDragKnotNarration = false
    private var hasShownGoCoralNarration = false
    private var hasShownCleanButtonNarration = false
    private var tipsButtonNode: SKNode?
    private var logButtonNode: SKNode?
    private var tipsGuideNode: SKNode?


    private var historyPanelNode: SKNode?
    private var historyContentNode: SKNode?
    private var historyCloseLabel: SKLabelNode?
    private var historyMinContentY: CGFloat = 0
    private var historyMaxContentY: CGFloat = 0
    private var isDraggingHistory: Bool = false
    private var lastHistoryTouchY: CGFloat = 0

    override func didMove(to view: SKView) {
        setupBackground()
        setupTurtle()
        setupMantaRay()
        setupNet()
        setupBackgroundSwimmers()
        setupCleanStations()
        addChild(ProgressNode(sceneSize: size, stage: .mantaRay))

        setupTipsButton()
        startInitialNarration()
    }

    private func setupBackground() {
        let bg = SKSpriteNode(imageNamed: backgroundName)
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        bg.setScale(max(size.width / bg.size.width,
                        size.height / bg.size.height))
        addChild(bg)
        backgroundNode = bg
    }


    private func setupBackgroundSwimmers() {
        let creatureNames = ["clean fish", "turtle"]

            for _ in 0..<40 {
                let name = creatureNames.randomElement()!
                let creature = SKSpriteNode(imageNamed: name)

                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: size.height * 0.3...size.height * 0.9)
                creature.position = CGPoint(x: x, y: y)
                creature.zPosition = -5
                creature.alpha = 0.9
                creature.setScale(CGFloat.random(in: 0.02...0.06))
                addChild(creature)

                let direction: CGFloat = Bool.random() ? 1 : -1
                creature.xScale *= direction

           
                let move = SKAction.moveBy(x: 120 * direction, y: CGFloat.random(in: -20...20), duration: 6)
                let moveBack = move.reversed()
                let loop = SKAction.repeatForever(SKAction.sequence([move, moveBack]))
                creature.run(loop)
            }
    }


    private func showNarrator(text: String) {
 
        narratorHistory.append(text)

        narratorNode?.removeFromParent()
        narratorNode = nil
        narratorLabel = nil

        let container = SKNode()
        container.zPosition = 60

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.fontSize = 22
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = size.width * 0.7
        label.position = CGPoint.zero

        label.text = text

        let paddingX: CGFloat = 40
        let paddingY: CGFloat = 20
        let bubbleSize = CGSize(width: label.frame.width + paddingX,
                                height: label.frame.height + paddingY)

        let rect = SKShapeNode(rectOf: bubbleSize, cornerRadius: 24)
        rect.fillColor = SKColor.white.withAlphaComponent(0.7)
        rect.strokeColor = SKColor.white.withAlphaComponent(0.8)
        rect.lineWidth = 2
        rect.zPosition = -1

        container.addChild(rect)
        container.addChild(label)

        container.position = CGPoint(x: size.width / 2,
                                     y: size.height * 0.8)

        addChild(container)
        narratorNode = container
        narratorLabel = label

        animateNarratorText(text)
    }

    private func animateNarratorText(_ text: String) {
        guard let label = narratorLabel else { return }
        label.removeAllActions()
        label.text = ""

        let characters = Array(text)
        var actions: [SKAction] = []

        for ch in characters {
            let append = SKAction.run { [weak label] in
                guard let label = label else { return }
                label.text = (label.text ?? "") + String(ch)
            }
            let wait = SKAction.wait(forDuration: 0.03)
            actions.append(append)
            actions.append(wait)
        }

        label.run(SKAction.sequence(actions))
    }

    private func startInitialNarration() {
        let text1 = "The Manta Ray seems to be in trouble."
        let text2 = "Tap the Manta Ray to get a clue."

        showNarrator(text: text1)

        let charInterval: TimeInterval = 0.03
        let duration1 = Double(text1.count) * charInterval

        run(SKAction.sequence([
            SKAction.wait(forDuration: duration1 + 1.0),
            SKAction.run { [weak self] in
                self?.showNarrator(text: text2)
            }
        ]))
    }


    private func createTopButton(title: String) -> (node: SKNode, width: CGFloat) {
        let container = SKNode()
        container.zPosition = 70

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = title
        label.fontSize = 20
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center

        let paddingX: CGFloat = 24
        let paddingY: CGFloat = 12
        let bubbleSize = CGSize(width: label.frame.width + paddingX,
                                height: label.frame.height + paddingY)

        let rect = SKShapeNode(rectOf: bubbleSize, cornerRadius: 18)
        rect.fillColor = SKColor.white.withAlphaComponent(0.25)
        rect.strokeColor = SKColor.black
        rect.lineWidth = 2
        rect.zPosition = -1

        container.addChild(rect)
        container.addChild(label)

        return (container, bubbleSize.width)
    }

    private func showHistoryPanel() {
        guard historyPanelNode == nil else { return }

        let result = History.createHistoryPanel(
            sceneSize: size,
            entries: narratorHistory
        )

        historyPanelNode = result.container
        historyContentNode = result.contentNode
        historyCloseLabel = result.closeLabel
        historyMinContentY = result.minContentY
        historyMaxContentY = result.maxContentY

        if let panel = historyPanelNode {
            addChild(panel)
        }
    }

    private func hideHistoryPanel() {
        historyPanelNode?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.15),
            SKAction.removeFromParent()
        ]))
        historyPanelNode = nil
        historyContentNode = nil
        historyCloseLabel = nil
        isDraggingHistory = false
    }


    private func setupTipsButton() {
        tipsButtonNode?.removeFromParent()
        logButtonNode?.removeFromParent()

 
        let (tipsNode, tipsWidth) = createTopButton(title: "💡 Tips")
        tipsNode.name = "tips_button"


        let (logNode, logWidth) = createTopButton(title: "📜 Log")
        logNode.name = "log_button"

        let tipsPosition = CGPoint(x: size.width * 0.9,
                                   y: size.height * 0.9)
        tipsNode.position = tipsPosition

        let spacing: CGFloat = 16
        let distance = (tipsWidth + logWidth) / 2 + spacing
        logNode.position = CGPoint(x: tipsPosition.x - distance,
                                   y: tipsPosition.y)

        addChild(logNode)
        addChild(tipsNode)

        tipsButtonNode = tipsNode
        logButtonNode = logNode
    }


    private func clearTipsGuide() {
        tipsGuideNode?.removeAllActions()
        tipsGuideNode?.removeFromParent()
        tipsGuideNode = nil
    }

    private func handleTipsTap() {
        clearTipsGuide()


        if knotsVisible, !mantaFreed {
            showKnotTips()
            return
        }

        if mantaFreed, !mantaCleaned {
            if !isMantaNearCleanStation() {
                showMantaToCoralTips()
            } else if let button = cleanButton, button.alpha > 0.5 {

                showCleanButtonTips()
            }
            return
        }

        if mantaCleaned {
            showExitTips()
        }
    }

    private func isMantaNearCleanStation() -> Bool {
        guard !cleanStations.isEmpty else { return false }
        for station in cleanStations {
            let d = hypot(mantaRay.position.x - station.position.x,
                          mantaRay.position.y - station.position.y)
            if d < 60 { return true }
        }
        return false
    }


    private func showKnotTips() {
        guard knotsVisible else { return }

        var targetIndex: Int?
        for (index, knot) in knotNodes.enumerated() {
            if index < knotsUntied.count,
               !knotsUntied[index],
               knot.parent != nil {
                targetIndex = index
                break
            }
        }
        guard let index = targetIndex else { return }

        let start = knotStartPositions[index]

        var dir = CGPoint(x: 1, y: 0)
        if index < hintLabels.count {
            let hintPos = hintLabels[index].position
            let vx = hintPos.x - start.x
            let vy = hintPos.y - start.y
            let len = hypot(vx, vy)
            if len > 0.001 {
                dir = CGPoint(x: vx / len, y: vy / len)
            }
        }

        let dragLength: CGFloat = 80
        let end = CGPoint(x: start.x + dir.x * dragLength,
                          y: start.y + dir.y * dragLength)

        let container = SKNode()
        container.zPosition = 80
        addChild(container)
        tipsGuideNode = container

        let finger = SKLabelNode(fontNamed: "Menlo-Bold")
        finger.text = "👆"
        finger.fontSize = 40
        finger.verticalAlignmentMode = .center
        finger.horizontalAlignmentMode = .center
        finger.position = start
        container.addChild(finger)

        let trailParent = SKNode()
        trailParent.zPosition = 79
        container.addChild(trailParent)

        let moveForward = SKAction.move(to: end, duration: 0.6)
        let moveBack = SKAction.move(to: start, duration: 0.6)
        let seq = SKAction.sequence([moveForward, moveBack])
        finger.run(SKAction.repeatForever(seq))

        let spawnTrail = SKAction.run { [weak trailParent, weak finger] in
            guard let parent = trailParent, let f = finger else { return }
            let dot = SKShapeNode(circleOfRadius: 6)
            dot.fillColor = SKColor.white.withAlphaComponent(0.7)
            dot.strokeColor = SKColor.clear
            dot.position = f.position
            parent.addChild(dot)
            dot.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.4),
                SKAction.removeFromParent()
            ]))
        }
        let trailLoop = SKAction.repeatForever(SKAction.sequence([
            spawnTrail,
            SKAction.wait(forDuration: 0.08)
        ]))
        container.run(trailLoop)
    }

    private func showMantaToCoralTips() {
        guard !cleanStations.isEmpty else { return }

        var bestStation: SKSpriteNode?
        var minDist = CGFloat.greatestFiniteMagnitude
        for station in cleanStations {
            let d = hypot(mantaRay.position.x - station.position.x,
                          mantaRay.position.y - station.position.y)
            if d < minDist {
                minDist = d
                bestStation = station
            }
        }
        guard let station = bestStation else { return }

        let start = mantaRay.position
        let end = station.position

        let container = SKNode()
        container.zPosition = 80
        addChild(container)
        tipsGuideNode = container

        let finger = SKLabelNode(fontNamed: "Menlo-Bold")
        finger.text = "👆"
        finger.fontSize = 40
        finger.verticalAlignmentMode = .center
        finger.horizontalAlignmentMode = .center
        finger.position = start
        container.addChild(finger)

        let trailParent = SKNode()
        trailParent.zPosition = 79
        container.addChild(trailParent)

        let moveForward = SKAction.move(to: end, duration: 0.8)
        let moveBack = SKAction.move(to: start, duration: 0.8)
        let seq = SKAction.sequence([moveForward, moveBack])
        finger.run(SKAction.repeatForever(seq))

        let spawnTrail = SKAction.run { [weak trailParent, weak finger] in
            guard let parent = trailParent, let f = finger else { return }
            let dot = SKShapeNode(circleOfRadius: 6)
            dot.fillColor = SKColor.white.withAlphaComponent(0.7)
            dot.strokeColor = SKColor.clear
            dot.position = f.position
            parent.addChild(dot)
            dot.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.4),
                SKAction.removeFromParent()
            ]))
        }
        let trailLoop = SKAction.repeatForever(SKAction.sequence([
            spawnTrail,
            SKAction.wait(forDuration: 0.08)
        ]))
        container.run(trailLoop)
    }

    private func showCleanButtonTips() {
        guard let button = cleanButton else { return }

        let container = SKNode()
        container.position = button.position
        container.zPosition = 80
        addChild(container)
        tipsGuideNode = container

        let finger = SKLabelNode(fontNamed: "Menlo-Bold")
        finger.text = "👆"
        finger.fontSize = 40
        finger.verticalAlignmentMode = .center
        finger.horizontalAlignmentMode = .center
        finger.position = CGPoint(x: 0, y: -10)
        container.addChild(finger)

        let spawnRipple = SKAction.run { [weak container] in
            guard let parent = container else { return }
            let circle = SKShapeNode(circleOfRadius: 20)
            circle.position = CGPoint.zero
            circle.strokeColor = SKColor.white.withAlphaComponent(0.9)
            circle.lineWidth = 3
            circle.fillColor = .clear
            circle.alpha = 0.7
            circle.zPosition = -1
            parent.addChild(circle)

            let scaleUp = SKAction.scale(to: 3.0, duration: 1.0)
            let fadeOut = SKAction.fadeOut(withDuration: 1.0)
            let group = SKAction.group([scaleUp, fadeOut])
            let remove = SKAction.removeFromParent()
            circle.run(SKAction.sequence([group, remove]))
        }

        let rippleLoop = SKAction.repeatForever(SKAction.sequence([
            spawnRipple,
            SKAction.wait(forDuration: 0.4)
        ]))
        container.run(rippleLoop)
    }

    private func showExitTips() {
        let exitPosition: CGPoint
        if let river = riverNode {
            let w = river.size.width * river.xScale
            let h = river.size.height * river.yScale
            exitPosition = CGPoint(x: river.position.x + w * 0.5,
                                   y: river.position.y + h * 0.5)
        } else {
            exitPosition = CGPoint(x: size.width * 0.15, y: size.height * 0.12)
        }

        let container = SKNode()
        container.zPosition = 80
        addChild(container)
        tipsGuideNode = container

        let finger = SKLabelNode(fontNamed: "Menlo-Bold")
        finger.text = "👆"
        finger.fontSize = 40
        finger.verticalAlignmentMode = .center
        finger.horizontalAlignmentMode = .center
        finger.position = CGPoint(x: exitPosition.x,
                                  y: exitPosition.y + 0)
        container.addChild(finger)

        let up = SKAction.moveBy(x: 0, y: 10, duration: 0.4)
        let down = SKAction.moveBy(x: 0, y: -10, duration: 0.4)
        finger.run(SKAction.repeatForever(SKAction.sequence([up, down])))
    }

    private func setupCleanStations() {
        let base = CGPoint(x: size.width * 0.8, y: size.height * 0.2)
        let offsets: [CGPoint] = [
            .zero,
            CGPoint(x: -50, y: 10),
            CGPoint(x: 50, y: -5)
        ]
        for offset in offsets {
            let station = SKSpriteNode(imageNamed: cleanStationName)
            station.position = CGPoint(x: base.x + offset.x, y: base.y + offset.y)
            station.zPosition = -2
            station.setScale(0.25)
            addChild(station)
            cleanStations.append(station)
        }
    }

    private func setupTurtle() {
        turtle = SKSpriteNode(imageNamed: "baby_turtle")
        turtle.name = "baby_turtle"
        turtle.setScale(0.35)
        turtle.position = CGPoint(x: size.width * 0.3,
                                  y: size.height * 0.4)
        turtle.zPosition = 5
        addChild(turtle)
    }

    private func moveTurtle(to position: CGPoint) {
        turtle.removeAllActions()
        let dx = position.x - turtle.position.x
        turtle.xScale = abs(turtle.xScale) * (dx >= 0 ? 1 : -1)
        let distance = hypot(dx, position.y - turtle.position.y)
        let speed: CGFloat = 200
        let duration = TimeInterval(distance / speed)
        let move = SKAction.move(to: position, duration: duration)
        move.timingMode = .easeInEaseOut
        turtle.run(move)
    }

    private func setupMantaRay() {
        mantaRay = SKSpriteNode(imageNamed: mantaRayName)
        mantaRay.name = "mantaRay"
        mantaRay.position = CGPoint(x: size.width * 0.6,
                                    y: size.height * 0.5)
        mantaRay.zPosition = 1
        mantaRay.setScale(0.3)
        addChild(mantaRay)

        startMantaPreWiggle()
    }

    private func startMantaPreWiggle() {
        let wiggle = SKAction.sequence([
            SKAction.rotate(byAngle: 0.04, duration: 0.15),
            SKAction.rotate(byAngle: -0.08, duration: 0.15),
            SKAction.rotate(byAngle: 0.04, duration: 0.15),
            SKAction.rotate(toAngle: 0, duration: 0.12)
        ])
        let repeatWiggle = SKAction.repeatForever(wiggle)
        mantaRay.run(repeatWiggle, withKey: "mantaPreWiggle")
    }

    private func stopMantaPreWiggle() {
        mantaRay.removeAction(forKey: "mantaPreWiggle")
        mantaRay.run(SKAction.rotate(toAngle: 0, duration: 0.2))
    }

    private func setupNet() {
        netNode = SKSpriteNode(imageNamed: netNames[0])
        netNode.position = mantaRay.position
        netNode.zPosition = 2
        netNode.setScale(mantaRay.xScale)
        addChild(netNode)
    }

    private func updateNet() {
        guard currentNetIndex < netNames.count else { return }
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let changeTexture = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.netNode.texture = SKTexture(imageNamed: self.netNames[self.currentNetIndex])
            self.netNode.alpha = 0
        }
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        netNode.run(SKAction.sequence([fadeOut, changeTexture, fadeIn]))
    }

    private func showKnots() {
        guard !knotsVisible else { return }
        knotsVisible = true

        let offsets: [CGPoint] = [
            CGPoint(x: -mantaRay.size.width * 0.3, y: mantaRay.size.height * 0.2),
            CGPoint(x: mantaRay.size.width * 0.2, y: -mantaRay.size.height * 0.15),
            CGPoint(x: -mantaRay.size.width * 0.1, y: -mantaRay.size.height * 0.3)
        ]

        let directions: [CGPoint] = [
            CGPoint(x: 1, y: 0),
            CGPoint(x: -1, y: 0),
            CGPoint(x: 0, y: 1)
        ]

        for (index, offset) in offsets.enumerated() {
            if knotsUntied[index] { continue }

            let knot = SKSpriteNode(imageNamed: knotName)
            let worldPos = CGPoint(x: mantaRay.position.x + offset.x,
                                  y: mantaRay.position.y + offset.y)
            knot.position = worldPos
            knot.zPosition = 3
            knot.setScale(0.07)
            knot.name = "knot\(index)"
            addChild(knot)
            knotNodes.append(knot)
            knotStartPositions.append(worldPos)
            knotDragDistances[index] = 0

   
            let hint = SKLabelNode(text: directionText(for: directions[index]))
            hint.fontName = "Helvetica-Bold"
            hint.fontSize = 32
            hint.fontColor = .yellow
            hint.zPosition = 4
            hint.position = CGPoint(x: worldPos.x + directions[index].x * 40,
                                   y: worldPos.y + directions[index].y * 40)
            hint.alpha = 0
            addChild(hint)
            hintLabels.append(hint)
            hint.run(SKAction.fadeIn(withDuration: 0.3))
        }
    }

    private func directionText(for direction: CGPoint) -> String {
        if direction.x > 0 { return "→" }
        if direction.x < 0 { return "←" }
        if direction.y > 0 { return "↑" }
        if direction.y < 0 { return "↓" }
        return "?"
    }

    private func untieKnot(at index: Int) {
        guard index < knotNodes.count, !knotsUntied[index] else { return }
        knotsUntied[index] = true

        let knot = knotNodes[index]
        let fade = SKAction.fadeOut(withDuration: 0.3)
        let scale = SKAction.scale(to: 0.1, duration: 0.3)
        knot.run(SKAction.sequence([.group([fade, scale]), .removeFromParent()]))

        if index < hintLabels.count {
            hintLabels[index].run(SKAction.fadeOut(withDuration: 0.3))
        }

        clearTipsGuide()

        currentNetIndex += 1
        if currentNetIndex < netNames.count {
            updateNet()
        } else {
            netNode.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.4),
                .removeFromParent()
            ]))
            animateMantaRay()
        }
    }

    private func animateMantaRay() {
        stopMantaPreWiggle()

        let wiggle = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 15, duration: 0.2),
            SKAction.moveBy(x: 0, y: -15, duration: 0.2),
            SKAction.moveBy(x: 10, y: 0, duration: 0.15),
            SKAction.moveBy(x: -10, y: 0, duration: 0.15)
        ])
        mantaRay.run(wiggle)

        dialogEngine?.endConversation()
        mantaFreed = true
        setupRiver()
        setupCleanButton()

        if !hasShownGoCoralNarration {
            hasShownGoCoralNarration = true
            showNarrator(text: "Drag the Manta Ray to the coral reef to clean its body（Tap the Manta Ray to get a clue.）")
        }
    }


    private func setupRiver() {
        let river = SKSpriteNode(imageNamed: riverName)
        river.anchorPoint = CGPoint(x: 0, y: 0)
        river.position = CGPoint(x: size.width * 0.02, y: size.height * 0.02)
        river.zPosition = -3
        river.setScale(0.35)
        river.alpha = 0.8
        addChild(river)
        riverNode = river
    }

    private func setupCleanButton() {
        let button = SKLabelNode(text: "clean")
        button.fontName = "Helvetica-Bold"
        button.fontSize = 30
        button.fontColor = .yellow
        button.zPosition = 6
        button.alpha = 0
        addChild(button)
        cleanButton = button
    }

    override func update(_ currentTime: TimeInterval) {
        if mantaFreed, let button = cleanButton {
            var nearStation = false
            for station in cleanStations {
                let d = hypot(mantaRay.position.x - station.position.x,
                              mantaRay.position.y - station.position.y)
                if d < 60 {
                    nearStation = true
                    break
                }
            }
            let targetAlpha: CGFloat = nearStation ? 1 : 0
            if button.alpha != targetAlpha {
                button.run(SKAction.fadeAlpha(to: targetAlpha, duration: 0.2))
            }

            if nearStation, !hasShownCleanButtonNarration {
                hasShownCleanButtonNarration = true
                showNarrator(text: "Tap the clean button（Tap the Manta Ray to get a clue.）")
            }

            button.position = CGPoint(x: mantaRay.position.x,
                                      y: mantaRay.position.y + mantaRay.size.height * -0.8)
        }


        if mantaCleaned, !hasGoneToOcean3, let river = riverNode {
            if turtle.position.x < river.position.x + river.size.width * river.xScale + 40,
               turtle.position.y > river.position.y + river.size.height * river.yScale * 0.6 {
                goToOceanScene3()
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)


        if let historyPanel = historyPanelNode {
            let pLoc = touch.location(in: historyPanel)

            if let close = historyCloseLabel, close.contains(pLoc) {
                hideHistoryPanel()
                return
            }

            isDraggingHistory = true
            lastHistoryTouchY = location.y
            return
        }

  
        if let log = logButtonNode, log.contains(location) {
            showHistoryPanel()
            return
        }


        if let tips = tipsButtonNode, tips.contains(location) {
            handleTipsTap()
            return
        }

    
        if mantaFreed {
            if let button = cleanButton,
               button.alpha > 0.5,
               button.contains(location) {
                startCleaningAnimation()
                return
            }
            if mantaRay.contains(location) {
                touchBeganOnMantaRay = true
                touchStartLocation = location
                return
            }
        }


        if knotsVisible {
            let knotHitRadius: CGFloat = 80
            for (index, knot) in knotNodes.enumerated() {
                guard index < knotsUntied.count, !knotsUntied[index], knot.parent != nil else { continue }
                let inFrame = knot.contains(location)
                let inRadius = hypot(location.x - knot.position.x, location.y - knot.position.y) < knotHitRadius
                if inFrame || inRadius {
                    isDraggingKnot = true
                    draggedKnotIndex = index
                    clearTipsGuide()
                    return
                }
            }
        }

    
        let nodesAtPoint = nodes(at: location)
        for node in nodesAtPoint {
            if node.name == "mantaRay" {
                guard let dialogEngine = dialogEngine else { return }
                if !mantaFreed {
                    dialogEngine.talkTo(trappedCharacter)
                    hasTalkedToManta = true
                    if !knotsVisible {
                        showKnots()
                    }

                    if !hasShownDragKnotNarration {
                        hasShownDragKnotNarration = true
                        showNarrator(text: "Drag the knot（Tap the Manta Ray to get a clue.）")
                    }
                    return
                }
 
                return
            }
        }

      
        moveTurtle(to: location)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

 
        if let _ = historyPanelNode, isDraggingHistory, let historyContent = historyContentNode {
            let currentY = touch.location(in: self).y
            let dy = currentY - lastHistoryTouchY
            lastHistoryTouchY = currentY

            var newY = historyContent.position.y + dy
            newY = max(historyMinContentY, min(historyMaxContentY, newY))
            historyContent.position.y = newY
            return
        }


        if touchBeganOnMantaRay, !isDraggingManta {
            let current = touch.location(in: self)
            let dist = hypot(current.x - touchStartLocation.x, current.y - touchStartLocation.y)
            if dist > dragThreshold {
                isDraggingManta = true
                clearTipsGuide()
            }
        }

        if isDraggingManta {
            var pos = touch.location(in: self)
            let halfW = mantaRay.size.width * 0.5
            let halfH = mantaRay.size.height * 0.5
            pos.x = max(halfW, min(size.width - halfW, pos.x))
            pos.y = max(halfH, min(size.height - halfH, pos.y))
            mantaRay.position = pos
            netNode?.position = pos
            return
        }

        guard isDraggingKnot, let index = draggedKnotIndex,
              index < knotNodes.count else { return }

        let current = touch.location(in: self)
        let previous = touch.previousLocation(in: self)
        let dx = current.x - previous.x
        let dy = current.y - previous.y

        let knot = knotNodes[index]
        knot.position.x += dx
        knot.position.y += dy

        let movedDistance = hypot(knot.position.x - knotStartPositions[index].x,
                                  knot.position.y - knotStartPositions[index].y)
        knotDragDistances[index] = movedDistance

        if movedDistance >= knotDragThreshold {
            untieKnot(at: index)
            isDraggingKnot = false
            draggedKnotIndex = nil
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchBeganOnMantaRay, !isDraggingManta, let dialogEngine = dialogEngine {
            if mantaCleaned {
                dialogEngine.talkTo(cleanedCharacter)
            } else if mantaFreed {
                dialogEngine.talkTo(freedCharacter)
            }
        }
        touchBeganOnMantaRay = false
        isDraggingKnot = false
        draggedKnotIndex = nil
        isDraggingManta = false
        isDraggingHistory = false
    }


    private func startCleaningAnimation() {
  
        for i in 0..<6 {
            let fish = SKSpriteNode(imageNamed: cleanFishName)
            let angle = CGFloat(i) / 4.0 * .pi * 2
            let radius = mantaRay.size.width * 0.3
            let startPos = CGPoint(x: mantaRay.position.x + cos(angle) * radius,
                                   y: mantaRay.position.y + sin(angle) * radius)
            fish.position = startPos
            fish.zPosition = mantaRay.zPosition + 1
            fish.setScale(0.07)
            addChild(fish)

            let circle = SKAction.sequence([
                SKAction.moveBy(x: 10, y: 0, duration: 0.15),
                SKAction.moveBy(x: -20, y: 0, duration: 0.3),
                SKAction.moveBy(x: 10, y: 0, duration: 0.15)
            ])
            let repeatClean = SKAction.repeat(circle, count: 3)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            fish.run(SKAction.sequence([repeatClean, fadeOut, .removeFromParent()]))
        }
        

        mantaCleaned = true

        dialogEngine?.endConversation()
    
        cleanButton?.run(SKAction.fadeOut(withDuration: 0.3))
        showExitGlow()

    
        clearTipsGuide()


        showNarrator(text: "Tap the Manta Ray to get a clue.")
    }


    private func showExitGlow() {
        if childNode(withName: "exitGlowPulse") != nil { return }

        let glowNode = SKNode()
        glowNode.name = "exitGlowPulse"
        addChild(glowNode)

        let exitPosition: CGPoint
        if let river = riverNode {
            let w = river.size.width * river.xScale
            let h = river.size.height * river.yScale
            exitPosition = CGPoint(x: river.position.x + w * 0.5, y: river.position.y + h * 0.5)
        } else {
            exitPosition = CGPoint(x: size.width * 0.15, y: size.height * 0.12)
        }

        let spawnCircle = SKAction.run { [weak self] in
            guard self != nil else { return }
            let circle = SKShapeNode(circleOfRadius: 20)
            circle.position = exitPosition
            circle.strokeColor = SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
            circle.lineWidth = 4
            circle.fillColor = .clear
            circle.alpha = 0.6
            circle.zPosition = 5
            glowNode.addChild(circle)

            let scaleUp = SKAction.scale(to: 4.0, duration: 1.2)
            let fadeOut = SKAction.fadeOut(withDuration: 1.2)
            let group = SKAction.group([scaleUp, fadeOut])
            let remove = SKAction.removeFromParent()
            circle.run(SKAction.sequence([group, remove]))
        }

        let wait = SKAction.wait(forDuration: 0.4)
        let sequence = SKAction.sequence([spawnCircle, wait])
        glowNode.run(SKAction.repeatForever(sequence))
    }

    private func goToOceanScene3() {
        guard !hasGoneToOcean3 else { return }
        hasGoneToOcean3 = true
        dialogEngine?.endConversation()
        let scene = OceanScene3(size: size)
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: .fade(withDuration: 0.8))
    }
}

import SwiftUI
#Preview {
    let scene = OceanScene2(size: CGSize(width: 1024, height: 768))
    let dialogEngine = DialogEngine()
    scene.dialogEngine = dialogEngine
    
    return ZStack {
        SpriteView(scene: scene)
            .ignoresSafeArea()
        VStack {
            Spacer()
            
            DialogBoxView(dialogEngine: dialogEngine)
        }
    }
}
