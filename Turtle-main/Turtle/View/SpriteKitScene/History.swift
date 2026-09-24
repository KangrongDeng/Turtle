import SpriteKit

struct History {
    

    static func createHistoryPanel(
        sceneSize: CGSize,
        entries: [String]
    ) -> (
        container: SKNode,
        contentNode: SKNode,
        closeLabel: SKLabelNode,
        minContentY: CGFloat,
        maxContentY: CGFloat
    ) {
        let container = SKNode()
        container.zPosition = 100
        
        let panelWidth = sceneSize.width * 0.7
        let panelHeight = sceneSize.height * 0.65
        let panelSize = CGSize(width: panelWidth, height: panelHeight)
        
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 28)
        panel.fillColor = SKColor.white.withAlphaComponent(0.25)
        panel.strokeColor = SKColor.white.withAlphaComponent(0.9)
        panel.lineWidth = 3
        panel.zPosition = 0
        container.addChild(panel)
        
        container.position = CGPoint(x: sceneSize.width / 2,
                                     y: sceneSize.height * 0.52)
        
 
        let titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        titleLabel.text = "📜 Log"
        titleLabel.fontSize = 26
        titleLabel.fontColor = .black
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -panelWidth * 0.44,
                                      y: panelHeight * 0.38)
        container.addChild(titleLabel)
        

        let closeLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        closeLabel.text = "Close"
        closeLabel.fontSize = 22
        closeLabel.fontColor = .black
        closeLabel.horizontalAlignmentMode = .right
        closeLabel.verticalAlignmentMode = .center
        closeLabel.position = CGPoint(x: panelWidth * 0.44,
                                      y: panelHeight * 0.38)
        closeLabel.name = "historyClose"
        container.addChild(closeLabel)
        
   
        let visibleWidth = panelWidth * 0.88
        let visibleHeight = panelHeight * 0.7
        
        let cropNode = SKCropNode()
        cropNode.zPosition = 1
        let mask = SKShapeNode(rectOf: CGSize(width: visibleWidth, height: visibleHeight), cornerRadius: 20)
        mask.fillColor = .white
        mask.strokeColor = .clear
        cropNode.maskNode = mask
        
   
        cropNode.position = CGPoint(x: 0, y: -panelHeight * 0.04)
        container.addChild(cropNode)
        
    
        let contentNode = SKNode()
        cropNode.addChild(contentNode)
        
     
        let startX: CGFloat = -visibleWidth / 2
        let startY: CGFloat = visibleHeight / 2
        
        let bubbleSpacing: CGFloat = 12
        var currentOffset: CGFloat = 0
        
        for text in entries {
       
            let label = SKLabelNode(fontNamed: "Menlo-Bold")
            label.fontSize = 20
            label.fontColor = .black
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .left
            label.numberOfLines = 0
            label.preferredMaxLayoutWidth = visibleWidth - 40
            label.text = text
            
            let bubbleWidth = visibleWidth
            let bubbleHeight = max(label.frame.height + 20, 44)
            let bubbleSize = CGSize(width: bubbleWidth, height: bubbleHeight)
            
            let bubble = SKShapeNode(rectOf: bubbleSize, cornerRadius: 20)
            bubble.fillColor = SKColor.white.withAlphaComponent(0.85)
            bubble.strokeColor = SKColor.white.withAlphaComponent(0.95)
            bubble.lineWidth = 2
            
            let itemNode = SKNode()
            itemNode.addChild(bubble)
            itemNode.addChild(label)
            
       
            let centerY = startY - currentOffset - bubbleHeight / 2
            itemNode.position = CGPoint(
                x: startX + bubbleWidth / 2,
                y: centerY
            )
            
          
            label.position = CGPoint(x: -bubbleWidth / 2 + 20, y: 0)
            
            contentNode.addChild(itemNode)
            currentOffset += bubbleHeight + bubbleSpacing
        }
        
      
        if entries.isEmpty {
            let emptyLabel = SKLabelNode(fontNamed: "Menlo-Bold")
            emptyLabel.text = "No history yet."
            emptyLabel.fontSize = 20
            emptyLabel.fontColor = .black
            emptyLabel.verticalAlignmentMode = .center
            emptyLabel.horizontalAlignmentMode = .center
            emptyLabel.position = CGPoint(x: 0, y: 0)
            contentNode.addChild(emptyLabel)
            
            currentOffset = 0
        }
        
     
        let initialY: CGFloat = 0
        contentNode.position = CGPoint(x: 0, y: initialY)
        
        let contentHeight = currentOffset
        let maxY = initialY
        let minY: CGFloat
        if contentHeight > visibleHeight {
            minY = initialY - (contentHeight - visibleHeight)
        } else {
            minY = initialY
        }
        
        return (container, contentNode, closeLabel, minY, maxY)
    }
}

