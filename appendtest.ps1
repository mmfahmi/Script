# Function to extract file size in GB
function Get-FileSize {
    param (
        [string]$filePath
    )

    try {
        $fileInfo = Get-Item $filePath
        # Convert file size to GB
        return $fileInfo.Length / 1GB
    }
    catch {
        Write-Host "Error processing file: $filePath - $($_.Exception.Message)"
        return $null
    }
}

# Get the current user's profile path
$userProfilePath = $env:USERPROFILE
$userProfileName = (Get-Item $userProfilePath).Name

# Specify directories to scan
$directoriesToScan = @(
    [System.IO.Path]::Combine($userProfilePath, 'Documents'),
    [System.IO.Path]::Combine($userProfilePath, 'Downloads'),
    [System.IO.Path]::Combine($userProfilePath, 'Desktop')
)

# Create an array to store user and total file size data
$userSizeData = @()

# Iterate through each directory and extract file size
foreach ($directory in $directoriesToScan) {
    Write-Host "Processing directory: $directory"

    # Get all files in the directory and its subdirectories
    $files = Get-ChildItem -Path $directory -Recurse -File

    # Initialize total size for the current directory
    $totalSize = 0

    # Iterate through each file and extract file size
    foreach ($file in $files) {
        $fileSize = Get-FileSize -filePath $file.FullName

        if ($fileSize -ne $null) {
            # Add file size to the total size for the current directory
            $totalSize += $fileSize
        }
    }

    # Add user and total size data to the array
    $userSizeData += [PSCustomObject]@{
        'User' = $userProfileName
        'Directory' = $directory
        'TotalSize_GB' = $totalSize
    }
}

# Define the CSV file path for total size data on the desktop
$totalSizeCsvFilePath = [System.IO.Path]::Combine($userProfilePath, 'Desktop', 'totalsize.csv')

# If the file already exists, append the data; otherwise, create a new file
if (Test-Path $totalSizeCsvFilePath) {
    $userSizeData | Export-Csv -Path $totalSizeCsvFilePath -Append -NoTypeInformation
} else {
    $userSizeData | Export-Csv -Path $totalSizeCsvFilePath -NoTypeInformation
}

Write-Host "Total size data appended to: $totalSizeCsvFilePath"
