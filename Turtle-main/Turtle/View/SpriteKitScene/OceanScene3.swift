
import SpriteKit
import UIKit
import AVFAudio

class OceanScene3: SKScene {

   
    private let endBackgroundNames = ["end1", "end2", "end3"]
    private let motherTurtleName = "mother_turtle"
    private let babyTurtleName = "baby_turtle"
    private let netTextureName = "net"
    private let knotName = "knot"
    private let garbageNames = ["garbage1", "garbage2", "garbage3", "garbage4"]

    private let shotSfx = SKAction.playSoundFileNamed("Shot.mp3", waitForCompletion: false)
 
    private var backgroundContainer = SKNode()
    private var babyTurtle: SKSpriteNode!
    private var motherTurtle: SKSpriteNode!
    private var netNode: SKSpriteNode!
    private var fogNode: SKShapeNode!
    private var garbageNodes: [SKSpriteNode] = []
    private var knotNodes: [SKSpriteNode] = []
    private var knotHints: [SKLabelNode] = []


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


    private var endPanel: SKShapeNode?
    private var endTextLabel: SKLabelNode?
    private var endButtonLabel: SKLabelNode?


    private var cleanedGarbageCount = 0
    private var knotsVisible = false
    private var knotsUntied = [false, false, false]
    private var isDraggingKnot = false
    private var draggedKnotIndex: Int?
    private var knotStartPositions: [CGPoint] = []
    private var knotDragDistances: [CGFloat] = [0, 0, 0]
    private let knotDragThreshold: CGFloat = 150
    private let motherTriggerDistance: CGFloat = 100


    private var end3SequenceStarted = false
    private var seahorseOutline: SKSpriteNode?
    private var mantaOutline: SKSpriteNode?
    private var seahorseNode: SKSpriteNode?
    private var mantaNode: SKSpriteNode?
    private var cameraButton: SKSpriteNode?
    private var photoNode: SKNode?
    private var photoPanel: SKShapeNode?
    private var photoTextLabel: SKLabelNode?
    private var photoBackLabel: SKLabelNode?
    private var photoNextLabel: SKLabelNode?
    private var photoPageIndex: Int = 0
    private let photoMessages: [String] = [
        "👊 Small actions create big waves.",
        """
🏅 You helped many marine friends:
• Seahorse
• Manta Ray
• Mother Turtle
And reunited the baby turtle with its mom!
""",
        "Let’s protect our oceans and keep marine life safe!",
        "📷 Capture this moment — a memory of hope for the ocean."
    ]
    private var hasShownPhotoPrompt = false
    private var end3HintBubble: SKNode?
    private var progressNode: ProgressNode?

    private var saveButton: SKSpriteNode?
    private var shareButton: SKSpriteNode?
    private var capturedPhoto: SKSpriteNode?
    private var pictureBookButton: SKNode?
    
    override func didMove(to view: SKView) {
        setupBackgrounds()
        setupBackgroundFishForEnd3()
        setupTurtlesAndGarbage()
        setupFog()
        addChild(backgroundContainer)
        let progress = ProgressNode(sceneSize: size, stage: .motherTurtle)
        addChild(progress)
        progressNode = progress

        setupTipsButton()
        startMotherNarration()
        

        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        
    }



