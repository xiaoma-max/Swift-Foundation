//
//  ViewController.swift
//  swift-extension
//
//  Created by Max on 4/08/2015.
//  Copyright (c) 2015 Max. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var sharingContentImageView: UIImageView!

  @IBAction func handleShareSampleTapped(sender: AnyObject) {
    shareContent(text: "Highland Cow", image: sharingContentImageView.image)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // Utility methods
  func shareContent(#text: String?, image: UIImage?) {
    var itemsToShare = [AnyObject]()
    
    if let text = text {
      itemsToShare.append(text)
    }
    if let image = image {
      itemsToShare.append(image)
    }
    
    let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
    presentViewController(activityViewController, animated: true, completion: nil)
  }
  

}

