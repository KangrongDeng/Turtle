import UIKit
import SpriteKit
import Photos

extension SKSpriteNode {

    func toImage(scale: CGFloat = UIScreen.main.scale) -> UIImage? {
 
        let sceneSize = self.size
        let scene = SKScene(size: sceneSize)
        scene.backgroundColor = .clear
        scene.scaleMode = .aspectFit
        
        guard let copied = self.copy() as? SKSpriteNode else { return nil }
        copied.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        copied.zRotation = 0
        scene.addChild(copied)
   
        let view = SKView(frame: CGRect(origin: .zero, size: sceneSize))
        view.isOpaque = false
        view.backgroundColor = .clear
        view.presentScene(scene)

        view.layoutIfNeeded()
        scene.update(0)
        view.setNeedsDisplay()
        view.layoutIfNeeded()
        

        guard let texture = view.texture(from: scene) else { return nil }
        return UIImage(cgImage: texture.cgImage())
    }
    

    func toJPGData(quality: CGFloat = 0.92) -> Data? {
        guard let image = toImage() else { return nil }
        return image.jpegData(compressionQuality: quality)
    }
}

extension UIImage {
    func flattenedOnWhiteBackground() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = self.scale
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: self.size, format: format)
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: self.size))
            self.draw(in: CGRect(origin: .zero, size: self.size))
        }
    }
}

func saveImageToAlbum(_ image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
    PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
        guard status == .authorized || status == .limited else {
            completion(false, NSError(domain: "PhotoAuth", code: 1))
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        })
    }
}
