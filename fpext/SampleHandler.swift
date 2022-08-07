//
//  SampleHandler.swift
//  fpext
//
//  Created by ARC 6 on 14/04/21.
//  Copyright © 2021 B@db0Y. All rights reserved.
//

import ReplayKit
import Photos

class SampleHandler: RPBroadcastSampleHandler {
    
    var videoSource: ReplayKitVideoSource?
    var disconnectSemaphore: DispatchSemaphore?
    
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        print(#function)
        videoSource = ReplayKitVideoSource()
        disconnectSemaphore = DispatchSemaphore(value: 0)
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
        print(#function)
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
        print(#function)
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .video:
            // Handle video sample buffer
            videoSource?.processFrame(sampleBuffer: sampleBuffer)
            break
        case .audioApp:
            // Handle audio sample buffer for app audio
            break
        case .audioMic:
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
    
    override func broadcastFinished() {
        
        guard videoSource?._assetWriterInput?.isReadyForMoreMediaData == true, videoSource?._assetWriter!.status != .failed, let _filename = videoSource?._filename else { self.disconnectSemaphore?.signal()
            return
        }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(_filename).mov")
        videoSource?._assetWriterInput?.markAsFinished()
        videoSource?._assetWriter?.finishWriting { [weak self] in
            self?.videoSource?._captureState = .idle
            self?.videoSource?._assetWriter = nil
            self?.videoSource?._assetWriterInput = nil
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { completed, error in
                if completed {
                    NSLog("Video has been moved to camera roll")
                }

                if error != nil {
                    NSLog("ERROR:::Cannot move the video to camera roll, error: \(error!.localizedDescription)")
                }

                self?.disconnectSemaphore?.signal()
            }
        }
                
        self.disconnectSemaphore?.wait()
    }
    
    
    /*override func broadcastFinished() {
        
        
        print(#function)
        //let dispatchGroup = DispatchGroup()
        // dispatchGroup.enter()
        self.videoSource?._videoWriterInput?.markAsFinished()
        self.videoSource?._videoWriter?.finishWriting {
            // Do your work to here to make video available
            let fileManager = FileManager.default
            let sharedFileURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.arc.replaykit")
            guard let documentsPath = sharedFileURL?.path, let videoOutputFullFileName = self.videoSource?.videoOutputFullFileName else {
                NSLog("ERROR:::No shared file URL path")
                // dispatchGroup.leave()
                return
            }
            
            let finalFilename = documentsPath + "/test_capture_video.mov"
            
            //Check whether file exists
            if fileManager.fileExists(atPath: finalFilename) {
                NSLog("WARN:::The file: \(finalFilename) exists, will delete the existing file")
                do {
                    try fileManager.removeItem(atPath: finalFilename)
                } catch let error as NSError {
                    NSLog("WARN:::Cannot delete existing file: \(finalFilename), error: \(error.debugDescription)")
                }
            } else {
                NSLog("DEBUG:::The file \(String(describing: videoOutputFullFileName)) doesn't exist")
            }
            
            do {
                try fileManager.copyItem(at: URL(fileURLWithPath: videoOutputFullFileName), to: URL(fileURLWithPath: finalFilename))
            }
            catch let error as NSError {
                NSLog("ERROR:::\(error.debugDescription)")
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "Broadcast")
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: finalFilename))
            }) { completed, error in
                if completed {
                    NSLog("Video \(videoOutputFullFileName) has been moved to camera roll")
                }
                
                if error != nil {
                    NSLog("ERROR:::Cannot move the video \(videoOutputFullFileName) to camera roll, error: \(error!.localizedDescription)")
                }
                
            }
            //dispatchGroup.leave()
            
            self.disconnectSemaphore?.signal()
        }
        //dispatchGroup.wait() // <= blocks the thread here
        // User has requested to finish the broadcast.
        
        print(#function)
        
        self.disconnectSemaphore?.wait()
        
    }*/
}
