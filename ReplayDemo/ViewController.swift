//
//  ViewController.swift
//  ReplayDemo
//
//  Created by B@db0Y on 13/04/21.
//  Copyright © 2021 B@db0Y. All rights reserved.
//

import ReplayKit
import UIKit
import Photos


class ViewController: UIViewController {
    
    let controller = RPBroadcastController()
    let recorder = RPScreenRecorder.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(startRecording))
        //startBroadcast()
        
        solution(3, 2)
        
        //exit(0)
        
       // NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationIdentifierVideo"), object: nil)
    }
    
    public func solution(_ N : Int, _ K : Int) -> String {
        
        let isEvenLength = N%2
        
        var unique = K
        
        
        let length = N/2
        
        var prefix = ""
        
        for _ in 0..<length{
            var character = randomString(length: 1)
            if unique > 0{
                while prefix.contains(character){
                    character = randomString(length: 1)
                }
                unique -= 1
            }
            else{
                if prefix.count > 0 {
                    character = String(prefix.randomElement()!)
                }
            }
            
            prefix += character
        }
        
        let middleletter = unique > 0 ? randomString(length: 1) : String(prefix.randomElement()!)
                
        let reversed = String(prefix.reversed())
        
        let palindrome = prefix + (isEvenLength > 0 ?  middleletter : "") + reversed
        
        return palindrome
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    
    
    
    //MARK: - - - - - Method for receiving Data through Post Notificaiton - - - - -
    @objc func methodOfReceivedNotification(notification: Notification) {
        print("Value of notification : ", notification.object ?? "")
        
//        if let videoURL = notification.object as? URL{
//            PHPhotoLibrary.shared().performChanges({
//                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
//            }) { saved, error in
//                
//                if let error = error {
//                    print("Error saving video to librayr: \(error.localizedDescription)")
//                }
//                if saved {
//                    print("Video save to library")
//                    
//                }
//            }
//        }
    }
    
    
    @objc func startRecording() {
        
        if controller.isBroadcasting {
            stopBroadcast()
        } else {
            startBroadcast()
        }
        
        /*RPBroadcastActivityViewController.load { broadcastAVC, error in
         
         guard error == nil else {
         print("Cannot load Broadcast Activity View Controller.")
         return
         }
         
         if let broadcastAVC = broadcastAVC {
         broadcastAVC.delegate = self
         self.navigationController?.present(broadcastAVC, animated: true, completion: {
         print(#function)
         })
         }
         }*/
        
        
        
        /*let recorder = RPScreenRecorder.shared()
         
         guard recorder.isAvailable else {
         print("Recording is not available at this time.")
         return
         }
         
         recorder.startRecording{ [unowned self] (error) in
         if let unwrappedError = error {
         print(unwrappedError.localizedDescription)
         } else {
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .plain, target: self, action: #selector(self.stopRecording))
         }
         }*/
    }
    
    @objc func stopRecording() {
        /*let recorder = RPScreenRecorder.shared()
         
         recorder.stopRecording { [unowned self] (preview, error) in
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(self.startRecording))
         
         if let unwrappedPreview = preview {
         unwrappedPreview.previewControllerDelegate = self
         self.present(unwrappedPreview, animated: true)
         }
         }*/
        
        if controller.isBroadcasting {
            stopBroadcast()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(startRecording))
        }
    }
    
}

extension ViewController : RPPreviewViewControllerDelegate {
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
    }
}

extension ViewController : RPBroadcastActivityViewControllerDelegate {
    
    func stopBroadcast() {
        controller.finishBroadcast { error in
            if error == nil {
                print("Broadcast ended")
            }
        }
    }
    
