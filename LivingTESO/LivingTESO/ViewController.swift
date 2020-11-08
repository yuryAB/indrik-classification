//
//  ViewController.swift
//  LivingTESO
//
//  Created by yury antony on 08/11/20.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
//    let identifierLabel: UILabel = {
//        let label = UILabel()
//        label.backgroundColor = .white
//        label.textAlignment = .center
//        label.textColor = .black
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
    
    enum CardState {
        case expanded
        case collapsed
    }
    var cardViewController:CardViewController!
    var visualEffectView:UIVisualEffectView!
    var cardHeight:CGFloat = 600
    var cardHandlerAreaHeight:CGFloat = 65
    
    var cardVisible = false
    var nextState:CardState{
        return cardVisible ? .collapsed: .expanded
    }
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
            
        }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
            
        }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        //setupIdentifierConfidenceLabel()
        setupCard()
    }
    
//    fileprivate func setupIdentifierConfidenceLabel() {
//        view.addSubview(identifierLabel)
//        identifierLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
//        identifierLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        identifierLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        identifierLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
//    }
     
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let buffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        guard let model = try? VNCoreMLModel(for: IndrikClassification(configuration: MLModelConfiguration()).model) else {
            return
        }
        let request = VNCoreMLRequest(model: model){ (finishedReq, err) in
            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
            //guard let firstObservation = results.first else {return}
            DispatchQueue.main.async {
                //self.identifierLabel.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)"
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: buffer, options: [:]).perform([request])
    }
    
    
    func setupCard() {
            visualEffectView = UIVisualEffectView()
            visualEffectView.frame = self.view.frame
            self.view.addSubview(visualEffectView)

            // Add CardViewController xib to the bottom of the screen, clipping bounds so that the corners can be rounded
            cardViewController = CardViewController(nibName:"CardViewController", bundle:nil)
        self.addChild(cardViewController)
            self.view.addSubview(cardViewController.view)
        
            cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandlerAreaHeight, width: self.view.bounds.width, height: cardHeight)
        
            cardViewController.view.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleCardTap(recognizer:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleCardPan(recognizer:)))
        
        cardViewController.handlerArea.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.handlerArea.addGestureRecognizer(panGestureRecognizer)
    }
    
            
    @objc
        func handleCardTap(recognizer:UITapGestureRecognizer) {
            switch recognizer.state {
            case .ended:
                animateTransitionIfNeeded(state: nextState, duration: 0.9)
            default:
                break
            }
        }
        
        @objc
        func handleCardPan (recognizer:UIPanGestureRecognizer) {
            switch recognizer.state {
            case .began:
                startInteractiveTransition(state: nextState, duration: 0.9)
                
            case .changed:
                let translation = recognizer.translation(in: self.cardViewController.handlerArea)
                var fractionComplete = translation.y / cardHeight
                fractionComplete = cardVisible ? fractionComplete : -fractionComplete
                updateInteractiveTransition(fractionCompleted: fractionComplete)
            case .ended:
                continueInteractiveTransition()
            default:
                break
            }
        }
}
    

extension ViewController{
    func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
            if runningAnimations.isEmpty {
                let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                    switch state {
                    case .expanded:
                        self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                        self.visualEffectView.effect = UIBlurEffect(style: .dark)
       
                    case .collapsed:
                        self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandlerAreaHeight
                        
                        self.visualEffectView.effect = nil
                    }
                }
                
                // Complete animation frame
                frameAnimator.addCompletion { _ in
                    self.cardVisible = !self.cardVisible
                    self.runningAnimations.removeAll()
                }
                
                // Start animation
                frameAnimator.startAnimation()
                
                // Append animation to running animations
                runningAnimations.append(frameAnimator)
                
                // Create UIViewPropertyAnimator to round the popover view corners depending on the state of the popover
                let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                    switch state {
                    case .expanded:
                        // If the view is expanded set the corner radius to 30
                        self.cardViewController.view.layer.cornerRadius = 30
                        
                    case .collapsed:
                        // If the view is collapsed set the corner radius to 0
                        self.cardViewController.view.layer.cornerRadius = 0
                    }
                }
                
                // Start the corner radius animation
                cornerRadiusAnimator.startAnimation()
                
                // Append animation to running animations
                runningAnimations.append(cornerRadiusAnimator)
                
            }
        }
    func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            //animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
            
        }
    }
    
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
            
        }
    }
    func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            
        }
        
    }
}


