# Script de automatización para Windows PowerShell
# Ejecuta todo el pipeline: generación de datos, serie y paralelo

Write-Host "=== GNU Parallel - Pipeline Completo ===" -ForegroundColor Green

# 1. Construir imagen si no existe
Write-Host "1. Verificando imagen Docker..." -ForegroundColor Yellow
$imageExists = docker images -q local/gnu-parallel-python:latest
if (-not $imageExists) {
    Write-Host "   Construyendo imagen..." -ForegroundColor Cyan
    docker build -t local/gnu-parallel-python:latest .
} else {
    Write-Host "   Imagen ya existe" -ForegroundColor Green
}

# 2. Generar datos CSV
Write-Host "2. Generando datos CSV..." -ForegroundColor Yellow
python data_gen.py --rows 200000

# 3. Ejecutar CSV en serie
Write-Host "3. Ejecutando CSV en serie..." -ForegroundColor Yellow
$serialStart = Get-Date
docker run --rm -v ${PWD}:/work -w /work local/gnu-parallel-python:latest bash -lc "python3 script.py data1.csv --column value2; python3 script.py data2.csv --column value2; python3 script.py data3.csv --column value2" | Tee-Object -FilePath "csv_serial_output.txt"
$serialEnd = Get-Date
$serialTime = ($serialEnd - $serialStart).TotalSeconds

# 4. Ejecutar CSV en paralelo
Write-Host "4. Ejecutando CSV en paralelo..." -ForegroundColor Yellow
$parallelStart = Get-Date
docker run --rm -v ${PWD}:/work -w /work local/gnu-parallel-python:latest bash -lc "time parallel python3 script.py --column value2 ::: data1.csv data2.csv data3.csv" | Tee-Object -FilePath "csv_parallel_output.txt"
$parallelEnd = Get-Date
$parallelTime = ($parallelEnd - $parallelStart).TotalSeconds

# 5. Números aleatorios
Write-Host "5. Ejecutando números aleatorios..." -ForegroundColor Yellow
docker run --rm -v ${PWD}:/work -w /work local/gnu-parallel-python:latest bash -lc "./numbers_parallel.sh"
docker run --rm -v ${PWD}:/work -w /work local/gnu-parallel-python:latest bash -lc "./numbers_parallel_20.sh"

# 6. Resumen
Write-Host "=== RESUMEN ===" -ForegroundColor Green
Write-Host "CSV Serie (PowerShell):    $($serialTime.ToString('F3')) s" -ForegroundColor White
Write-Host "CSV Paralelo (PowerShell): $($parallelTime.ToString('F3')) s" -ForegroundColor White
Write-Host "Speed-up aproximado:       $(($serialTime/$parallelTime).ToString('F2'))x" -ForegroundColor Cyan

Write-Host "`nConsulta los archivos de salida:" -ForegroundColor Yellow
Write-Host "- csv_serial_output.txt" -ForegroundColor White
Write-Host "- csv_parallel_output.txt" -ForegroundColor White
Write-Host "- RESULTS.md" -ForegroundColor White
Write-Host "- RESULTS.tex" -ForegroundColor White