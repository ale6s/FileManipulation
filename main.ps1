param (
    [string]$FileName,       # Example: "rep[yymmdd]_test.txt"
    [string]$DateFormat,     # Example: "yymmdd"
    [string]$FolderPath      # Example: "C:\Users\Ale6\Documents\fileName\files"  
)

function Extract-DateFromFilename {
    param (
        [string]$Filename,
        [string]$DateFormat
    )
    
    # Create a pattern for the date part in the filename
    $DatePattern = '\d{' + $DateFormat.Length + '}'
    if ($Filename -match $DatePattern) {
        try {
            # Parse the date from the matched string
            return [datetime]::ParseExact($Matches[0], $DateFormat, $null)
        } catch {
            Write-Warning "Unable to parse date from '$Filename' with format '$DateFormat'."
            return $null
        }
    }
    return $null
}

# Validate input parameters
if (-not $FileName -or -not $DateFormat) {
    Write-Error "You must provide both a filename pattern and a date format."
    exit 1
}

# Search for files matching the pattern in the provided folder
$CorrectFile = Get-ChildItem -Path $FolderPath -File -Filter "*$($FileName -replace '\[.*?\]', '*')*" | ForEach-Object {
    $DateInFile = Extract-DateFromFilename $_.Name $DateFormat
    if ($DateInFile) {
        # If the date is found and valid, return the file object
        return $_
    }
}

# Return the file object
if ($CorrectFile) {
    return $CorrectFile
} else {
    Write-Warning "No file found matching the pattern '$FileName' in '$FolderPath'."
    return $null
}



#This is use like so
#$File = ./main.ps1 -FileName "rep[yymmdd]_test.txt" -DateFormat "yymmdd" -FolderPath "C:\Users\Ale6\Documents\fileName\files"; Rename-Item -Path $File.FullName -NewName "repor1t.txt"
#$File = ./main.ps1 -FileName "[yyyymmdd]repor1t.txt" -DateFormat "yyyymmdd" -FolderPath "C:\Users\Ale6\Documents\fileName\files"; Remove-Item -Path $File.FullName
#$File = ./main.ps1 -FileName "file[mmddyyyy].txt" -DateFormat "mmddyyyy" -FolderPath "C:\Users\Ale6\Documents\fileName\files"; Move-Item -Path $File.FullName -Destination "C:\Users\Ale6\Documents\fileName"
