# Parallel programming – Results
# Programación paralela – Resultados

Este informe documenta la ejecución de las actividades y compara el tiempo en serie vs. con GNU parallel. Además, incluye un ejercicio adicional con archivos de números aleatorios.

## 1) Generación de datos (CSV)
- Comando: `python .\data_gen.py --rows 200000`
- Archivos generados: `data1.csv`, `data2.csv`, `data3.csv` (~11 MB cada uno)
- Columnas: `value1,value2,value3`

## 2) Script de procesamiento
- Plantilla de ejecución: `python .\script.py <archivo> --column value2`
- Salida: `archivo\tcolumna\tconteo\tpromedio\tmediana\tsegundos`

## 3) Ejecución en serie (dentro del contenedor)
- Comandos:
  - `python3 script.py data1.csv --column value2`
  - `python3 script.py data2.csv --column value2`
  - `python3 script.py data3.csv --column value2`
- Salida:
  - `data1.csv\tvalue2\t200000\t50.017292\t50.044544\t0.624`
  - `data2.csv\tvalue2\t200000\t50.017292\t50.044544\t0.623`
  - `data3.csv\tvalue2\t200000\t50.017292\t50.044544\t0.628`
- Tiempo total en serie (suma de los tres): `0.624 + 0.623 + 0.628 ≈ 1.875 s`

## 4) Ejecución con GNU parallel (dentro del contenedor)
- Comando:
  - `time parallel python3 script.py --column value2 ::: data1.csv data2.csv data3.csv`
- Salida (por archivo):
  - `data1.csv\tvalue2\t200000\t50.017292\t50.044544\t0.659`
  - `data3.csv\tvalue2\t200000\t50.017292\t50.044544\t0.660`
  - `data2.csv\tvalue2\t200000\t50.017292\t50.044544\t0.668`
- Tiempo total paralelo (wall clock, real): `~1.021 s`

## 5) Comparación (CSV)
- Tiempo en serie: `~1.875 s`
- Tiempo en paralelo: `~1.021 s`
- Aceleración aproximada: $S = \frac{T_{serie}}{T_{paralelo}} \approx \frac{1.875}{1.021} \approx 1.84\times$
- Observaciones:
  - El tiempo paralelo suele aproximarse al de la tarea más lenta (≈ 0.66 s) más el overhead.
  - Con cargas dominadas por I/O y poco cómputo por archivo, la ganancia es moderada. Aumentar `--rows` incrementa el trabajo y tiende a mejorar el beneficio del paralelismo.

## 6) Reproducibilidad – Comandos usados (PowerShell)
```powershell
# Construir la imagen con GNU parallel + Python
### Extended experiment: 20 files, 200 numbers each

# Serie (dentro del contenedor)
- Script: `numbers_parallel_20.sh`
- Steps:
  1. Generate 20 files: `seq 20 | parallel "shuf -i 1-1000 -n 200 > data{}.txt"`

  2. Serial sums with timing (`time` + awk in a loop)
  3. Parallel sums with timing (`time parallel` + awk)
- Sample per-file sums (both serial and parallel output matched):

Notas:
- Para silenciar el aviso de citación de GNU parallel en la imagen:
```powershell
```
data1.txt: 97728
- Control de concurrencia: `--jobs N`.
- Para estresar más CPU y ver mayor speed-up, aumenta `--rows` al generar datos.

---

## GNU parallel – Archivos de números aleatorios y suma por archivo

### 1) Crear varios archivos con números aleatorios
- Comando (dentro del contenedor):
```bash
seq 5 | parallel "shuf -i 1-1000 -n 100 > data{}.txt"
```
- Esto crea `data1.txt`..`data5.txt` con 100 enteros (1..1000) cada uno.

### 2) Calcular la suma por archivo (en paralelo)
- Comando (dentro del contenedor):
```bash
parallel "awk '{s+=\$1} END {print \"{}: \" s}' {}" ::: data*.txt | sort -V | tee sums.txt
```
- Salida de ejemplo:
```
data1.txt: 51043
data2.txt: 47010
data3.txt: 50168
data4.txt: 45650
data5.txt: 52477
```
- Se guarda también como `sums.txt`.

### Experimento extendido: 20 archivos, 200 números por archivo
- Script: `numbers_parallel_20.sh`
- Pasos:
  1. Generar 20 archivos: `seq 20 | parallel "shuf -i 1-1000 -n 200 > data{}.txt"`
  2. Sumas en serie con medición de tiempo (bucle + awk)
  3. Sumas en paralelo con medición de tiempo (`time parallel` + awk)
- Muestras de salida (coinciden serie y paralelo):
```
data1.txt: 97728
data2.txt: 98915
data3.txt: 94000
...
data20.txt: 101886
```
- Tiempos registrados:
  - Serie (real): `0m0.081s`
  - Paralelo (real): `0m0.253s`
- Observación: con poco trabajo por archivo (200 números), el overhead hace que paralelo sea más lento. Para ver aceleración, aumenta el tamaño por archivo (p. ej., `-n 10000`) y/o el número de archivos.

---

## Conclusiones
- El paralelismo reduce el tiempo de pared cuando las tareas tienen suficiente cómputo y pueden ejecutarse de manera independiente.
- El overhead (arranque de procesos, orquestación, E/S, contenedores) puede anular la ganancia si el trabajo por tarea es muy pequeño.
- Para workloads con más cómputo (más filas `--rows` o más operaciones por elemento), la aceleración crece. En el experimento CSV, el speed-up fue ≈ 1.84×.
- Ajustar `--jobs` en GNU parallel al número de núcleos/recursos disponibles ayuda a aprovechar mejor el hardware.
- Documentar y automatizar (scripts y contenedor) facilita la reproducibilidad de los resultados.
data2.txt: 98915
data3.txt: 94000
...
data20.txt: 101886
```
- Timings captured:
  - Serial real: `0m0.081s`
  - Parallel real: `0m0.253s`
- Observation: With small per-file work (only 200 numbers), overhead makes the parallel version slower. Increasing the work per file (e.g., `-n 10000`) or the number of files can demonstrate a speed-up.
