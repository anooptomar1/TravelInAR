//
//  ViewController.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import UIKit
import SceneKit 
import MapKit
import CocoaLumberjack

@available(iOS 11.0, *)
class ViewController: UIViewController, MKMapViewDelegate, SceneLocationViewDelegate {
  let sceneLocationView = SceneLocationView()
  
  let mapView = MKMapView()
  var userAnnotation: MKPointAnnotation?
  var locationEstimateAnnotation: MKPointAnnotation?
  
  var updateUserLocationTimer: Timer?
  
  ///Whether to show a map view
  ///The initial value is respected
  var showMapView: Bool = false
  
  var centerMapOnUserLocation: Bool = true
  
  ///Whether to display some debugging data
  ///This currently displays the coordinate of the best location estimate
  ///The initial value is respected
  var displayDebugging = false
  
  var infoLabel = UILabel()
  
  var updateInfoLabelTimer: Timer?
  
  var addBubbleButton: UIButton?
  var messageLabel: UILabel?
  
  var adjustNorthByTappingSidesOfScreen = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    infoLabel.font = UIFont.systemFont(ofSize: 10)
    infoLabel.textAlignment = .left
    infoLabel.textColor = UIColor.white
    infoLabel.numberOfLines = 0
    sceneLocationView.addSubview(infoLabel)
    
    updateInfoLabelTimer = Timer.scheduledTimer(
      timeInterval: 0.1,
      target: self,
      selector: #selector(ViewController.updateInfoLabel),
      userInfo: nil,
      repeats: true)
    
    //Set to true to display an arrow which points north.
    //Checkout the comments in the property description and on the readme on this.
    //        sceneLocationView.orientToTrueNorth = false
    
    //        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly
    sceneLocationView.showAxesNode = false
    sceneLocationView.locationDelegate = self
    
    if displayDebugging {
      sceneLocationView.showFeaturePoints = true
    }
    
    //Currently set to Canary Wharf
    //        let pinCoordinate = CLLocationCoordinate2D(latitude: 51.504607, longitude: -0.019592)
    //        let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 236)
    //        let pinImage = UIImage(named: "Image")!
    //        let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
    //        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
    
    view.addSubview(sceneLocationView)
    
    if showMapView {
      mapView.delegate = self
      mapView.showsUserLocation = true
      mapView.alpha = 0.8
      view.addSubview(mapView)
      
      updateUserLocationTimer = Timer.scheduledTimer(
        timeInterval: 0.5,
        target: self,
        selector: #selector(ViewController.updateUserLocation),
        userInfo: nil,
        repeats: true)
    }
    
