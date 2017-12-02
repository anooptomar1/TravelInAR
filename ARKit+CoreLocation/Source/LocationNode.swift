//
//  LocationNode.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import Foundation
import SceneKit
import CoreLocation

///A location node can be added to a scene using a coordinate.
///Its scale and position should not be adjusted, as these are used for scene layout purposes
///To adjust the scale and position of items within a node, you can add them to a child node and adjust them there
open class LocationNode: SCNNode {
  ///Location can be changed and confirmed later by SceneLocationView.
  public var location: CLLocation!
  
  ///Whether the location of the node has been confirmed.
  ///This is automatically set to true when you create a node using a location.
  ///Otherwise, this is false, and becomes true once the user moves 100m away from the node,
  ///except when the locationEstimateMethod is set to use Core Location data only,
  ///as then it becomes true immediately.
  public var locationConfirmed = false
  
  ///Whether a node's position should be adjusted on an ongoing basis
  ///based on its' given location.
  ///This only occurs when a node's location is within 100m of the user.
  ///Adjustment doesn't apply to nodes without a confirmed location.
  ///When this is set to false, the result is a smoother appearance.
  ///When this is set to true, this means a node may appear to jump around
  ///as the user's location estimates update,
  ///but the position is generally more accurate.
  ///Defaults to true.
  public var continuallyAdjustNodePositionWhenWithinRange = true
  
  ///Whether a node's position and scale should be updated automatically on a continual basis.
  ///This should only be set to false if you plan to manually update position and scale
  ///at regular intervals. You can do this with `SceneLocationView`'s `updatePositionOfLocationNode`.
  public var continuallyUpdatePositionAndScale = true
  
  public init(location: CLLocation?) {
    self.location = location
    self.locationConfirmed = location != nil
    super.init()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

open class LocationAnnotationNode: LocationNode {
  ///An image to use for the annotation
  ///When viewed from a distance, the annotation will be seen at the size provided
  ///e.g. if the size is 100x100px, the annotation will take up approx 100x100 points on screen.
  public let image: UIImage?
  
  let bubbleView: BubbleView?
  
  ///Subnodes and adjustments should be applied to this subnode
  ///Required to allow scaling at the same time as having a 2D 'billboard' appearance
  public let annotationNode: SCNNode
  
  ///Whether the node should be scaled relative to its distance from the camera
  ///Default value (false) scales it to visually appear at the same size no matter the distance
  ///Setting to true causes annotation nodes to scale like a regular node
  ///Scaling relative to distance may be useful with local navigation-based uses
  ///For landmarks in the distance, the default is correct
  public var scaleRelativeToDistance = false
  
  public init(location: CLLocation?, image: UIImage) {
    
    self.image = image
    self.bubbleView = nil
    let plane = SCNPlane(width: image.size.width / 100, height: image.size.height / 100)
    
    plane.cornerRadius = 1.0
    plane.firstMaterial!.diffuse.contents = self.image
    plane.firstMaterial!.lightingModel = .constant
    //    if #available(iOS 10.0, *) {
    //      plane.firstMaterial!.lightingModel = .physicallyBased
    //    } else {
    //      plane.firstMaterial!.lightingModel = .constant
    //    }
    
    annotationNode = SCNNode()
    annotationNode.geometry = plane
    
    super.init(location: location)
    
    let billboardConstraint = SCNBillboardConstraint()
    billboardConstraint.freeAxes = SCNBillboardAxis.Y
    constraints = [billboardConstraint]
    
    addChildNode(annotationNode)
  }
  
  public init(location: CLLocation?, image: UIImage, hotelName: String, hotelPrice: String, hotelDistance: String) {
    self.bubbleView = BubbleView(frame: CGRect(x: 0, y: 0, width: 45, height: 60))
    self.image = nil
    annotationNode = SCNNode()
    super.init(location: location)
    if let bubbleView = self.bubbleView{
      bubbleView.imageView?.image = image
      bubbleView.imageView?.layer.borderWidth = 1.0
      bubbleView.imageView?.layer.borderColor = UIColor.red.cgColor
      bubbleView.imageView?.layer.cornerRadius = 17.5
      bubbleView.imageView?.clipsToBounds = true
      bubbleView.messageLabel?.text = hotelName
      bubbleView.messageLabel?.textColor = .black
      bubbleView.messageLabel?.font = bubbleView.messageLabel?.font.withSize(5)
      bubbleView.hotelPriceLabel?.text = hotelPrice
      bubbleView.hotelDistanceLabel?.text = hotelDistance
      let plane = SCNPlane(width: bubbleView.bounds.size.width / 100, height: bubbleView.bounds.size.height / 100)
      
      plane.cornerRadius = 1.0
      plane.firstMaterial!.diffuse.contents = bubbleView
      plane.firstMaterial!.lightingModel = .constant
      //    if #available(iOS 10.0, *) {
      //      plane.firstMaterial!.lightingModel = .physicallyBased
      //    } else {
      //      plane.firstMaterial!.lightingModel = .constant
      //    }
      annotationNode.geometry = plane
      let billboardConstraint = SCNBillboardConstraint()
      billboardConstraint.freeAxes = SCNBillboardAxis.Y
      constraints = [billboardConstraint]
      addChildNode(annotationNode)
    }
  }
  
  
  
  public init(location: CLLocation?, image: UIImage, message: String) {
    self.bubbleView = BubbleView(frame: CGRect(x: 0, y: 0, width: 45, height: 60))
    self.image = nil
    annotationNode = SCNNode()
    super.init(location: location)
    if let bubbleView = self.bubbleView{
      bubbleView.imageView?.image = image
      bubbleView.imageView?.layer.borderWidth = 1.0
      bubbleView.imageView?.layer.borderColor = UIColor.purple.cgColor
      bubbleView.imageView?.layer.cornerRadius = 17.5
      bubbleView.imageView?.clipsToBounds = true
      bubbleView.messageLabel?.text = message
      bubbleView.messageLabel?.textColor = .black
      bubbleView.messageLabel?.font = bubbleView.messageLabel?.font.withSize(5)
      let plane = SCNPlane(width: bubbleView.bounds.size.width / 100, height: bubbleView.bounds.size.height / 100)
      
      plane.cornerRadius = 1.0
      plane.firstMaterial!.diffuse.contents = bubbleView
      plane.firstMaterial!.lightingModel = .constant
      //    if #available(iOS 10.0, *) {
      //      plane.firstMaterial!.lightingModel = .physicallyBased
      //    } else {
      //      plane.firstMaterial!.lightingModel = .constant
      //    }
      annotationNode.geometry = plane
      let billboardConstraint = SCNBillboardConstraint()
      billboardConstraint.freeAxes = SCNBillboardAxis.Y
      constraints = [billboardConstraint]
      addChildNode(annotationNode)
    }
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
