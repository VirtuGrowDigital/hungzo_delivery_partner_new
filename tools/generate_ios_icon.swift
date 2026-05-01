import AppKit
import CoreGraphics

let fileManager = FileManager.default
let root = "/Users/manishshivhare/Virtugrow/hungzo_delivery_partner_new"
let sourcePath = "\(root)/assets/logo/hunzo_main_logo_source.jpeg"
let outputPath = "\(root)/assets/logo/hungzo_app_icon.png"
let iconSize: CGFloat = 1024

guard fileManager.fileExists(atPath: sourcePath) else {
  fputs("Source image not found at \(sourcePath)\n", stderr)
  exit(1)
}

guard let sourceImage = NSImage(contentsOfFile: sourcePath) else {
  fputs("Unable to load source image.\n", stderr)
  exit(1)
}

guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
  fputs("Unable to create color space.\n", stderr)
  exit(1)
}

guard let context = CGContext(
  data: nil,
  width: Int(iconSize),
  height: Int(iconSize),
  bitsPerComponent: 8,
  bytesPerRow: 0,
  space: colorSpace,
  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
) else {
  fputs("Unable to create graphics context.\n", stderr)
  exit(1)
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)

let canvasRect = NSRect(x: 0, y: 0, width: iconSize, height: iconSize)
let gradient = NSGradient(
  colors: [
    NSColor(calibratedRed: 0.03, green: 0.28, blue: 0.20, alpha: 1.0),
    NSColor(calibratedRed: 0.11, green: 0.56, blue: 0.39, alpha: 1.0),
  ]
)
gradient?.draw(in: canvasRect, angle: -25)

NSColor(calibratedWhite: 1.0, alpha: 0.08).setFill()
NSBezierPath(ovalIn: NSRect(x: 72, y: 690, width: 210, height: 210)).fill()
NSBezierPath(ovalIn: NSRect(x: 750, y: 110, width: 165, height: 165)).fill()

let cardRect = NSRect(x: 132, y: 132, width: 760, height: 760)
let cardPath = NSBezierPath(
  roundedRect: cardRect,
  xRadius: 190,
  yRadius: 190
)

context.saveGState()
context.setShadow(offset: CGSize(width: 0, height: -18), blur: 34, color: NSColor.black.withAlphaComponent(0.22).cgColor)
NSColor.white.setFill()
cardPath.fill()
context.restoreGState()

let innerRect = cardRect.insetBy(dx: 34, dy: 34)
let innerPath = NSBezierPath(
  roundedRect: innerRect,
  xRadius: 160,
  yRadius: 160
)

context.saveGState()
innerPath.addClip()

if let cgSource = sourceImage.cgImage(
  forProposedRect: nil,
  context: nil,
  hints: [.interpolation: NSImageInterpolation.high]
) {
  let cropRect = CGRect(x: 145, y: 120, width: 734, height: 430)
  let cropped = cgSource.cropping(to: cropRect) ?? cgSource
  let imageRect = CGRect(x: 112, y: 400, width: 800, height: 468)
  context.interpolationQuality = .high
  context.draw(cropped, in: imageRect)
}

context.restoreGState()

NSColor.white.withAlphaComponent(0.18).setStroke()
let borderPath = NSBezierPath(
  roundedRect: innerRect.insetBy(dx: 8, dy: 8),
  xRadius: 150,
  yRadius: 150
)
borderPath.lineWidth = 8
borderPath.stroke()

let badgeRect = NSRect(x: 645, y: 142, width: 170, height: 170)
let badgePath = NSBezierPath(ovalIn: badgeRect)
context.saveGState()
context.setShadow(offset: CGSize(width: 0, height: -10), blur: 22, color: NSColor.black.withAlphaComponent(0.18).cgColor)
NSColor(calibratedRed: 1.0, green: 0.57, blue: 0.10, alpha: 1.0).setFill()
badgePath.fill()
context.restoreGState()

NSColor.white.setStroke()
badgePath.lineWidth = 10
badgePath.stroke()

let pinPath = NSBezierPath()
pinPath.move(to: NSPoint(x: 730, y: 250))
pinPath.curve(
  to: NSPoint(x: 700, y: 200),
  controlPoint1: NSPoint(x: 718, y: 238),
  controlPoint2: NSPoint(x: 700, y: 223)
)
pinPath.curve(
  to: NSPoint(x: 730, y: 160),
  controlPoint1: NSPoint(x: 700, y: 178),
  controlPoint2: NSPoint(x: 714, y: 160)
)
pinPath.curve(
  to: NSPoint(x: 760, y: 200),
  controlPoint1: NSPoint(x: 746, y: 160),
  controlPoint2: NSPoint(x: 760, y: 178)
)
pinPath.curve(
  to: NSPoint(x: 730, y: 250),
  controlPoint1: NSPoint(x: 760, y: 223),
  controlPoint2: NSPoint(x: 742, y: 238)
)
pinPath.close()
NSColor.white.setFill()
pinPath.fill()

let pinCenter = NSBezierPath(ovalIn: NSRect(x: 717, y: 190, width: 26, height: 26))
NSColor(calibratedRed: 1.0, green: 0.57, blue: 0.10, alpha: 1.0).setFill()
pinCenter.fill()

NSGraphicsContext.restoreGraphicsState()

guard
  let cgImage = context.makeImage(),
  let pngData = NSBitmapImageRep(cgImage: cgImage).representation(using: .png, properties: [:])
else {
  fputs("Unable to encode PNG.\n", stderr)
  exit(1)
}

try pngData.write(to: URL(fileURLWithPath: outputPath))
print("Generated \(outputPath)")
