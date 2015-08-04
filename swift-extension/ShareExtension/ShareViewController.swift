//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Max on 4/08/2015.
//  Copyright (c) 2015 Max. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
class ShareViewController: SLComposeServiceViewController {
  let sc_maxCharactersAllowed = 25
  var attachedImage: UIImage?
  let sc_uploadURL = "http://requestb.in/1k8i9hf1"
  
  
  override func isContentValid() -> Bool {
    // Do validation of contentText and/or NSExtensionContext attachments here
    if let currentMessage = contentText {
      let currentMessageLength = count(currentMessage)
      charactersRemaining = sc_maxCharactersAllowed - currentMessageLength
      
      if Int(charactersRemaining) < 0 {
        return false
      }
    }
    
    return true
  }
  override func presentationAnimationDidFinish() {
    // Only interested in the first item
    let extensionItem = extensionContext?.inputItems[0] as! NSExtensionItem
    // Extract an image (if one exists)
    imageFromExtensionItem(extensionItem) {
      image in
      if let image = image {
        dispatch_async(dispatch_get_main_queue()) {
          self.attachedImage = image
        }
      }
    }
  }
  
  override func didSelectPost() {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    let configName = "appscore.swift-extension.BackgroundSessionConfig"
    let sessionConfig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(configName)
    // Extensions aren't allowed their own cache disk space. Need to share with application
    sessionConfig.sharedContainerIdentifier = "group.appscore.swift-extension"
    let session = NSURLSession(configuration: sessionConfig)
    
    // Prepare the URL Request
    let request = urlRequestWithImage(attachedImage, text: contentText)
    
    // Create the task, and kick it off
    let task = session.dataTaskWithRequest(request!)
    
    task.resume()
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    extensionContext?.completeRequestReturningItems([AnyObject](), completionHandler: nil)
  }
  
  private func urlRequestWithImage(image: UIImage?, text: String) -> NSURLRequest? {
    let url = NSURL(fileURLWithPath: sc_uploadURL)
    let request: NSMutableURLRequest?  = (url==nil) ? NSMutableURLRequest(URL: url!) : nil
    request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request?.addValue("application/json", forHTTPHeaderField: "Accept")
    request?.HTTPMethod = "POST"
    
    var jsonObject = NSMutableDictionary()
    jsonObject["text"] = text
    if let image = image {
      jsonObject["image_details"] = extractDetailsFromImage(image)
    }
    
    // Create the JSON payload
    var jsonError: NSError?
    let jsonData = NSJSONSerialization.dataWithJSONObject(jsonObject, options: nil, error: &jsonError)
    if (jsonData != nil) {
      request?.HTTPBody = jsonData
    } else {
      if let error = jsonError {
        println("JSON Error: \(error.localizedDescription)")
      }
    }
    
    return request
  }
  
  private func extractDetailsFromImage(image: UIImage) -> NSDictionary {
    var resultDict = [String : AnyObject]()
    resultDict["height"] = image.size.height
    resultDict["width"] = image.size.width
    resultDict["orientation"] = image.imageOrientation.rawValue
    resultDict["scale"] = image.scale
    resultDict["description"] = image.description
    return resultDict
  }
  
  override func configurationItems() -> [AnyObject]! {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return [AnyObject]()
  }
  
  private func imageFromExtensionItem(extensionItem: NSExtensionItem, callback: (image: UIImage?) -> Void) {
    
    for attachment in extensionItem.attachments as! [NSItemProvider] {
      if(attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String)) {
        // Marshal on to a background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, UInt(0))) {
          attachment.loadItemForTypeIdentifier(kUTTypeImage as String, options: nil) {
            (imageProvider, error) in
            var image: UIImage? = nil
            if let error = error {
              println("Item loading error: \(error.localizedDescription)")
            }
            image = imageProvider as? UIImage
            dispatch_async(dispatch_get_main_queue()) {
              callback(image: image)
            }
          }
        }
      }
    }
  }

  
}
