
# Cleanup script to remove definitions and fix folder layouts
$folderFiles = Get-ChildItem "folder/*.html"
$toolFiles = Get-ChildItem "tools/*.html"

$utf8NoBOM = New-Object System.Text.UTF8Encoding($false)

# Update Folders
foreach ($file in $folderFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    
    # 1. Add category-layout class
    $content = $content.Replace('class="tool-page-container"', 'class="tool-page-container category-layout"')
    
    # 2. Remove header description (the <p> after h1)
    $content = [regex]::Replace($content, '(?s)<h1 class="tool-title">.*?</h1>\s*<p>.*?</p>', { param($m) $m.Value -replace '<p>.*?</p>', '' })
    
    # 3. Remove SEO content article
    $content = [regex]::Replace($content, '(?s)<article class="seo-content">.*?</article>', '')

    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBOM)
}

# Update Tools
foreach ($file in $toolFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    
    # 1. Remove header description
    $content = [regex]::Replace($content, '(?s)<h1 class="tool-title">.*?</h1>\s*<p>.*?</p>', { param($m) $m.Value -replace '<p>.*?</p>', '' })
    
    # 2. Remove SEO content article if exists
    $content = [regex]::Replace($content, '(?s)<article class="seo-content">.*?</article>', '')

    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBOM)
}
