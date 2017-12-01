//code //
//  MMTViewController.swift
//  Siri
//
//  Created by Swagat PARIDA on 01/12/17.
//  Copyright © 2017 Sahand Edrisian. All rights reserved.
//

import UIKit
import WebKit
class MMTViewController: UIViewController, WKUIDelegate {
  
  var webView: WKWebView!
  var arModeButton: UIButton?
  
  override func loadView() {
    let webConfiguration = WKWebViewConfiguration()
    webView = WKWebView(frame: .zero, configuration: webConfiguration)
    
    webView.uiDelegate = self
    self.view = webView
    
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    let myURL = URL(string: "https://www.makemytrip.com/")
    let myRequest = URLRequest(url: myURL!)
    webView.load(myRequest)
    
    arModeButton = UIButton(frame: CGRect.zero)
    arModeButton?.translatesAutoresizingMaskIntoConstraints = false
    arModeButton?.setImage(UIImage(named: "augReality"), for: UIControlState.normal)
    arModeButton?.backgroundColor = UIColor.white
    self.view.addSubview(arModeButton!)
    arModeButton?.addTarget(self, action: #selector(arModeButtonButtonTap(_:)), for: UIControlEvents.touchDown)
    
    let arModeButtonContraintTrailing = NSLayoutConstraint(item: self.view,
                                                        attribute: NSLayoutAttribute.trailing,
                                                        relatedBy: NSLayoutRelation.equal,
                                                        toItem: arModeButton,
                                                        attribute: NSLayoutAttribute.trailing,
                                                        multiplier: 1.0,
                                                        constant: 20)
    
    let arModeButtonContraintBottom = NSLayoutConstraint(item: self.view,
                                                      attribute: NSLayoutAttribute.bottom,
                                                      relatedBy: NSLayoutRelation.equal,
                                                      toItem: arModeButton,
                                                      attribute: NSLayoutAttribute.bottom,
                                                      multiplier: 1.0,
                                                      constant: 40)
    
    let arModeButtonContraintWidth = NSLayoutConstraint(item: arModeButton!,
                                                     attribute: NSLayoutAttribute.width,
                                                     relatedBy: NSLayoutRelation.equal,
                                                     toItem: nil,
                                                     attribute: NSLayoutAttribute.notAnAttribute,
                                                     multiplier: 1.0,
                                                     constant: 60)
    
    let arModeButtonContraintHeight = NSLayoutConstraint(item: arModeButton!,
                                                      attribute: NSLayoutAttribute.height,
                                                      relatedBy: NSLayoutRelation.equal,
                                                      toItem: nil,
                                                      attribute: NSLayoutAttribute.notAnAttribute,
                                                      multiplier: 1.0,
                                                      constant: 60)
    
    self.view.addConstraints([arModeButtonContraintTrailing, arModeButtonContraintBottom, arModeButtonContraintWidth, arModeButtonContraintHeight])
  }
  
  override func viewDidLayoutSubviews() {
    arModeButton?.layer.cornerRadius = (arModeButton?.bounds.size.width)!/2
  }
  
  @objc func arModeButtonButtonTap(_ sender: UIButton!) {
    var arVC: UIViewController? = nil
    if #available(iOS 11.0, *) {
      arVC = ViewController()
    } else {
      arVC = NotSupportedViewController()
    }
    self.present(arVC!, animated: true, completion: nil)
  }
}
