//
//  CaptureProcess.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation
import AVFoundation
import Vision
import CoreImage
import UIKit

enum RKError: Error {
    case unableToConnectCaptureDevice
}

final class CaptureProcess: NSObject {
    private let bufferImageProcessor: ISampleBufferImageProcessor
    private let textRecognizer: ITextRecognizer
    
    
    init(
        bufferImageProcessor: ISampleBufferImageProcessor,
        textRecognizer: ITextRecognizer
    ) throws {
        self.bufferImageProcessor = bufferImageProcessor
        self.textRecognizer = textRecognizer
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CaptureProcess: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let image = bufferImageProcessor.process(buffer: sampleBuffer) else {
            debugPrint("IMAGE IS EMPTy")
            return
        }
       
        do {
            let recognizedTexts = try textRecognizer.recognize(textFrom: image)
            
        } catch {
            debugPrint(error)
        }
    }
}

