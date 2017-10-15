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

// MARK: Public Protocl Declarations

/// SwiftyDrawView Delegate

public protocol SwiftyDrawViewDelegate: class {

    /**
     SwiftyDrawViewDelegate called when a touch gesture begins on the SwiftyDrawView.
     
     - Parameter view: SwiftyDrawView where touches occured.
     */
    func swiftyDrawDidBeginDrawing(view: SwiftyDrawView)

    /**
     SwiftyDrawViewDelegate called when touch gestures continue on the SwiftyDrawView.
     
     - Parameter view: SwiftyDrawView where touches occured.
     */
    func swiftyDrawIsDrawing(view: SwiftyDrawView)

    /**
     SwiftyDrawViewDelegate called when touches gestures finish on the SwiftyDrawView.
     
     - Parameter view: SwiftyDrawView where touches occured.
     */
    func swiftyDrawDidFinishDrawing(view: SwiftyDrawView)

    /**
     SwiftyDrawViewDelegate called when there is an issue registering touch gestures on the  SwiftyDrawView.
     
     - Parameter view: SwiftyDrawView where touches occured.
     */
    func swiftyDrawDidCancelDrawing(view: SwiftyDrawView)
}

extension SwiftyDrawViewDelegate {

    func swiftyDrawDidBeginDrawing(view: SwiftyDrawView) {
        //optional
    }

    func swiftyDrawIsDrawing(view: SwiftyDrawView) {
        //optional
    }

    func swiftyDrawDidFinishDrawing(view: SwiftyDrawView) {
        //optional
    }

    func swiftyDrawDidCancelDrawing(view: SwiftyDrawView) {
        //optional
    }
}

/// UIView Subclass where touch gestures are translated into Core Graphics drawing

open class SwiftyDrawView: UIView {

    /// Line color for current drawing strokes
    public var lineColor = UIColor.black

    /// Line width for current drawing strokes
    public var lineWidth: CGFloat = 10.0

    /// Line opacity for current drawing strokes
    public var lineOpacity: CGFloat = 1.0

    /// Sets whether touch gestures should be registered as drawing strokes on the current canvas
    public var drawingEnabled = true

    /// Public SwiftyDrawView delegate
    public weak var delegate: SwiftyDrawViewDelegate?

    private var pathArray: [Line] = []
    private var currentPoint = CGPoint()
    private var previousPoint = CGPoint()
    private var previousPreviousPoint = CGPoint()

    private struct Line {
        var path: CGMutablePath
        var color: UIColor
        var width: CGFloat
        var opacity: CGFloat

        init(path: CGMutablePath, color: UIColor, width: CGFloat, opacity: CGFloat) {
            self.path = path
            self.color = color
            self.width = width
            self.opacity = opacity
        }
    }

    public var hasContent: Bool {
        return pathArray.count > 0
    }

    /// Public init(frame:) implementation

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    /// Public init(coder:) implementation

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// Overriding draw(rect:) to stroke paths

    override open func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.setLineCap(.round)

        for line in pathArray {
            context.setLineWidth(line.width)
            context.setAlpha(line.opacity)
            context.setStrokeColor(line.color.cgColor)
            context.addPath(line.path)
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            context.strokePath()
            context.endTransparencyLayer()
        }
    }

    /// touchesBegan implementation to capture strokes

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard drawingEnabled == true else {
            return
        }

        self.delegate?.swiftyDrawDidBeginDrawing(view: self)
        if let touch = touches.first {
            setTouchPoints(touch, view: self)
            let newLine = Line(path: CGMutablePath(), color: self.lineColor, width: self.lineWidth, opacity: self.lineOpacity)
            newLine.path.addPath(createNewPath())
            pathArray.append(newLine)
        }
    }

    /// touchesMoves implementation to capture strokes

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard drawingEnabled == true else {
            return
        }

        self.delegate?.swiftyDrawIsDrawing(view: self)
        if let touch = touches.first {
            updateTouchPoints(touch, view: self)
            let newLine = createNewPath()
            if let currentPath = pathArray.last {
                currentPath.path.addPath(newLine)
            }
        }
    }

    /// touchedEnded implementation to capture strokes

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard drawingEnabled == true else {
            return
        }

        self.delegate?.swiftyDrawDidFinishDrawing(view: self)
    }

    /// touchedCancelled implementation

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard drawingEnabled == true else {
            return
        }

        self.delegate?.swiftyDrawDidCancelDrawing(view: self)
    }

    /// Remove last stroked line

    public func removeLastLine() {
        if pathArray.count > 0 {
            pathArray.removeLast()
        }
        setNeedsDisplay()
    }

    /// Clear all stroked lines on canvas

    public func clearCanvas() {
        pathArray = []
        setNeedsDisplay()
    }

    public func captureView() -> UIImage? {
        UIGraphicsBeginImageContext(bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return img
        }

        return nil
    }

/********************************** Private Functions **********************************/

    private func setTouchPoints(_ touch: UITouch, view: UIView) {
        previousPoint = touch.previousLocation(in: view)
        previousPreviousPoint = touch.previousLocation(in: view)
        currentPoint = touch.location(in: view)
    }

    private func updateTouchPoints(_ touch: UITouch, view: UIView) {
        previousPreviousPoint = previousPoint
        previousPoint = touch.previousLocation(in: view)
        currentPoint = touch.location(in: view)
    }

    private func createNewPath() -> CGMutablePath {
        let midPoints = getMidPoints()
        let subPath = createSubPath(midPoints.0, mid2: midPoints.1)
        let newPath = addSubPathToPath(subPath)
        return newPath
    }

    private func calculateMidPoint(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
        return CGPoint(x: (point1.x + point2.x) * 0.5, y: (point1.y + point2.y) * 0.5)
    }

    private func getMidPoints() -> (CGPoint, CGPoint) {
        let mid1 = calculateMidPoint(previousPoint, previousPreviousPoint)
        let mid2 = calculateMidPoint(currentPoint, previousPoint)
        return (mid1, mid2)
    }

    private func createSubPath(_ mid1: CGPoint, mid2: CGPoint) -> CGMutablePath {
        let subpath = CGMutablePath()
        subpath.move(to: CGPoint(x: mid1.x, y: mid1.y))
        subpath.addQuadCurve(to: CGPoint(x: mid2.x, y: mid2.y), control: CGPoint(x: previousPoint.x, y: previousPoint.y))
        return subpath
    }

    private func addSubPathToPath(_ subpath: CGMutablePath) -> CGMutablePath {
        let bounds = subpath.boundingBox
        let drawBox = bounds.insetBy(dx: -2.0 * lineWidth, dy: -2.0 * lineWidth)
        self.setNeedsDisplay(drawBox)
        return subpath
    }
}