    addBubbleButton = UIButton(frame: CGRect.zero)
    addBubbleButton?.translatesAutoresizingMaskIntoConstraints = false
    addBubbleButton?.setImage(UIImage(named: "add"), for: UIControlState.normal)
    addBubbleButton?.backgroundColor = UIColor.white
    sceneLocationView.addSubview(addBubbleButton!)
    addBubbleButton?.addTarget(self, action: #selector(addBubbleButtonTap(_:)), for: UIControlEvents.touchDown)
    
    let addButtonContraintTrailing = NSLayoutConstraint(item: sceneLocationView,
                                                        attribute: NSLayoutAttribute.trailing,
                                                        relatedBy: NSLayoutRelation.equal,
                                                        toItem: addBubbleButton,
                                                        attribute: NSLayoutAttribute.trailing,
                                                        multiplier: 1.0,
                                                        constant: 20)
    
    let addButtonContraintBottom = NSLayoutConstraint(item: sceneLocationView,
                                                      attribute: NSLayoutAttribute.bottom,
                                                      relatedBy: NSLayoutRelation.equal,
                                                      toItem: addBubbleButton,
                                                      attribute: NSLayoutAttribute.bottom,
                                                      multiplier: 1.0,
                                                      constant: 20)
    
    let addButtonContraintWidth = NSLayoutConstraint(item: addBubbleButton!,
                                                     attribute: NSLayoutAttribute.width,
                                                     relatedBy: NSLayoutRelation.equal,
                                                     toItem: nil,
                                                     attribute: NSLayoutAttribute.notAnAttribute,
                                                     multiplier: 1.0,
                                                     constant: 50)
    
    let addButtonContraintHeight = NSLayoutConstraint(item: addBubbleButton!,
                                                      attribute: NSLayoutAttribute.height,
                                                      relatedBy: NSLayoutRelation.equal,
                                                      toItem: nil,
                                                      attribute: NSLayoutAttribute.notAnAttribute,
                                                      multiplier: 1.0,
                                                      constant: 50)
    
    sceneLocationView.addConstraints([addButtonContraintTrailing, addButtonContraintBottom, addButtonContraintWidth, addButtonContraintHeight])
    
    let tapRec = UITapGestureRecognizer(target: self, action: #selector(handleBubbleTap(_:)))
    sceneLocationView.addGestureRecognizer(tapRec)
    
    // message label
    messageLabel = UILabel(frame: CGRect.zero)
    messageLabel?.translatesAutoresizingMaskIntoConstraints = false
    messageLabel?.backgroundColor = UIColor.white
    messageLabel?.textAlignment = NSTextAlignment.center;
    //messageLabel?.font = UIFont.systemFont(ofSize: 3)
    messageLabel?.textColor = UIColor.black
    sceneLocationView.addSubview(messageLabel!)
    let messageLabelContraintLeading = NSLayoutConstraint(item: sceneLocationView,
                                                          attribute: NSLayoutAttribute.leading,
                                                          relatedBy: NSLayoutRelation.equal,
                                                          toItem: messageLabel,
                                                          attribute: NSLayoutAttribute.leading,
                                                          multiplier: 1.0,
                                                          constant: 5)
    
    let messageLabelContraintTrailing = NSLayoutConstraint(item: sceneLocationView,
                                                           attribute: NSLayoutAttribute.trailing,
                                                           relatedBy: NSLayoutRelation.equal,
                                                           toItem: messageLabel,
                                                           attribute: NSLayoutAttribute.trailing,
                                                           multiplier: 1.0,
                                                           constant: 5)
    let messageLabelContraintCenterY = NSLayoutConstraint(item: sceneLocationView,
                                                          attribute: NSLayoutAttribute.centerY,
                                                          relatedBy: NSLayoutRelation.equal,
                                                          toItem: messageLabel,
                                                          attribute: NSLayoutAttribute.centerY,
                                                          multiplier: 1.0,
                                                          constant: 0.0)
    let messageLabelContraintHeight = NSLayoutConstraint(item: messageLabel!,
                                                          attribute: NSLayoutAttribute.height,
                                                          relatedBy: NSLayoutRelation.equal,
                                                          toItem: nil,
                                                          attribute: NSLayoutAttribute.notAnAttribute,
                                                          multiplier: 1.0,
                                                          constant: 30.0)
    
    sceneLocationView.addConstraints([messageLabelContraintLeading, messageLabelContraintTrailing, messageLabelContraintCenterY, messageLabelContraintHeight])
    messageLabel?.isHidden = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    DDLogDebug("run")
    sceneLocationView.run()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    DDLogDebug("pause")
    // Pause the view's session
    sceneLocationView.pause()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    sceneLocationView.frame = CGRect(
      x: 0,
      y: 0,
      width: self.view.frame.size.width,
      height: self.view.frame.size.height)
    
    infoLabel.frame = CGRect(x: 6, y: 0, width: self.view.frame.size.width - 12, height: 14 * 4)
    
    if showMapView {
      infoLabel.frame.origin.y = (self.view.frame.size.height / 2) - infoLabel.frame.size.height
    } else {
      infoLabel.frame.origin.y = self.view.frame.size.height - infoLabel.frame.size.height
    }
    
    mapView.frame = CGRect(
      x: 0,
      y: self.view.frame.size.height / 2,
      width: self.view.frame.size.width,
      height: self.view.frame.size.height / 2)
    
    addBubbleButton?.layer.cornerRadius = (addBubbleButton?.bounds.size.width)!/2
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  @objc func updateUserLocation() {
    if let currentLocation = sceneLocationView.currentLocation() {
      DispatchQueue.main.async {
        
        if let bestEstimate = self.sceneLocationView.bestLocationEstimate(),
          let position = self.sceneLocationView.currentScenePosition() {
          DDLogDebug("")
          DDLogDebug("Fetch current location")
          DDLogDebug("best location estimate, position: \(bestEstimate.position), location: \(bestEstimate.location.coordinate), accuracy: \(bestEstimate.location.horizontalAccuracy), date: \(bestEstimate.location.timestamp)")
          DDLogDebug("current position: \(position)")
          
          let translation = bestEstimate.translatedLocation(to: position)
          
          DDLogDebug("translation: \(translation)")
          DDLogDebug("translated location: \(currentLocation)")
          DDLogDebug("")
        }
        
        if self.userAnnotation == nil {
          self.userAnnotation = MKPointAnnotation()
          self.mapView.addAnnotation(self.userAnnotation!)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
          self.userAnnotation?.coordinate = currentLocation.coordinate
        }, completion: nil)
        
        if self.centerMapOnUserLocation {
          UIView.animate(withDuration: 0.45, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.mapView.setCenter(self.userAnnotation!.coordinate, animated: false)
          }, completion: {
            _ in
            self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
          })
        }
        
        if self.displayDebugging {
          let bestLocationEstimate = self.sceneLocationView.bestLocationEstimate()
          
          if bestLocationEstimate != nil {
            if self.locationEstimateAnnotation == nil {
              self.locationEstimateAnnotation = MKPointAnnotation()
              self.mapView.addAnnotation(self.locationEstimateAnnotation!)
            }
            
            self.locationEstimateAnnotation!.coordinate = bestLocationEstimate!.location.coordinate
          } else {
            if self.locationEstimateAnnotation != nil {
              self.mapView.removeAnnotation(self.locationEstimateAnnotation!)
              self.locationEstimateAnnotation = nil
            }
          }
        }
      }
    }
  }
  
