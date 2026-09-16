import UIKit

enum ImageStorageError: LocalizedError {
    case unableToEncodeImage
    case fileNotFound
    case saveFailed(Error)

    var errorDescription: String? {
        switch self {
        case .unableToEncodeImage:
            return "Failed to encode plant image to JPEG format."
        case .fileNotFound:
            return "Plant image file could not be found in local storage."
        case .saveFailed(let error):
            return "Failed to save plant photo: \(error.localizedDescription)"
        }
    }
}

final class ImageStorageService {
    static let shared = ImageStorageService()

    private let fileManager = FileManager.default
    private let directoryName = "PlantImages"

    var imagesDirectoryURL: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imagesDir = documentsDirectory.appendingPathComponent(directoryName, isDirectory: true)

        if !fileManager.fileExists(atPath: imagesDir.path) {
            try? fileManager.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        }
        return imagesDir
    }

    func saveImage(_ image: UIImage) throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.82) else {
            throw ImageStorageError.unableToEncodeImage
        }
        let filename = "\(UUID().uuidString).jpg"
        let fileURL = imagesDirectoryURL.appendingPathComponent(filename)
        try data.write(to: fileURL, options: .atomic)
        return filename
    }

    func loadImage(filename: String) -> UIImage? {
        let fileURL = imagesDirectoryURL.appendingPathComponent(filename)
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return UIImage(data: data)
    }

    func deleteImage(filename: String) {
        let fileURL = imagesDirectoryURL.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: fileURL.path) {
            try? fileManager.removeItem(at: fileURL)
        }
    }
}
