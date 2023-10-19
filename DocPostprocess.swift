import Foundation

// Define the paths for the files
let htmlFilePath = "./docs/documentation/forcesimulation/index.html"
let iconSourcePath = "./assets/grape_icon.png"
let iconDestPath = "./docs/favicon.png"

do {
    // Read the HTML file into a string
    var htmlString = try String(contentsOfFile: htmlFilePath, encoding: .utf8)
    
    // Perform the replacements
    htmlString = htmlString.replacingOccurrences(of: """
    <link rel="icon" href="/Grape/favicon.ico">
    """, with: """
    <link rel="icon" href="/Grape/favicon.png">
    """)
    htmlString = htmlString.replacingOccurrences(of: """
    <link rel="mask-icon" href="/Grape/favicon.svg" color="#333333">
    """, with: """
<link rel="mask-icon" href="/Grape/favicon.png" color="#333333">
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
""")

    // Write the modified HTML string back to the file
    try htmlString.write(toFile: htmlFilePath, atomically: false, encoding: .utf8)
    
    // Copy the icon file
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: iconDestPath) {
        try fileManager.removeItem(atPath: iconDestPath)
    }
    try fileManager.copyItem(atPath: iconSourcePath, toPath: iconDestPath)

} catch {
    // Handle errors by printing to the console for now
    print("An error occurred: \(error)")
}
