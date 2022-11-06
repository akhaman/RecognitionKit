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

protocol ICaptureProcessDelegate: AnyObject {
    func captureProcessDidComplete(_ process: ICaptureProcess)
}

protocol ICaptureProcess: AVCaptureVideoDataOutputSampleBufferDelegate {
    func setup(with delegate: ICaptureProcessDelegate)
}

final class CaptureProcess: NSObject {
    private let bufferImageProcessor: ISampleBufferImageProcessor
    private let textRecognizer: ITextRecognizer
    private let recognizingBuffer: ITextRecognizingBuffer
    private weak var delegate: ICaptureProcessDelegate?
    
    init(
        bufferImageProcessor: ISampleBufferImageProcessor,
        textRecognizer: ITextRecognizer,
        recognizingBuffer: ITextRecognizingBuffer
    ) {
        self.bufferImageProcessor = bufferImageProcessor
        self.textRecognizer = textRecognizer
        self.recognizingBuffer = recognizingBuffer
        super.init()
    }
}

// MARK: - ICaptureProcess

extension CaptureProcess: ICaptureProcess {
    func setup(with delegate: ICaptureProcessDelegate) {
        self.delegate = delegate
        recognizingBuffer.setup(with: self)
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
            recognizingBuffer.update(with: recognizedTexts.convertToSet())
        } catch {
            debugPrint(error)
        }
    }
}

// MARK: - ITextRecognizingBufferDelegate

extension CaptureProcess: ITextRecognizingBufferDelegate {
    func recognizingBuffer(
        _ buffer: ITextRecognizingBuffer,
        received receivedCandidates: Set<TextRecognitionCandidate>,
        updatedWith candidates: Set<TextRecognitionCandidate>,
        completelyFilled: Bool
    ) {
        if completelyFilled {
            DispatchQueue.main.async { [weak delegate] in
                delegate?.captureProcessDidComplete(self)
            }
            
            buffer.complete()
        }
    }
}
