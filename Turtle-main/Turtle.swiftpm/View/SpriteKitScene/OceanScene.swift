import SpriteKit

class OceanScene: SKScene {

    var dialogEngine: DialogEngine!
    let trappedCharacter: any Character = SeahorseTrapped()
    let freedCharacter: any Character = Seahorse()
    
    private var turtle: SKSpriteNode!
    private var seahorse: SKSpriteNode!
    private var garbageNodes: [SKSpriteNode] = []
    private var hintLabel: SKLabelNode!
    private var seahorseBubble: SKNode?
    private var seahorseWiggleAction: SKAction?


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


    private var seaweedNodes: [SKSpriteNode] = []
    private var seaweedCenter: CGPoint = CGPoint.zero
    private var isDraggingSeaweed = false
    private var seaweedSwipeDistance: CGFloat = 0
    private let seaweedSwipeThresholdPerCluster: CGFloat = 200
    private var seaweedCleared = false
    private var hasGoneToPassage1 = false
    private let seaweedDragRange: CGFloat = 80
    private var seaweedSwipeHintNode: SKNode?

    private var cleanedCount = 0
    private let totalGarbage = 3
    private var seahorseCanMove = false
    private var hasTalkedToSeahorse = false
    private let seahorseCleanDistance: CGFloat = 80

   
    override func didMove(to view: SKView) {
        setupBackground()
        setupBackgroundCreatures()
        setupTurtle()
        setupSeahorse()
        setupGarbage()
        setupHintLabel()
        addChild(ProgressNode(sceneSize: size, stage: .seahorse))

        setupTipsButton()
        startInitialNarration()
    }

  
    private func setupBackground() {
        let bg = SKSpriteNode(imageNamed: "seahorse habitat")
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
        turtle.position = CGPoint(x: size.width * 0.25,
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
    
    private func getPositionBesideSeahorse() -> CGPoint {
        let offsetX: CGFloat = -70
        let offsetY: CGFloat = 0
        
        return CGPoint(x: seahorse.position.x + offsetX,
                      y: seahorse.position.y + offsetY)
    }
    
    private func moveTurtleToBesideAndClean(besidePosition: CGPoint, garbageNode: SKNode) {
        turtle.removeAllActions()
        
        let dx = besidePosition.x - turtle.position.x
        turtle.xScale = abs(turtle.xScale) * (dx >= 0 ? 1 : -1)
        
        let distance = hypot(dx, besidePosition.y - turtle.position.y)
        let speed: CGFloat = 200
        let duration = TimeInterval(distance / speed)
        
        let move = SKAction.move(to: besidePosition, duration: duration)
        move.timingMode = .easeInEaseOut
        
        let cleanAction = SKAction.run { [weak self] in
            self?.cleanGarbage(garbageNode)
        }
        
        turtle.run(SKAction.sequence([move, cleanAction]))
    }
    

    private func setupBackgroundCreatures() {
        let creatureNames = ["seahorse1", "seahorse2", "fish1", "fish2"]

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

            let move = SKAction.moveBy(x: 120 * direction,
                                       y: CGFloat.random(in: -20...20),
                                       duration: 6)
            let moveBack = move.reversed()
            let loop = SKAction.repeatForever(SKAction.sequence([move, moveBack]))
            creature.run(loop)
        }
    }

 
    private func setupSeahorse() {
        seahorse = SKSpriteNode(imageNamed: "seahorse")
        seahorse.name = "seahorse"
        seahorse.position = CGPoint(x: size.width * 0.6,
                                    y: size.height * 0.5)
        seahorse.zPosition = 1
        seahorse.setScale(0.2)
        addChild(seahorse)

        startSeahorseWiggle()
    }
    
    private func startSeahorseWiggle() {
        let wiggle = SKAction.sequence([
            SKAction.rotate(byAngle: 0.05, duration: 0.15),
            SKAction.rotate(byAngle: -0.1, duration: 0.15),
            SKAction.rotate(byAngle: 0.05, duration: 0.15),
            SKAction.rotate(toAngle: 0, duration: 0.1)
        ])
        seahorseWiggleAction = SKAction.repeatForever(wiggle)
        seahorse.run(seahorseWiggleAction!, withKey: "wiggle")
    }
    
    private func stopSeahorseWiggle() {
        seahorse.removeAction(forKey: "wiggle")
        seahorse.run(SKAction.rotate(toAngle: 0, duration: 0.2))
    }


    private func setupGarbage() {
        let garbageData: [(String, CGPoint, CGFloat)] = [
            ("bottle1", CGPoint(x: 20, y: 30), 0.35),
            ("plastic bag1", CGPoint(x: -10, y: 0), 0.4),
            ("rope", CGPoint(x: 0, y: -35), 0.45)
        ]

        for (name, position, _) in garbageData {
            let garbage = SKSpriteNode(imageNamed: name)
            garbage.name = "garbage"
            garbage.position = position
            garbage.setScale(0.6)
            garbage.zPosition = 2
            seahorse.addChild(garbage)
            garbageNodes.append(garbage)
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


    private func startInitialNarration() {
        let text1 = "The seahorse seems to be in trouble."
        let text2 = "Tap the seahorse to get a clue."

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
        container.position = worldPos
        container.zPosition = 50

        let finger = SKLabelNode(fontNamed: "Menlo-Bold")
        finger.text = "👆"
        finger.fontSize = 40
        finger.verticalAlignmentMode = .center
        finger.horizontalAlignmentMode = .center
        finger.position = CGPoint(x: 0, y: -20)

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

        addChild(container)
        garbageTipsNode = container
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
    
  
    override func update(_ currentTime: TimeInterval) {
        if !garbageNodes.isEmpty {
            for garbage in garbageNodes {
                garbage.alpha = hasTalkedToSeahorse ? 0.8 : 1.0
            }
            if hasTalkedToSeahorse {
                showHint(true)
            }
        }

        if garbageNodes.isEmpty, seahorseWiggleAction != nil {
            stopSeahorseWiggle()
            seahorseWiggleAction = nil
        }

        if seaweedCleared, !hasGoneToPassage1 {
            let distance = hypot(turtle.position.x - seaweedCenter.x,
                                 turtle.position.y - seaweedCenter.y)
            if distance < 70 {
                goToPassage1()
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
            if !garbageNodes.isEmpty {
                showGarbageTips()
            } else if !seaweedCleared, !seaweedNodes.isEmpty {
                showSeaweedSwipeHint()
            } else if seaweedCleared {
                let exitPos = seaweedCenter

                let finger = SKLabelNode(fontNamed: "Menlo-Bold")
                finger.text = "👆"
                finger.fontSize = 40
                finger.verticalAlignmentMode = .center
                finger.horizontalAlignmentMode = .center
                finger.position = CGPoint(x: exitPos.x, y: exitPos.y + -10)
                finger.zPosition = 50

                let up = SKAction.moveBy(x: 0, y: 10, duration: 0.4)
                let down = SKAction.moveBy(x: 0, y: -10, duration: 0.4)
                finger.run(SKAction.repeatForever(SKAction.sequence([up, down])))

                addChild(finger)
            }
            return
        }


        if !seaweedCleared, !seaweedNodes.isEmpty {
            let distToSeaweed = hypot(location.x - seaweedCenter.x,
                                      location.y - seaweedCenter.y)
            if distToSeaweed < 120 {
                for node in seaweedNodes where node.contains(location) {
                    isDraggingSeaweed = true
                    hideSeaweedSwipeHint()
                    return
                }
            }
        }


        let nodesAtPoint = nodes(at: location)
        for node in nodesAtPoint {
            if node.name == "seahorse", !hasTalkedToSeahorse {
                dialogEngine.talkTo(trappedCharacter)
                hasTalkedToSeahorse = true
                return
            }
        }
        

        for node in nodesAtPoint {
            if node.name == "garbage" {
                if !hasTalkedToSeahorse {

                    moveTurtle(to: getPositionBesideSeahorse())
                    return
                }

                cleanGarbage(node)
                return
            }
        }
        

        if garbageNodes.isEmpty {
            for node in nodesAtPoint {
                if node.name == "seahorse" {
                    dialogEngine.talkTo(freedCharacter)
                    return
                }
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

        guard isDraggingSeaweed, !seaweedCleared else { return }
        let current = touch.location(in: self)
        let previous = touch.previousLocation(in: self)
        let dx = current.x - previous.x

        seaweedSwipeDistance += abs(dx)


        let maxOffset: CGFloat = 25
        for node in seaweedNodes {
            var newX = node.position.x + dx * 0.2
            newX = max(seaweedCenter.x - maxOffset,
                       min(seaweedCenter.x + maxOffset, newX))
            node.position.x = newX
        }


        if seaweedSwipeDistance >= seaweedSwipeThresholdPerCluster {
            seaweedSwipeDistance = 0
            if let node = seaweedNodes.first {
                let fade = SKAction.fadeOut(withDuration: 0.25)
                let scale = SKAction.scale(to: 0.2, duration: 0.25)
                let group = SKAction.group([fade, scale])
                node.run(SKAction.sequence([group, .removeFromParent()]))
                seaweedNodes.removeFirst()
            }
            if seaweedNodes.isEmpty {
                clearSeaweed()
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDraggingSeaweed = false
        isDraggingHistory = false
    }
    
    private func cleanGarbage(_ node: SKNode) {
        node.name = nil
        node.run(SKAction.fadeOut(withDuration: 0.25)) {
            node.removeFromParent()
        }

        cleanedCount += 1
        garbageNodes.removeAll { $0 == node }

        if cleanedCount == totalGarbage {
            allGarbageCleaned()
        }
    }

    private func allGarbageCleaned() {
        seahorseCanMove = true
        showHint(false)

        let wiggle = SKAction.sequence([
            SKAction.rotate(byAngle: 0.1, duration: 0.2),
            SKAction.rotate(byAngle: -0.2, duration: 0.2),
            SKAction.rotate(toAngle: 0, duration: 0.2)
        ])
        seahorse.run(wiggle)

        dialogEngine?.endConversation()

        setupSeaweedCluster()

        if let tips = garbageTipsNode {
            tips.removeAllActions()
            tips.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))
            garbageTipsNode = nil
        }
    }

    private func setupSeaweedCluster() {
        seaweedNodes.removeAll()
        seaweedSwipeDistance = 0
        seaweedCleared = false
        
        seaweedCenter = CGPoint(x: size.width * 0.87,
                                y: size.height * 0.22)
        

        for _ in 0..<3 {  

            let node = SKSpriteNode(imageNamed: "seaweed")

            let offsetX = CGFloat.random(in: -80...80)
            let offsetY = CGFloat.random(in: -40...40)

            node.position = CGPoint(
                x: seaweedCenter.x + offsetX,
                y: seaweedCenter.y + offsetY
            )

            node.zPosition = 0
            node.setScale(CGFloat.random(in: 0.3...0.5))

            addChild(node)
            seaweedNodes.append(node)
        }
    }
    
    private func clearSeaweed() {
        seaweedCleared = true
        isDraggingSeaweed = false
        seaweedNodes.removeAll()
        hideSeaweedSwipeHint()
        showExitGlow()
    }


    private func showExitGlow() {
        if childNode(withName: "exitGlowPulse") != nil { return }

        let glowNode = SKNode()
        glowNode.name = "exitGlowPulse"
        addChild(glowNode)

        let exitPosition = seaweedCenter

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


    private func showSeaweedSwipeHint() {
        guard seaweedSwipeHintNode == nil, !seaweedNodes.isEmpty else { return }

        let container = SKNode()
        container.zPosition = 40

        let finger = SKLabelNode(fontNamed: "Menlo-Bold")
        finger.text = "👆"
        finger.fontSize = 40
        finger.verticalAlignmentMode = .center
        finger.horizontalAlignmentMode = .center

        let topY = seaweedCenter.y + seaweedDragRange * 0.5
        let bottomY = seaweedCenter.y - seaweedDragRange * 0.5
        let leftX = seaweedCenter.x - seaweedDragRange * 0.8
        let rightX = seaweedCenter.x + seaweedDragRange * 0.8

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
        seaweedSwipeHintNode = container

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

    private func hideSeaweedSwipeHint() {
        seaweedSwipeHintNode?.removeAllActions()
        seaweedSwipeHintNode?.removeFromParent()
        seaweedSwipeHintNode = nil
    }

    private func goToPassage1() {
        guard !hasGoneToPassage1 else { return }
        hasGoneToPassage1 = true
        dialogEngine?.endConversation()
        let scene = Passage1Scene(size: size)
        scene.dialogEngine = dialogEngine
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: .fade(withDuration: 0.8))
    }

    private func showHint(_ show: Bool) {
        if show {
            if hintLabel.alpha == 0 {
                hintLabel.run(SKAction.fadeIn(withDuration: 0.2))
            }
        } else {
            if hintLabel.alpha == 1 {
                hintLabel.run(SKAction.fadeOut(withDuration: 0.2))
            }
        }
    }
}

import SwiftUI
#Preview {
    let scene = OceanScene(size: CGSize(width: 1024, height: 768))
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
