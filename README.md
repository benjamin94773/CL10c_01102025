# GNU Parallel - Programación Paralela

Este proyecto demuestra el uso de GNU Parallel para acelerar el procesamiento de datos en dos escenarios:
1. Análisis de archivos CSV (cálculo de media y mediana)
2. Procesamiento de archivos con números aleatorios

## Archivos principales

- `Dockerfile`: Imagen con GNU Parallel + Python 3
- `data_gen.py`: Generador de archivos CSV con datos aleatorios
- `script.py`: Script para calcular media y mediana de columnas CSV
- `numbers_parallel.sh`: Procesamiento de 5 archivos con números aleatorios
- `numbers_parallel_20.sh`: Procesamiento de 20 archivos con comparación serie vs paralelo
- `RESULTS.md`: Resultados en formato Markdown
- `RESULTS.tex`: Informe completo en LaTeX

## Uso rápido

1. **Construir la imagen Docker:**
```bash
docker build -t local/gnu-parallel-python:latest .
```

2. **Generar datos CSV:**
```bash
python data_gen.py --rows 200000
```

3. **Ejecutar en serie (CSV):**
```bash
docker run --rm -it -v ${PWD}:/work -w /work local/gnu-parallel-python:latest bash -lc "python3 script.py data1.csv --column value2; python3 script.py data2.csv --column value2; python3 script.py data3.csv --column value2"
```

4. **Ejecutar en paralelo (CSV):**
```bash
docker run --rm -it -v ${PWD}:/work -w /work local/gnu-parallel-python:latest bash -lc "time parallel python3 script.py --column value2 ::: data1.csv data2.csv data3.csv"
```

5. **Números aleatorios (5 archivos):**
```bash
docker run --rm -it -v ${PWD}:/work -w /work local/gnu-parallel-python:latest bash -lc "./numbers_parallel.sh"
```

6. **Números aleatorios (20 archivos con timing):**
```bash
docker run --rm -it -v ${PWD}:/work -w /work local/gnu-parallel-python:latest bash -lc "./numbers_parallel_20.sh"
```

## Resultados

Consulta `RESULTS.md` para un resumen ejecutivo o `RESULTS.tex` para el informe completo en LaTeX.

### Principales hallazgos

- **Speed-up CSV**: ~1.84× para 3 archivos de 200k filas
- **Overhead**: Con tareas pequeñas, el paralelismo puede ser más lento
- **Escalabilidad**: Mayor beneficio con más datos por archivo

## Requisitos

- Docker
- Python 3 (para generación local de datos)
- GNU Parallel (incluido en la imagen Docker)