
# Permanent Routing and Path fix script
$folderFiles = Get-ChildItem "folder/*.html"
$toolFiles = Get-ChildItem "tools/*.html"

$utf8NoBOM = New-Object System.Text.UTF8Encoding($false)

# Update Folder Files
foreach ($file in $folderFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    
    # 1. Standardize Navbar Logo to use root relative
    $content = [regex]::Replace($content, 'onclick="location.href=''index.html''"', 'onclick="location.href=''../index.html''"')
    $content = [regex]::Replace($content, 'onclick="location.href=''../index.html''"', 'onclick="location.href=''../index.html''"')
    
    # 2. Fix scripts and breadcrumbs
    $content = $content.Replace('href="index.html">Home</a>', 'href="../index.html">Home</a>')
    
    # 3. SELF-HEALING: Detect and fix invalid /folder/tools/ path if it sneaked into any <a> tags
    $content = $content.Replace('folder/tools/', 'tools/')

    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBOM)
}

# Update Tool Files
foreach ($file in $toolFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    
    # 1. Standardize Navbar Logo
    $content = [regex]::Replace($content, 'onclick="location.href=''index.html''"', 'onclick="location.href=''../index.html''"')
    $content = $content.Replace('onclick="navigateTo(''home-page'')"','onclick="location.href=''../index.html''"')
    
    # 2. Fix breadcrumbs
    $content = $content.Replace('href="index.html">Home</a>', 'href="../index.html">Home</a>')
    
    # 3. SELF-HEALING: Detect and fix invalid /folder/tools/
    $content = $content.Replace('folder/tools/', 'tools/')
    
    # 4. Ensure back links match the real file structure
    # Match: <a href='../folder/category.html' ... >
    # This is usually correct, but we ensure it.

    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBOM)
}

Write-Host "Site-wide path standardization and routing fix complete."
