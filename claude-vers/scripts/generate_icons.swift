#!/usr/bin/env swift
// Generates LexSurv app icon PNGs at every macOS-required size.
// Run with: swift scripts/generate_icons.swift
//
// Design:
//   - Continuous-corner squircle background, deep navy → teal gradient
//   - Subtle top highlight for depth
//   - Cream-white phylogenetic tree centered on the canvas
//   - Filled leaf dots so the form reads at 16×16

import AppKit
import CoreGraphics
import Foundation

// MARK: - Output sizes (pixel side, filename)

let sizes: [(side: Int, filename: String)] = [
    (16,   "icon_16.png"),
    (32,   "icon_16@2x.png"),
    (32,   "icon_32.png"),
    (64,   "icon_32@2x.png"),
    (128,  "icon_128.png"),
    (256,  "icon_128@2x.png"),
    (256,  "icon_256.png"),
    (512,  "icon_256@2x.png"),
    (512,  "icon_512.png"),
    (1024, "icon_512@2x.png"),
]

let outDir = URL(fileURLWithPath: CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "LexSurv/Resources/Assets.xcassets/AppIcon.appiconset")

// MARK: - Colors

func srgb(_ r: Double, _ g: Double, _ b: Double, _ a: Double = 1) -> CGColor {
    CGColor(srgbRed: r, green: g, blue: b, alpha: a)
}

let bgTopColor    = srgb(0.118, 0.165, 0.302)   // #1E2A4D deep indigo
let bgBottomColor = srgb(0.239, 0.420, 0.549)   // #3D6B8C teal-blue
let highlightTop  = srgb(1.0, 1.0, 1.0, 0.10)
let highlightMid  = srgb(1.0, 1.0, 1.0, 0.0)
let treeColor     = srgb(0.961, 0.941, 0.878)   // #F5F0E0 cream
let leafDotInner  = srgb(1.0, 0.96, 0.85)
let leafDotGlow   = srgb(1.0, 0.96, 0.85, 0.3)

// MARK: - Squircle path (continuous-corner approximation)

func squirclePath(rect: CGRect) -> CGPath {
    let path = CGMutablePath()
    let radius = min(rect.width, rect.height) * 0.2237
    let smoothing = radius * 0.6
    let x = rect.minX, y = rect.minY
    let w = rect.width, h = rect.height
    let r = radius, s = smoothing

    // Start at top edge just past the smoothed top-left corner
    path.move(to: CGPoint(x: x + r + s, y: y))
    path.addLine(to: CGPoint(x: x + w - r - s, y: y))
    path.addCurve(
        to: CGPoint(x: x + w, y: y + r + s),
        control1: CGPoint(x: x + w - s, y: y),
        control2: CGPoint(x: x + w, y: y + s)
    )
    path.addLine(to: CGPoint(x: x + w, y: y + h - r - s))
    path.addCurve(
        to: CGPoint(x: x + w - r - s, y: y + h),
        control1: CGPoint(x: x + w, y: y + h - s),
        control2: CGPoint(x: x + w - s, y: y + h)
    )
    path.addLine(to: CGPoint(x: x + r + s, y: y + h))
    path.addCurve(
        to: CGPoint(x: x, y: y + h - r - s),
        control1: CGPoint(x: x + s, y: y + h),
        control2: CGPoint(x: x, y: y + h - s)
    )
    path.addLine(to: CGPoint(x: x, y: y + r + s))
    path.addCurve(
        to: CGPoint(x: x + r + s, y: y),
        control1: CGPoint(x: x, y: y + s),
        control2: CGPoint(x: x + s, y: y)
    )
    path.closeSubpath()
    return path
}

// MARK: - Drawing

