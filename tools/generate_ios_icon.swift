import AppKit
import CoreGraphics

let fileManager = FileManager.default
let root = URL(fileURLWithPath: #filePath)
  .deletingLastPathComponent()
  .deletingLastPathComponent()
  .path
let sourcePath = "\(root)/assets/logo/hunzo_main_logo_source.jpeg"
let logoOutputPath = "\(root)/assets/logo/hunzo_main_logo.png"
let outputPath = "\(root)/assets/logo/hungzo_app_icon.png"
let iconSize: CGFloat = 1024
let logoPaddingRatio: CGFloat = 0.06

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

let canvasRect = CGRect(x: 0, y: 0, width: iconSize, height: iconSize)
context.setFillColor(NSColor.white.cgColor)
context.fill(canvasRect)

guard let cgSource = sourceImage.cgImage(
  forProposedRect: nil,
  context: nil,
  hints: [.interpolation: NSImageInterpolation.high]
) else {
  fputs("Unable to create CGImage from source image.\n", stderr)
  exit(1)
}

func isContentPixel(_ pixel: UnsafePointer<UInt8>, threshold: UInt8 = 245) -> Bool {
  let red = pixel[0]
  let green = pixel[1]
  let blue = pixel[2]
  return red < threshold || green < threshold || blue < threshold
}

func trimmedBounds(for image: CGImage) -> CGRect {
  let width = image.width
  let height = image.height
  let bytesPerPixel = 4
  let bytesPerRow = width * bytesPerPixel
  let bitsPerComponent = 8
  var rawData = [UInt8](repeating: 255, count: height * bytesPerRow)

  guard let dataContext = CGContext(
    data: &rawData,
    width: width,
    height: height,
    bitsPerComponent: bitsPerComponent,
    bytesPerRow: bytesPerRow,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
  ) else {
    return CGRect(x: 0, y: 0, width: width, height: height)
  }

  dataContext.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

  var minX = width
  var minY = height
  var maxX = 0
  var maxY = 0
  var found = false

  rawData.withUnsafeBufferPointer { buffer in
    guard let base = buffer.baseAddress else { return }
    for y in 0..<height {
      for x in 0..<width {
        let pixel = base.advanced(by: (y * bytesPerRow) + (x * bytesPerPixel))
        if isContentPixel(pixel) {
          found = true
          minX = min(minX, x)
          minY = min(minY, y)
          maxX = max(maxX, x)
          maxY = max(maxY, y)
        }
      }
    }
  }

  guard found else {
    return CGRect(x: 0, y: 0, width: width, height: height)
  }

  let padding = max(width, height) / 30
  let paddedMinX = max(minX - padding, 0)
  let paddedMinY = max(minY - padding, 0)
  let paddedMaxX = min(maxX + padding, width - 1)
  let paddedMaxY = min(maxY + padding, height - 1)

  return CGRect(
    x: paddedMinX,
    y: paddedMinY,
    width: paddedMaxX - paddedMinX + 1,
    height: paddedMaxY - paddedMinY + 1
  ).integral
}

let cropRect = trimmedBounds(for: cgSource)
let croppedSource = cgSource.cropping(to: cropRect) ?? cgSource
let sourceWidth = CGFloat(croppedSource.width)
let sourceHeight = CGFloat(croppedSource.height)
let availableSide = iconSize * (1.0 - (logoPaddingRatio * 2))
let scale = min(availableSide / sourceWidth, availableSide / sourceHeight)
let scaledWidth = sourceWidth * scale
let scaledHeight = sourceHeight * scale
let imageRect = CGRect(
  x: (iconSize - scaledWidth) / 2.0,
  y: (iconSize - scaledHeight) / 2.0,
  width: scaledWidth,
  height: scaledHeight
)

context.interpolationQuality = .high
context.draw(croppedSource, in: imageRect)

NSGraphicsContext.restoreGraphicsState()

guard
  let cgImage = context.makeImage(),
  let pngData = NSBitmapImageRep(cgImage: cgImage).representation(using: .png, properties: [:])
else {
  fputs("Unable to encode PNG.\n", stderr)
  exit(1)
}

try pngData.write(to: URL(fileURLWithPath: outputPath))
try pngData.write(to: URL(fileURLWithPath: logoOutputPath))
print("Generated \(outputPath)")
