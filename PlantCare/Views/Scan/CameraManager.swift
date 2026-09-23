import AVFoundation
import Combine
import SwiftUI
import UIKit

@MainActor
final class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()

    @Published private(set) var isAuthorized = false
    @Published private(set) var isConfigured = false
    @Published private(set) var isReady = false
    @Published private(set) var isTorchOn = false
    @Published var errorMessage: String?

    private let sessionQueue = DispatchQueue(label: "com.plantcare.camera.session")
    private let photoOutput = AVCapturePhotoOutput()
    private var captureCompletion: ((UIImage?) -> Void)?
    private var isRunning = false

    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            configureIfNeeded()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    guard let self else { return }
                    self.isAuthorized = granted
                    if granted {
                        self.configureIfNeeded()
                    } else {
                        self.errorMessage = "Camera access is required to take a plant photo. Enable it in Settings."
                    }
                }
            }
        case .denied, .restricted:
            isAuthorized = false
            errorMessage = "Camera access is disabled. Enable it in Settings to take a photo."
        @unknown default:
            isAuthorized = false
            errorMessage = "Camera access is unavailable on this device."
        }
    }

    func stop() {
        guard isRunning else { return }
        isReady = false
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.session.stopRunning()
            Task { @MainActor in self.isRunning = false }
        }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard isConfigured, isAuthorized, isReady else {
            errorMessage = "The camera is not ready yet. Please try again."
            completion(nil)
            return
        }

        captureCompletion = completion
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isTorchOn ? .on : .off
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            errorMessage = "Flash is not available on this device."
            return
        }

        do {
            try device.lockForConfiguration()
            device.torchMode = isTorchOn ? .off : .on
            device.unlockForConfiguration()
            isTorchOn.toggle()
        } catch {
            errorMessage = "Flash could not be enabled."
        }
    }

    func turnTorchOff() {
        guard isTorchOn,
              let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = .off
        device.unlockForConfiguration()
        isTorchOn = false
    }

    private func configureIfNeeded() {
        guard !isConfigured else {
            startRunning()
            return
        }

        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                self.session.commitConfiguration()
                Task { @MainActor in self.errorMessage = "No camera is available on this device." }
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: device)
                guard self.session.canAddInput(input), self.session.canAddOutput(self.photoOutput) else {
                    self.session.commitConfiguration()
                    Task { @MainActor in self.errorMessage = "The camera could not be configured." }
                    return
                }
                self.session.addInput(input)
                self.session.addOutput(self.photoOutput)
                self.photoOutput.isHighResolutionCaptureEnabled = true

                // Configuration must be committed before the session is started.
                self.session.commitConfiguration()

                Task { @MainActor in
                    self.isConfigured = true
                    self.startRunning()
                }
            } catch {
                self.session.commitConfiguration()
                Task { @MainActor in self.errorMessage = "The camera could not be configured." }
            }
        }
    }

    private func startRunning() {
        guard isConfigured, !isRunning else {
            isReady = isConfigured && isRunning
            return
        }
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.session.startRunning()
            let running = self.session.isRunning
            Task { @MainActor in
                self.isRunning = running
                self.isReady = running
                if !running {
                    self.errorMessage = "The camera could not be started. Please try again."
                }
            }
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput,
                                 didFinishProcessingPhoto photo: AVCapturePhoto,
                                 error: Error?) {
        let image: UIImage?
        if let error {
            image = nil
            let message = error.localizedDescription
            Task { @MainActor [weak self] in
                self?.errorMessage = "Photo capture failed: \(message)"
            }
        } else if let data = photo.fileDataRepresentation() {
            image = UIImage(data: data)
        } else {
            image = nil
        }

        Task { @MainActor [weak self] in
            guard let self else { return }
            let completion = self.captureCompletion
            self.captureCompletion = nil
            completion?(image)
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.videoPreviewLayer.session = session
    }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
