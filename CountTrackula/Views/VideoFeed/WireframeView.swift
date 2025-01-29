import SwiftUI

struct WireframeView: View {
    enum Selection {
        case none
        case boundary
        case gradientX
        case gradientY
    }
    
    enum Position {
        case top
        case left
        case bottom
        case right
    }
    
    struct Line {
        var center: CGPoint = .zero
        var a: CGPoint = .zero
        var b: CGPoint = .zero
    }
    
    @Environment(CameraHandler.self) var camera: CameraHandler?
    
    @AppStorage(Settings.isOutsideOnTop.key) private var isOutsideOnTopOrRight = Settings.isOutsideOnTop.value
    @AppStorage(Settings.isVerticalBoundary.key) private var isVerticalBoundary = Settings.isVerticalBoundary.value
    @AppStorage(Settings.boundaryPosition.key) private var linePosition = Settings.boundaryPosition.value
    
    @AppStorage(Settings.timeoutGradientCenterX.key) private var timeoutGradientCenterX = Settings.timeoutGradientCenterX.value
    @AppStorage(Settings.timeoutGradientCenterY.key) private var timeoutGradientCenterY = Settings.timeoutGradientCenterY.value
    
    @AppStorage(Settings.timeoutGradientWidth.key) private var timeoutGradientWidth = Settings.timeoutGradientWidth.value
    @AppStorage(Settings.timeoutGradientHeight.key) private var timeoutGradientHeight = Settings.timeoutGradientHeight.value

    @State var width: CGFloat = 0.0
    @State var height: CGFloat = 0.0
    @State var line: Line = Line()
    @State var currentSelection: Selection = .none
    @State var lastBoundaryTransform: CGPoint = .zero
    @State var boundaryRotation: Angle = .zero
    @State var outsidePosition: Position = .bottom
    
    @State var lastGradientTranslation: CGPoint = .zero
    @State var lastGradientScale: CGSize = CGSize(width: 1.0, height: 1.0)
    
    func rotateLine(isClockwise: Bool) {
        isVerticalBoundary.toggle()
        if isClockwise {
            switch outsidePosition {
                case .bottom:
                    isOutsideOnTopOrRight = true
                    break
                case .right:
                    isOutsideOnTopOrRight = true
                    break
                case .top:
                    isOutsideOnTopOrRight = false
                    break
                case .left:
                    isOutsideOnTopOrRight = false
                    break
            }
        } else {
            switch outsidePosition {
                case .bottom:
                    isOutsideOnTopOrRight = false
                    break
                case .right:
                    isOutsideOnTopOrRight = false
                    break
                case .top:
                    isOutsideOnTopOrRight = true
                    break
                case .left:
                    isOutsideOnTopOrRight = true
                    break
            }
        }
    }
    
    func onDragBoundaryChange(_ gesture: DragGesture.Value) {
        var newTransform = CGPoint(
            x: gesture.translation.width / width,
            y: gesture.translation.height / height
        )
        var newPosition = linePosition
        switch outsidePosition {
        case .top, .bottom:
            newTransform.x = 0
            newPosition += newTransform.y - lastBoundaryTransform.y
        case .left, .right:
            newTransform.y = 0
            newPosition += newTransform.x - lastBoundaryTransform.x
        }
        linePosition = newPosition.clamp(between: 0.0...1.0)
        lastBoundaryTransform = newTransform
    }
    
    func onDragBoundaryEnd() {
        lastBoundaryTransform = .zero
    }
    
    func onDragGradientChange(_ gesture: DragGesture.Value) {
        let newTranslation = CGPoint(
            x: gesture.translation.width / width,
            y: gesture.translation.height / height
        )
        var newCenterX = timeoutGradientCenterX
        var newCenterY = timeoutGradientCenterY
        newCenterX += newTranslation.x - lastGradientTranslation.x
        newCenterY += newTranslation.y - lastGradientTranslation.y
        lastGradientTranslation = newTranslation

        timeoutGradientCenterX = newCenterX.clamp(between: 0.0...1.0)
        timeoutGradientCenterY = newCenterY.clamp(between: 0.0...1.0)
    }
    
