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

enum RKError: Error {
    case unableToConnectCaptureDevice
}

final class CardScannerViewController: UIViewController {
    private let device: AVCaptureDevice
    private let session: AVCaptureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let cardDataHandlingQueue = DispatchQueue(label: "recognitionKit.cardScanner.cardDataHandler", qos: .userInitiated)
    private let captureProcess: ICaptureProcess
        
    // MARK: UI
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resize
        return preview
    }()
        
    // MARK: Init
    
    init(
        device: AVCaptureDevice? = .default(for: .video),
        captureProcess: ICaptureProcess
    ) throws {
        self.device = try device.orThrow(RKError.unableToConnectCaptureDevice)
        self.captureProcess = captureProcess
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stop()
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        session.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
    
    // MARK: View Setting Up
    
    private func setupUI() {
        setupCameraInput()
        setupPreviewLayer()
        setupVideoOutput()
        captureProcess.setup(with: self)
    }
    
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
        videoOutput.setSampleBufferDelegate(captureProcess, queue: outputQueue)
        session.addOutput(videoOutput)
        
        guard let connection = videoOutput.connection(with: .video),
              connection.isVideoOrientationSupported else {
            return
        }
        
        connection.videoOrientation = .portrait
    }
    
    // MARK: End
    
    private func stop() {
        session.stopRunning()
    }
}

// MARK: - ICaptureProcessDelegate

extension CardScannerViewController: ICaptureProcessDelegate {
    func captureProcessDidComplete(_ process: ICaptureProcess) {
        stop()
        dismiss(animated: true)
    }
}
