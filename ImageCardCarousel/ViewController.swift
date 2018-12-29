//
//  ViewController.swift
//  ImageCardCarousel
//
//  Created by Charles Martin Reed on 12/28/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //a helper function that converts a degree angle to radians
    func degreeToRadians(deg: CGFloat) -> CGFloat {
        return (deg * CGFloat.pi) / 180
    }

    //MARK:- Properties
    let imageNames: [String] = ["Ajanta Caves", "Ellora Caves", "Agra Fort", "Taj Mahal", "Sun Temple", "Monuments at Mahabalipuram", "Kaziranga National Park"]
    
    let transformLayer = CATransformLayer()
    var currentAngle: CGFloat = 0
    var currentOffset: CGFloat = 0 //holds offset of our pan gesture recognizer
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transformLayer.frame = self.view.bounds //grab the screen size
        view.layer.addSublayer(transformLayer)
        
        //for loop to add images to the transformLayer
        for i in 1..<imageNames.count { //6 because we only have 6 images at the moment
            addImageCard(name: "\(i)", title: String(imageNames[i]))
        }
        
        turnCarousel() //image cards will be arranged in a circle
        
        //MARK:- Pan Gesture recognizer
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.performPanAction(recognizer:)))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.performTapAction(recognizer:)))
        
        view.addGestureRecognizer(panGestureRecognizer)
        view.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    //MARK:- 3D effect methods
    fileprivate func turnCarousel() {
        //turns the images, gives the image layers their initial positions
        
        //get the sublayers
        guard let transformSubLayers = transformLayer.sublayers else { return }
        
        //define the image card seg size needed to create a circle
        let segmentForImageCard = CGFloat(360 / transformSubLayers.count)
        
        //get the angle offset for each image
        var angleOffset = currentAngle
        
        //iterate through the sublayers/imageCard to give proper position
        //transform, rotate, translate
        for layer in transformSubLayers {
            //create a 4x4 matrix
            var transform = CATransform3DIdentity
            transform.m34 = -1 / 500 //this matrix element is responsible for depth of perspective, closer to 0 equals deeper perspective
            
            //rotate around the Y axis
            transform = CATransform3DRotate(transform, degreeToRadians(deg: angleOffset), 0, 1, 0)
            transform = CATransform3DTranslate(transform, 0, 0, 200)
            
            CATransaction.setAnimationDuration(0) //we're setting the transform animation time to our pan gesture, so we disable the default time duration here
            layer.transform = transform
            
            angleOffset += segmentForImageCard
        }
}
    
    fileprivate func addImageCard(name: String, title: String) {
        
        let imageCardSize = CGSize(width: 200, height: 300)
        
        //create the image Layer
        let imageLayer = CALayer()
        imageLayer.name = title
        imageLayer.frame = CGRect(x: view.frame.size.width / 2 - imageCardSize.width / 2 , y: view.frame.size.height / 2 - imageCardSize.height / 2, width: imageCardSize.width, height: imageCardSize.height)
        
        //create the image title layer
        let imageTitleLayer = CATextLayer()
        //create a CATextLayer to serve as label
        let imageTitleLayerWidth: CGFloat = 150
        let imageTitleLayerHeight: CGFloat = 100
        //imageTitleLayer.frame = CGRect(x: imageLayer.frame.width * 2 + imageTitleLayerWidth , y: imageLayer.frame.height / 2 + imageTitleLayerHeight, width: imageTitleLayerWidth, height: imageTitleLayerHeight)
        imageTitleLayer.frame = CGRect(x: (imageLayer.bounds.width / 2) - (imageTitleLayerWidth / 2), y: imageLayer.bounds.height - 24, width: imageTitleLayerWidth, height: imageTitleLayerHeight)
        
        imageTitleLayer.string = imageLayer.name
        imageTitleLayer.foregroundColor = UIColor.blue.cgColor
        imageTitleLayer.contentsScale = UIScreen.main.scale //should fix the blurred text issue
        imageTitleLayer.fontSize = 14
        
        imageLayer.addSublayer(imageTitleLayer)
        
        //the point around which our carousel will rotate, 0.5 is actually default
        imageLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //add the image(s) to our layer - note that we need to convert to a cgImage
        guard let imageCardImage = UIImage(named: name)?.cgImage else { return }
        
        imageLayer.contents = imageCardImage
        imageLayer.contentsGravity = .resizeAspectFill //similar to contentMode with UIImageView
        imageLayer.masksToBounds = true
        
        //imageLayer properties
        imageLayer.isDoubleSided = false //makes the backside visible when we're rotating our layer in 3D
        imageLayer.borderColor = UIColor(white: 1, alpha: 0.5).cgColor
        imageLayer.borderWidth = 5
        imageLayer.cornerRadius = 10
        
        //added to the transform layer so that we can manipulate all of our cards at once
        transformLayer.addSublayer(imageLayer)
    }

    //MARK:- Gesture recognizer helper methods
    @objc fileprivate func performPanAction(recognizer: UIPanGestureRecognizer) {
        //update carousel transform layout values
        
        //get translation of our finger position in our view; x view only since we're only panning in one direction
        let xOffset = recognizer.translation(in: self.view).x
        
        if recognizer.state == .began {
            currentOffset = 0
        }
        
        //figure out how far we've scrolled with our finger
        //using 0.6 to slow down the animation, but this is obviously a matter of taste
        let xDifference = xOffset * 0.6 - currentOffset
        currentOffset += xDifference
        currentAngle += xDifference
        
        //update the values continuously while the finger is moving
        turnCarousel()
    }
    
    @objc fileprivate func performTapAction(recognizer: UITapGestureRecognizer) {
        //center the card in question
        
        
        //TESTING: print the name of the wonder depicted in the image
        let touchLocation = recognizer.location(in: self.view)
        //print(touchLocation)
        
        guard let sublayers = transformLayer.sublayers else { return }
        //grab the imageLayer
        for layer in sublayers {
            if layer.frame.contains(touchLocation) {
                guard let locationName = layer.name else { return }
                print(locationName)
            }
        }
    }

}

extension CATextLayer {
    static let textLabel: CATextLayer = {
       let label = CATextLayer()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.foregroundColor = UIColor.white.cgColor
        return label
    }()
}

extension UIView {
    func anchorBottomRight() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewTrailing = superview?.trailingAnchor {
            trailingAnchor.constraint(equalTo: superviewTrailing, constant: -8)
        }
        
        if let superviewBottom = superview?.bottomAnchor {
            bottomAnchor.constraint(equalTo: superviewBottom, constant: -8)
        }
    }
}
