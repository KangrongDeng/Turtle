import SpriteKit
import UIKit


class PictureBookScene: SKScene {
    private var currentPage: Int = 0
    private let pageContainer = SKNode()
    
    private var prevButton: SKNode?
    private var nextButton: SKNode?
    private var bottomBackButton: SKNode?
    
    var fromTitlepage: Bool = false
    var endPhotoTexture: SKTexture?
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        addChild(pageContainer)
        setupNavigationButtons()
        showPage(index: 0, animated: false)
    }
    
 
    
    private func showPage(index: Int, animated: Bool) {
        let clamped = max(0, min(4, index))
        currentPage = clamped
        
        pageContainer.removeAllActions()
        pageContainer.removeAllChildren()
        
        switch clamped {
        case 0: buildPage1()
        case 1: buildPage2()
        case 2: buildPage3()
        case 3: buildPage4()
        default: buildPage5()
        }
        
        updateNavButtonsState()
    }
    
  
    private func buildPage1() {
        let text = """
🌍 The Ocean Is Facing Challenges
The ocean gives us life. But today, it is under threat.
"""
        
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.fontSize = 26
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = size.width * 0.7
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        label.text = ""
        
        pageContainer.addChild(label)
        runTyping(on: label, text: text, charInterval: 0.03)
    }
    

    private func buildPage2() {
        let leftX = size.width * 0.25
        let rightX = size.width * 0.55
        let topY = size.height * 0.8
        let verticalSpacing: CGFloat = size.height * 0.26
        
        let imageNames = ["1-1", "1-2", "1-3"]
        let texts: [String] = [
            "📌 It is estimated that 8–12 million tons of plastic enter the ocean every year. That is roughly the equivalent of one garbage truck of plastic being dumped into the ocean every minute.",
            "📌 Plastic can take over 450 years to break down. Even then, it does not fully disappear — it simply breaks into smaller pieces.",
            "📌 There may be more than 5.25 trillion pieces of plastic in the ocean today, including microplastics and even nanoplastics."
        ]
        
        for i in 0..<3 {
            let delayImage = TimeInterval(i) * 2.0
            let delayText = delayImage + 1.0
            let y = topY - CGFloat(i) * verticalSpacing
            
   
            if i < imageNames.count {
                let name = imageNames[i]
                let imgAction = SKAction.sequence([
                    SKAction.wait(forDuration: delayImage),
                    SKAction.run { [weak self] in
                        guard let self = self else { return }
                        let sprite = SKSpriteNode(imageNamed: name)
                        sprite.position = CGPoint(x: leftX, y: y)
                        sprite.zPosition = 1
                        let targetWidth = self.size.width * 0.25
                        let scale = targetWidth / max(sprite.size.width, 1)
                        sprite.setScale(scale)
                        sprite.alpha = 0
                        self.pageContainer.addChild(sprite)
                        sprite.run(SKAction.fadeIn(withDuration: 0.25))
                    }
                ])
                pageContainer.run(imgAction)
            }
            
       
            if i < texts.count {
                let text = texts[i]
                let textAction = SKAction.sequence([
                    SKAction.wait(forDuration: delayText),
                    SKAction.run { [weak self] in
                        guard let self = self else { return }
                        let label = SKLabelNode(fontNamed: "Menlo-Bold")
                        label.fontSize = 20
                        label.fontColor = .black
                        label.verticalAlignmentMode = .center
                        label.horizontalAlignmentMode = .left
                        label.numberOfLines = 0
                        label.preferredMaxLayoutWidth = self.size.width * 0.35
                        label.text = text

                        let node = SKNode()
                        node.position = CGPoint(x: rightX, y: y)
                        node.zPosition = 1
                        node.alpha = 0
                        self.pageContainer.addChild(node)
                        
                        label.position = CGPoint.zero
                        node.addChild(label)
                        
                        node.run(SKAction.fadeIn(withDuration: 0.25))
                    }
                ])
                pageContainer.run(textAction)
            }
        }
    }

    private func buildPage3() {
        let leftX = size.width * 0.25
        let rightX = size.width * 0.5
        let topY = size.height * 0.75
        let imageSpacing: CGFloat = size.height * 0.25
        let textSpacing: CGFloat = size.height * 0.25
        
        let imageNames = ["2-1", "2-2"]
        let texts: [String] = [
            "🐦 Around 90% of seabirds are believed to have ingested plastic. Each year, approximately 1 million seabirds and hundreds of thousands of marine mammals die due to plastic pollution.",
            "🐢 Even a very small amount — just a few pieces the size of sugar cubes — can be enough to cause serious harm or even death.",
            "🐋 Contact with plastic increases coral disease rates by about 20%. Studies have found that around 50% of fish contain plastic in their stomachs."
        ]
        
  
        for i in 0..<imageNames.count {
            let delay = TimeInterval(i) * 1.0
            let y = topY - CGFloat(i) * imageSpacing
            let name = imageNames[i]
            let action = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    let sprite = SKSpriteNode(imageNamed: name)
                    sprite.position = CGPoint(x: leftX, y: y)
                    sprite.zPosition = 1
                    let targetWidth = self.size.width * 0.25
                    let scale = targetWidth / max(sprite.size.width, 1)
                    sprite.setScale(scale)
                    sprite.alpha = 0
                    self.pageContainer.addChild(sprite)
                    sprite.run(SKAction.fadeIn(withDuration: 0.25))
                }
            ])
            pageContainer.run(action)
        }
        
    
        let baseTextDelay = TimeInterval(imageNames.count) * 1.0
        for i in 0..<texts.count {
            let delay = baseTextDelay + TimeInterval(i) * 1.0
            let y = topY - CGFloat(i) * textSpacing
            let text = texts[i]
            
            let action = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    let label = SKLabelNode(fontNamed: "Menlo-Bold")
                    label.fontSize = 20
                    label.fontColor = .black
                    label.verticalAlignmentMode = .center
                    label.horizontalAlignmentMode = .left
                    label.numberOfLines = 0
                    label.preferredMaxLayoutWidth = self.size.width * 0.35
                    label.text = text
                    
                    let node = SKNode()
                    node.position = CGPoint(x: rightX, y: y)
                    node.zPosition = 1
                    node.alpha = 0
                    self.pageContainer.addChild(node)
                    
                    label.position = CGPoint.zero
                    node.addChild(label)
                    
                    node.run(SKAction.fadeIn(withDuration: 0.25))
                }
            ])
            pageContainer.run(action)
        }
    }
    
 
    private func buildPage4() {
        let text = """
📉 A recent study shows that when the ocean floor temperature rises by just 0.1°C per decade, total fish biomass may decline by approximately 7.2%.
"""
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.fontSize = 24
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = size.width * 0.7
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        label.text = ""
        
        pageContainer.addChild(label)
        runTyping(on: label, text: text, charInterval: 0.03) { [weak self, weak label] in
            guard let self = self, let label = label else { return }
            self.showTemperatureAndChartAnimations(below: label)
        }
    }
    
 
    private func buildPage5() {
        let titleText = "🌊 The Future Is Still in Our Hands. Small actions create real change!"
        
        let titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        titleLabel.fontSize = 24
        titleLabel.fontColor = .black
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.numberOfLines = 0
        titleLabel.preferredMaxLayoutWidth = size.width * 0.8
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        titleLabel.text = ""
        pageContainer.addChild(titleLabel)
        
        runTyping(on: titleLabel, text: titleText, charInterval: 0.03)
        
     
        let delay: TimeInterval = 1.2
        let action = SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                
                let sprite: SKSpriteNode
                if let texture = self.endPhotoTexture {
                    sprite = SKSpriteNode(texture: texture)
                } else {
                    sprite = SKSpriteNode(color: SKColor.white.withAlphaComponent(0.9),
                                          size: CGSize(width: self.size.width * 0.6,
                                                       height: self.size.height * 0.5))
                    let border = SKShapeNode(rectOf: sprite.size, cornerRadius: 20)
                    border.strokeColor = .black
                    border.lineWidth = 3
                    border.fillColor = .clear
                    border.zPosition = 1
                    
                    let container = SKNode()
                    container.position = CGPoint(x: self.size.width / 2,
                                                 y: self.size.height * 0.45)
                    container.zPosition = 10
                    self.pageContainer.addChild(container)
                    
                    sprite.position = .zero
                    sprite.zPosition = 0
                    container.addChild(sprite)
                    border.position = .zero
                    container.addChild(border)
                    
                    let placeholder = SKLabelNode(fontNamed: "Menlo-Bold")
                    placeholder.text = "Photo from your ocean journey"
                    placeholder.fontSize = 22
                    placeholder.fontColor = .black
                    placeholder.verticalAlignmentMode = .center
                    placeholder.horizontalAlignmentMode = .center
                    placeholder.numberOfLines = 0
                    placeholder.preferredMaxLayoutWidth = sprite.size.width * 0.9
                    placeholder.position = CGPoint.zero
                    container.addChild(placeholder)
                    
                    container.alpha = 0
                    container.run(SKAction.fadeIn(withDuration: 0.3))
                    return
                }
                
                let container = SKNode()
                container.position = CGPoint(x: self.size.width / 2,
                                             y: self.size.height * 0.45)
                container.zPosition = 10
                self.pageContainer.addChild(container)
                
                let targetSize = CGSize(width: self.size.width * 0.65,
                                        height: self.size.height * 0.55)
                let scale = min(targetSize.width / sprite.size.width,
                                targetSize.height / sprite.size.height)
                sprite.setScale(scale)
                sprite.position = .zero
                sprite.zPosition = 0
                container.addChild(sprite)
                
                let frameSize = CGSize(width: sprite.size.width * 1.05,
                                       height: sprite.size.height * 1.05)
                let border = SKShapeNode(rectOf: frameSize, cornerRadius: 20)
                border.strokeColor = .white
                border.lineWidth = 10
                border.fillColor = .clear
                border.zPosition = -1
                container.addChild(border)
                
                container.alpha = 0
                container.run(SKAction.fadeIn(withDuration: 0.3))

             
                self.setupBottomBackButton()
            }
        ])
        
        pageContainer.run(action)
    }

    private func setupBottomBackButton() {
        bottomBackButton?.removeFromParent()

        let container = SKNode()
        container.zPosition = 50
        let buttonText = fromTitlepage ? "Back" : "Back to Start"

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = buttonText
        label.fontSize = 22
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center

        let paddingX: CGFloat = 32
        let paddingY: CGFloat = 14
        let bubbleSize = CGSize(width: label.frame.width + paddingX,
                                height: label.frame.height + paddingY)

        let rect = SKShapeNode(rectOf: bubbleSize, cornerRadius: 18)
        rect.fillColor = SKColor.white.withAlphaComponent(0.25)
        rect.strokeColor = .black
        rect.lineWidth = 2
        rect.zPosition = -1

        container.addChild(rect)
        container.addChild(label)

        container.position = CGPoint(x: size.width / 2,
                                     y: size.height * 0.1)
        pageContainer.addChild(container)
        bottomBackButton = container
    }
    
   
    
    private func runTyping(
        on label: SKLabelNode,
        text: String,
        charInterval: TimeInterval,
        completion: (() -> Void)? = nil
    ) {
        label.removeAllActions()
        label.text = ""
        
        let characters = Array(text)
        var actions: [SKAction] = []
        
        for ch in characters {
            let append = SKAction.run { [weak label] in
                guard let label = label else { return }
                label.text = (label.text ?? "") + String(ch)
            }
            let wait = SKAction.wait(forDuration: charInterval)
            actions.append(append)
            actions.append(wait)
        }
        
        if let completion = completion {
            let done = SKAction.run(completion)
            actions.append(done)
        }
        
        label.run(SKAction.sequence(actions))
    }


    
    private func showTemperatureAndChartAnimations(below label: SKLabelNode) {
        let baseY = label.position.y - label.frame.height / 2 - 40
        let leftX = size.width * 0.3
        let rightX = size.width * 0.7
        let midX = (leftX + rightX) / 2.0
        
    
        let thermometerTexture: SKTexture?
        if let image = UIImage(systemName: "thermometer.sun") {
            thermometerTexture = SKTexture(image: image)
        } else {
            thermometerTexture = nil
        }
        
        let thermometer: SKSpriteNode
        if let texture = thermometerTexture {
            thermometer = SKSpriteNode(texture: texture)
        } else {
            thermometer = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 80))
        }
        thermometer.position = CGPoint(x: leftX, y: baseY-40)
        thermometer.zPosition = 10
        thermometer.alpha = 0
        thermometer.setScale(0.1)
        pageContainer.addChild(thermometer)
        
        let rise = SKAction.group([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.moveBy(x: 0, y: 30, duration: 1.2),
            SKAction.scale(to: 1.8, duration: 1.2)
        ])
        
        thermometer.run(rise) { [weak self, weak thermometer] in
            guard let self = self, let thermometer = thermometer else { return }
            
         
            let valueLabel = SKLabelNode(fontNamed: "Menlo-Bold")
            valueLabel.text = "0.1°C"
            valueLabel.fontSize = 20
            valueLabel.fontColor = .black
            valueLabel.verticalAlignmentMode = .top
            valueLabel.horizontalAlignmentMode = .center
            valueLabel.position = CGPoint(x: thermometer.position.x,
                                          y: thermometer.position.y - thermometer.calculateAccumulatedFrame().height / 2 - 8)
            valueLabel.alpha = 0
            valueLabel.zPosition = 10
            self.pageContainer.addChild(valueLabel)
            valueLabel.run(SKAction.fadeIn(withDuration: 0.4))
            
 
            let arrowTexture: SKTexture?
            if let image = UIImage(systemName: "arrow.right") {
                arrowTexture = SKTexture(image: image)
            } else {
                arrowTexture = nil
            }
            
            let arrow: SKSpriteNode
            if let texture = arrowTexture {
                arrow = SKSpriteNode(texture: texture)
            } else {
                arrow = SKSpriteNode(color: .black, size: CGSize(width: 40, height: 12))
            }
            arrow.position = CGPoint(x: midX, y: baseY - 10)
            arrow.zPosition = 10
            arrow.alpha = 0
            arrow.setScale(0.1)
            self.pageContainer.addChild(arrow)
            
            let arrowAppear = SKAction.group([
                SKAction.fadeIn(withDuration: 0.2),
                SKAction.scale(to: 1.4, duration: 0.5)
            ])
            let arrowMove = SKAction.moveBy(x: 20, y: 0, duration: 0.5)
            let arrowSeq = SKAction.sequence([
                SKAction.group([arrowAppear, arrowMove])
            ])
            
            arrow.run(arrowSeq) { [weak self] in
                self?.showDeclineChart(atX: rightX, belowY: baseY - 10)
            }
        }
    }
    
    private func showDeclineChart(atX x: CGFloat, belowY: CGFloat) {
        let chartTexture: SKTexture?
        if #available(iOS 16.0, *) {
            if let image = UIImage(systemName: "chart.line.downtrend.xyaxis") {
                chartTexture = SKTexture(image: image)
            } else {
                chartTexture = nil
            }
        } else {
            chartTexture = nil
        }
        
        let chart: SKSpriteNode
        if let texture = chartTexture {
            chart = SKSpriteNode(texture: texture)
        } else {
 
            let size = CGSize(width: self.size.width * 0.45, height: 40)
            let shape = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -size.width / 2, y: size.height / 2))
            path.addLine(to: CGPoint(x: size.width / 2, y: -size.height / 2))
            shape.path = path
            shape.strokeColor = .blue
            shape.lineWidth = 4
            
            let container = SKSpriteNode(color: .clear, size: size)
            container.addChild(shape)
            chart = container
        }
        
        chart.position = CGPoint(x: x, y: belowY-3)
        chart.zPosition = 10
        chart.alpha = 0
        chart.setScale(0.1)
        pageContainer.addChild(chart)
        
        let appear = SKAction.group([
            SKAction.fadeIn(withDuration: 0.4),
            SKAction.scale(to: 1.8, duration: 0.8)
        ])
        chart.run(appear) { [weak self, weak chart] in
            guard let self = self, let chart = chart else { return }
            
        
            let valueLabel = SKLabelNode(fontNamed: "Menlo-Bold")
            valueLabel.text = "7.2%"
            valueLabel.fontSize = 20
            valueLabel.fontColor = .black
            valueLabel.verticalAlignmentMode = .top
            valueLabel.horizontalAlignmentMode = .center
            valueLabel.position = CGPoint(x: chart.position.x,
                                          y: chart.position.y - chart.calculateAccumulatedFrame().height / 2 - 8)
            valueLabel.alpha = 0
            valueLabel.zPosition = 10
            self.pageContainer.addChild(valueLabel)
            valueLabel.run(SKAction.fadeIn(withDuration: 0.4))
        }
    }
    

    
    private func setupNavigationButtons() {
        prevButton?.removeFromParent()
        nextButton?.removeFromParent()
        
        let radius: CGFloat = 26
        
        func makeButton(isNext: Bool) -> SKNode {
            let container = SKNode()
            container.zPosition = 100
            
            let circle = SKShapeNode(circleOfRadius: radius)
            circle.fillColor = SKColor.white.withAlphaComponent(0.25)
            circle.strokeColor = .black
            circle.lineWidth = 2
            circle.zPosition = -1
            container.addChild(circle)
            
            let arrow = SKLabelNode(fontNamed: "Menlo-Bold")
            arrow.fontSize = 22
            arrow.fontColor = .black
            arrow.verticalAlignmentMode = .center
            arrow.horizontalAlignmentMode = .center
            arrow.text = isNext ? "▶" : "◀"
            container.addChild(arrow)
            
            return container
        }
        
        let prev = makeButton(isNext: false)
        prev.name = "prev_button"
        prev.position = CGPoint(x: size.width * 0.12, y: size.height * 0.12)
        addChild(prev)
        prevButton = prev
        
        let next = makeButton(isNext: true)
        next.name = "next_button"
        next.position = CGPoint(x: size.width * 0.88, y: size.height * 0.12)
        addChild(next)
        nextButton = next
        
        updateNavButtonsState()
    }
    
    private func updateNavButtonsState() {
        prevButton?.alpha = currentPage == 0 ? 0.3 : 1.0
        nextButton?.alpha = currentPage == 4 ? 0.3 : 1.0
    }
    
 
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let prev = prevButton, prev.contains(location), currentPage > 0 {
            showPage(index: currentPage - 1, animated: true)
            return
        }
        
        if let next = nextButton, next.contains(location), currentPage < 4 {
            showPage(index: currentPage + 1, animated: true)
            return
        }

     
        if currentPage == 4, let back = bottomBackButton, back.contains(location) {
            goBackToTitle()
            return
        }
    }

    private func goBackToTitle() {
        guard let view = view else { return }
        let title = Titlepage(size: size)
    
        title.showOceanBookButton = true
        title.lastPhotoTexture = endPhotoTexture
        title.scaleMode = scaleMode
        view.presentScene(title, transition: .fade(withDuration: 0.6))
    }
}

import SwiftUI
#Preview {
    SpriteView(scene: PictureBookScene(size: CGSize(width: 1024, height: 768)))
        .ignoresSafeArea()
}
