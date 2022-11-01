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

protocol ICaptureProcess {
    func start()
    func stop()
}

final class CaptureProcess: NSObject {
    private let videoOutput = AVCaptureVideoDataOutput()
    private let captureSession: AVCaptureSession
    private let captureDevice: AVCaptureDevice
    private let outputHandlingQueue: DispatchQueue
    private let bufferImageProcessor: ISampleBufferImageProcessor
    private let textRecognizer: ITextRecognizer
    
    init(
        captureSession: AVCaptureSession,
        captureDevice: AVCaptureDevice? = .default(for: .video),
        outputHandlingQueue: DispatchQueue? = nil,
        bufferImageProcessor: ISampleBufferImageProcessor,
        textRecognizer: ITextRecognizer
    ) throws {
        self.captureSession = captureSession
        self.captureDevice = try captureDevice.orThrow(RKError.unableToConnectCaptureDevice)
        self.bufferImageProcessor = bufferImageProcessor
        self.textRecognizer = textRecognizer

        self.outputHandlingQueue = DispatchQueue(
            label: "recognitionKit.captureProcess.outputHandling",
            qos: outputHandlingQueue?.qos ?? .userInitiated,
            autoreleaseFrequency: .workItem,
            target: outputHandlingQueue
        )
    }
}

extension CaptureProcess: ICaptureProcess {
    func start() {
        guard let cameraInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        
        captureSession.addInput(cameraInput)
        
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey: NSNumber(value: kCVPixelFormatType_32BGRA)
        ] as [String: Any]
        
        videoOutput.setSampleBufferDelegate(self, queue: outputHandlingQueue)
        captureSession.addOutput(videoOutput)
        
        guard let connection = videoOutput.connection(with: .video),
              connection.isVideoOrientationSupported else {
            return
        }
        
        connection.videoOrientation = .portrait
    }
    
    func stop() {
        captureSession.stopRunning()
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
            return
        }
       
        do {
            let recognizedTexts = try textRecognizer.recognize(textFrom: image)
        } catch {
            debugPrint(error)
        }
    }
}

