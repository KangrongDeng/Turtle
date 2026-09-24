import SpriteKit

class BeachScene: SKScene {
    
    var dialogEngine: DialogEngine!

    private let beachName = "beach"
    private let eggName = "egg"
    private let eggCrackName = "egg_crack"
    private let babyTurtleName = "baby_turtle"

    private var backgroundNode: SKSpriteNode!
    private var eggNode: SKSpriteNode!
    private var crackNode: SKSpriteNode!
    private var turtleNode: SKSpriteNode!

    private var isDraggingEgg = false
    private var eggStartPosition: CGPoint = CGPoint.zero
    private var touchStartX: CGFloat = 0
    private var totalSwipeDistance: CGFloat = 0
    private let crackThreshold: CGFloat = 900
    private let eggDragRange: CGFloat = 100
    private var hasCracked = false
    private var hasTurtleAppeared = false
    private var hasTalkedToBabyTurtle = false
    
    private var isAvailableToTalk = false

    private var oceanZoneMinX: CGFloat { size.width * 0.72 }

    private var introPanel: SKShapeNode?
    private var introTextLabel: SKLabelNode?
    private var introBackLabel: SKLabelNode?
    private var introNextLabel: SKLabelNode?
    private var introPageIndex: Int = 0
    private var hasShownIntro: Bool = false

    private var swipeHintNode: SKNode?


    private var narratorNode: SKNode?
    private var narratorLabel: SKLabelNode?
    private var narratorHistory: [String] = []
    

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


    private var welcomePanel: SKShapeNode?
    private var welcomeTextLabel: SKLabelNode?
    private var welcomeOKLabel: SKLabelNode?

