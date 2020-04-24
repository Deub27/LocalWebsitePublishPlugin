import Foundation
import Publish
import Files

public extension Plugin {
    
    /// Localify the HTML file specified relative to the output folder.
    static func localifyHTML(at path: Path) throws -> Self {
        Plugin(name: "Localify HTML file") { context in
            let file = try context.outputFile(at: path)
            let outputFolder = try context.outputFolder(at: "")
            try localifyHTML(file, outputFolder: outputFolder)
        }
    }
    
    /// Localify all HTML files in the given folder relative to the output folder.
    static func localifyHTML(in path: Path = "") throws -> Self {
        Plugin(name: "Localify HTML files") { context in
            //let folder = try context.outputFolder(at: path)
            let outputFolder = try context.outputFolder(at: "")
            try Plugin.scanFiles(in: path, outputFolder: outputFolder)
        }
    }
    
    private static func scanFiles(in path: Path = "", outputFolder: Folder) throws {
        let currentFolder = try outputFolder.subfolder(at: path.string)
        let files = currentFolder
            .files
            .filter({ $0.extension == "html" })
        
        try files.forEach({ (file) in
            try localifyHTML(file, outputFolder: outputFolder)
        })
        
        let subfolders = currentFolder.subfolders
        try subfolders.forEach { (folder) in
            let path = folder.path(relativeTo: outputFolder)
            try Plugin.scanFiles(in: Path(path), outputFolder: outputFolder)
        }
        
    }
    
    private static func localifyHTML(_ file: File, outputFolder: Folder) throws {
        
        var html = try file.readAsString()
        let nbComponents = file.path(relativeTo: outputFolder).split(separator: "/").count
        
        var relativePath = "./"
        if nbComponents > 1 {
            relativePath = [String](repeating: "../", count: nbComponents - 1).joined()
        }
        html = try html.replaceFiles(with: relativePath, for: "href")
        html = try html.replaceFiles(with: relativePath, for: "src")
        html = try html.replacePaths(with: relativePath)
        
        try file.write(html)
    }
    
    
}

extension String {
    
    func replaceFiles(with relativePath: String, for tag: String) throws -> String {
        var output = self
        let pattern = "\(tag)=\"/([\\/a-zA-Z0-9_-]*\\.{1}[a-zA-Z0-9]*)\""
        let regex = try NSRegularExpression(pattern: pattern, options: [])

        let nsrange = NSRange(self.startIndex..<self.endIndex, in: self)

        let matches = regex.matches(in: self, options: [], range: nsrange)

        for match in matches where match.numberOfRanges == 2 {
            if let keyRange = Range(match.range(at: 1), in: self) {
                let key = String(self[keyRange])
                output = output.replacingOccurrences(of: "\(tag)=\"/\(key)\"", with: "\(tag)=\"\(relativePath)\(key)\"")
            }
        }
        
        return output
    }
    
    func replacePaths(with relativePath: String) throws -> String {
        
        var output = self
        let pattern = #"href="/([\/a-zA-Z0-9_-]*)""#
        let regex = try NSRegularExpression(pattern: pattern, options: [])

        let nsrange = NSRange(self.startIndex..<self.endIndex, in: self)

        let matches = regex.matches(in: self, options: [], range: nsrange)

        for match in matches where match.numberOfRanges == 2 {
            if let keyRange = Range(match.range(at: 1), in: self) {
                let key = String(self[keyRange])
                if key.count == 0 {
                    output = output.replacingOccurrences(of: "href=\"/\(key)\"", with: "href=\"\(relativePath)index.html\"")
                } else {
                    output = output.replacingOccurrences(of: "href=\"/\(key)\"", with: "href=\"\(relativePath)\(key)/index.html\"")
                }
                
            }
        }
        
        return output
    }
    
}
