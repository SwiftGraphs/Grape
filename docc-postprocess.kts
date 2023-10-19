import java.io.File


File("./docs/documentation/forcesimulation/index.html").apply {
    var text = readText()
    text = text.replace(
        """<link rel="icon" href="/Grape/favicon.ico">""", 
        """<link rel="icon" href="/Grape/favicon.png">""")
        .replace(
            """<link rel="mask-icon" href="/Grape/favicon.svg" color="#333333">""",
            """<link rel="mask-icon" href="/Grape/favicon.png" color="#333333">
                <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:ital,wght@0,400;0,600;1,400;1,600&display=swap" rel="stylesheet">
    <link rel="stylesheet" media="all" href="https://lizhen.me/inter/inter.css" type="text/css"/>
    <style>
        :root {
            --typography-html-font: "intervar";
            --typography-html-font-mono: "SF Mono", ui-monospace, "JetBrains Mono";
        }
    </style>
    """)

    writeText(text)
}

File("./docs/favicon.png").apply {
    writeBytes(File("./assets/grape_icon.png").readBytes())
}

