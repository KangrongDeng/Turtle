import SpriteKit

class Passage1Scene: SKScene {

    var dialogEngine: DialogEngine!
    
    private var turtle: SKSpriteNode!
    private var garbageNodes: [SKSpriteNode] = []
    private var hintLabel: SKLabelNode!

    private var cleanedCount = 0
    private let totalGarbage = 4
    private var canLeave = false
    private var hasGoneToOcean2 = false

   
    private var introPanel: SKShapeNode?
    private var introTextLabel: SKLabelNode?
    private var introNextLabel: SKLabelNode?
    private var introBackLabel: SKLabelNode?
    private var introPageIndex: Int = 0
    private var canCleanGarbage: Bool = false

  
    private var finishPanel: SKShapeNode?
    private var finishTextLabel: SKLabelNode?
    private var finishOkLabel: SKLabelNode?
    private var exitGlowEmitter: SKEmitterNode?

 
    private var narratorNode: SKNode?
    private var narratorLabel: SKLabelNode?
    private var narratorHistory: [String] = []
    private var tipsButtonNode: SKNode?
    private var logButtonNode: SKNode?
    private var garbageTipsNode: SKNode?


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
        setupGarbage()
        setupHintLabel()
        addChild(ProgressNode(sceneSize: size, stage: .seahorse))