    private func setupBackgrounds() {

        for (index, name) in endBackgroundNames.enumerated() {

            let bg = SKSpriteNode(imageNamed: name)

   
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)

      
            let scale = max(size.width / bg.size.width,
                            size.height / bg.size.height)
            bg.setScale(scale)

           
            bg.position = CGPoint(
                x: size.width * CGFloat(index) + size.width / 2,
                y: size.height / 2
            )

            bg.zPosition = -10
            backgroundContainer.addChild(bg)
        }
    }
    
 
    private func setupBackgroundFishForEnd3() {
        let fishNames = ["fish3", "fish4", "fish5"]
        

        let minX = size.width * 2
        let maxX = size.width * 3
        
        for _ in 0..<60 {
            guard let name = fishNames.randomElement() else { continue }
            let fish = SKSpriteNode(imageNamed: name)
            
            let x = CGFloat.random(in: minX...maxX)
            let y = CGFloat.random(in: size.height * 0.3...size.height * 0.9)
            fish.position = CGPoint(x: x, y: y)
            fish.zPosition = -5
            fish.alpha = 0.8
            fish.setScale(CGFloat.random(in: 0.02...0.07))
            
            backgroundContainer.addChild(fish)
            
            let direction: CGFloat = Bool.random() ? 1 : -1
            fish.xScale *= direction
            
            let move = SKAction.moveBy(x: 120 * direction,
                                       y: CGFloat.random(in: -20...20),
                                       duration: 6)
            let moveBack = move.reversed()
            let loop = SKAction.repeatForever(SKAction.sequence([move, moveBack]))
            fish.run(loop)
        }
    }
    
    private func setupTurtlesAndGarbage() {
  
        let baseX: CGFloat = size.width * 0


        babyTurtle = SKSpriteNode(imageNamed: babyTurtleName)
        babyTurtle.name = "baby_turtle"
        babyTurtle.setScale(0.3)
        babyTurtle.position = CGPoint(x: baseX + size.width * 0.18,
                                      y: size.height * 0.4)
        babyTurtle.zPosition = 1
        addChild(babyTurtle)


        motherTurtle = SKSpriteNode(imageNamed: motherTurtleName)
        motherTurtle.name = "mother_turtle"
        motherTurtle.setScale(0.3)
        motherTurtle.position = CGPoint(x: baseX + size.width * 0.78,
                                        y: size.height * 0.4)
        motherTurtle.zPosition = 0.9
        addChild(motherTurtle)


        netNode = SKSpriteNode(imageNamed: netTextureName)
        netNode.position = motherTurtle.position
        netNode.zPosition = 2
        netNode.setScale(motherTurtle.xScale * 0.9)
        addChild(netNode)

        startMotherWiggle()

  
        let garbagePositions: [CGPoint] = [
            CGPoint(x: (babyTurtle.position.x + motherTurtle.position.x) * 0.4,
                    y: size.height * 0.45),
            CGPoint(x: (babyTurtle.position.x + motherTurtle.position.x) * 0.55,
                    y: size.height * 0.35),
            CGPoint(x: (babyTurtle.position.x + motherTurtle.position.x) * 0.7,
                    y: size.height * 0.5),
            CGPoint(x: (babyTurtle.position.x + motherTurtle.position.x) * 0.5,
                    y: size.height * 0.25)
        ]

        for (index, name) in garbageNames.enumerated() {
            let node = SKSpriteNode(imageNamed: name)
            node.name = "garbage"
            node.setScale(0.18)
            node.position = garbagePositions[min(index, garbagePositions.count - 1)]
            node.zPosition = 1
            addChild(node)
            garbageNodes.append(node)
        }
    }



    private func setupFog() {

        let w = motherTurtle.size.width * 1.4
        let h = motherTurtle.size.height * 1.4

        let path = CGMutablePath()

 
        path.move(to: CGPoint(x: -w * 0.4, y: -h * 0.2))

   
        path.addQuadCurve(
            to: CGPoint(x: -w * 0.2, y:  h * 0.3),
            control: CGPoint(x: -w * 0.5, y:  h * 0.1)
        )

        path.addQuadCurve(
            to: CGPoint(x:  w * 0.3, y:  h * 0.35),
            control: CGPoint(x:  0,      y:  h * 0.7)
        )

        path.addQuadCurve(
            to: CGPoint(x:  w * 0.4, y: 0),
            control: CGPoint(x:  w * 0.6, y:  h * 0.5)
        )

        path.addQuadCurve(
            to: CGPoint(x:  w * 0.25, y: -h * 0.4),
            control: CGPoint(x:  w * 0.5, y: -h * 0.2)
        )

        path.addQuadCurve(
            to: CGPoint(x: -w * 0.3, y: -h * 0.4),
            control: CGPoint(x:  0,      y: -h * 0.6)
        )

        path.addQuadCurve(
            to: CGPoint(x: -w * 0.4, y: -h * 0.1),
            control: CGPoint(x: -w * 0.5, y: -h * 0.4)
        )

        path.closeSubpath()

        fogNode = SKShapeNode(path: path)
        fogNode.fillColor = SKColor.white.withAlphaComponent(0.55)
        fogNode.strokeColor = SKColor.white.withAlphaComponent(0.2)
        fogNode.position = motherTurtle.position
        fogNode.zPosition = 3

        addChild(fogNode)
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

  
        if let panel = endPanel {
            let pLoc = touch.location(in: panel)
            if let button = endButtonLabel, button.contains(pLoc) {
                hideEndPanelAndScroll()
            }
            return
        }

   
        if let panel = photoPanel {
            let pLoc = touch.location(in: panel)
            if let back = photoBackLabel, back.contains(pLoc), photoPageIndex > 0 {
                showPhotoPage(index: photoPageIndex - 1)
                return
            }
            if let next = photoNextLabel, next.contains(pLoc) {
                if photoPageIndex < photoMessages.count - 1 {
                    showPhotoPage(index: photoPageIndex + 1)
                } else {
                    hidePhotoPanelAndShowCamera()
                }
                return
            }
            return
        }


        if let button = cameraButton, button.contains(location) {
            handleCameraTap()
   
            clearTipsGuide()
            return
        }
        if let outline = seahorseOutline, outline.contains(location), seahorseNode == nil {

            outline.removeFromParent()
            seahorseOutline = nil

            let node = SKSpriteNode(imageNamed: "seahorse")
            node.position = outline.position
            node.zPosition = 3
            node.xScale = outline.xScale
            node.yScale = outline.yScale
            node.colorBlendFactor = 0
            addChild(node)
            seahorseNode = node

            let wiggle = SKAction.sequence([
                SKAction.rotate(byAngle: 0.08, duration: 0.15),
                SKAction.rotate(byAngle: -0.16, duration: 0.3),
                SKAction.rotate(byAngle: 0.08, duration: 0.15),
                SKAction.rotate(toAngle: 0, duration: 0.15)
            ])
            node.run(wiggle)
         
            clearTipsGuide()
            if mantaNode != nil, !hasShownPhotoPrompt {
                hasShownPhotoPrompt = true
                showPhotoPanel()
            }
            if seahorseNode != nil, mantaNode != nil {
                hideEnd3HintBubble()
            }
            return
        }
        if let outline = mantaOutline, outline.contains(location), mantaNode == nil {
            outline.removeFromParent()
            mantaOutline = nil

            let node = SKSpriteNode(imageNamed: "Manta Ray")
            node.position = outline.position
            node.zPosition = 3
            node.xScale = outline.xScale
            node.yScale = outline.yScale
            node.colorBlendFactor = 0
            addChild(node)
            mantaNode = node

            let wiggle = SKAction.sequence([
                SKAction.moveBy(x: 10, y: 0, duration: 0.15),
                SKAction.moveBy(x: -20, y: 0, duration: 0.3),
                SKAction.moveBy(x: 10, y: 0, duration: 0.15)
            ])
            node.run(wiggle)
        
            clearTipsGuide()
            if seahorseNode != nil, !hasShownPhotoPrompt {
                hasShownPhotoPrompt = true
                showPhotoPanel()
            }
            if seahorseNode != nil, mantaNode != nil {
                hideEnd3HintBubble()
            }
            return
        }
        
        if let container = photoNode {
            let locationInside = touch.location(in: container)
            

            if let button = pictureBookButton, button.contains(locationInside) {
                presentPictureBook()
                return
            }
            
            if let button = saveButton,
               let photo = capturedPhoto,
               button.contains(locationInside) {
                savePhoto(from: photo)
                return
            }

        }

       
        if knotsVisible {
            for (index, knot) in knotNodes.enumerated() {
                if knot.parent != nil, knot.contains(location), !knotsUntied[index] {
                    isDraggingKnot = true
                    draggedKnotIndex = index
                 
                    clearTipsGuide()
                    return
                }
            }
        }

     
        for garbage in garbageNodes {
            if garbage.contains(location) {
                cleanGarbage(garbage)
            
                clearTipsGuide()
                return
            }
        }

        
        moveBabyTurtle(to: location)
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

        if isDraggingKnot, let index = draggedKnotIndex,
           index < knotNodes.count {
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
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDraggingKnot = false
        draggedKnotIndex = nil
        isDraggingHistory = false
    }

    private func moveBabyTurtle(to position: CGPoint) {
        babyTurtle.removeAllActions()
        let dx = position.x - babyTurtle.position.x
        babyTurtle.xScale = abs(babyTurtle.xScale) * (dx >= 0 ? 1 : -1)
        let distance = hypot(dx, position.y - babyTurtle.position.y)
        let speed: CGFloat = 200
        let duration = TimeInterval(distance / speed)
        let move = SKAction.move(to: position, duration: duration)
        move.timingMode = .easeInEaseOut
        babyTurtle.run(move)
    }


    private func cleanGarbage(_ node: SKSpriteNode) {
        node.name = nil
        let fade = SKAction.fadeOut(withDuration: 0.25)
        let scale = SKAction.scale(to: 0.2, duration: 0.25)
        node.run(SKAction.sequence([.group([fade, scale]), .removeFromParent()]))

        cleanedGarbageCount += 1
        garbageNodes.removeAll { $0 == node }


        let total = max(1, garbageNames.count)
        let remainingRatio = CGFloat(max(0, total - cleanedGarbageCount)) / CGFloat(total)
        let targetAlpha = 0.55 * remainingRatio
        fogNode.run(SKAction.fadeAlpha(to: targetAlpha, duration: 0.3))


        if garbageNodes.isEmpty {
            fogNode.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.4),
                .removeFromParent()
            ]))
            if !knotsVisible {
                showKnots()
            }
        }
    }


    override func update(_ currentTime: TimeInterval) {
  
        if garbageNodes.isEmpty, !knotsVisible {
            let distance = hypot(babyTurtle.position.x - motherTurtle.position.x,
                                 babyTurtle.position.y - motherTurtle.position.y)
            if distance < motherTriggerDistance {
                showKnots()
            }
        }

   
        if let bubble = end3HintBubble {
            bubble.position = CGPoint(
                x: babyTurtle.position.x,
                y: babyTurtle.position.y + size.height * 0.14
            )
        }
    }


    private func showKnots() {
        guard !knotsVisible else { return }
        knotsVisible = true

        let offsets: [CGPoint] = [
            CGPoint(x: -motherTurtle.size.width * 0.25, y: motherTurtle.size.height * 0.2),
            CGPoint(x:  motherTurtle.size.width * 0.2,  y: 0),
            CGPoint(x: -motherTurtle.size.width * 0.1, y: -motherTurtle.size.height * 0.25)
        ]
        let directions: [CGPoint] = [
            CGPoint(x: 1, y: 0),
            CGPoint(x: -1, y: 0),
            CGPoint(x: 0, y: 1)
        ]

        for (index, offset) in offsets.enumerated() {
            let knot = SKSpriteNode(imageNamed: knotName)
            let worldPos = CGPoint(x: motherTurtle.position.x + offset.x,
                                   y: motherTurtle.position.y + offset.y)
            knot.position = worldPos
            knot.zPosition = 3
            knot.setScale(0.1)
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
            addChild(hint)
            knotHints.append(hint)
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

        if index < knotHints.count {
            knotHints[index].run(SKAction.fadeOut(withDuration: 0.3))
        }

  
        let shrinkStep = SKAction.scale(by: 0.7, duration: 0.25)
        netNode.run(shrinkStep)


        if knotsUntied.allSatisfy({ $0 }) {
   
            stopMotherWiggle()

            let finalShrink = SKAction.group([
                SKAction.scale(to: 0.05, duration: 0.35),
                SKAction.fadeOut(withDuration: 0.35)
            ])
            netNode.run(SKAction.sequence([finalShrink, .removeFromParent()]))

   
            let text = "Thank you, Mother Turtle can swim freely again."
            showNarrator(text: text)

 
            let charInterval: TimeInterval = 0.03
            let duration = Double(text.count) * charInterval

            run(SKAction.sequence([
                SKAction.wait(forDuration: duration + 1.0),
                SKAction.run { [weak self] in
                    self?.showEndPanel()
                }
            ]))
        }
    }

  
    private func startMotherWiggle() {
        let wiggle = SKAction.sequence([
            SKAction.rotate(byAngle: 0.04, duration: 0.15),
            SKAction.rotate(byAngle: -0.08, duration: 0.15),
            SKAction.rotate(byAngle: 0.04, duration: 0.15),
            SKAction.rotate(toAngle: 0, duration: 0.12)
        ])
        let repeatWiggle = SKAction.repeatForever(wiggle)
        motherTurtle.run(repeatWiggle, withKey: "motherWiggle")
    }

    private func stopMotherWiggle() {
        motherTurtle.removeAction(forKey: "motherWiggle")
        motherTurtle.run(SKAction.rotate(toAngle: 0, duration: 0.2))
    }

   
    private func startMotherNarration() {
        let text1 = "Mother Turtle is trapped."
        let text2 = "Help Mother Turtle just like you helped the seahorse and the manta ray."

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

    private func showNarrator(text: String) {

        narratorHistory.append(text)

        narratorNode?.removeFromParent()
        narratorNode = nil
        narratorLabel = nil

        let (node, label) = Tips.createNarratorNode(sceneSize: size, text: text, yFactor: 0.8)
        addChild(node)
        narratorNode = node
        narratorLabel = label

        Tips.runTypingAnimation(on: label, text: text)
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

   
        if end3SequenceStarted {
            handleEnd3Tips()
            return
        }


        if let garbage = garbageNodes.first {
            let guide = Tips.createFingerRippleGuide(center: garbage.position, fingerOffsetY: -10)
            addChild(guide)
            tipsGuideNode = guide
            return
        }

  
        if knotsVisible {
            showKnotTips()
        }
    }


    private func handleEnd3Tips() {
        clearTipsGuide()


        if let outline = seahorseOutline {
            let guide = Tips.createFingerRippleGuide(center: outline.position, fingerOffsetY: -10)
            addChild(guide)
            tipsGuideNode = guide
            return
        }


        if let outline = mantaOutline {
            let guide = Tips.createFingerRippleGuide(center: outline.position, fingerOffsetY: -10)
            addChild(guide)
            tipsGuideNode = guide
            return
        }

 
        if let button = cameraButton {
            let guide = Tips.createFingerRippleGuide(center: button.position, fingerOffsetY: 30)
            addChild(guide)
            tipsGuideNode = guide
        }
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

     
        var end = CGPoint(x: start.x + 80, y: start.y)
        if index < knotHints.count {
            let hintPos = knotHints[index].position
            let vx = hintPos.x - start.x
            let vy = hintPos.y - start.y
            let len = hypot(vx, vy)
            if len > 0.001 {
                let dir = CGPoint(x: vx / len, y: vy / len)
                let dragLength: CGFloat = 80
                end = CGPoint(x: start.x + dir.x * dragLength,
                              y: start.y + dir.y * dragLength)
            }
        }

        let guide = Tips.createFingerDragGuide(from: start, to: end, forwardDuration: 0.6)
        addChild(guide)
        tipsGuideNode = guide
    }



    private func showEndPanel() {
        guard endPanel == nil else { return }

        let panelWidth = size.width * 0.55
        let panelHeight = size.height * 0.25
        let rectSize = CGSize(width: panelWidth, height: panelHeight)

        let panel = SKShapeNode(rectOf: rectSize, cornerRadius: 28)
        panel.fillColor = boardBackgroundColor
        panel.strokeColor = boardBorderColor
        panel.lineWidth = 4
        panel.zPosition = 50
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.55)

        let text = """
🎉You helped the baby turtle find her mother.
Now it’s time to swim home.
"""
        let textLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        textLabel.fontSize = 22
        textLabel.fontColor = .white
        textLabel.verticalAlignmentMode = .center
        textLabel.horizontalAlignmentMode = .center
        textLabel.numberOfLines = 0
        textLabel.preferredMaxLayoutWidth = panelWidth * 0.88
        textLabel.position = CGPoint(x: 0, y: 20)
        textLabel.text = ""
        panel.addChild(textLabel)
        endTextLabel = textLabel

        let buttonLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        buttonLabel.fontSize = 22
        buttonLabel.fontColor = boardButtonColor //SKColor.yellow
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.horizontalAlignmentMode = .center
        buttonLabel.text = "Swim Home"
        buttonLabel.name = "endSwimHome"
        buttonLabel.position = CGPoint(x: 0, y: -panelHeight * 0.36)
        panel.addChild(buttonLabel)
        endButtonLabel = buttonLabel

        addChild(panel)
        endPanel = panel
        animateEndText(text)
    }


    private func animateEndText(_ text: String) {
        guard let label = endTextLabel else { return }
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

    private func hideEndPanelAndScroll() {
        guard let panel = endPanel else {
            scrollBackgroundToNextScenes()
            return
        }
        panel.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        endPanel = nil
        endTextLabel = nil
        endButtonLabel = nil
        scrollBackgroundToNextScenes()
    }

    private func scrollBackgroundToNextScenes() {
        let moveToEnd2 = SKAction.moveBy(x: -size.width, y: 0, duration: 2.0)
        moveToEnd2.timingMode = .easeInEaseOut

        backgroundContainer.run(moveToEnd2) { [weak self] in
            guard let self = self else { return }

   
            let wait = SKAction.wait(forDuration: 1.0)
            self.run(wait) { [weak self] in
                guard let self = self else { return }

  
                let flash = SKSpriteNode(color: .white, size: self.size)
                flash.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
                flash.zPosition = 100
                flash.alpha = 0
                self.addChild(flash)

                let flashIn = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
                let hold = SKAction.wait(forDuration: 1.0)
                let flashOut = SKAction.fadeAlpha(to: 0.0, duration: 0.25)
                let flashSeq = SKAction.sequence([flashIn, hold, flashOut, .removeFromParent()])
                flash.run(flashSeq)

                let moveToEnd3 = SKAction.moveBy(x: -self.size.width, y: 0, duration: 2.0)
                moveToEnd3.timingMode = .easeInEaseOut
                self.backgroundContainer.run(moveToEnd3) { [weak self] in
                    self?.startEnd3Sequence()
                }
            }
        }
    }


    private func startEnd3Sequence() {
        guard !end3SequenceStarted else { return }
        end3SequenceStarted = true
        progressNode?.updateStage(.home)

  
        let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        motherTurtle.position = center

  
        let orbitNode = SKNode()
        orbitNode.position = center
        orbitNode.zPosition = babyTurtle.zPosition
        addChild(orbitNode)

        babyTurtle.removeAllActions()
        babyTurtle.removeFromParent()
        let radius = motherTurtle.size.width * 0.9
        babyTurtle.position = CGPoint(x: radius, y: 0)
        orbitNode.addChild(babyTurtle)

        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 3.0)
        orbitNode.run(rotate) { [weak self, weak orbitNode] in
            guard let self = self, let orbitNode = orbitNode else { return }

    
            _ = orbitNode.convert(self.babyTurtle.position, to: self)
            self.babyTurtle.removeFromParent()
            self.babyTurtle.position = CGPoint(
                x: self.motherTurtle.position.x + self.motherTurtle.size.width * 0.15,
                y: self.motherTurtle.position.y - self.motherTurtle.size.height * 0.25
            )
            self.babyTurtle.xScale = -abs(self.babyTurtle.xScale)
            self.addChild(self.babyTurtle)
            orbitNode.removeFromParent()

            self.showEnd3FriendsAndCamera()
            self.startEnd3Narration()
        }
    }


    private func startEnd3Narration() {
        let text1 = "The little turtle is so happy!💗"
        let text2 = "Tap the glowing shapes to gather the friends you saved."

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

    private func showEnd3HintBubble() {
        guard end3HintBubble == nil else { return }

        let container = SKNode()
        container.zPosition = 20
        container.name = "end3_hint_bubble"

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "Tap the glowing shapes to gather the friends you saved."
        label.fontSize = 18
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = size.width * 0.4

        let paddingX: CGFloat = 24
        let paddingY: CGFloat = 16
        let bubbleSize = CGSize(width: label.frame.width + paddingX,
                                height: label.frame.height + paddingY)

        let rect = SKShapeNode(rectOf: bubbleSize, cornerRadius: 18)
        rect.fillColor = SKColor.white.withAlphaComponent(0.9)
        rect.strokeColor = SKColor.black
        rect.lineWidth = 3
        rect.zPosition = -1

        container.addChild(rect)
        container.addChild(label)
        addChild(container)
        end3HintBubble = container
    }

    private func hideEnd3HintBubble() {
        guard let bubble = end3HintBubble else { return }
        bubble.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        end3HintBubble = nil
    }

  
    private func whiteSilhouetteTexture(imageNamed name: String) -> SKTexture? {
        guard let image = UIImage(named: name),
              let cgImage = image.cgImage else { return nil }
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return nil }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let data = context.data else { return nil }
        let bytesPerPixel = 4
        let bytesPerRow = context.bytesPerRow
        for y in 0..<height {
            for x in 0..<width {
                let offset = y * bytesPerRow + x * bytesPerPixel
                let a = data.load(fromByteOffset: offset + 3, as: UInt8.self)
              
                data.storeBytes(of: a, toByteOffset: offset, as: UInt8.self)
                data.storeBytes(of: a, toByteOffset: offset + 1, as: UInt8.self)
                data.storeBytes(of: a, toByteOffset: offset + 2, as: UInt8.self)
            }
        }
        guard let newCGImage = context.makeImage() else { return nil }
        let newImage = UIImage(cgImage: newCGImage, scale: image.scale, orientation: image.imageOrientation)
        return SKTexture(image: newImage)
    }

    private func showEnd3FriendsAndCamera() {
        let center = motherTurtle.position


        if seahorseOutline == nil, let whiteTex = whiteSilhouetteTexture(imageNamed: "seahorse") {
            let node = SKSpriteNode(texture: whiteTex)
            node.position = CGPoint(
                x: center.x - motherTurtle.size.width * 0.6,
                y: center.y + motherTurtle.size.height * 0.2
            )
            node.zPosition = 2
            node.setScale(0.15)
            node.alpha = 0.9
            node.name = "seahorse_outline"
            node.xScale = -abs(node.yScale)
            addChild(node)
            seahorseOutline = node
        }

        if mantaOutline == nil, let whiteTex = whiteSilhouetteTexture(imageNamed: "Manta Ray") {
            let node = SKSpriteNode(texture: whiteTex)
            node.position = CGPoint(
                x: center.x + motherTurtle.size.width * 1,
                y: center.y + motherTurtle.size.height * 0.2
            )
            node.zPosition = 2
            node.setScale(0.35)
            node.alpha = 0.9
            node.name = "manta_outline"
            addChild(node)
            mantaOutline = node
        }
    }

    private func showPhotoPanel() {
        guard photoPanel == nil else { return }

        let panelWidth = size.width * 0.55
        let panelHeight = size.height * 0.25
        let rectSize = CGSize(width: panelWidth, height: panelHeight)

        let panel = SKShapeNode(rectOf: rectSize, cornerRadius: 28)
        panel.fillColor = boardBackgroundColor
        panel.strokeColor = boardBorderColor
        panel.lineWidth = 4
        panel.zPosition = 80
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.55)

        let textLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        textLabel.fontSize = 22
        textLabel.fontColor = .white
        textLabel.verticalAlignmentMode = .center
        textLabel.horizontalAlignmentMode = .center
        textLabel.numberOfLines = 0
        textLabel.preferredMaxLayoutWidth = panelWidth * 0.88
        textLabel.position = CGPoint(x: 0, y: 20)
        textLabel.text = ""
        panel.addChild(textLabel)
        photoTextLabel = textLabel

   
        let backLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        backLabel.fontSize = 22
        backLabel.fontColor = .white
        backLabel.horizontalAlignmentMode = .left
        backLabel.verticalAlignmentMode = .center
        backLabel.text = "< Back"
        backLabel.name = "photoBack"
        backLabel.position = CGPoint(x: -panelWidth * 0.36, y: -panelHeight * 0.36)
        panel.addChild(backLabel)
        photoBackLabel = backLabel

   
        let nextLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        nextLabel.fontSize = 22
        nextLabel.fontColor = boardButtonColor
        nextLabel.horizontalAlignmentMode = .right
        nextLabel.verticalAlignmentMode = .center
        nextLabel.text = "Next"
        nextLabel.name = "photoNext"
        nextLabel.position = CGPoint(x: panelWidth * 0.36, y: -panelHeight * 0.36)
        panel.addChild(nextLabel)
        photoNextLabel = nextLabel

        addChild(panel)
        photoPanel = panel
        photoPageIndex = 0
        showPhotoPage(index: 0)
    }

    private func hidePhotoPanelAndShowCamera() {
        guard let panel = photoPanel else {
            showCameraButton()
            return
        }
        panel.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        photoPanel = nil
        photoTextLabel = nil
        photoBackLabel = nil
        photoNextLabel = nil
        showCameraButton()
    }

    private func showPhotoPage(index: Int) {
        guard index >= 0, index < photoMessages.count else { return }
        photoPageIndex = index
        let text = photoMessages[index]
        animatePhotoText(text)


        photoBackLabel?.alpha = index == 0 ? 0.3 : 1.0
        if index == photoMessages.count - 1 {
            photoNextLabel?.text = "OK"
        } else {
            photoNextLabel?.text = "Next"
        }
    }

    private func animatePhotoText(_ text: String) {
        guard let label = photoTextLabel else { return }
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

    private func showCameraButton() {
        guard cameraButton == nil else { return }

        let texture: SKTexture?
        if let image = UIImage(systemName: "camera.circle") {
            texture = SKTexture(image: image)
        } else {
            texture = nil
        }

        let button: SKSpriteNode
        if let texture = texture {
            button = SKSpriteNode(texture: texture)
        } else {
            button = SKSpriteNode(color: .white, size: CGSize(width: 60, height: 60))
        }

        button.position = CGPoint(x: size.width * 0.5, y: size.height * 0.12)
        button.zPosition = 60
        button.setScale(4)
        button.name = "camera_button"
        addChild(button)
        cameraButton = button
    }

    private func handleCameraTap() {
    
        clearTipsGuide()

  
        run(shotSfx)
        
        photoNode?.removeFromParent()
        photoNode = nil

        let wasCameraHidden = cameraButton?.isHidden ?? false
        let wasProgressHidden = progressNode?.isHidden ?? false
        let wasNarratorHidden = narratorNode?.isHidden ?? false
        let wasTipsHidden = tipsButtonNode?.isHidden ?? false
        let wasLogHidden = logButtonNode?.isHidden ?? false

        cameraButton?.isHidden = true
        progressNode?.isHidden = true
        narratorNode?.isHidden = true
        tipsButtonNode?.isHidden = true
        logButtonNode?.isHidden = true

        guard let view = view, let texture = view.texture(from: self) else {
            cameraButton?.isHidden = wasCameraHidden
            progressNode?.isHidden = wasProgressHidden
            narratorNode?.isHidden = wasNarratorHidden
            tipsButtonNode?.isHidden = wasTipsHidden
            logButtonNode?.isHidden = wasLogHidden
            return
        }

    
        cameraButton?.isHidden = wasCameraHidden
        progressNode?.isHidden = wasProgressHidden
        narratorNode?.isHidden = wasNarratorHidden
        tipsButtonNode?.isHidden = wasTipsHidden
        logButtonNode?.isHidden = wasLogHidden
        let photo = SKSpriteNode(texture: texture)

        let scale = min(size.width / texture.size().width,
                        size.height / texture.size().height) * 0.7
        photo.setScale(scale)
        photo.position = CGPoint(x: size.width / 2, y: size.height / 2)
        photo.zPosition = 70


        let frameSize = CGSize(width: photo.size.width,
                               height: photo.size.height)
        let border = SKShapeNode(rectOf: frameSize, cornerRadius: 20)
        border.strokeColor = .white
        border.lineWidth = 10
        border.fillColor = .clear
        border.zPosition = photo.zPosition + 1

        let container = SKNode()
        container.position = photo.position
        container.zPosition = photo.zPosition
        addChild(container)

        photo.position = CGPoint.zero
        border.position = CGPoint.zero
        container.addChild(border)
        container.addChild(photo)
        capturedPhoto = photo
        
  
        let saveButtonTexture = SKTexture(imageNamed: "square.and.arrow.down")
        let saveButton = SKSpriteNode(texture: saveButtonTexture)
        saveButton.name = "saveButton"
        saveButton.size = saveButtonTexture.size()
        saveButton.position = CGPoint(x: 0, y: -photo.size.height / 2 + 40)
        saveButton.zPosition = photo.zPosition + 1
        container.addChild(saveButton)
        self.saveButton = saveButton
        
        let buttonBackground = SKShapeNode(circleOfRadius: 24)
        buttonBackground.fillColor = .white
        buttonBackground.position = saveButton.position
        buttonBackground.zPosition = saveButton.zPosition - 0.1
        container.addChild(buttonBackground)
        

        let buttonContainer = SKNode()
        buttonContainer.name = "pictureBookButton"
        buttonContainer.zPosition = photo.zPosition + 2
        buttonContainer.position = CGPoint(x: 0, y: -photo.size.height * 0.6)

        let titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        titleLabel.text = "From Rescue to Reality"
        titleLabel.fontSize = 22
        titleLabel.fontColor = .black
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .center

        let paddingX: CGFloat = 32
        let paddingY: CGFloat = 16
        let bubbleSize = CGSize(width: titleLabel.frame.width + paddingX,
                                height: titleLabel.frame.height + paddingY)

        let rect = SKShapeNode(rectOf: bubbleSize, cornerRadius: 18)
        rect.fillColor = SKColor.white.withAlphaComponent(1.0)
        rect.strokeColor = .black
        rect.lineWidth = 2
        rect.zPosition = -1

        buttonContainer.addChild(rect)
        buttonContainer.addChild(titleLabel)

        container.addChild(buttonContainer)
        pictureBookButton = buttonContainer

        clearTipsGuide()

        let buttonWorldPos = container.convert(buttonContainer.position, to: self)
        let guide = Tips.createFingerRippleGuide(center: buttonWorldPos, fingerOffsetY: -10)
        addChild(guide)
        tipsGuideNode = guide

        photoNode = container
    }
    
    private func savePhoto(from node: SKSpriteNode) {
   
        if let image = node.toImage()?.flattenedOnWhiteBackground() {
            saveImageToAlbum(image) { success, error in
                print("save:", success, error as Any)
            }
        }
    }
    
    private func presentShareSheet(items: [Any], sourceView: UIView?, sourceRect: CGRect) {
        guard let vc = view?.window?.rootViewController else { return }
        
        let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        

        if let pop = avc.popoverPresentationController {
            pop.sourceView = sourceView ?? vc.view
            pop.sourceRect = sourceRect
        }
        
        vc.present(avc, animated: true)
    }
    

    private func presentPictureBook() {
        let scene = PictureBookScene(size: size)
        scene.scaleMode = scaleMode
        scene.endPhotoTexture = capturedPhoto?.texture
        scene.fromTitlepage = false
        view?.presentScene(scene, transition: .fade(withDuration: 0.8))
    }
}


import SwiftUI
#Preview {
    SpriteView(scene: OceanScene3(size: CGSize(width: 1024, height: 768)))
        .ignoresSafeArea()
}
