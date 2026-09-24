import SpriteKit

struct Tips {
    @MainActor static func createNarratorNode(
        sceneSize: CGSize,
        text: String,
        yFactor: CGFloat = 0.8
    ) -> (container: SKNode, label: SKLabelNode) {

        let container = SKNode()
        container.zPosition = 60

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.fontSize = 22
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = sceneSize.width * 0.7
        label.position = .zero

     
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

        container.position = CGPoint(
            x: sceneSize.width / 2,
            y: sceneSize.height * yFactor
        )

        return (container, label)
    }

  
    @MainActor static func runTypingAnimation(
        on label: SKLabelNode,
        text: String,
        charInterval: TimeInterval = 0.03
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

        label.run(SKAction.sequence(actions))
    }

    @MainActor static func createFingerDragGuide(
        from start: CGPoint,
        to end: CGPoint,
        forwardDuration: TimeInterval = 0.6
    ) -> SKNode {
        let container = SKNode()
        container.zPosition = 80

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

        let moveForward = SKAction.move(to: end, duration: forwardDuration)
        let moveBack = SKAction.move(to: start, duration: forwardDuration)
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

        return container
    }

   
    @MainActor static func createFingerRippleGuide(
        center: CGPoint,
        fingerOffsetY: CGFloat = 35
    ) -> SKNode {
        let container = SKNode()
        container.position = center
        container.zPosition = 80

        let finger = SKLabelNode(fontNamed: "Menlo-Bold")
        finger.text = "👆"
        finger.fontSize = 40
        finger.verticalAlignmentMode = .center
        finger.horizontalAlignmentMode = .center
 
        finger.position = CGPoint(x: 0, y: fingerOffsetY)
        container.addChild(finger)

      
        let spawnRipple = SKAction.run { [weak container] in
            guard let parent = container else { return }
            let circle = SKShapeNode(circleOfRadius: 20)
            circle.position = .zero
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

        return container
    }
}

