import UIKit
import ImageIO
import MobileCoreServices

extension UIImage {
    /// Returns HEIC-encoded data for the image if possible, otherwise falls back to JPEG.
    /// - Parameters:
    ///   - compressionQuality: A value between 0.0 and 1.0 indicating the desired compression quality.
    /// - Returns: Encoded image data, or nil if encoding fails.
    func heicData(compressionQuality: CGFloat = 0.8) -> Data? {
        // Try HEIC first if supported
        if #available(iOS 11.0, *),
           let heicType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, "image/heic" as CFString, nil)?.takeRetainedValue() {

            let data = NSMutableData()
            guard let destination = CGImageDestinationCreateWithData(data, heicType, 1, nil) else {
                return nil
            }

            guard let cgImage = self.cgImage else { return nil }

            let options: [CFString: Any] = [
                kCGImageDestinationLossyCompressionQuality: compressionQuality
            ]

            CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)

            if CGImageDestinationFinalize(destination) {
                return data as Data
            }
        }

        // Fallback to JPEG
        return self.jpegData(compressionQuality: compressionQuality)
    }
}