    func startBroadcast() {
        //recorder.isMicrophoneEnabled = true
        
        // In the view controller
        let pickerView = RPSystemBroadcastPickerView(frame: CGRect(x: 0,
                                                                   y: 0,
                                                                   width: view.bounds.width,
                                                                   height: view.bounds.height))
        pickerView.preferredExtension = "arc.replaykit.ext.up"
        
        // Microphone audio is passed through the main application instead of
        // the broadcast extension.
        pickerView.showsMicrophoneButton = false
        
        if let button = pickerView.subviews.first as? UIButton {
            button.imageView?.tintColor = UIColor.red
        }
        
        // Set up view constraints as necessary.
        view.addSubview(pickerView)
        
    }
    
    func broadcastActivityViewController(_ broadcastActivityViewController: RPBroadcastActivityViewController, didFinishWith broadcastController: RPBroadcastController?, error: Error?) {
        print(#function)
        broadcastActivityViewController.dismiss(animated: true, completion: nil)
    }
}

/*
import AVFoundation

class ViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(capture))

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self._setupCaptureSession()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            _setupCaptureSession()
        }
    }

    private var _captureSession: AVCaptureSession?
    private var _videoOutput: AVCaptureVideoDataOutput?
    private var _assetWriter: AVAssetWriter?
    private var _assetWriterInput: AVAssetWriterInput?
    private var _adpater: AVAssetWriterInputPixelBufferAdaptor?
    private var _filename = ""
    private var _time: Double = 0
    private func _setupCaptureSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .hd1920x1080

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input) else { return }

        session.beginConfiguration()
        session.addInput(input)
        session.commitConfiguration()

        let output = AVCaptureVideoDataOutput()
        guard session.canAddOutput(output) else { return }
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.yusuke024.video"))
        session.beginConfiguration()
        session.addOutput(output)
        session.commitConfiguration()

        DispatchQueue.main.async {
            let previewView = _PreviewView()
            previewView.videoPreviewLayer.session = session
            previewView.frame = self.view.bounds
            previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.insertSubview(previewView, at: 0)
        }

        session.startRunning()
        _videoOutput = output
        _captureSession = session
    }

    private enum _CaptureState {
        case idle, start, capturing, end
    }
    private var _captureState = _CaptureState.idle
    @objc func capture() {
        switch _captureState {
        case .idle:
            _captureState = .start
        case .capturing:
            _captureState = .end
        default:
            break
        }
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        switch _captureState {
        case .start:
            // Set up recorder
            _filename = UUID().uuidString
            let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(_filename).mov")
            let writer = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)
            let settings = _videoOutput!.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings) // [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1920, AVVideoHeightKey: 1080])
            input.mediaTimeScale = CMTimeScale(bitPattern: 600)
            input.expectsMediaDataInRealTime = true
            input.transform = CGAffineTransform(rotationAngle: .pi/2)
            let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
            if writer.canAdd(input) {
                writer.add(input)
            }
            writer.startWriting()
            writer.startSession(atSourceTime: .zero)
            _assetWriter = writer
            _assetWriterInput = input
            _adpater = adapter
            _captureState = .capturing
            _time = timestamp
        case .capturing:
            if _assetWriterInput?.isReadyForMoreMediaData == true {
                let time = CMTime(seconds: timestamp - _time, preferredTimescale: CMTimeScale(600))
                _adpater?.append(CMSampleBufferGetImageBuffer(sampleBuffer)!, withPresentationTime: time)
            }
            break
        case .end:
            guard _assetWriterInput?.isReadyForMoreMediaData == true, _assetWriter!.status != .failed else { break }
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(_filename).mov")
            _assetWriterInput?.markAsFinished()
            _assetWriter?.finishWriting { [weak self] in
                self?._captureState = .idle
                self?._assetWriter = nil
                self?._assetWriterInput = nil
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }) { completed, error in
                    if completed {
                        NSLog("Video has been moved to camera roll")
                    }

                    if error != nil {
                        NSLog("ERROR:::Cannot move the video to camera roll, error: \(error!.localizedDescription)")
                    }

                }
            }
        default:
            break
        }
    }
}

private class _PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
*/
