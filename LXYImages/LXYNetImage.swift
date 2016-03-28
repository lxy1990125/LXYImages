//
//  LXYNetImage.swift
//  LXYImages
//
//  Created by 李 欣耘 on 16/3/24.
//  Copyright © 2016年 lixinyun. All rights reserved.
//
// This is load Image From net and add some Layer if you want and it is very easy

import UIKit

internal let selfCachePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as NSString

internal

class LXYNetImage: NSObject,NSURLSessionDownloadDelegate {
    
// simple Image
    class func lxy_imageWithURL(imageNetPath: String, placeholderImage: String?, completionHandler: (UIImage?,NSURLResponse?, NSError?) -> Void) ->UIImage {
        let imageName : NSString = imageNetPath.componentsSeparatedByString("/")[imageNetPath.componentsSeparatedByString("/").count-1]
        
        let imageDataPath = (selfCachePath as String) + "/\(imageName)"
        
        let cateImagesUrl : NSURL = NSURL(fileURLWithPath: imageDataPath)
        
        
        if let cateReadData : NSData  = NSData(contentsOfURL: cateImagesUrl) {
            return UIImage.init(data: cateReadData)!
        }else{
            var returnImage : UIImage?
            
            if placeholderImage == "" || placeholderImage == nil {
                returnImage = nil
            }else {
                returnImage = UIImage.init(named: placeholderImage!)!
            }
            
            
            let request : NSURLRequest = NSURLRequest.init(URL: NSURL.init(string: imageNetPath)!)
            
            
            let session : NSURLSession = NSURLSession.sharedSession()
            
            let task : NSURLSessionDownloadTask = session.downloadTaskWithRequest(request, completionHandler: { (location : NSURL?, response : NSURLResponse?, error : NSError?) in
                if error != nil {
                    print ("网络连接失败")
                }else {
                    
                    let locationPath = location!.path
                  
                    let cacheImage:String = (selfCachePath as String) + "/\(imageName)"
                   
                    let fileManager:NSFileManager = NSFileManager.defaultManager()
                    try! fileManager.moveItemAtPath(locationPath!, toPath: cacheImage)
                    print("new location:\(cacheImage)")
                    
                    dispatch_sync(dispatch_get_main_queue(),{ () -> Void in
                        completionHandler(UIImage.init(contentsOfFile: cacheImage)!,response,error)
                    })
                    
                    
                }
            })
            
            task.resume()
            
            return returnImage!
            
        }
        
    }
    
//MARK: addImage layer on -----
    
    internal func addLayerOnImage(image: UIImage?) -> UIImage {
        
        if image == nil {
          return  LXYColorImageSwift.imageWithColor(UIColor.init(colorLiteralRed: 97/255.0, green: 151/255.0, blue: 182/255.0, alpha: 0.8))

        }else {
          return  LXYUIImageViewEffectsSwift.shareInstance().applyBlurRadius(image!, blurRadius: 0, tintColor: UIColor.init(colorLiteralRed: 97/255.0, green: 151/255.0, blue: 182/255.0, alpha: 0.8), saturationDeltaFactor: 1.8, maskImage: nil)!
        }
    }
    
    
//MARK: downloadDelegate with progress come soon-----------
    
    
    func sessionSeniorDownload(){

        let url = NSURL(string: "xxxx")

        let request:NSURLRequest = NSURLRequest(URL: url!)
        
        let session = currentSession() as NSURLSession
        

        let downloadTask = session.downloadTaskWithRequest(request)

        
        downloadTask.resume()
    }
    
    
    func currentSession() -> NSURLSession{
        var predicate:dispatch_once_t = 0
        var currentSession:NSURLSession? = nil
        
        dispatch_once(&predicate, {
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            currentSession = NSURLSession(configuration: config, delegate: self,
                delegateQueue: nil)
        })
        return currentSession!
    }
    
    
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
    }
    
   
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }

}
