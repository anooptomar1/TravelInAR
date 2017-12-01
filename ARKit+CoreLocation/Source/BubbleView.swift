//
//  BubbleView.swift
//  ARKit+CoreLocation
//
//  Created by Dheerasameer KOTTAPALLI on 01/12/17.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import UIKit

class BubbleView: UIView {

  let imageViewPadding: CGFloat = 5.0
  let messageLabelPadding: CGFloat = 2.0
  var imageView: UIImageView? = nil
  var messageLabel: UILabel?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.commonInit()
  }
  
  private func commonInit() {
    self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
    
    // image view
    imageView = UIImageView(frame: CGRect.zero)
    imageView?.translatesAutoresizingMaskIntoConstraints = false
    imageView?.backgroundColor = UIColor.clear
    imageView?.contentMode = UIViewContentMode.center
    self.addSubview(imageView!)
    
    let imageViewContraintLeading = NSLayoutConstraint(item: imageView!,
                                                       attribute: NSLayoutAttribute.leading,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: self,
                                                       attribute: NSLayoutAttribute.leading,
                                                       multiplier: 1.0,
                                                       constant: imageViewPadding)
    
    let imageViewContraintTop = NSLayoutConstraint(item: imageView!,
                                                       attribute: NSLayoutAttribute.top,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: self,
                                                       attribute: NSLayoutAttribute.top,
                                                       multiplier: 1.0,
                                                       constant: imageViewPadding)

    let imageViewContraintTrailing = NSLayoutConstraint(item: imageView!,
                                                       attribute: NSLayoutAttribute.trailing,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: self,
                                                       attribute: NSLayoutAttribute.trailing,
                                                       multiplier: 1.0,
                                                       constant: -imageViewPadding)
    
    let imageViewContraintHeight = NSLayoutConstraint(item: imageView!,
                                                        attribute: NSLayoutAttribute.height,
                                                        relatedBy: NSLayoutRelation.equal,
                                                        toItem: nil,
                                                        attribute: NSLayoutAttribute.notAnAttribute,
                                                        multiplier: 1.0,
                                                        constant: self.bounds.size.width - 2*imageViewPadding)
    self.addConstraints([imageViewContraintLeading, imageViewContraintTop, imageViewContraintTrailing, imageViewContraintHeight])
    imageView?.layer.cornerRadius = (imageView?.frame.size.width)!/2
    // message label
    messageLabel = UILabel(frame: CGRect.zero)
    messageLabel?.translatesAutoresizingMaskIntoConstraints = false
    messageLabel?.backgroundColor = UIColor.clear
    messageLabel?.textAlignment = NSTextAlignment.center;
    messageLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
    messageLabel?.numberOfLines = 0;
    messageLabel?.font = UIFont.systemFont(ofSize: 3)
    messageLabel?.textColor = UIColor.black
    self.addSubview(messageLabel!)
    
    let messageLabelContraintLeading = NSLayoutConstraint(item: messageLabel!,
                                                          attribute: NSLayoutAttribute.leading,
                                                          relatedBy: NSLayoutRelation.equal,
                                                          toItem: self,
                                                          attribute: NSLayoutAttribute.leading,
                                                          multiplier: 1.0,
                                                          constant: messageLabelPadding)
    
    let messageLabelContraintTop = NSLayoutConstraint(item: messageLabel!,
                                                      attribute: NSLayoutAttribute.top,
                                                      relatedBy: NSLayoutRelation.equal,
                                                      toItem: imageView,
                                                      attribute: NSLayoutAttribute.bottom,
                                                      multiplier: 1.0,
                                                      constant: 1.0)
    
    let messageLabelContraintTrailing = NSLayoutConstraint(item: messageLabel!,
                                                           attribute: NSLayoutAttribute.trailing,
                                                           relatedBy: NSLayoutRelation.equal,
                                                           toItem: self,
                                                           attribute: NSLayoutAttribute.trailing,
                                                           multiplier: 1.0,
                                                           constant: -messageLabelPadding)
    
    self.addConstraints([messageLabelContraintLeading, messageLabelContraintTop, messageLabelContraintTrailing])

  }

}
