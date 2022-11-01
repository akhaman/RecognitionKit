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

protocol CardScannerDelegate: AnyObject {
    func cardScanner(didScan data: CardData)
}

final class CardScannerViewController: UIViewController {
    private let device: AVCaptureDevice
    private let session: AVCaptureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let cardDataHandlingQueue = DispatchQueue(label: "recognitionKit.cardScanner.cardDataHandler", qos: .userInitiated)
    private let cardDataParser: ICardDataParser
    private let captureProcessor: AVCaptureVideoDataOutputSampleBufferDelegate
    
    weak var delegate: CardScannerDelegate?
    
    // MARK: UI
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resize
        return preview
    }()
    
    private lazy var maskView = MaskView(style: .card)
    
    // MARK: Init
    
    init?(
        device: AVCaptureDevice? = .default(for: .video),
        cardDataParser: ICardDataParser,
        captureProcessor: AVCaptureVideoDataOutputSampleBufferDelegate
    ) {
        guard let device = device else {
            return nil
        }

        self.device = device
        self.cardDataParser = cardDataParser
        self.captureProcessor = captureProcessor
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
        setupMaskView()
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
        videoOutput.setSampleBufferDelegate(captureProcessor, queue: outputQueue)
        session.addOutput(videoOutput)
        
        guard let connection = videoOutput.connection(with: .video),
              connection.isVideoOrientationSupported else {
            return
        }
        
        connection.videoOrientation = .portrait
    }
    
    private func setupMaskView() {
//        view.addSubview(maskView)
//        maskView.pinEdgesToSuperview()
    }
    
    // MARK: End
    
    private func stop() {
        session.stopRunning()
    }
}
