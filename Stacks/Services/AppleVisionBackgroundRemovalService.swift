import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import UIKit
import Vision

actor AppleVisionBackgroundRemovalService: BackgroundRemovalService {
    func removeBackground(for item: StackItem) async throws -> URL? {
        guard let imageURL = item.originalImageURL else {
            return item.removedBackgroundImageURL
        }

        guard let imageData = try? await loadImageData(from: imageURL),
              let inputImage = CIImage(data: imageData) else {
            return imageURL
        }

        do {
            let outputData = try makeTransparentPNGData(from: inputImage)
            return try writeRemovedImage(outputData, itemID: item.id)
        } catch {
            return imageURL
        }
    }

    private func loadImageData(from url: URL) async throws -> Data {
        if url.isFileURL {
            return try Data(contentsOf: url)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }

    private func makeTransparentPNGData(from inputImage: CIImage) throws -> Data {
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(ciImage: inputImage)
        try handler.perform([request])

        guard let result = request.results?.first else {
            throw AppError.notFound
        }

        let maskBuffer = try result.generateScaledMaskForImage(
            forInstances: result.allInstances,
            from: handler
        )
        let maskImage = CIImage(cvPixelBuffer: maskBuffer)
        let clearBackground = CIImage(color: CIColor.clear).cropped(to: inputImage.extent)

        let filter = CIFilter.blendWithMask()
        filter.inputImage = inputImage
        filter.backgroundImage = clearBackground
        filter.maskImage = maskImage

        guard let outputImage = filter.outputImage else {
            throw AppError.notFound
        }

        let context = CIContext(options: [.workingColorSpace: CGColorSpaceCreateDeviceRGB()])
        guard let cgImage = context.createCGImage(outputImage, from: inputImage.extent) else {
            throw AppError.notFound
        }

        return UIImage(cgImage: cgImage).pngData() ?? Data()
    }

    private func writeRemovedImage(_ data: Data, itemID: UUID) throws -> URL {
        guard !data.isEmpty else { throw AppError.missingRequiredField("Image") }

        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("RemovedBackgrounds", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let url = directory.appendingPathComponent("\(itemID.uuidString).png")
        try data.write(to: url, options: [.atomic])
        return url
    }
}
