//
//  CardScannerViewController.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 30.10.2022.
//

import UIKit
import AVFoundation
import Vision
import CoreImage

struct CardScannerOutputData {
    struct ValidThru {
        let month: String
        let year: String
    }
    
    let pan: String?
    let validThru: String?
    let cvc: String?
}

protocol CardScannerDelegate: AnyObject {
    func cardScanner(didScan data: CardScannerOutputData)
}

final class CardScannerViewController: UIViewController {
    
    private let device: AVCaptureDevice
    private let session: AVCaptureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let cardDataHandlingQueue = DispatchQueue(label: "recognitionKit.cardScanner.cardDataHandler", qos: .userInitiated)
    
    weak var delegate: CardScannerDelegate?
    
    
    // MARK: UI
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resize
        return preview
    }()
    
    // MARK: Init
    
    init(device: AVCaptureDevice) {
        self.device = device
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: View Setting Up
    
    private func setupCameraInput() {
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        session.addInput(cameraInput)
    }
    
    private func setupPreviewLayer() {
        view.layer.addSublayer(previewLayer)
    }
    
    private func setupVideoOutput() {
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey: NSNumber(value: kCVPixelFormatType_32BGRA)
        ] as [String: Any]
        
        let outputQueue = DispatchQueue(label: "recognitionKit.cardScanner.videoOutput")
        videoOutput.setSampleBufferDelegate(self, queue: outputQueue)
        session.addOutput(videoOutput)
        
        guard let connection = videoOutput.connection(with: .video),
              connection.isVideoOrientationSupported else {
            return
        }
        
        connection.videoOrientation = .portrait
    }
    
    
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CardScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("Unable to get image from sample buffer")
            return
        }
        
        handleObservedCard(with: imageBuffer)
    }
    
    private func handleObservedCard(with buffer: CVImageBuffer) {
        cardDataHandlingQueue.async {
            let ciImage = CIImage(cvImageBuffer: buffer)
            let width = UIScreen.main.bounds.width * 0.8
            let height = width * 0.55
            let xOrigin = (UIScreen.main.bounds.width - width) / 2
            let yOrigin = (UIScreen.main.bounds.height - height) / 2
            
            
            let targetSize = UIScreen.main.bounds.size
            
            let scale = targetSize.height / ciImage.extent.height
            let aspectRatio = targetSize.width / (ciImage.extent.width * scale)
            
            let resizeFilter = CIFilter(name: "CILanczosScaleTransform")!
            resizeFilter.setValue(ciImage, forKey: kCIInputImageKey)
            resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
            resizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
            
            let outputImage = resizeFilter.outputImage!
            let cropRect = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
            let croppedImage = outputImage.cropped(to: cropRect)
            
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            
            let imageRequestHandler = VNImageRequestHandler(ciImage: croppedImage)
            
            try? imageRequestHandler.perform([request])
            
            guard let texts = request.results, !texts.isEmpty else {
                return
            }
            
            let lines = texts
                .flatMap { $0.topCandidates(20) }
                .map { $0.string.trimmingCharacters(in: .whitespacesAndNewlines) }
            
            
            
            
            
        }
    }
}
