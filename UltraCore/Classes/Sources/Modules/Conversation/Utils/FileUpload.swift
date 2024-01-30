//
//  FileUpload.swift
//  _NIODataStructures
//
//  Created by Slam on 1/30/24.
//

import Foundation

typealias MimeType = String


struct FileUpload {
    let url: URL?
    let data: Data
    let mime: MimeType
    let width: CGFloat
    let height: CGFloat
    let filename: String
    var duration: TimeInterval
    
    init(url: URL?, data: Data, mime: MimeType, width: CGFloat, height: CGFloat, duration: TimeInterval = 0.0 , filename: String? = nil) {
        self.url = url
        self.data = data
        self.mime = mime
        self.width = width
        self.height = height
        self.duration = duration
        self.filename = filename ?? (url?.pathComponents.last ?? "\(UUID().uuidString).\(mime.extension)")
    }
}

extension MimeType {
    var `extension`: String {
        return mimeTypesToExtension[self] ?? "unknown"
    }
}

fileprivate let mimeTypesToExtension: [MimeType: String] = [
    "application/epub+zip": "epub",
    "application/gzip": "gz",
    "application/java-archive": "jar",
    "application/json": "json",
    "application/msword": "doc",
    "application/octet-stream": "bin",
    "application/ogg": "ogx",
    "application/pdf": "pdf",
    "application/rtf": "rtf",
    "application/vnd.amazon.ebook": "azw",
    "application/vnd.apple.installer+xml": "mpkg",
    "application/vnd.mozilla.xul+xml": "xul",
    "application/vnd.ms-excel": "xls",
    "application/vnd.ms-fontobject": "eot",
    "application/vnd.ms-powerpoint": "ppt",
    "application/vnd.oasis.opendocument.presentation": "odp",
    "application/vnd.oasis.opendocument.spreadsheet": "ods",
    "application/vnd.oasis.opendocument.text": "odt",
    "application/vnd.openxmlformats-officedocument.presentationml.presentation": "pptx",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": "xlsx",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document": "docx",
    "application/vnd.rar": "rar",
    "application/vnd.visio": "vsd",
    "application/x-7z-compressed": "7z",
    "application/x-abiword": "abw",
    "application/x-bzip": "bz",
    "application/x-bzip2": "bz2",
    "application/x-csh": "csh",
    "application/x-freearc": "arc",
    "application/x-httpd-php": "php",
    "application/x-sh": "sh",
    "application/x-shockwave-flash": "swf",
    "application/x-tar": "tar",
    "application/xhtml+xml": "xhtml",
    "application/xml": "xml", // Может быть использовано как текстовый файл
    "application/zip": "zip",
    "audio/3gpp": "3gp",
    "audio/3gpp2": "3g2",
    "audio/aac": "aac",
    "audio/midi": "midi",
    "audio/mpeg": "mp3",
    "audio/ogg": "oga",
    "audio/opus": "opus",
    "audio/wav": "wav",
    "audio/webm": "weba",
    "audio/x-midi": "midi",
    "font/otf": "otf",
    "font/ttf": "ttf",
    "font/woff": "woff",
    "font/woff2": "woff2",
    "image/bmp": "bmp",
    "image/gif": "gif",
    "image/jpeg": "jpg",
    "image/png": "png",
    "image/svg+xml": "svg",
    "image/tiff": "tiff",
    "image/vnd.microsoft.icon": "ico",
    "image/webp": "webp",
    "text/calendar": "ics",
    "text/css": "css",
    "text/csv": "csv",
    "text/html": "html",
    "text/javascript": "js",
    "text/plain": "txt",
    "text/xml": "xml",
    "video/3gpp": "3gp",
    "video/3gpp2": "3g2",
    "video/mp4": "mp4",
    "video/mpeg": "mpeg",
    "video/ogg": "ogv",
    "video/webm": "webm",
    "video/x-msvideo": "avi"
]
