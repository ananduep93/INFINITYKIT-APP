
# Comprehensive Routing Fix Script
$folderFiles = Get-ChildItem "folder/*.html"
$toolFiles = Get-ChildItem "tools/*.html"

$utf8NoBOM = New-Object System.Text.UTF8Encoding($false)

# Update FOLDERS
foreach ($file in $folderFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    
    # Standardize Navbar Logo
    $content = [regex]::Replace($content, 'onclick="location.href=''index.html''"', 'onclick="location.href=''../index.html''"')
    $content = [regex]::Replace($content, 'onclick="location.href=''\./index.html''"', 'onclick="location.href=''../index.html''"')
    
    # Fix Script and Link tags to be relative to root
    $content = $content.Replace('href="app.css', 'href="../app.css')
    $content = $content.Replace('src="main.js', 'src="../main.js')
    
    # Verify Breadcrumb Home
    $content = $content.Replace('href="index.html">Home</a>', 'href="../index.html">Home</a>')

    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBOM)
}

# Update TOOLS
foreach ($file in $toolFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    
    # Fix Navbar Logo
    $content = [regex]::Replace($content, 'onclick="location.href=''index.html''"', 'onclick="location.href=''../index.html''"')
    $content = [regex]::Replace($content, 'onclick="location.href=''\.\./folder/index.html''"', 'onclick="location.href=''../index.html''"')
    
    # Fix Breadcrumb Home & Folder paths
    # (Tools should already have ../ for app.css, but we verify)
    $content = $content.Replace('href="index.html">Home</a>', 'href="../index.html">Home</a>')
    
    # Detect wrong folder/tools/ paths if any
    $content = [regex]::Replace($content, 'href="folder/', 'href="../folder/')
    
    # Fix potentially broken logos
    $content = $content.Replace('onclick="navigateTo(''home-page'')"','onclick="location.href=''../index.html''"')

    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBOM)
}

Write-Host "Site-wide path standardization complete."
