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
    
    let informationIdentifierView = UIView()
    let nameLabel = UILabel()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        
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
        
        setupInformationIdentifierView()
    }
    
    fileprivate func setupInformationIdentifierView() {
        let extremity:CGFloat = 10
        
        informationIdentifierView.backgroundColor = .white
        view.addSubview(informationIdentifierView)
        
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center
        informationIdentifierView.addSubview(nameLabel)
        
        
        //Constraints
        informationIdentifierView.translatesAutoresizingMaskIntoConstraints = false
        informationIdentifierView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 190).isActive = true
        informationIdentifierView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: extremity).isActive = true
        informationIdentifierView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -extremity).isActive = true
        informationIdentifierView.heightAnchor.constraint(equalToConstant: 190).isActive = true
        informationIdentifierView.layer.cornerRadius = 20
        informationIdentifierView.clipsToBounds = true
        
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        let viewReference = informationIdentifierView
        nameLabel.topAnchor.constraint(equalTo: viewReference.topAnchor, constant: 0).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: viewReference.centerXAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: viewReference.leftAnchor, constant: 0).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: viewReference.rightAnchor, constant: 0).isActive = true
        
        
    }
     
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let buffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        guard let model = try? VNCoreMLModel(for: IndrikClassification(configuration: MLModelConfiguration()).model) else {
            return
        }
        let request = VNCoreMLRequest(model: model){ (finishedReq, err) in
            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
            guard let firstObservation = results.first else {return}
            DispatchQueue.main.async {
                if firstObservation.identifier == "Caanerin"{
                    self.nameLabel.text = "Caanerin"
                    self.informationIdentifierApears()
                }
                //self.identifierLabel.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)"
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: buffer, options: [:]).perform([request])
    }
    
}

extension ViewController {
    func informationIdentifierApears(){
        self.informationIdentifierView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        UIView.animate(withDuration: 0.6) {
            self.view.layoutIfNeeded()
        }
    }
}