    func onDragGradientEnd() {
        lastGradientTranslation = .zero
        updateTracker()
    }
    
    func onRotateBoundaryChange(_ gesture: RotateGesture.Value) {
        boundaryRotation = gesture.rotation
    }
    
    func onRotateBoundaryEnd() {
        let rotatedB = line.b.rotate(by: boundaryRotation, around: line.center)

        var direction = 1
        switch outsidePosition {
        case .top, .bottom:
            direction = (rotatedB.y - line.center.y).sign.rawValue
            linePosition = line.center.x / width
            break
        case .left, .right:
            direction = (line.center.x - rotatedB.x).sign.rawValue
            linePosition = line.center.y / height
            break
        }
        rotateLine(isClockwise: direction == 0)
        boundaryRotation = .zero
    }
    
    func onMagnifyGradientChange(_ gesture: MagnifyGesture.Value) {
        switch currentSelection {
        case .gradientX:
            timeoutGradientWidth += gesture.magnification - lastGradientScale.width
            timeoutGradientWidth = timeoutGradientWidth.clamp(between: 0.01...2.0)
            lastGradientScale.width = gesture.magnification
        case .gradientY:
            timeoutGradientHeight += gesture.magnification - lastGradientScale.height
            timeoutGradientHeight = timeoutGradientHeight.clamp(between: 0.01...2.0)
            lastGradientScale.height = gesture.magnification
        default:
            return
        }
    }
    
    func onMagnifyGradientEnd() {
        lastGradientScale = CGSize(width: 1.0, height: 1.0)
        updateTracker()
    }
    
