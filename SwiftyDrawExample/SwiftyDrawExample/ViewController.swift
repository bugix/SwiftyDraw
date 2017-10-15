/*Copyright (c) 2016, Andrew Walz.
 
 Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
 BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

import UIKit

class ViewController: UIViewController {

    var drawView: SwiftyDrawView!
    var redButton: ColorButton!
    var greenButton: ColorButton!
    var blueButton: ColorButton!
    var orangeButton: ColorButton!
    var purpleButton: ColorButton!
    var yellowButton: ColorButton!
    var undoButton: UIButton!
    var deleteButton: UIButton!
    var captureButton: UIButton!
    var lineWidthSlider: UISlider!
    var opacitySlider: UISlider!
    var buttons = [UIButton]()

    override func viewDidLoad() {
        super.viewDidLoad()
        drawView = SwiftyDrawView(frame: self.view.frame)
        drawView.delegate = self
        view.addSubview(drawView)
        addButtons()
        addSliders()
    }

    func addButtons() {
        redButton = ColorButton(frame: CGRect(x: 10, y: view.frame.height - 50, width: 40, height: 40), color: UIColor.red)
        redButton.addTarget(self, action: #selector(colorButtonPressed(button:)), for: .touchUpInside)
        view.addSubview(redButton)
        buttons.append(redButton)

        greenButton = ColorButton(frame: CGRect(x: 10, y: view.frame.height - 100, width: 40, height: 40), color: UIColor.green)
        greenButton.addTarget(self, action: #selector(colorButtonPressed(button:)), for: .touchUpInside)
        view.addSubview(greenButton)
        buttons.append(greenButton)

        blueButton = ColorButton(frame: CGRect(x: 10, y: view.frame.height - 150, width: 40, height: 40), color: UIColor.blue)
        blueButton.addTarget(self, action: #selector(colorButtonPressed(button:)), for: .touchUpInside)
        view.addSubview(blueButton)
        buttons.append(blueButton)

        orangeButton = ColorButton(frame: CGRect(x: 60, y: view.frame.height - 150, width: 40, height: 40), color: UIColor.orange)
        orangeButton.addTarget(self, action: #selector(colorButtonPressed(button:)), for: .touchUpInside)
        view.addSubview(orangeButton)
        buttons.append(orangeButton)

        purpleButton = ColorButton(frame: CGRect(x: 60, y: view.frame.height - 100, width: 40, height: 40), color: UIColor.purple)
        purpleButton.addTarget(self, action: #selector(colorButtonPressed(button:)), for: .touchUpInside)
        view.addSubview(purpleButton)
        buttons.append(purpleButton)

        yellowButton = ColorButton(frame: CGRect(x: 60, y: view.frame.height - 50, width: 40, height: 40), color: UIColor.yellow)
        yellowButton.addTarget(self, action: #selector(colorButtonPressed(button:)), for: .touchUpInside)
        view.addSubview(yellowButton)
        buttons.append(yellowButton)

        undoButton = UIButton(type: .system)
        undoButton.frame = CGRect(x: view.frame.width - 80, y: 30, width: 80, height: 30)
        undoButton.setTitle("undo", for: .normal)
        undoButton.addTarget(self, action: #selector(undo), for: .touchUpInside)
        undoButton.isEnabled = false
        view.addSubview(undoButton)
        buttons.append(undoButton)

        deleteButton = UIButton(type: .system)
        deleteButton.frame = CGRect(x: view.frame.width - 80, y: 60, width: 80, height: 30)
        deleteButton.setTitle("delete", for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteDrawing), for: .touchUpInside)
        deleteButton.isEnabled = false
        view.addSubview(deleteButton)
        buttons.append(deleteButton)

        captureButton = UIButton(type: .system)
        captureButton.frame = CGRect(x: view.frame.width - 80, y: 90, width: 80, height: 30)
        captureButton.setTitle("capture", for: .normal)
        captureButton.addTarget(self, action: #selector(captureDrawing), for: .touchUpInside)
        captureButton.isEnabled = false
        view.addSubview(captureButton)
        buttons.append(captureButton)
    }

    func addSliders() {
        lineWidthSlider = UISlider(frame: CGRect(x: 120, y: view.frame.height - 50, width: 100, height: 40))
        lineWidthSlider.minimumValue = 1.0
        lineWidthSlider.maximumValue = 30.0
        lineWidthSlider.setValue(10.0, animated: false)
        lineWidthSlider.isContinuous = true
        lineWidthSlider.addTarget(self, action: #selector(lineWidthSliderValueDidChange(sender:)), for: .valueChanged)
        view.addSubview(lineWidthSlider)

        opacitySlider = UISlider(frame: CGRect(x: 120, y: self.view.frame.height - 80, width: 100, height: 40))
        opacitySlider.minimumValue = 0.001
        opacitySlider.maximumValue = 1.0
        opacitySlider.setValue(1.0, animated: false)
        opacitySlider.isContinuous = true
        opacitySlider.addTarget(self, action: #selector(lineOpacitySliderValueDidChange(sender:)), for: .valueChanged)
        view.addSubview(opacitySlider)
    }

    @objc func colorButtonPressed(button: ColorButton) {
        drawView.lineColor = button.color
    }

    @objc func undo() {
        drawView.removeLastLine()

        if !drawView.hasContent {
            undoButton.isEnabled = false
            deleteButton.isEnabled = false
            captureButton.isEnabled = false
        }
    }

    @objc func deleteDrawing() {
        undoButton.isEnabled = false
        deleteButton.isEnabled = false
        captureButton.isEnabled = false
        drawView.clearCanvas()
    }

    @objc func captureDrawing() {
        if let image = drawView.captureView() {
            if let data = UIImagePNGRepresentation(image) {
                let filename = getDocumentsDirectory().appendingPathComponent("capture.png")
                try? data.write(to: filename)

                print("Captured to \(filename)")
            }
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    @objc func lineWidthSliderValueDidChange(sender: UISlider!) {
        drawView.lineWidth = CGFloat(sender.value)
    }

    @objc func lineOpacitySliderValueDidChange(sender: UISlider!) {
        drawView.lineOpacity = CGFloat(sender.value)
    }
}

extension ViewController: SwiftyDrawViewDelegate {

    func swiftyDrawDidBeginDrawing(view: SwiftyDrawView) {
        print("Did begin drawing")
        UIView.animate(withDuration: 0.5, animations: {
            self.buttons.forEach({ $0.alpha = 0.0 })
            self.lineWidthSlider.alpha = 0.0
            self.opacitySlider.alpha = 0.0
        })
    }

    func swiftyDrawIsDrawing(view: SwiftyDrawView) {
        print("Is Drawing")
    }

    func swiftyDrawDidFinishDrawing(view: SwiftyDrawView) {
        print("Did finish drawing")

        undoButton.isEnabled = true
        deleteButton.isEnabled = true
        captureButton.isEnabled = true

        UIView.animate(withDuration: 0.5, animations: {
            self.buttons.forEach({ $0.alpha = 1.0 })
            self.lineWidthSlider.alpha = 1.0
            self.opacitySlider.alpha = 1.0
        })
    }

    func swiftyDrawDidCancelDrawing(view: SwiftyDrawView) {
        print("Did cancel")
    }

}
