//
//  RepayVideoSource.swift
//  ReplayDemo
//
//  Created by ARC 6 on 14/04/21.
//  Copyright © 2021 B@db0Y. All rights reserved.
//

import Foundation
import CoreVideo
import CoreMedia
import AVFoundation
import UIKit
import Photos

class ReplayKitVideoSource{
    
    /*var _videoWriter: AVAssetWriter?
    var _videoWriterInput: AVAssetWriterInput?
    private var _adpater: AVAssetWriterInputPixelBufferAdaptor?
    private var _time: Double = 0
    private var _videoOutputURL: URL?
    var videoOutputFullFileName: String?
    
    init() {
        setupWriter()
    }
    
    
    
    func videoFileLocation() -> URL {
        let fileManager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let videoOutputUrl = URL(fileURLWithPath: documentsPath.appendingPathComponent("videoFile")).appendingPathExtension("mov")
        do {
            if fileManager.fileExists(atPath: videoOutputUrl.path) {
                try fileManager.removeItem(at: videoOutputUrl)
            }
        } catch {
            print(error)
        }
        return videoOutputUrl
    }
    
    func setupWriter(){
        
        self.videoOutputFullFileName = videoFileLocation().relativePath
        
        if self.videoOutputFullFileName == nil {
            print("ERROR:The video output file name is nil")
            return
        }
        
        
        //        guard let videoOutputURL = _videoOutputURL else {
        //            fatalError("videoOutputURL error")
        //        }
        
        guard let videoWriter = try? AVAssetWriter(outputURL: URL(fileURLWithPath: self.videoOutputFullFileName!), fileType: AVFileType.mov) else {
            fatalError("AVAssetWriter error")
        }
        
        var status = videoWriter.status
        
        let screenSize: CGRect = UIScreen.main.bounds
        let videoCompressionPropertys = [
            AVVideoAverageBitRateKey: screenSize.width * screenSize.height * 10.1
        ]
        
        let outputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: screenSize.width,
            AVVideoHeightKey: screenSize.height,
            AVVideoCompressionPropertiesKey: videoCompressionPropertys
        ]
        
//        guard videoWriter.canApply(outputSettings: outputSettings, forMediaType: AVMediaType.video) else {
//            fatalError("Negative : Can't apply the Output settings...")
//        }
        
        let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: outputSettings)
        videoWriterInput.expectsMediaDataInRealTime = true
        
        let sourcePixelBufferAttributesDictionary = [
            kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: NSNumber(value: Float(screenSize.width)),
            kCVPixelBufferHeightKey as String: NSNumber(value: Float(screenSize.height))
        ]
        
        //let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        
        if videoWriter.canAdd(videoWriterInput) {
            videoWriter.add(videoWriterInput)
        }
        
        
        let timestamp = CMTime.zero
        
        let hasStartedWriting = videoWriter.startWriting()
        if hasStartedWriting {
            videoWriter.startSession(atSourceTime: timestamp)
            print("DEBUG:::Have started writting on videoWriter, session at source time: \(timestamp)")
        } else {
            print("WARN:::Fail to start writing on videoWriter")
        }
        
        status = videoWriter.status
        
        _videoWriter = videoWriter
        _videoWriterInput = videoWriterInput
        //_adpater = pixelBufferAdaptor
        
        _time = CMTime.zero.seconds
    }
    
    /// Provide a frame to the source for processing. This operation might result in the frame being delivered to the sink,
    /// dropped, and/or remapped.
    ///
    /// - Parameter sampleBuffer: The new CMSampleBuffer input to process.
    public func processFrame(sampleBuffer: CMSampleBuffer) {
        //        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        //        if _assetWriterInput?.isReadyForMoreMediaData == true {
        //            let time = CMTime(seconds: timestamp - _time, preferredTimescale: CMTimeScale(600))
        //            _adpater?.append(CMSampleBufferGetImageBuffer(sampleBuffer)!, withPresentationTime: time)
        //        }
        
        
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        // Append the sampleBuffer into videoWriterInput
        if self._videoWriterInput!.isReadyForMoreMediaData {
            if self._videoWriter!.status == AVAssetWriter.Status.writing {
                let whetherAppendSampleBuffer = self._videoWriterInput!.append(sampleBuffer)
                print(">>>>>>>>>>>>>The time::: \(timestamp.value)/\(timestamp.timescale)")
                if whetherAppendSampleBuffer {
                    print("DEBUG::: Append sample buffer successfully")
                } else {
                    print("WARN::: Append sample buffer failed")
                }
            } else {
                print("WARN:::The videoWriter status is not writing")
            }
        } else {
            print("WARN:::Cannot append sample buffer into videoWriterInput")
        }
    }
    
    public func end(){
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        _videoWriterInput?.markAsFinished()
        _videoWriter?.finishWriting {
            
            self._videoWriter = nil
            self._videoWriterInput = nil
            
            let fileManager = FileManager.default
            let sharedFileURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.arc.replaykit")
            guard let documentsPath = sharedFileURL?.path else {
                NSLog("ERROR:::No shared file URL path")
                dispatchGroup.leave()
                return
            }
            
            let finalFilename = documentsPath + "/test_capture_video.mp4"
            
            //Check whether file exists
            if fileManager.fileExists(atPath: finalFilename) {
                NSLog("WARN:::The file: \(finalFilename) exists, will delete the existing file")
                do {
                    try fileManager.removeItem(atPath: finalFilename)
                } catch let error as NSError {
                    NSLog("WARN:::Cannot delete existing file: \(finalFilename), error: \(error.debugDescription)")
                }
            } else {
                NSLog("DEBUG:::The file \(String(describing: self.videoOutputFullFileName!)) doesn't exist")
            }
            
            do {
                try fileManager.copyItem(at: URL(fileURLWithPath: self.videoOutputFullFileName!), to: URL(fileURLWithPath: finalFilename))
            }
            catch let error as NSError {
                NSLog("ERROR:::\(error.debugDescription)")
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "Broadcast")
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: finalFilename))
            }) { completed, error in
                if completed {
                    NSLog("Video \(self.videoOutputFullFileName ?? "") has been moved to camera roll")
                }
                
                if error != nil {
                    NSLog("ERROR:::Cannot move the video \(self.videoOutputFullFileName ?? "") to camera roll, error: \(error!.localizedDescription)")
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait()
    }*/
    
    enum _CaptureState {
        case idle, start, capturing, end
    }
    
    var _captureState = _CaptureState.idle
    var _assetWriter: AVAssetWriter?
    var _assetWriterInput: AVAssetWriterInput?
    private var _adpater: AVAssetWriterInputPixelBufferAdaptor?
    var _filename = ""
    private var _time: Double = 0
    
    init() {
        _captureState = .start
    }
    
    
    func processFrame(sampleBuffer: CMSampleBuffer) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        switch _captureState {
        case .start:
            // Set up recorder
            _filename = UUID().uuidString
            let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(_filename).mov")
            let writer = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)

            let screenSize: CGRect = UIScreen.main.bounds
            let videoCompressionPropertys = [
                AVVideoAverageBitRateKey: screenSize.width * screenSize.height * 10.1
            ]
            
            let outputSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: screenSize.width,
                AVVideoHeightKey: screenSize.height,
                AVVideoCompressionPropertiesKey: videoCompressionPropertys
            ]

            let input = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
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
        default:
            break
        }
    }
    
    func end(completion: @escaping ()->()){
        guard _assetWriterInput?.isReadyForMoreMediaData == true, _assetWriter!.status != .failed else { return }
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

                completion()
            }
        }
    }
}
