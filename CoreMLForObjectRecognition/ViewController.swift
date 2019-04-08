//
//  ViewController.swift
//  CoreMLForObjectRecognition
//
//  Created by Mompi on 16/11/18.
//  Copyright © 2018 Mompi. All rights reserved.
//

import UIKit
import AVKit
import Vision
import AVFoundation
class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var faceDetected: UILabel!
    let redView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        let capturesession = AVCaptureSession()
        capturesession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(.builtInTrueDepthCamera, for: AVMediaType.video, position: .front) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        
        capturesession.addInput(input)
        capturesession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: capturesession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        capturesession.addOutput(dataOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        let request = VNDetectFaceRectanglesRequest { (req, err) in
            if let err = err {
                print("failed to detect faces")
            }
            DispatchQueue.main.async {
                self.faceDetected.isHidden = true
            }
            req.results?.forEach({ (res) in
                DispatchQueue.main.async {
                    self.faceDetected.isHidden = false
                }
                
            })
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Error")
        }
    }

}

