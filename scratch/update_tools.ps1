
$folders = @(
    @{id='daily-essentials'; name='Daily Essentials'; tools=@('calculator', 'todolist', 'notes', 'timer')},
    @{id='expense-tracker'; name='Expense Tracker'; tools=@('expenseadd', 'expenselist', 'categorysummary', 'dailymonthlyreport', 'budgettracker', 'searchexpenses', 'resetexpenses', 'expenseanalytics', 'topspendinginsights', 'smartsuggestions')},
    @{id='utilities'; name='Utilities'; tools=@('unitconverter', 'passwordgen', 'passwordsaver', 'passwordstrength', 'randomnamepicker')},
    @{id='pdf-tools'; name='PDF Tools'; tools=@('imagetopdf', 'pdftoimage', 'mergepdf', 'rotatepdf')},
    @{id='image'; name='Image'; tools=@('compressimage', 'imageinfo')},
    @{id='math-tools'; name='Math Tools'; tools=@('discountcalc', 'percentagecalc', 'primenumber', 'palindrome', 'factorial', 'fibonacci', 'lcmhcf', 'trianglechecker', 'distancecalc', 'equationsolver')},
    @{id='time-tools'; name='Time Tools'; tools=@('daysbetween')},
    @{id='text-tools'; name='Text Tools'; tools=@('usernamegen')},
    @{id='student-tools'; name='Student Tools'; tools=@('examcalc')},
    @{id='quick-tools'; name='Quick Tools'; tools=@('texttospeech')},
    @{id='data-tools'; name='Data Tools'; tools=@('graphmaker', 'averagecalculator', 'numbersorter', 'csvviewer')},
    @{id='decision-tools'; name='Decision Tools'; tools=@('spinwheel', 'yesnogerator', 'choicecomparator')},
    @{id='planner-tools'; name='Planner Tools'; tools=@('calendarviewer', 'dailyplanner', 'reminderalert')},
    @{id='web-tools'; name='Web Tools'; tools=@('urlencoder', 'urlextractor', 'metatagviewer')},
    @{id='health-utility-hub'; name='Health Utility Hub'; tools=@('bmicalculator', 'drugdosage', 'ivdripcalc', 'medicinereminder')}
)

$utf8NoBOM = New-Object System.Text.UTF8Encoding($false)
$files = Get-ChildItem "tools/*.html"

foreach ($file in $files) {
    # Read as UTF8
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    $toolId = $file.BaseName
    
    $parentFolder = $null
    foreach ($f in $folders) {
        if ($f.tools -contains $toolId) {
            $parentFolder = $f
            break
        }
    }
    
    if ($parentFolder) {
        # 1. Update Back Link
        $oldBackLinkPattern = '<a href="../index.html#[^"]+" class="back-link" id="backToFolders">'
        $newBackLink = "<a href='../folder/$($parentFolder.id).html' class='back-link' id='backToFolders'>"
        $content = [regex]::Replace($content, $oldBackLinkPattern, $newBackLink)
        
        # 2. Add Breadcrumbs (if not already there)
        if ($content.IndexOf("class=`"breadcrumb`"") -lt 0) {
            $breadcrumbHtml = @"
    <div class="breadcrumb">
        <a href="../index.html">Home</a>
        <span class="separator">&rsaquo;</span>
        <a href="../folder/$($parentFolder.id).html">$($parentFolder.name)</a>
        <span class="separator">&rsaquo;</span>
        <span class="current">$($file.BaseName)</span>
    </div>
"@
            $content = $content.Replace("</nav>", "</nav>`n$breadcrumbHtml")
        }
        
        # Write back as UTF8 without BOM
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBOM)
    }
}