  @objc func updateInfoLabel() {
    if let position = sceneLocationView.currentScenePosition() {
      infoLabel.text = "x: \(String(format: "%.2f", position.x)), y: \(String(format: "%.2f", position.y)), z: \(String(format: "%.2f", position.z))\n"
    }
    
    if let eulerAngles = sceneLocationView.currentEulerAngles() {
      infoLabel.text!.append("Euler x: \(String(format: "%.2f", eulerAngles.x)), y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
    }
    
    if let heading = sceneLocationView.locationManager.heading,
      let accuracy = sceneLocationView.locationManager.headingAccuracy {
      infoLabel.text!.append("Heading: \(heading)º, accuracy: \(Int(round(accuracy)))º\n")
    }
    
    let date = Date()
    let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
    
    if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
      infoLabel.text!.append("\(String(format: "%02d", hour)):\(String(format: "%02d", minute)):\(String(format: "%02d", second)):\(String(format: "%03d", nanosecond / 1000000))")
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
//    if let touch = touches.first {
//      if touch.view != nil {
//        if (mapView == touch.view! ||
//          mapView.recursiveSubviews().contains(touch.view!)) {
//          centerMapOnUserLocation = false
//        } else {
//
//          let location = touch.location(in: self.view)
//
//          if location.x <= 40 && adjustNorthByTappingSidesOfScreen {
//            print("left side of the screen")
//            sceneLocationView.moveSceneHeadingAntiClockwise()
//          } else if location.x >= view.frame.size.width - 40 && adjustNorthByTappingSidesOfScreen {
//            print("right side of the screen")
//            sceneLocationView.moveSceneHeadingClockwise()
//          } else {
//            let image = UIImage(named: "dominoes")!
//            let annotationNode = LocationAnnotationNode(location: nil, image: image)
//            annotationNode.scaleRelativeToDistance = true
//            sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
//          }
//        }
//      }
//    }
  }
  
  @objc func addBubbleButtonTap(_ sender: UIButton!) {
    let image = UIImage(named: "dominoes")!
    let annotationNode = LocationAnnotationNode(location: nil, image: image)
    annotationNode.scaleRelativeToDistance = true
    annotationNode.name = "Bla bla"
    sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
  }
  
  @objc func handleBubbleTap(_ rec: UITapGestureRecognizer) {
    if rec.state == .ended {
      let location: CGPoint = rec.location(in: sceneLocationView)
      let hits = sceneLocationView.hitTest(location, options: nil)
      if let tappednode = hits.first?.node {
        let node = tappednode.parent as! LocationAnnotationNode
        let name = node.name
        node.bubbleView.backgroundColor = UIColor.green
      }
    }
  }
  
  
  //MARK: MKMapViewDelegate
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      return nil
    }
    
    if let pointAnnotation = annotation as? MKPointAnnotation {
      let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
      
      if pointAnnotation == self.userAnnotation {
        marker.displayPriority = .required
        marker.glyphImage = UIImage(named: "user")
      } else {
        marker.displayPriority = .required
        marker.markerTintColor = UIColor(hue: 0.267, saturation: 0.67, brightness: 0.77, alpha: 1.0)
        marker.glyphImage = UIImage(named: "compass")
      }
      
      return marker
    }
    
    return nil
  }
  
  //MARK: SceneLocationViewDelegate
  
  func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
    DDLogDebug("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
  }
  
  func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
    DDLogDebug("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
  }
  
  func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
  }
  
  func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
    
  }
  
  func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
    
  }
}

extension DispatchQueue {
  func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
    self.asyncAfter(
      deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
  }
}

extension UIView {
  func recursiveSubviews() -> [UIView] {
    var recursiveSubviews = self.subviews
    
    for subview in subviews {
      recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
    }
    
    return recursiveSubviews
  }
}
