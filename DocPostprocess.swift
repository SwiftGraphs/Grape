import Foundation

// Define the paths for the files
let docsDirectoryPath = "./docs"
let iconSourcePath = "./assets/grape_icon_256.png"
let iconDestPath = "./docs/favicon.png"

do {
    let fileManager = FileManager.default

    // Check if docs directory exists
    var isDir: ObjCBool = false
    if fileManager.fileExists(atPath: docsDirectoryPath, isDirectory: &isDir) {
        if isDir.boolValue {
            // Docs directory exists, proceed with enumeration
            let enumerator = fileManager.enumerator(atPath: docsDirectoryPath)

            while let element = enumerator?.nextObject() as? String {
                if element.hasSuffix("index.html") {  // checks the extension
                    let indexPath = "\(docsDirectoryPath)/\(element)"
                    var htmlString = try String(contentsOfFile: indexPath, encoding: .utf8)

                    htmlString = htmlString.replacingOccurrences(
                        of: """
                            <link rel="icon" href="/Grape/favicon.ico">
                            """,
                        with: """
                            <link rel="icon" href="/Grape/favicon.png">
                            """)
                    htmlString = htmlString.replacingOccurrences(
                        of: """
                            <link rel="mask-icon" href="/Grape/favicon.svg" color="#333333">
                            """,
                        with: """
                            <link rel="preconnect" href="https://fonts.googleapis.com">
                            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                            <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:ital,wght@0,400;0,600;1,400;1,600&display=swap" rel="stylesheet">
                            <link rel="stylesheet" media="all" href="https://lizhen.me/inter/inter.css" type="text/css"/>
                            <style>
                                :root {
                                    --typography-html-font: "intervar";
                                    --typography-html-font-mono: "SF Mono", ui-monospace, "JetBrains Mono";
                                }
                                h1.title {
                                    font-weight: 600!important;
                                    font-variation-settings: 'wght' 600, 'opsz' 24!important;
                                }
                                h2.title {
                                    font-weight: 600!important;
                                    font-variation-settings: 'wght' 600, 'opsz' 24!important;
                                }
                            </style>
                            <script>
                            MathJax = {
                            tex: {
                                inlineMath: [['$', '$'], ['\\(', '\\)']]
                            },
                            svg: {
                                fontCache: 'global'
                            },
                            loader: {load: ['ui/lazy']}
                            };
                            </script>
                            <script type="text/javascript" id="MathJax-script" async
                            src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js">
                            </script>
                            """)

                    try htmlString.write(toFile: indexPath, atomically: false, encoding: .utf8)
                }
            }
        }
    }

    // Copy the icon file if it doesn't exist at the destination
    if !fileManager.fileExists(atPath: iconDestPath) {
        try fileManager.copyItem(atPath: iconSourcePath, toPath: iconDestPath)
    }

} catch {
    // Handle errors by printing to the console for now
    print("An error occurred: \(error)")
}
