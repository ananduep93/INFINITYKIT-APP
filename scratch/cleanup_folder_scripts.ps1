
# Batch remove redundant setTimeout script from folder pages
$folderFiles = Get-ChildItem "folder/*.html"
$utf8NoBOM = New-Object System.Text.UTF8Encoding($false)

foreach ($file in $folderFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    
    $oldScriptPattern = '(?s)setTimeout\(\(\) => \{.*?\}, 100\);'
    $content = [regex]::Replace($content, $oldScriptPattern, '')
    
    # Also clean up empty lines left behind
    $content = $content.Replace("`n`n`n", "`n`n")

    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBOM)
}
