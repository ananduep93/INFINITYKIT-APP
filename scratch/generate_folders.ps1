
$folders = @(
    @{id="daily-essentials"; name="Daily Essentials"; emoji="🏠"; title="Daily Essentials Tools - Infinity Kit"; desc="Must-have daily tools like calculators, notes, and task lists for maximum productivity."},
    @{id="expense-tracker"; name="Expense Tracker"; emoji="💸"; title="Expense Tracker Tools - Infinity Kit"; desc="Manage your finances with powerful budget, analytics, and spending tools."},
    @{id="utilities"; name="Utilities"; emoji="🛠️"; title="Essential Digital Utilities - Infinity Kit"; desc="High-utility tools including password generators, unit converters, and person pickers."},
    @{id="pdf-tools"; name="PDF Tools"; emoji="📄"; title="PDF Management Tools - Infinity Kit"; desc="Edit, merge, rotate, and convert PDF files online for free."},
    @{id="image"; name="Image"; emoji="🖼️"; title="Image Processing Tools - Infinity Kit"; desc="Compress images and view detailed image metadata instantly."},
    @{id="time-tools"; name="Time Tools"; emoji="⏰"; title="Time and Date Tools - Infinity Kit"; desc="Calculate days between dates and manage your schedules efficiently."},
    @{id="text-tools"; name="Text Tools"; emoji="✍️"; title="Text Processing Tools - Infinity Kit"; desc="Generate usernames, clean text, and perform advanced text transformations."},
    @{id="student-tools"; name="Student Tools"; emoji="📚"; title="Student & Academic Tools - Infinity Kit"; desc="Specialized tools for students, including exam marks calculators and study planners."},
    @{id="quick-tools"; name="Quick Tools"; emoji="⚡"; title="Lightning Fast Utilities - Infinity Kit"; desc="Quick access to converters like Text-to-Speech and more."},
    @{id="data-tools"; name="Data Tools"; emoji="📊"; title="Data Analysis Tools - Infinity Kit"; desc="Create graphs, average data, and sort numbers with advanced data utilities."},
    @{id="decision-tools"; name="Decision Tools"; emoji="🎯"; title="Random Decision Makers - Infinity Kit"; desc="Spin wheels and compare choices to make faster decisions."},
    @{id="planner-tools"; name="Planner Tools"; emoji="📅"; title="Daily Planning Tools - Infinity Kit"; desc="View calendars, plan your day, and set reminder alerts."},
    @{id="web-tools"; name="Web Tools"; emoji="🌐"; title="Web Development Tools - Infinity Kit"; desc="Extract URL parameters, view meta tags, and encode/decode URLs."},
    @{id="health-utility-hub"; name="Health Utility Hub"; emoji="🩺"; title="Health & Wellness Tools - Infinity Kit"; desc="BMI calculators, drug dosage guides, and medication reminders."},
    @{id="favorites"; name="Favorites"; emoji="⭐"; title="Starred Tools - Infinity Kit"; desc="Quick access to your favorite utility tools in one place."}
)

$template = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{TITLE}}</title>
    <meta name="description" content="{{DESCRIPTION}}">
    <link rel="canonical" href="https://infinitykit.online/folder/{{ID}}.html">
    
    <!-- Google AdSense -->
    <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-8795968572402515" crossorigin="anonymous"></script>

    <link rel="stylesheet" href="../app.css?v=16.3">
    <link rel="shortcut icon" href="../icon-192.png" type="image/png">
    
    <!-- Structured Data -->
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "CollectionPage",
      "name": "{{NAME}}",
      "description": "{{DESCRIPTION}}",
      "url": "https://infinitykit.online/folder/{{ID}}.html"
    }
    </script>
</head>
<body>
    <nav class="navbar">
        <div class="nav-logo" onclick="location.href='../index.html'">⚡INFINITY KIT</div>
        <button class="menu-btn" onclick="toggleMenu()">☰</button>
        <div class="nav-right" id="navRight">
            <div class="nav-links">
                <a href="../index.html">Home</a>
                <a href="../index.html#about-page">About</a>
                <a href="../index.html#contact-page">Contact</a>
            </div>
        </div>
    </nav>

    <div class="breadcrumb">
        <a href="../index.html">Home</a>
        <span class="separator">&rsaquo;</span>
        <span class="current">{{NAME}}</span>
    </div>

    <main class="tool-page-container">
        <div class="tool-header">
            <h1 class="tool-title">{{EMOJI}} {{NAME}}</h1>
            <p>{{DESCRIPTION}}</p>
        </div>

        <div class="tools-grid" id="toolsGrid">
            <!-- Tools will be rendered here by main.js -->
        </div>

        <article class="seo-content">
            <h2>Explore {{NAME}}</h2>
            <p>Welcome to the {{NAME}} section of Infinity Kit. Here you will find a curated collection of powerful, free, and easy-to-use tools designed to help you with {{NAME}} tasks.</p>
            <p>Our tools are built for speed and privacy. Whether you are on a mobile device or a desktop, you can access these utilities instantly without any signups or hidden costs.</p>
        </article>
    </main>

    <footer class="footer">
        <div class="footer-links">
            <a href="../index.html#about-page">About</a>
            <a href="../index.html#privacy-page">Privacy Policy</a>
            <a href="../index.html#terms-page">Terms & Conditions</a>
            <a href="../index.html#contact-page">Contact</a>
        </div>
        <div class="footer-bottom">
            <p id="copyrightText"></p>
        </div>
    </footer>

    <script src="../notifications.js?v=5"></script>
    <script src="../main.js?v=16.3"></script>
    <script src="../expense-tracker.js?v=6"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const folderId = '{{ID}}';
            const folder = folders.find(f => f.id === folderId);
            if (folder) {
                renderToolsInFolder(folder);
                // Ensure tools link correctly from here
                setTimeout(() => {
                    document.querySelectorAll('.tool-card').forEach(card => {
                        const toolId = card.getAttribute('onclick').match(/'([^']+)'/)[1];
                        card.setAttribute('onclick', ``location.href='../tools/${toolId}.html'``);
                    });
                }, 100);
            }
        });
    </script>
</body>
</html>
"@

foreach ($f in $folders) {
    $content = $template.Replace("{{TITLE}}", $f.title).Replace("{{DESCRIPTION}}", $f.desc).Replace("{{ID}}", $f.id).Replace("{{NAME}}", $f.name).Replace("{{EMOJI}}", $f.emoji)
    $content | Out-File -FilePath "folder/$($f.id).html" -Encoding utf8
}
