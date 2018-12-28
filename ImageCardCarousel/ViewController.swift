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
        for i in 1...6 { //6 because we only have 6 images at the moment
            addImageCard(name: "\(i)")
        }
        
        turnCarousel() //image cards will be arranged in a circle
        
        //MARK:- Pan Gesture recognizer
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.performPanAction(recognizer:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
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
    
    fileprivate func addImageCard(name: String) {
        
        let imageCardSize = CGSize(width: 200, height: 300)
        
        //create the image Layer
        let imageLayer = CALayer()
        imageLayer.frame = CGRect(x: view.frame.size.width / 2 - imageCardSize.width / 2 , y: view.frame.size.height / 2 - imageCardSize.height / 2, width: imageCardSize.width, height: imageCardSize.height)
        
        //the point around which our carousel will rotate, 0.5 is actually default
        imageLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //add the image(s) to our layer - note that we need to convert to a cgImage
        guard let imageCardImage = UIImage(named: name)?.cgImage else { return }
        imageLayer.contents = imageCardImage
        imageLayer.contentsGravity = .resizeAspectFill //similar to contentMode with UIImageView
        imageLayer.masksToBounds = true
        
        //imageLayer properties
        imageLayer.isDoubleSided = true //makes the backside visible when we're rotating our layer in 3D
        imageLayer.borderColor = UIColor(white: 1, alpha: 0.5).cgColor
        imageLayer.borderWidth = 5
        imageLayer.cornerRadius = 10
        
        //added to the transform layer so that we can manipulate all of our cards at once
        transformLayer.addSublayer(imageLayer)
    }

    //MARK:- Gesture recognizer helper method
    @objc fileprivate func performPanAction(recognizer: UIPanGestureRecognizer) {
        
    }

}