        setupTipsButton()

   
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run { [weak self] in
                self?.showIntro(page: 0)
            }
        ]))
    }

    private func setupBackground() {
        let bg = SKSpriteNode(imageNamed: "passage1")
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        bg.setScale(max(size.width / bg.size.width,
                        size.height / bg.size.height))
        addChild(bg)
    }

    private func setupTurtle() {
        turtle = SKSpriteNode(imageNamed: "baby_turtle")
        turtle.name = "baby_turtle"
        turtle.setScale(0.35)
        turtle.position = CGPoint(x: size.width * 0.5,
                                  y: size.height * 0.25)
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


    private func setupGarbage() {

        let garbageData: [(String, CGFloat, CGFloat, CGFloat)] = [
            ("bottle2",           0.32, 0.18, -0.4),
            ("plastic bag2",      0.55, 0.26,  0.3),
            ("plastic container", 0.68, 0.12, -0.2),
            ("plastic cup",       0.45, 0.08,  0.5)
        ]

        for data in garbageData {

            let node = SKSpriteNode(imageNamed: data.0)
            node.name = "garbage"

            node.position = CGPoint(
                x: size.width * data.1,
                y: size.height * data.2
            )

            node.zRotation = data.3
            node.zPosition = 2
            node.setScale(0.15)

            addChild(node)
            garbageNodes.append(node)
        }
    }

    private func setupHintLabel() {
        hintLabel = SKLabelNode(text: "Tap to clean the trash")
        hintLabel.fontSize = 18
        hintLabel.fontColor = .white
        hintLabel.alpha = 0
        hintLabel.zPosition = 10
        hintLabel.position = CGPoint(x: size.width / 2,
                                     y: size.height * 0.15)
        addChild(hintLabel)
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

  
    private func showGarbageTips() {

        guard let firstGarbage = garbageNodes.first else { return }

     
        garbageTipsNode?.removeAllActions()
        garbageTipsNode?.removeFromParent()
        garbageTipsNode = nil

        let worldPos = firstGarbage.convert(CGPoint.zero, to: self)

        let container = SKNode()

        container.position = CGPoint(x: worldPos.x, y: worldPos.y - size.height * 0.02)
        container.zPosition = 50

        let finger = SKLabelNode(fontNamed: "Menlo-Bold")
        finger.text = "👆"
        finger.fontSize = 40
        finger.verticalAlignmentMode = .center
        finger.horizontalAlignmentMode = .center
 
        finger.position = CGPoint(x: 0, y: 25)

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

    
        let up = SKAction.moveBy(x: 0, y: 8, duration: 0.4)
        let down = SKAction.moveBy(x: 0, y: -8, duration: 0.4)
        finger.run(SKAction.repeatForever(SKAction.sequence([up, down])))

        addChild(container)
        garbageTipsNode = container
    }

  
    private func showExitTips() {

        let exitPos = CGPoint(x: size.width / 2, y: size.height * 0.75)

    
        if let existing = childNode(withName: "passage1_exit_finger") {
            existing.removeFromParent()
        }

        let finger = SKLabelNode(fontNamed: "Menlo-Bold")
        finger.name = "passage1_exit_finger"
        finger.text = "👆"
        finger.fontSize = 40
        finger.verticalAlignmentMode = .center
        finger.horizontalAlignmentMode = .center
        finger.position = CGPoint(x: exitPos.x, y: exitPos.y + 0)
        finger.zPosition = 50

 
        let up = SKAction.moveBy(x: 0, y: 10, duration: 0.4)
        let down = SKAction.moveBy(x: 0, y: -10, duration: 0.4)
        finger.run(SKAction.repeatForever(SKAction.sequence([up, down])))

        addChild(finger)
    }

    override func update(_ currentTime: TimeInterval) {
  
        if canLeave, !hasGoneToOcean2,
           turtle.position.y > size.height * 0.7 {
            goToOceanScene2()
        }
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
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)


        if let panel = introPanel {
            let pLoc = touch.location(in: panel)
  
            if let back = introBackLabel,
               introPageIndex > 0,
               back.contains(pLoc) {
                showIntro(page: introPageIndex - 1)
                return
            }

            if let next = introNextLabel, next.contains(pLoc) {
                if introPageIndex == 0 {
                    showIntro(page: 1)
                } else {
                 
                    hideIntro()
                }
                return
            }
        
            return
        }

   
        if let panel = finishPanel {
            let pLoc = touch.location(in: panel)
            if let ok = finishOkLabel, ok.contains(pLoc) {
                hideFinishPanel()
                return
            }
            return
        }

  
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
            if !garbageNodes.isEmpty {
                showGarbageTips()
            } else if cleanedCount == totalGarbage {
                showExitTips()
            }
            return
        }


        guard canCleanGarbage else { return }

        moveTurtle(to: location)

        let nodesHere = nodes(at: location)
        for node in nodesHere where node.name == "garbage" {
            cleanGarbage(node)
            return
        }
    }

    private func cleanGarbage(_ node: SKNode) {
        node.name = nil
        let fade = SKAction.fadeOut(withDuration: 0.25)
        let scale = SKAction.scale(to: 0.2, duration: 0.25)
        node.run(SKAction.sequence([.group([fade, scale]), .removeFromParent()]))

        cleanedCount += 1
        garbageNodes.removeAll { $0 == node }

    
        if let tips = garbageTipsNode {
            tips.removeAllActions()
            tips.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))
            garbageTipsNode = nil
        }

        if cleanedCount == totalGarbage {
            allGarbageCleaned()
        }
    }

    private func allGarbageCleaned() {
        canLeave = true
        if hintLabel.alpha == 0 {
            hintLabel.text = "Swim up to continue"
            hintLabel.run(SKAction.fadeIn(withDuration: 0.3))
        } else {
            hintLabel.text = "Swim up to continue"
        }

      
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run { [weak self] in
                self?.showFinishPanel()
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

    private func goToOceanScene2() {
        hasGoneToOcean2 = true
        let scene = OceanScene2(size: size)
        scene.dialogEngine = dialogEngine
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: .fade(withDuration: 0.8))
    }

    
    private func showIntro(page: Int) {
        introPageIndex = max(0, min(1, page))

        let panelWidth = size.width * 0.55
        let panelHeight = size.height * 0.25

        let panel: SKShapeNode
        if let existing = introPanel {
            panel = existing
        } else {
            let rect = CGSize(width: panelWidth, height: panelHeight)
            panel = SKShapeNode(rectOf: rect, cornerRadius: 28)
            panel.fillColor = boardBackgroundColor
            panel.strokeColor = boardBorderColor
            panel.lineWidth = 4
            panel.zPosition = 50
            panel.position = CGPoint(x: size.width / 2, y: size.height * 0.6)

      
            let textLabel = SKLabelNode(fontNamed: "Menlo-Bold")
            textLabel.fontSize = 22
            textLabel.fontColor = .white
            textLabel.verticalAlignmentMode = .center
            textLabel.horizontalAlignmentMode = .center
            textLabel.numberOfLines = 0
            textLabel.preferredMaxLayoutWidth = panelWidth * 0.86
            textLabel.position = CGPoint(x: 0, y: 20)
            panel.addChild(textLabel)
            introTextLabel = textLabel

     
            let backLabel = SKLabelNode(fontNamed: "Menlo-Bold")
            backLabel.fontSize = 22
            backLabel.fontColor = .white
            backLabel.horizontalAlignmentMode = .left
            backLabel.verticalAlignmentMode = .center
            backLabel.text = "< Back"
            backLabel.name = "introBack"
            backLabel.position = CGPoint(x: -panelWidth * 0.36, y: -panelHeight * 0.36)
            panel.addChild(backLabel)
            introBackLabel = backLabel

         
            let nextLabel = SKLabelNode(fontNamed: "Menlo-Bold")
            nextLabel.fontSize = 22
            nextLabel.fontColor = boardButtonColor
            nextLabel.horizontalAlignmentMode = .right
            nextLabel.verticalAlignmentMode = .center
            nextLabel.text = "Next"
            nextLabel.name = "introNext"
            nextLabel.position = CGPoint(x: panelWidth * 0.36, y: -panelHeight * 0.36)
            panel.addChild(nextLabel)
            introNextLabel = nextLabel

            addChild(panel)
            introPanel = panel
        }

        let text: String
        if introPageIndex == 0 {
            text = "👉 This passage to the deep sea has been blocked by waste left behind by humans..."
            introNextLabel?.text = "Next"
       
            introBackLabel?.alpha = 0.0
        } else {
            text = "👊 The ocean is not a dumping ground. Tap to clear the waste and protect the sea!"
            introNextLabel?.text = "Start"
            introBackLabel?.alpha = 1.0
        }
        animateIntroText(text)
    }

    private func hideIntro() {
        introPanel?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        introPanel = nil
        introTextLabel = nil
        introNextLabel = nil
        introBackLabel = nil

     
        canCleanGarbage = true

   
        showNarrator(text: "Tap the trash to clean it, just like you helped the seahorse earlier.")
    }

  
    private func animateIntroText(_ text: String) {
        guard let label = introTextLabel else { return }
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


    private func showFinishPanel() {
        guard finishPanel == nil else { return }

        let panelWidth = size.width * 0.55
        let panelHeight = size.height * 0.25
        let rect = CGSize(width: panelWidth, height: panelHeight)

        let panel = SKShapeNode(rectOf: rect, cornerRadius: 28)
        panel.fillColor = boardBackgroundColor
        panel.strokeColor = boardBorderColor
        panel.lineWidth = 4
        panel.zPosition = 60
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.6)

        let textLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        textLabel.fontSize = 22
        textLabel.fontColor = .white
        textLabel.verticalAlignmentMode = .center
        textLabel.horizontalAlignmentMode = .center
        textLabel.numberOfLines = 0
        textLabel.preferredMaxLayoutWidth = panelWidth * 0.86
        textLabel.position = CGPoint(x: 0, y: 10)
        panel.addChild(textLabel)
        finishTextLabel = textLabel

        animateFinishText("👏 Well done. Every small action helps protect our ocean. Move toward the exit.")

        let okLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        okLabel.fontSize = 22
        okLabel.fontColor = boardButtonColor
        okLabel.horizontalAlignmentMode = .center
        okLabel.verticalAlignmentMode = .center
        okLabel.text = "OK"
        okLabel.name = "finishOK"
        okLabel.position = CGPoint(x: 0, y: -panelHeight * 0.34)
        panel.addChild(okLabel)
        finishOkLabel = okLabel

        addChild(panel)
        finishPanel = panel
    }

    private func hideFinishPanel() {
        finishPanel?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        finishPanel = nil
        finishTextLabel = nil
        finishOkLabel = nil

        showExitGlow()
    }


    private func animateFinishText(_ text: String) {
        guard let label = finishTextLabel else { return }
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

    private func showExitGlow() {
   
        if childNode(withName: "exitGlowPulse") != nil { return }

        let glowNode = SKNode()
        glowNode.name = "exitGlowPulse"
        addChild(glowNode)

  
        let spawnCircle = SKAction.run { [weak self] in
            guard let self = self else { return }

            let circle = SKShapeNode(circleOfRadius: 20)
            circle.position = CGPoint(x: self.size.width/2, y: self.size.height*0.75)

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
        let repeatForever = SKAction.repeatForever(sequence)
        glowNode.run(repeatForever)
    }
}

import SwiftUI
#Preview {
    SpriteView(scene: Passage1Scene(size: CGSize(width: 1024, height: 768)))
        .ignoresSafeArea()
}