    func updateTracker() {
        guard let camera = camera else {
            return
        }
        
        camera.tracker.gradientRegion = CGRect(
            cx: timeoutGradientCenterX,
            cy: timeoutGradientCenterY,
            width: timeoutGradientWidth,
            height: timeoutGradientHeight
        ).withNormalizedOrientation(.down)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let idealRatio = width / 640.0
            let idealFontSize = 24 * idealRatio
            let lineWidth = 3 * idealRatio
            let font = Font.system(size: idealFontSize < 8 ? 8 : idealFontSize)
            
            let flipInsideOut = isOutsideOnTopOrRight
                ? -1.0
                : 1.0
            
            let offset = 0.1 * idealRatio * flipInsideOut * width
            
            let dragGesture = DragGesture()
                .onChanged { gesture in
                    switch currentSelection {
                    case .none:
                        break
                    case .boundary:
                        onDragBoundaryChange(gesture)
                        break
                    case .gradientX, .gradientY:
                        onDragGradientChange(gesture)
                        break
                    }
                }
                .onEnded { _ in
                    switch currentSelection {
                    case .none:
                        break
                    case .boundary:
                        onDragBoundaryEnd()
                        break
                    case .gradientX, .gradientY:
                        onDragGradientEnd()
                        break
                    }
                }
            
            let rotateGesture = RotateGesture(minimumAngleDelta: .degrees(5.0))
                .onChanged { gesture in
                    switch currentSelection {
                    case .none, .gradientX, .gradientY:
                        break
                    case .boundary:
                        onRotateBoundaryChange(gesture)
                        break
                    }
                    
                }
                .onEnded { _ in
                    switch currentSelection {
                    case .none, .gradientX, .gradientY:
                        break
                    case .boundary:
                        onRotateBoundaryEnd()
                        break
                    }
                }
            
            let magnifyGesture = MagnifyGesture()
                .onChanged { gesture in
                    switch currentSelection {
                    case .none, .boundary:
                        break
                    case .gradientX, .gradientY:
                        onMagnifyGradientChange(gesture)
                        break
                    }
                    
                }
                .onEnded { _ in
                    switch currentSelection {
                    case .none, .boundary:
                        break
                    case .gradientX, .gradientY:
                        onMagnifyGradientEnd()
                        break
                    }
                }
            
            Group() {
                // masking added to simulate bilinear interpolation
                let gradientColors: [Color] = [.blood.opacity(0.9), .clear]
                let topBottomEnd = UnitPoint(x: 0.5, y: timeoutGradientCenterY)
                
                let topToBottomGradient = LinearGradient(
                    colors: gradientColors,
                    startPoint: UnitPoint(x: 0.5, y: timeoutGradientCenterY - timeoutGradientHeight * 0.5),
                    endPoint: topBottomEnd
                )
                Rectangle()
                    .fill(topToBottomGradient)
                    .mask(Rectangle().fill(topToBottomGradient))
                
                let bottomToTopGradient = LinearGradient(
                    colors: gradientColors,
                    startPoint: UnitPoint(x: 0.5, y: timeoutGradientCenterY + timeoutGradientHeight * 0.5),
                    endPoint: topBottomEnd
                )
                Rectangle()
                    .fill(bottomToTopGradient)
                    .mask(Rectangle().fill(bottomToTopGradient))
                
                let rightLeftEnd = UnitPoint(x: timeoutGradientCenterX, y: 0.5)
                let leftToRightGradient = LinearGradient(
                    colors: gradientColors,
                    startPoint: UnitPoint(x: timeoutGradientCenterX - timeoutGradientWidth * 0.5, y: 0.5),
                    endPoint: rightLeftEnd
                )
                Rectangle()
                    .fill(leftToRightGradient)
                    .mask(Rectangle().fill(leftToRightGradient))
                
                let rightToLeftGradient = LinearGradient(
                    colors: gradientColors,
                    startPoint: UnitPoint(x: timeoutGradientCenterX + timeoutGradientWidth * 0.5, y: 0.5),
                    endPoint: rightLeftEnd
                )
                Rectangle()
                    .fill(rightToLeftGradient)
                    .mask(Rectangle().fill(rightToLeftGradient))
                
                // the outlined rectangle representing the starting boundary of the gradient
                let gradientCenterOffset = 10 * idealRatio
                let lineWidthCorrection = lineWidth * 0.4
                // scaling the x-axis
                Path { path in
                    // leftmost vertical border
                    path.move(to: CGPoint(
                        x: (timeoutGradientCenterX - timeoutGradientWidth * 0.5) * width,
                        y: (timeoutGradientCenterY - timeoutGradientHeight * 0.5) * height - lineWidthCorrection
                    ))
                    path.addLine(to: CGPoint(
                        x: (timeoutGradientCenterX - timeoutGradientWidth * 0.5) * width,
                        y: (timeoutGradientCenterY + timeoutGradientHeight * 0.5) * height + lineWidthCorrection
                    ))
                    
                    // rightmost vertical border
                    path.move(to: CGPoint(
                        x: (timeoutGradientCenterX + timeoutGradientWidth * 0.5) * width,
                        y: (timeoutGradientCenterY - timeoutGradientHeight * 0.5) * height - lineWidthCorrection
                    ))
                    path.addLine(to: CGPoint(
                        x: (timeoutGradientCenterX + timeoutGradientWidth * 0.5) * width,
                        y: (timeoutGradientCenterY + timeoutGradientHeight * 0.5) * height + lineWidthCorrection
                    ))
                    
                    // vertical crosshair
                    path.move(to: CGPoint(x: timeoutGradientCenterX * width, y: timeoutGradientCenterY * height - gradientCenterOffset))
                    path.addLine(to: CGPoint(x: timeoutGradientCenterX * width, y: timeoutGradientCenterY * height  + gradientCenterOffset))
                }
                .stroke(.white, lineWidth: lineWidth)
                .opacity(currentSelection == .gradientY ? 1.0 : 0.25)

                // scaling the y-axis
                Path { path in
                    // bottom horizontal
                    path.move(to: CGPoint(
                        x: (timeoutGradientCenterX - timeoutGradientWidth * 0.5) * width - lineWidthCorrection,
                        y: (timeoutGradientCenterY + timeoutGradientHeight * 0.5) * height
                    ))
                    path.addLine(to: CGPoint(
                        x: (timeoutGradientCenterX + timeoutGradientWidth * 0.5) * width + lineWidthCorrection,
                        y: (timeoutGradientCenterY + timeoutGradientHeight * 0.5) * height
                    ))
                    
                    // top horizontal
                    path.move(to: CGPoint(
                        x: (timeoutGradientCenterX - timeoutGradientWidth * 0.5) * width - lineWidthCorrection,
                        y: (timeoutGradientCenterY - timeoutGradientHeight * 0.5) * height
                    ))
                    path.addLine(to: CGPoint(
                        x: (timeoutGradientCenterX + timeoutGradientWidth * 0.5) * width + lineWidthCorrection,
                        y: (timeoutGradientCenterY - timeoutGradientHeight * 0.5) * height
                    ))
                    
                    // horizontal crosshair
                    path.move(to: CGPoint(x: timeoutGradientCenterX * width - gradientCenterOffset, y: timeoutGradientCenterY * height))
                    path.addLine(to: CGPoint(x: timeoutGradientCenterX * width + gradientCenterOffset, y: timeoutGradientCenterY * height))
                }
                .stroke(.white, lineWidth: lineWidth)
                .opacity(currentSelection == .gradientX ? 1.0 : 0.25)
            }
            
            Group() {
                Text("inside")
                    .font(font)
                    .monospaced()
                    .kerning(1.0)
                    .offset(x: 0, y: 0 - offset)
                    .rotationEffect(.degrees(isVerticalBoundary ? -90 : 0))
                    .position(line.center)
                
                // the current boundary line
                Path { path in
                    path.move(to: line.a)
                    path.addLine(to: line.b)
                }
                .stroke(.white, lineWidth: lineWidth)
                
                Text("outside")
                    .font(font)
                    .kerning(1.0)
                    .monospaced()
                    .offset(x: 0, y: offset)
                    .rotationEffect(.degrees(isVerticalBoundary ? -90 : 0))
                    .position(line.center)
                
                // the line demonstrating rotation
                if boundaryRotation != .zero {
                    Path { path in
                        path.move(to: line.a.rotate(by: boundaryRotation, around: line.center))
                        path.addLine(to: line.b.rotate(by: boundaryRotation, around: line.center))
                    }
                    .stroke(.white.opacity(0.5), style: StrokeStyle(lineWidth: lineWidth, dash: [5 * idealRatio, 5 * idealRatio]))
                }
            }
            .opacity(currentSelection == .boundary ? 1.0 : 0.25)
            
            Color.black
                .opacity(0.0001)
                .simultaneousGesture(dragGesture)
                .simultaneousGesture(magnifyGesture)
                .simultaneousGesture(rotateGesture)
                .task {
                    width = geometry.size.width
                    height = geometry.size.height
                }
        }
        .onChange(of: [isVerticalBoundary, isOutsideOnTopOrRight], initial: true) {
            // set the rotation to the correct position in degree
            if isVerticalBoundary {
                outsidePosition = isOutsideOnTopOrRight ? .right : .left
            } else {
                outsidePosition = isOutsideOnTopOrRight ? .top : .bottom
            }
        }
        .onChange(of: [width, height, linePosition], initial: true) {
            switch outsidePosition {
            case .top, .bottom:
                let center = CGPoint(x: width * 0.5, y: height * linePosition)
                line = Line(
                    center: center,
                    a: CGPoint(x: 0 - width, y: center.y),
                    b: CGPoint(x: width * 2, y: center.y)
                )
                break
            case .left, .right:
                let center = CGPoint(x: width * linePosition, y: height * 0.5)
                line = Line(
                    center: center,
                    a: CGPoint(x: center.x, y: 0 - height),
                    b: CGPoint(x: center.x, y: height * 2)
                )
                break
            }
        }
        .onTapGesture {
            switch currentSelection {
            case .none:
                currentSelection = .boundary
                break
            case .boundary:
                currentSelection = .gradientX
                break
            case .gradientX:
                currentSelection = .gradientY
                break
            case .gradientY:
                currentSelection = .none
                break
            }
        }
    }
}

#Preview {
    Settings.boundaryPosition.value = 0.5
    Settings.isOutsideOnTop.value = true
    Settings.isVerticalBoundary.value = false
    Settings.analyticsIsDisabled.value = true
    Settings.analyticsIsDevelopment.value = true

    return ZStack {
        Color.gray
        WireframeView(currentSelection: .gradientX)
    }
    .frame(idealWidth: 640, idealHeight: 480)
    .clipped()
    .ignoresSafeArea()
    .aspectRatio(contentMode: .fit)
}