func drawIcon(side: Int) -> Data? {
    let n = CGFloat(side)
    let cs = CGColorSpace(name: CGColorSpace.sRGB)!
    guard let ctx = CGContext(
        data: nil,
        width: side,
        height: side,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: cs,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    ctx.setShouldAntialias(true)
    ctx.interpolationQuality = .high

    let canvas = CGRect(x: 0, y: 0, width: n, height: n)
    let squircle = squirclePath(rect: canvas)

    // Background gradient (clipped to squircle)
    ctx.saveGState()
    ctx.addPath(squircle)
    ctx.clip()
    let bgGrad = CGGradient(
        colorsSpace: cs,
        colors: [bgTopColor, bgBottomColor] as CFArray,
        locations: [0, 1]
    )!
    // diagonal: top-left brighter, bottom-right deeper
    ctx.drawLinearGradient(
        bgGrad,
        start: CGPoint(x: 0, y: n),
        end: CGPoint(x: n, y: 0),
        options: []
    )

    // Top highlight overlay
    let hiGrad = CGGradient(
        colorsSpace: cs,
        colors: [highlightTop, highlightMid] as CFArray,
        locations: [0, 1]
    )!
    ctx.drawLinearGradient(
        hiGrad,
        start: CGPoint(x: n / 2, y: n),
        end: CGPoint(x: n / 2, y: n * 0.45),
        options: []
    )
    ctx.restoreGState()

    // Phylogenetic tree — fills the central area
    drawTree(in: canvas.insetBy(dx: n * 0.16, dy: n * 0.18), ctx: ctx, scale: n)

    guard let cgImage = ctx.makeImage() else { return nil }
    let bitmap = NSBitmapImageRep(cgImage: cgImage)
    bitmap.size = NSSize(width: side, height: side)
    return bitmap.representation(using: .png, properties: [:])
}

func drawTree(in rect: CGRect, ctx: CGContext, scale: CGFloat) {
    // Note: y increases upward in CGContext default coords.
    let stroke = max(1.0, scale * 0.045)
    let dotRadius = stroke * 1.65

    ctx.setStrokeColor(treeColor)
    ctx.setLineWidth(stroke)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)

    // We draw a balanced 4-leaf tree with two internal bifurcations.
    // Leaf y positions (4 leaves stacked top→bottom in screen-orientation; here +y is up)
    let h = rect.height, w = rect.width
    let leafYs: [CGFloat] = [
        rect.minY + h * 0.86,
        rect.minY + h * 0.62,
        rect.minY + h * 0.38,
        rect.minY + h * 0.14,
    ]
    let leafX = rect.minX + w * 0.92
    let upperNodeX = rect.minX + w * 0.62
    let lowerNodeX = rect.minX + w * 0.62
    let trunkSplitX = rect.minX + w * 0.32
    let rootX = rect.minX + w * 0.04
    let rootY = rect.midY

    // Trunk
    ctx.move(to: CGPoint(x: rootX, y: rootY))
    ctx.addLine(to: CGPoint(x: trunkSplitX, y: rootY))

    // Upper internal node (mean of leaves 0 and 1, indices upward)
    let upperBranchY = (leafYs[0] + leafYs[1]) / 2
    let lowerBranchY = (leafYs[2] + leafYs[3]) / 2

    // Vertical at trunk split
    ctx.move(to: CGPoint(x: trunkSplitX, y: lowerBranchY))
    ctx.addLine(to: CGPoint(x: trunkSplitX, y: upperBranchY))

    // Horizontals from trunk split to upper/lower internal nodes
    ctx.move(to: CGPoint(x: trunkSplitX, y: upperBranchY))
    ctx.addLine(to: CGPoint(x: upperNodeX, y: upperBranchY))
    ctx.move(to: CGPoint(x: trunkSplitX, y: lowerBranchY))
    ctx.addLine(to: CGPoint(x: lowerNodeX, y: lowerBranchY))

    // Upper internal vertical
    ctx.move(to: CGPoint(x: upperNodeX, y: leafYs[0]))
    ctx.addLine(to: CGPoint(x: upperNodeX, y: leafYs[1]))
    // Lower internal vertical
    ctx.move(to: CGPoint(x: lowerNodeX, y: leafYs[2]))
    ctx.addLine(to: CGPoint(x: lowerNodeX, y: leafYs[3]))

    // Leaves
    for (i, yVal) in leafYs.enumerated() {
        let originX = (i < 2) ? upperNodeX : lowerNodeX
        ctx.move(to: CGPoint(x: originX, y: yVal))
        ctx.addLine(to: CGPoint(x: leafX, y: yVal))
    }
    ctx.strokePath()

    // Leaf dots with soft glow (skip glow at very small sizes; would be muddy)
    if scale >= 64 {
        ctx.setFillColor(leafDotGlow)
        for yVal in leafYs {
            let r = dotRadius * 2.4
            ctx.fillEllipse(in: CGRect(x: leafX - r, y: yVal - r, width: r * 2, height: r * 2))
        }
    }
    ctx.setFillColor(leafDotInner)
    for yVal in leafYs {
        ctx.fillEllipse(in: CGRect(x: leafX - dotRadius, y: yVal - dotRadius,
                                   width: dotRadius * 2, height: dotRadius * 2))
    }

    // Root cap dot (subtle anchor)
    ctx.setFillColor(treeColor)
    let rootDotR = dotRadius * 0.9
    ctx.fillEllipse(in: CGRect(x: rootX - rootDotR, y: rootY - rootDotR,
                               width: rootDotR * 2, height: rootDotR * 2))
}

// MARK: - Write files

try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

for (side, name) in sizes {
    guard let data = drawIcon(side: side) else {
        FileHandle.standardError.write("Failed to render \(name)\n".data(using: .utf8)!)
        exit(1)
    }
    let url = outDir.appendingPathComponent(name)
    do {
        try data.write(to: url)
        print("Wrote \(name) (\(side)×\(side))")
    } catch {
        FileHandle.standardError.write("Failed to write \(name): \(error)\n".data(using: .utf8)!)
        exit(1)
    }
}

print("Done.")
