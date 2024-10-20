param (
    [string]$InitialPath,
    [string]$archivePath,
    [int]$Threshold,
    [int]$fileCount,
    [int64]$SIZE
)

# Валидация параметров
if ((-not $InitialPath) -or (-not $archivePath) -or (-not $Threshold) -or (-not $fileCount) -or (-not $SIZE)){
    Write-Host "Incorrect Information; Set parametres: InitialFolderPath, ArchiveFolderPath, Threshold, fileCount, SIZE."
    exit 1
}

# Получаем размер папки
$usedSpace = (Get-ChildItem -Path $InitialPath -Recurse | Measure-Object -Property Length -Sum).Sum
$usedPercentage = [math]::Round(($usedSpace / $SIZE) * 100)

# Проверяем, превышает ли использование диска порог
if ($usedPercentage -lt $Threshold) {
    Write-Host "Folder usage is $usedPercentage%, archiving will not start."
    exit 0
}

# Архивирование файлов
$archiveName = Join-Path $archivePath "archive.zip"

# Если архив уже существует, распаковываем его в временную директорию
$tempDir = Join-Path $env:TEMP "TempArchive"
if (Test-Path $archiveName) {
    Write-Host "Extracting existing archive to temporary folder..."
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
    New-Item -Path $tempDir -ItemType Directory
    Expand-Archive -Path $archiveName -DestinationPath $tempDir -Force
} else {
    Write-Host "Archive does not exist. Creating new archive."
    New-Item -Path $tempDir -ItemType Directory
}

# Получаем список файлов в исходной папке
$fileList = Get-ChildItem -Path $InitialPath | Sort-Object LastWriteTime | Select-Object -First $fileCount

# Проверяем количество файлов для архивирования
if ($fileList.Count -lt $fileCount) {
    Write-Host "Not enough files to archive. Found $($fileList.Count) files, but need $fileCount."
    exit 0
}

Write-Host "Copying the oldest $fileCount files to temporary folder..."

# Копируем файлы во временную директорию для последующей архивации
$fileList | ForEach-Object { Copy-Item $_.FullName -Destination $tempDir }

# Создаем новый архив или обновляем существующий
Write-Host "Creating/Updating archive..."
if (Test-Path $archiveName) {
    Remove-Item $archiveName -Force
}
Compress-Archive -Path $tempDir\* -DestinationPath $archiveName -CompressionLevel Optimal -Force

Write-Host "Deleting the oldest $fileCount files..."

# Удаление архивированных файлов
$fileList | ForEach-Object { Remove-Item $_.FullName -Force }

# Очистка временной директории
Remove-Item $tempDir -Recurse -Force

Write-Host "Deleted $fileCount files and updated archive."