    override func didMove(to view: SKView) {
        setupBackground()
        setupEgg()
        addChild(ProgressNode(sceneSize: size, stage: .egg))

 
        setupTipsButton()


        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run { [weak self] in
                self?.showIntro(page: 0)
            }
        ]))
    }

    private func setupBackground() {
        let tex = SKTexture(imageNamed: beachName)
        backgroundNode = SKSpriteNode(texture: tex)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.zPosition = -1
        let scale = max(size.width / tex.size().width, size.height / tex.size().height)
        backgroundNode.setScale(scale)
        addChild(backgroundNode)
    }

    private func setupEgg() {
        let tex = SKTexture(imageNamed: eggName)
        eggNode = SKSpriteNode(texture: tex)
        eggNode.name = "egg"
        eggNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        eggStartPosition = CGPoint(x: size.width / 2, y: size.height * 0.32)
        eggNode.position = eggStartPosition
        eggNode.zPosition = 1
        let scale = (size.width * 0.22) / tex.size().width
        eggNode.setScale(scale)
        addChild(eggNode)
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)


        if let panel = introPanel {
            let pLoc = touch.location(in: panel)

            if let back = introBackLabel, back.contains(pLoc), introPageIndex > 0 {
                showIntro(page: introPageIndex - 1)
                return
            }

            if let next = introNextLabel, next.contains(pLoc) {
                if introPageIndex < 2 {
                    showIntro(page: introPageIndex + 1)
                } else {
                    hideIntro()
                }
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
            lastHistoryTouchY = loc.y
            return
        }
        

        if let panel = welcomePanel {
            let pLoc = touch.location(in: panel)
            if let okLabel = welcomeOKLabel, okLabel.contains(pLoc) {
                hideWelcomePanel()
            }
            return
        }


        if let log = logButtonNode, log.contains(loc) {
            showHistoryPanel()
            return
        }
        

        if let tips = tipsButtonNode, tips.contains(loc) {
            if hasTurtleAppeared {
                if !hasTalkedToBabyTurtle {
      
                    showTipsGuideToBabyTurtle()
                } else {

                    showTipsGuideToExit()
                }
            } else if hasShownIntro, introPanel == nil, !hasCracked {

                showSwipeHint()
            }
            return
        }


        if hasTurtleAppeared, let turtle = turtleNode {
            let nodesAtPoint = nodes(at: loc)
            let tappedTurtle = nodesAtPoint.contains { node in
                return node === turtle || node.name == "baby_turtle" || node.parent === turtle
            }

            if tappedTurtle {
                if dialogEngine?.talkingTo == nil, isAvailableToTalk {
                    dialogEngine?.talkTo(BabyTurtle())
                    if !hasTalkedToBabyTurtle {
                        hasTalkedToBabyTurtle = true
                        showExitGlow()
                    }
                }
                return
            }


            moveTurtle(to: loc)
            return
        }

        guard hasShownIntro, introPanel == nil else { return }


        if !hasCracked, eggNode.contains(loc) {
            isDraggingEgg = true
            touchStartX = touch.location(in: view).x
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
        

        guard hasShownIntro, introPanel == nil else {
            isDraggingEgg = false
            return
        }
        guard isDraggingEgg, !hasCracked else { return }


        hideSwipeHint()

        let viewX = touch.location(in: view).x
        let prevViewX = touch.previousLocation(in: view).x
        let dx = viewX - prevViewX

        totalSwipeDistance += abs(dx)


        var newX = eggNode.position.x + dx
        newX = max(eggStartPosition.x - eggDragRange, min(eggStartPosition.x + eggDragRange, newX))
        eggNode.position.x = newX


        let tilt = (newX - eggStartPosition.x) / eggDragRange * 0.15
        eggNode.zRotation = -tilt

        if totalSwipeDistance >= crackThreshold {
            crackEgg()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        isDraggingHistory = false
        

        guard hasShownIntro, introPanel == nil else {
            isDraggingEgg = false
            return
        }


        isDraggingEgg = false
        if !hasCracked, eggNode.parent != nil {
            let back = SKAction.group([
                SKAction.move(to: eggStartPosition, duration: 0.2),
                SKAction.rotate(toAngle: 0, duration: 0.2)
            ])
            back.timingMode = .easeOut
            eggNode.run(back)
        }
    }


    private func moveTurtle(to position: CGPoint) {
        guard let turtle = turtleNode else { return }
        

        let dx = position.x - turtle.position.x
        turtle.xScale = abs(turtle.xScale) * (dx >= 0 ? 1 : -1)

        let destinationY = min(400, position.y)
        let destination = CGPoint(x: position.x, y: destinationY)
        
 
        let moveAction = SKAction.move(to: destination, duration: 0.5)
        moveAction.timingMode = .easeInEaseOut
        turtle.run(moveAction) { [weak self] in
            if position.x >= self?.oceanZoneMinX ?? 0 {
                self?.goToOceanScene()
            }
        }
    }


    private func goToOceanScene() {
        dialogEngine?.endConversation()
        let ocean = OceanScene(size: size)
        ocean.dialogEngine = dialogEngine
        ocean.scaleMode = scaleMode
        view?.presentScene(ocean, transition: .fade(withDuration: 0.6))
    }


    private func crackEgg() {
        guard !hasCracked else { return }
        hasCracked = true
        isDraggingEgg = false

        eggNode.removeFromParent()

        crackNode = SKSpriteNode(imageNamed: eggCrackName)
        crackNode.position = eggStartPosition
        crackNode.zPosition = 1
        let scale = (size.width * 0.22) / (crackNode.size.width)
        crackNode.setScale(scale)
        addChild(crackNode)

        let wait = SKAction.wait(forDuration: 0.6)
        let showTurtle = SKAction.run { [weak self] in
            self?.showBabyTurtle()
        }
        run(SKAction.sequence([wait, showTurtle]))
    }

    private func showBabyTurtle() {
        crackNode.removeFromParent()
        hasTurtleAppeared = true

        turtleNode = SKSpriteNode(imageNamed: babyTurtleName)
        turtleNode.name = "baby_turtle"
        turtleNode.position = eggStartPosition
        turtleNode.zPosition = 2
        turtleNode.alpha = 0
        let scale = (size.width * 0.18) / turtleNode.size.width
        turtleNode.setScale(scale)
        addChild(turtleNode)

        let targetY = eggStartPosition.y + size.height * 0.08
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let moveUp = SKAction.move(to: CGPoint(x: eggStartPosition.x, y: targetY), duration: 0.8)
        moveUp.timingMode = .easeOut
        turtleNode.run(SKAction.group([fadeIn, moveUp])) { [weak self] in
            self?.showNarrator(text: "Tap the baby turtle to talk!")
            self?.showWelcomePanel()
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
                                     y: size.height * 0.86)

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


    private func showWelcomePanel() {
        guard welcomePanel == nil else { return }

        let panelWidth = size.width * 0.55
        let panelHeight = size.height * 0.25
        let rect = CGSize(width: panelWidth, height: panelHeight)
        let panel = SKShapeNode(rectOf: rect, cornerRadius: 28)
        panel.fillColor = boardBackgroundColor
        panel.strokeColor = boardBorderColor
        panel.lineWidth = 4
        panel.zPosition = 50
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        panel.name = "welcomePanel"

        let text = "🌊  Welcome to the ocean!\nEvery creature here loves to chat.\nTap them to start a conversation and ask anything!"
        let textLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        textLabel.text = ""
        textLabel.fontSize = 22
        textLabel.fontColor = .white
        textLabel.verticalAlignmentMode = .center
        textLabel.horizontalAlignmentMode = .center
        textLabel.numberOfLines = 0
        textLabel.preferredMaxLayoutWidth = panelWidth * 0.88
        textLabel.position = CGPoint(x: 0, y: 20)
        panel.addChild(textLabel)
        welcomeTextLabel = textLabel

        let okLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        okLabel.text = "OK"
        okLabel.fontSize = 22
        okLabel.fontColor = boardButtonColor
        okLabel.verticalAlignmentMode = .center
        okLabel.horizontalAlignmentMode = .center
        okLabel.position = CGPoint(x: 0, y: -panelHeight * 0.36)
        okLabel.name = "welcomeOK"
        panel.addChild(okLabel)
        welcomeOKLabel = okLabel

        addChild(panel)
        welcomePanel = panel
        animateWelcomeText(text)
    }


    private func animateWelcomeText(_ text: String) {
        guard let label = welcomeTextLabel else { return }
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

    private func hideWelcomePanel() {
        welcomePanel?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        welcomePanel = nil
        welcomeTextLabel = nil
        welcomeOKLabel = nil
        
        isAvailableToTalk = true
    }

    private func showExitGlow() {
        if childNode(withName: "exitGlowPulse") != nil { return }

        let glowNode = SKNode()
        glowNode.name = "exitGlowPulse"
        addChild(glowNode)

        let exitX = (oceanZoneMinX + size.width) / 2
        let exitY = size.height * 0.4

        let spawnCircle = SKAction.run { [weak self] in
            guard self != nil else { return }
            let circle = SKShapeNode(circleOfRadius: 20)
            circle.position = CGPoint(x: exitX, y: exitY)
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


    private func showIntro(page: Int) {
        hasShownIntro = true
        introPageIndex = max(0, min(2, page))

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
            panel.position = CGPoint(x: size.width / 2, y: size.height * 0.55)

      
            let textLabel = SKLabelNode(fontNamed: "Menlo-Bold")
            textLabel.fontSize = 22
            textLabel.fontColor = .white
            textLabel.verticalAlignmentMode = .center
            textLabel.horizontalAlignmentMode = .center
            textLabel.numberOfLines = 0
            textLabel.preferredMaxLayoutWidth = panelWidth * 0.88
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
        switch introPageIndex {
        case 0:
            text = """
🥚 Beneath the warm sand, a small sea turtle egg begins to gently tremble. It is about to begin its very first journey.
"""
        case 1:
            text = """
🐢 From the moment they hatch, every baby sea turtle must cross the beach alone and make its way into the vast ocean. The sea is its true home.
"""
        default:
            text = """
🤔 “Are you ready to begin this journey? Follow the narrator and the sea animals to discover what to do next.”
"""
        }
        animateIntroText(text)

    
        introBackLabel?.alpha = introPageIndex == 0 ? 0.3 : 1.0
        if introPageIndex == 2 {
            introNextLabel?.text = "Start"
        } else {
            introNextLabel?.text = "Next"
        }
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

    private func hideIntro() {
        introPanel?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        introPanel = nil
        introTextLabel = nil
        introBackLabel = nil
        introNextLabel = nil

      
        showNarrator(text: "slide the egg")
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
    
    private func showTipsGuideToBabyTurtle() {
        tipsGuideNode?.removeFromParent()
        
        guard let turtle = turtleNode else { return }
        let guide = Tips.createFingerRippleGuide(center: turtle.position, fingerOffsetY: 35)
        addChild(guide)
        tipsGuideNode = guide
    }
    
    private func showTipsGuideToExit() {
        tipsGuideNode?.removeFromParent()
        
        let exitX = (oceanZoneMinX + size.width) / 2
        let exitY = size.height * 0.32
        let exitPos = CGPoint(x: exitX, y: exitY)
        
        let finger = SKLabelNode(fontNamed: "Menlo-Bold")
        finger.text = "👆"
        finger.fontSize = 40
        finger.verticalAlignmentMode = .center
        finger.horizontalAlignmentMode = .center
        finger.position = CGPoint(x: exitPos.x, y: exitPos.y + 30)
        finger.zPosition = 50
        
        let up = SKAction.moveBy(x: 0, y: 10, duration: 0.4)
        let down = SKAction.moveBy(x: 0, y: -10, duration: 0.4)
        finger.run(SKAction.repeatForever(SKAction.sequence([up, down])))
        
        addChild(finger)
        tipsGuideNode = finger
    }
    

    private func showSwipeHint() {
        guard swipeHintNode == nil, !hasCracked else { return }

   
        let container = SKNode()
        container.zPosition = 40

        let finger = SKLabelNode(fontNamed: "Menlo-Bold")
        finger.text = "👆"
        finger.fontSize = 40
        finger.verticalAlignmentMode = .center
        finger.horizontalAlignmentMode = .center

  
        let topY = eggStartPosition.y + eggNode.size.height * 0.3
        let bottomY = eggStartPosition.y - eggNode.size.height * 0.10
        let leftX = eggStartPosition.x - eggDragRange * 0.8
        let rightX = eggStartPosition.x + eggDragRange * 0.8

        let topLeft = CGPoint(x: leftX, y: topY)
        let topRight = CGPoint(x: rightX, y: topY)
        let bottomLeft = CGPoint(x: leftX, y: bottomY)
        let bottomRight = CGPoint(x: rightX, y: bottomY)

        finger.position = topLeft
        container.position = CGPoint.zero
        container.addChild(finger)

   
        let trailParent = SKNode()
        trailParent.zPosition = 39
        container.addChild(trailParent)

        addChild(container)
        swipeHintNode = container

     
        let move1 = SKAction.move(to: topRight, duration: 0.4)
        let move2 = SKAction.move(to: bottomLeft, duration: 0.4)
        let move3 = SKAction.move(to: bottomRight, duration: 0.4)
        let move4 = SKAction.move(to: topLeft, duration: 0.4)
        let fingerSeq = SKAction.sequence([move1, move2, move3, move4])
        finger.run(SKAction.repeatForever(fingerSeq))

     
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

    private func hideSwipeHint() {
        swipeHintNode?.removeAllActions()
        swipeHintNode?.removeFromParent()
        swipeHintNode = nil

    }
}


import SwiftUI
#Preview {
    let scene = BeachScene(size: CGSize(width: 1024, height: 768))
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
