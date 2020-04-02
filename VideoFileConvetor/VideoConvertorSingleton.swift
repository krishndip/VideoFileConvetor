//
//  VideoConvertorSingleton.swift
//  VideoFileConvetor
//
//  Created by Karan  on 01/04/20.
//  Copyright © 2020 Karan . All rights reserved.
//

import Foundation
import AVFoundation

class VideoConvertorSingleton: NSObject {
    static let sharedConvertor = VideoConvertorSingleton()

    override init(){}
    
    func convertVideo(videoURL : URL, completion: @escaping (Bool) -> Void)
    {
//        var pathVideoFile = Bundle.main.path(forResource: "bird", ofType: "mov")

        let avAsset = AVURLAsset(url: videoURL, options: nil)
        
        let startDate = NSDate()

        //Create Export session
        let exportSession : AVAssetExportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)!
        
        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL

        let filePath = documentsDirectory2.appendingPathComponent("rendered-Video.3gp")
        deleteFile(filePath: filePath! as NSURL)
        
   
       // test - get audio track from video
        /*
         avAsset.writeAudioTrackToURL(documentsDirectory2.appendingPathComponent("rendered-Audio.m4a")!) { (success, error) in
        
        }*/


        exportSession.outputURL = filePath
        exportSession.outputFileType = AVFileType.mobile3GPP
        exportSession.shouldOptimizeForNetworkUse = false
        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRangeMake(start: start, duration: avAsset.duration)
        exportSession.timeRange = range

        exportSession.exportAsynchronously(completionHandler: {() -> Void in
            
            var sucess : Bool = false
            switch exportSession.status {
            case .failed:
                print("%@",(exportSession as AnyObject).error as Any)
            case .cancelled:
                print("Export canceled")
            case .completed:
                //Video conversion finished
                let endDate = NSDate()

                let time = endDate.timeIntervalSince(startDate as Date)
                print(time)
                print("Successful!")
                print(exportSession.outputURL as Any)
                
                sucess = true

            default:
                break
            }

            completion(sucess)
        })
    }
    
    func deleteFile(filePath:NSURL) {
        guard FileManager.default.fileExists(atPath: filePath.path!) else {
            return
        }
        do {
            try FileManager.default.removeItem(atPath: filePath.path!)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
}


extension AVAsset {
    
    /// as per output url will write audio file in .m4a formate - make change to pass type for different formats
    /// - Parameters:
    ///   - url: output file url
    ///   - completion: success or failed + error if any
    func writeAudioTrackToURL(_ url: URL, completion: @escaping (Bool, Error?) -> ()) {
        do {
            let audioAsset = try self.audioAsset()
            audioAsset.writeToURL(url, completion: completion)
        } catch (let error as NSError){
            completion(false, error)
        }
    }

    func writeToURL(_ url: URL, completion: @escaping (Bool, Error?) -> ()) {

        guard let exportSession = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetAppleM4A) else {
            completion(false, nil)
            return
        }

        exportSession.outputFileType = .m4a
        exportSession.outputURL      = url

        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(true, nil)
            case .unknown, .waiting, .exporting, .failed, .cancelled:
                completion(false, nil)
            @unknown default:
                completion(false, nil)
            }
        }
    }
    
    /// returns composition with audio type
    func audioAsset() throws -> AVAsset {

        let composition = AVMutableComposition()
        let audioTracks = tracks(withMediaType: .audio)

        for track in audioTracks {

            let compositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try compositionTrack?.insertTimeRange(track.timeRange, of: track, at: track.timeRange.start)
            compositionTrack?.preferredTransform = track.preferredTransform
        }
        return composition
    }
}

enum conersionType {
    case MP4
    case MOV
    
}
