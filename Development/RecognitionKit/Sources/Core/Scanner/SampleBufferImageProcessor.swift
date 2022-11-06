//
//  SampleBufferImageProcessor.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 01.11.2022.
//

import Foundation
import CoreMedia
import UIKit

protocol ISampleBufferImageProcessor {
    func process(buffer: CMSampleBuffer) -> CIImage?
}

final class SampleBufferImageProcessor: ISampleBufferImageProcessor {
    private let screen: UIScreen = .main
    
    func process(buffer: CMSampleBuffer) -> CIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(buffer) else {
            return nil
        }
        
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let width = screen.bounds.width * 0.8
        let height = width * 0.55
        let xOrigin = (screen.bounds.width - width) / 2
        let yOrigin = (screen.bounds.height - height) / 2
        
        let targetSize = UIScreen.main.bounds.size
        
        let scale = targetSize.height / ciImage.extent.height
        let aspectRatio = targetSize.width / (ciImage.extent.width * scale)
        
        let croppedImage = CIFilter
            .resize(image: ciImage, scale: scale, aspectRatio: aspectRatio)
            .outputImage
            .map { $0.cropped(to: CGRect(x: xOrigin, y: yOrigin, width: width, height: height)) }
        
        return croppedImage
    }
}

// MARK: - CIFilter + Utils

private extension CIFilter {
    static func resize(image: CIImage, scale: CGFloat, aspectRatio: CGFloat) -> CIFilter {
        let resizeFilter = CIFilter(name: "CILanczosScaleTransform")!
        resizeFilter.setValue(image, forKey: kCIInputImageKey)
        resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
        resizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        return resizeFilter
    }
}
