import UIKit
import AVFoundation

class ViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var Overlay: UIImageView!
    
    var captureSession = AVCaptureSession()
    
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice? {
        didSet{
            captureSession.stopRunning()
            setupInputOutput()
            captureSession.startRunning()
        }
    }
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer:AVCaptureVideoPreviewLayer?
    
    var image: UIImage?
    var imagePicker: UIImagePickerController?
    
    var isFrontFacing = false {
        didSet{
            if self.isFrontFacing {
                self.currentDevice = self.frontCamera
            } else {
                self.currentDevice = self.backCamera
            }
        }
    }
    
    var scale = CGFloat(1)
    var minScale = CGFloat(1)
    var maxScale = CGFloat(5)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Overlay.alpha = 0.5

        setupImagePicker()
        setupCaptureSession()
        setupDevice()
        setupPreviewLayer()
        captureSession.startRunning()
    }
    
    //MARK: - Settings
    var currentSettings: Settings = Settings(alpha: 0.5) {
        didSet {
            self.Overlay.alpha = self.currentSettings.alpha
        }
    }
    
    @IBAction func didPressSettings(_ sender: Any) {
        let vc = SettingsViewController(self.currentSettings) { newSettings in
            self.currentSettings = newSettings
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    

    //MARK: - Capture Session
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        currentDevice = backCamera
    }
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            
            // if there are inputs already, remove them
            if let input = captureSession.inputs.first {
                captureSession.removeInput(input)
            }
            captureSession.addInput(captureDeviceInput)
            
            photoOutput = AVCapturePhotoOutput()
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            // if there are outputs already, remove them
            if let output = captureSession.outputs.first {
                captureSession.removeOutput(output)
            }
            captureSession.addOutput(photoOutput!)
            
        } catch {
            print("⚠️", error)
        }
    }
    
    func setupPreviewLayer() {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.cameraPreviewLayer?.frame = view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
        
    //MARK: Gesture Recognizer
    
    @objc func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
    }
    
    @IBAction func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    @IBAction func handleRotate(recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    //MARK: - Image Picker
    
    func setupImagePicker(){
        self.imagePicker = UIImagePickerController()
        self.imagePicker?.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.Overlay.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressChangeImage(_ sender: Any) {
        self.presentPickerOptions()
    }
    
    func presentPickerOptions() {
        guard let imagePicker = self.imagePicker else { return }
        imagePicker.allowsEditing = true
        let alert = UIAlertController(title: "Image", message: "Choose an image.", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {_ in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        })
        let galeryAction = UIAlertAction(title: "Gallery", style: .default, handler : {_ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(galeryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}
