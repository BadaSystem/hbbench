# 📘 HARBENCH USER MANUAL — English Version
## Harbour Benchmark Suite v1.0

---

## 📑 Table of Contents

1. [🎯 Introduction](#1--introduction)
2. [📦 System Requirements](#2--system-requirements)
3. [🚀 Installation](#3--installation)
4. [🏁 Quick Start](#4--quick-start)
5. [⚙️ Command-Line Options](#5--command-line-options)
6. [📊 Test Categories Explained](#6--test-categories-explained)
7. [🧵 Multi-Thread Tests](#7--multi-thread-tests)
8. [🔍 Understanding Results](#8--understanding-results)
9. [💾 Exporting Results](#9--exporting-results)
10. [📂 File Structure](#10--file-structure)
11. [🛠️ Troubleshooting](#11--troubleshooting)
12. [🎓 Practical Examples](#12--practical-examples)

---

## 1. 🎯 Introduction

**Harbour Benchmark Suite (hbbench)** is a professional, industrial-grade performance measurement tool designed for the **Harbour 3.2.0dev** compiler and **MiniGUI Extended Edition** runtime environment.

### 🌟 What Does It Measure?

hbbench evaluates the performance of **12 critical categories** of Harbour operations:

| # | Category | What It Tests |
|---|----------|---------------|
| 1 | 🖥️ **VM** | Virtual machine core operations |
| 2 | 🔤 **String** | Text manipulation functions |
| 3 | 📚 **Array** | Arrays, hashes, and collections |
| 4 | 🔢 **NumDate** | Numeric and date operations |
| 5 | ⚡ **Eval** | Code block evaluation |
| 6 | 🗄️ **DBF** | Database file operations |
| 7 | 💾 **File** | File I/O operations |
| 8 | 🔍 **Regex** | Regular expressions |
| 9 | 🧠 **MemObj** | Memory and object management |
| 10 | 🔒 **Concur** | Concurrency primitives |
| 11 | 🧵 **MT** | Multi-threading performance |
| 12 | 🌐 **Net** | Network operations (reserved) |

### 🎓 Why Use hbbench?

✅ **Compare compiler versions** — Detect performance regressions  
✅ **Tune your hardware** — Find optimal CPU/RAM configurations  
✅ **Validate deployment** — Ensure production systems meet performance SLAs  
✅ **Educational tool** — Learn Harbour's internal performance characteristics  
✅ **Regression testing** — Track performance over time with CSV/JSON exports

---

## 2. 📦 System Requirements

### 💻 Minimum Requirements

| Component | Requirement |
|-----------|-------------|
| 🖥️ **OS** | Windows 7/8/10/11 (32-bit or 64-bit) |
| 🧠 **CPU** | Any x86/x64 processor |
| 💾 **RAM** | 512 MB minimum (2 GB recommended) |
| 📂 **Disk** | 50 MB free space |
| 🔧 **Runtime** | Harbour 3.2.0dev (r2503200530+) |

### ⚠️ Important Notes

> 💡 **Tip:** hbbench is a **console application** — it runs in the Windows Command Prompt (cmd.exe) or PowerShell. No graphical interface is required.

> ⚠️ **Warning:** Multi-thread tests (category 11) require a Harbour build compiled with `HB_MULTITHREAD` enabled. If disabled, MT tests will gracefully report `0.000s`.

---

## 3. 🚀 Installation

### 📥 Step-by-Step Installation

**Step 1:** 📂 Create the project directory
```cmd
mkdir C:\hbbench
cd C:\hbbench
```

**Step 2:** 📋 Copy the executable
```
Place hbbench.exe in C:\hbbench\
```

**Step 3:** 🗂️ The program will auto-create these folders on first run:
```
C:\hbbench\
├── 📁 data\         ← Temporary DBF and I/O test files
├── 📁 logs\         ← Execution logs (.log files)
└── 📁 reports\      ← Exported CSV/JSON reports
```

**Step 4:** ✅ Verify installation
```cmd
hbbench.exe --help
```

If you see the help message, installation is successful! 🎉

---

## 4. 🏁 Quick Start

### 🚀 Run Your First Benchmark

```cmd
hbbench.exe
```

### 📊 Expected Output

```
09/24/2026 17:21:21 Windows 10 10.0.19045
Harbour 3.2.0dev (r2503200530)  Borland C++ 5.8.2 (32-bit)
LOOPS: 1000000
==============================================================================
TEST                                                        SECONDS
==============================================================================
[ 000: empty loop overhead ].....................................0.000
[ 001: local char assign ].......................................0.016
[ 002: local num assign ]........................................0.031
...
[ Total CPU time: ]..............................................8.984
[ Total real time: ].............................................9.422
```

### 🎯 What Just Happened?

1. ✅ hbbench created a temporary DBF table with 500 records
2. ✅ Ran **31 single-threaded tests** across 10 categories
3. ✅ Measured each test against a baseline overhead (test 000)
4. ✅ Displayed results in real-time
5. ✅ Saved a detailed log in `logs\hbbench_YYYYMMDD_HHMMSS.log`

---

## 5. ⚙️ Command-Line Options

### 📋 Complete Options Reference

#### 🔧 Core Options

| Option | Description | Example |
|--------|-------------|---------|
| `--loops=<n>` | Set iterations per test | `--loops=500000` |
| `--only=<cat>` | Run only one category | `--only=array` |
| `--exclude=<tests>` | Skip specific tests | `--exclude=500.501.502` |
| `--nolog` | Don't create log file | `--nolog` |
| `--noenv` | Hide environment header | `--noenv` |
| `--help` or `-h` | Show help message | `--help` |

#### 🧵 Multi-Thread Options

| Option | Description | Example |
|--------|-------------|---------|
| `--mt` | Enable MT tests (run after ST) | `--mt` |
| `--mt-only` | Run ONLY MT tests | `--mt-only` |
| `--threads=<n>` | Number of threads (1-16) | `--threads=8` |

#### 💾 Export Options

| Option | Description | Example |
|--------|-------------|---------|
| `--csv` | Export results to CSV | `--csv` |
| `--json` | Export results to JSON | `--json` |
| `--output=<name>` | Custom output filename | `--output=mytest` |

### 🎯 Available Categories for `--only=`

```
vm        → Virtual Machine tests (000-004)
string    → String operations (100-102)
array     → Array/Hash operations (200-204)
numdate   → Numeric/Date operations (300-301)
eval      → Code block evaluation (400-401)
dbf       → Database operations (500-502)
file      → File I/O operations (600-601)
regex     → Regular expressions (700-701)
memobj    → Memory/Object ops (800-804)
concur    → Concurrency primitives (900-901)
```

---

## 6. 📊 Test Categories Explained

### 🖥️ Category 1: VM (Tests 000-004)

Measures the **core virtual machine** performance.

| Test | Description | What It Reveals |
|------|-------------|-----------------|
| 🔹 **000** | Empty loop overhead | Baseline measurement |
| 🔹 **001** | Local char assignment | Variable assignment speed |
| 🔹 **002** | Local numeric assignment | Numeric handling |
| 🔹 **003** | Pre-compiled codeblock eval | Codeblock efficiency |
| 🔹 **004** | Direct `&` macro | Macro compilation overhead |

> 💡 **Tip:** Test 000 is subtracted from all other tests to remove loop overhead.

### 🔤 Category 2: String (Tests 100-102)

| Test | Function | Use Case |
|------|----------|----------|
| 🔹 **100** | `Upper()` | Text normalization |
| 🔹 **101** | `Lower()` | Case conversion |
| 🔹 **102** | `AllTrim()` | Whitespace removal |

### 📚 Category 3: Array (Tests 200-204)

| Test | Description | Complexity |
|------|-------------|------------|
| 🔹 **200** | Array element assignment | ⭐ Basic |
| 🔹 **201** | `AScan()` search | ⭐⭐ Linear search |
| 🔹 **202** | Hash assignment (1M iter) | ⭐⭐⭐ Hash operations |
| 🔹 **203** | GC stress test | ⭐⭐⭐⭐ Garbage collection |
| 🔹 **204** | Hash iteration | ⭐⭐⭐ Hash traversal |

### 🗄️ Category 5: DBF (Tests 500-502)

> ⚠️ **Note:** These tests require a valid `data\bench.dbf` file (auto-created).

| Test | Operation | Records |
|------|-----------|---------|
| 🔹 **500** | Indexed `SEEK` (CODE) | 50,000 seeks |
| 🔹 **501** | Sequential scan | 500 iterations × 500 records |
| 🔹 **502** | Append + unlock | 5,000 inserts |

### 💾 Category 6: File (Tests 600-601)

| Test | Operation | Iterations |
|------|-----------|------------|
| 🔹 **600** | `MemoWrit()` | 1,000 writes |
| 🔹 **601** | `MemoRead()` | 5,000 reads |

### 🧠 Category 8: MemObj (Tests 800-804)

| Test | Operation | Description |
|------|-----------|-------------|
| 🔹 **800** | `ErrorNew` args | Object property access |
| 🔹 **801** | `hb_Base64Encode` | Encoding speed |
| 🔹 **802** | `HB_Serialize` | Binary serialization |
| 🔹 **803** | `HB_DeSerialize` | Binary deserialization |
| 🔹 **804** | Serialize roundtrip | Full cycle (200,000 iter) |

---

## 7. 🧵 Multi-Thread Tests

### 🎯 How to Enable MT Tests

```cmd
hbbench.exe --mt
```

### 📊 MT Test Suite (Tests 1000-1005)

| Test | Description | What It Measures |
|------|-------------|------------------|
| 🔹 **1000** | Thread create + join | Thread overhead (5,000 threads) |
| 🔹 **1001** | Mutex contention | Lock/unlock under load |
| 🔹 **1002** | Shared hash MT | Concurrent hash access |
| 🔹 **1003** | Parallel work | **Scalability test** (speedup) |
| 🔹 **1004** | Producer/Consumer | Fine-grained locking |
| 🔹 **1005** | Chunked P/C | **Optimized** chunk processing |

### 📈 Understanding Speedup (Test 1003)

The **speedup** metric compares single-thread vs multi-thread performance:

```
Speedup = ST_Baseline / MT_Time
```

| Speedup | Meaning |
|---------|---------|
| 🟢 **> 1.00x** | MT is FASTER than ST (good scaling) |
| 🟡 **= 1.00x** | No benefit from multi-threading |
| 🔴 **< 1.00x** | MT is SLOWER (overhead exceeds benefit) |

### 🔧 Configuring Thread Count

```cmd
hbbench.exe --mt --threads=8
```

Valid range: **1 to 16 threads** (default: 4)

---

## 8. 🔍 Understanding Results

### 📊 Reading the Output

```
[ 202: Hash assign (1000000 iter, pre-alloc) ]...0.500
│     │                                          │
│     │                                          └─ Time in seconds
│     └─ Test description
└─ Test ID
```

### 🎯 Key Metrics

| Metric | Meaning |
|--------|---------|
| **SECONDS** | Net execution time (overhead subtracted) |
| **Total CPU time** | Sum of all test times |
| **Total real time** | Wall-clock elapsed time |
| **ST Baseline** | Reference time for speedup calculation |

### 📈 Performance Benchmarks (Typical Values)

| Test | Fast 🚀 | Average 🏃 | Slow 🐢 |
|------|---------|------------|---------|
| 001 (char assign) | < 0.020s | 0.020-0.050s | > 0.050s |
| 202 (hash assign) | < 0.400s | 0.400-0.600s | > 0.600s |
| 500 (indexed seek) | < 0.100s | 0.100-0.200s | > 0.200s |
| 804 (roundtrip) | < 1.500s | 1.500-2.000s | > 2.000s |

---

## 9. 💾 Exporting Results

### 📄 CSV Export

```cmd
hbbench.exe --csv
```

**Output:** `reports\bench_YYYYMMDD_HHMMSS.csv`

**CSV Structure:**
```csv
test_id,test_name,category,seconds,loops,compiler
"001","local char assign",1,0.016000,1000000,"Borland C++ 5.8.2"
"202","Hash assign",3,0.500000,1000000,"Borland C++ 5.8.2"
```

### 📄 JSON Export

```cmd
hbbench.exe --json
```

**Output:** `reports\bench_YYYYMMDD_HHMMSS.json`

**JSON Structure:**
```json
{
  "benchmark": "hbbench",
  "version": "14.0-beta",
  "compiler": "Borland C++ 5.8.2",
  "date": "20260924 17:21:21",
  "results": [
    {
      "id": "001",
      "name": "local char assign",
      "category": 1,
      "seconds": 0.016000,
      "loops": 1000000
    }
  ]
}
```

### 🎯 Custom Output Filename

```cmd
hbbench.exe --csv --output=reports\my_custom_report
```

Creates: `reports\my_custom_report.csv`

---

## 10. 📂 File Structure

### 📁 After First Run

```
C:\hbbench\
│
├── 📄 hbbench.exe              ← Main executable
│
├── 📁 data\
│   ├── 📄 bench.dbf            ← Temporary test table
│   ├── 📄 bench.cdx            ← Structural index
│   └── 📄 bench_io.tmp         ← I/O test file
│
├── 📁 logs\
│   ├── 📄 hbbench_20260924_131137.log
│   ├── 📄 hbbench_20260924_160638.log
│   └── 📄 hbbench_20260924_172121.log
│
└── 📁 reports\
    ├── 📄 bench_20260924_172121.csv
    └── 📄 bench_20260924_172121.json
```

### 🗑️ Cleanup

hbbench **automatically deletes** temporary files (`bench.dbf`, `bench.cdx`) after execution. Log and report files are **preserved** for historical analysis.

---

## 11. 🛠️ Troubleshooting

### ❌ Problem: "DBF bootstrap failed"

**Cause:** Cannot create `data\bench.dbf`

**Solutions:**
1. ✅ Ensure `data\` folder is writable
2. ✅ Check disk space (minimum 10 MB free)
3. ✅ Close other programs using the file

### ❌ Problem: MT tests show "MT disabled in this build"

**Cause:** Harbour was compiled without multi-threading support

**Solution:** Recompile Harbour with `HB_MULTITHREAD` enabled, or ignore MT tests.

### ❌ Problem: Some tests show `0.000s`

**Cause:** Test completes faster than timer resolution

**Solutions:**
1. ✅ Increase iterations: `--loops=5000000`
2. ✅ Run multiple times and average results
3. ✅ Use `--only=<category>` to focus on slow tests

### ❌ Problem: Speedup < 1.00x in test 1003

**Cause:** Thread overhead exceeds parallelism benefit

**This is NORMAL** for small workloads. Try:
- Increase `--threads=8` or higher
- Run on a multi-core CPU
- Accept that some operations don't benefit from MT

### ❌ Problem: "Mutex creation failed"

**Cause:** System resource exhaustion

**Solution:** Reduce thread count or close other applications.

---

## 12. 🎓 Practical Examples

### 📝 Example 1: Quick Test (Fast Feedback)

```cmd
hbbench.exe --loops=100000 --only=vm
```

**Use case:** Quick validation after code changes

### 📝 Example 2: Database Performance Focus

```cmd
hbbench.exe --loops=50000 --only=dbf --csv
```

**Use case:** Evaluate DBF performance before production deployment

### 📝 Example 3: Multi-Thread Scalability Test

```cmd
hbbench.exe --mt-only --threads=8 --json
```

**Use case:** Test how well your application scales on multi-core systems

### 📝 Example 4: Exclude Slow Tests

```cmd
hbbench.exe --exclude=804.502.1004
```

**Use case:** Skip known slow tests for faster iteration

### 📝 Example 5: Full Benchmark with All Exports

```cmd
hbbench.exe --mt --csv --json --output=reports\full_bench
```

**Use case:** Comprehensive benchmark for documentation

### 📝 Example 6: Silent Mode (No Log)

```cmd
hbbench.exe --nolog --noenv --loops=500000
```

**Use case:** Automated CI/CD pipelines

---

## 🏁 Conclusion

🎉 **Congratulations!** You now have a complete understanding of hbbench v1.0.

### 🔑 Key Takeaways

✅ hbbench measures **12 categories** of Harbour performance  
✅ Use `--only=<cat>` to focus on specific areas  
✅ Enable `--mt` for multi-threading analysis  
✅ Export to `--csv` or `--json` for historical tracking  
✅ Check `logs\` for detailed execution records  
✅ Use `reports\` for data analysis and comparison

### 📞 Support

- 📧 **Email:** marvijarrin@gmail.com
- 🌐 **Website:** badasystem.com
- 📅 **Version:** 1.0 (September 2026)

---

**🎓 Happy benchmarking! 🚀**

---

# 📘 MANUAL DE USUARIO DE HARBENCH — Versión en Español
## Harbour Benchmark Suite v1.0 Edición Industrial

---

## 📑 Tabla de Contenidos

1. [🎯 Introducción](#1--introducción)
2. [📦 Requisitos del Sistema](#2--requisitos-del-sistema)
3. [🚀 Instalación](#3--instalación)
4. [🏁 Inicio Rápido](#4--inicio-rápido)
5. [⚙️ Opciones de Línea de Comandos](#5--opciones-de-línea-de-comandos)
6. [📊 Categorías de Tests Explicadas](#6--categorías-de-tests-explicadas)
7. [🧵 Tests Multi-Hilo](#7--tests-multi-hilo)
8. [🔍 Entendiendo los Resultados](#8--entendiendo-los-resultados)
9. [💾 Exportando Resultados](#9--exportando-resultados)
10. [📂 Estructura de Archivos](#10--estructura-de-archivos)
11. [🛠️ Solución de Problemas](#11--solución-de-problemas)
12. [🎓 Ejemplos Prácticos](#12--ejemplos-prácticos)

---

## 1. 🎯 Introducción

**Harbour Benchmark Suite (hbbench)** es una herramienta profesional de medición de rendimiento de grado industrial, diseñada para el compilador **Harbour 3.2.0dev** y el entorno de ejecución **MiniGUI Extended Edition**.

### 🌟 ¿Qué Mide?

hbbench evalúa el rendimiento de **12 categorías críticas** de operaciones Harbour:

| # | Categoría | Qué Evalúa |
|---|-----------|------------|
| 1 | 🖥️ **VM** | Operaciones core de la máquina virtual |
| 2 | 🔤 **String** | Funciones de manipulación de texto |
| 3 | 📚 **Array** | Arrays, hashes y colecciones |
| 4 | 🔢 **NumDate** | Operaciones numéricas y de fechas |
| 5 | ⚡ **Eval** | Evaluación de bloques de código |
| 6 | 🗄️ **DBF** | Operaciones con archivos de base de datos |
| 7 | 💾 **File** | Operaciones de entrada/salida de archivos |
| 8 | 🔍 **Regex** | Expresiones regulares |
| 9 | 🧠 **MemObj** | Gestión de memoria y objetos |
| 10 | 🔒 **Concur** | Primitivas de concurrencia |
| 11 | 🧵 **MT** | Rendimiento multi-hilo |
| 12 | 🌐 **Net** | Operaciones de red (reservado) |

### 🎓 ¿Por Qué Usar hbbench?

✅ **Comparar versiones del compilador** — Detectar regresiones de rendimiento  
✅ **Afinar tu hardware** — Encontrar configuraciones óptimas de CPU/RAM  
✅ **Validar despliegues** — Asegurar que los sistemas en producción cumplan los SLA  
✅ **Herramienta educativa** — Aprender las características internas de rendimiento de Harbour  
✅ **Pruebas de regresión** — Seguir el rendimiento a lo largo del tiempo con exportaciones CSV/JSON

---

## 2. 📦 Requisitos del Sistema

### 💻 Requisitos Mínimos

| Componente | Requisito |
|------------|-----------|
| 🖥️ **SO** | Windows 7/8/10/11 (32-bit o 64-bit) |
| 🧠 **CPU** | Cualquier procesador x86/x64 |
| 💾 **RAM** | 512 MB mínimo (2 GB recomendado) |
| 📂 **Disco** | 50 MB de espacio libre |
| 🔧 **Runtime** | Harbour 3.2.0dev (r2503200530+) |

### ⚠️ Notas Importantes

> 💡 **Consejo:** hbbench es una **aplicación de consola** — se ejecuta en el Símbolo del Sistema de Windows (cmd.exe) o PowerShell. No requiere interfaz gráfica.

> ⚠️ **Advertencia:** Los tests multi-hilo (categoría 11) requieren una compilación de Harbour con `HB_MULTITHREAD` habilitado. Si está deshabilitado, los tests MT reportarán graciosamente `0.000s`.

---

## 3. 🚀 Instalación

### 📥 Instalación Paso a Paso

**Paso 1:** 📂 Crear el directorio del proyecto
```cmd
mkdir C:\hbbench
cd C:\hbbench
```

**Paso 2:** 📋 Copiar el ejecutable
```
Colocar hbbench.exe en C:\hbbench\
```

**Paso 3:** 🗂️ El programa creará automáticamente estas carpetas en la primera ejecución:
```
C:\hbbench\
├── 📁 data\         ← Archivos temporales de tests DBF e I/O
├── 📁 logs\         ← Logs de ejecución (archivos .log)
└── 📁 reports\      ← Reportes exportados CSV/JSON
```

**Paso 4:** ✅ Verificar la instalación
```cmd
hbbench.exe --help
```

¡Si ves el mensaje de ayuda, la instalación fue exitosa! 🎉

---

## 4. 🏁 Inicio Rápido

### 🚀 Ejecuta Tu Primer Benchmark

```cmd
hbbench.exe
```

### 📊 Salida Esperada

```
09/24/2026 17:21:21 Windows 10 10.0.19045
Harbour 3.2.0dev (r2503200530)  Borland C++ 5.8.2 (32-bit)
LOOPS: 1000000
==============================================================================
TEST                                                        SECONDS
==============================================================================
[ 000: empty loop overhead ].....................................0.000
[ 001: local char assign ].......................................0.016
[ 002: local num assign ]........................................0.031
...
[ Total CPU time: ]..............................................8.984
[ Total real time: ].............................................9.422
```

### 🎯 ¿Qué Acaba de Pasar?

1. ✅ hbbench creó una tabla DBF temporal con 500 registros
2. ✅ Ejecutó **31 tests single-thread** a través de 10 categorías
3. ✅ Midió cada test contra una línea base de overhead (test 000)
4. ✅ Mostró los resultados en tiempo real
5. ✅ Guardó un log detallado en `logs\hbbench_YYYYMMDD_HHMMSS.log`

---

## 5. ⚙️ Opciones de Línea de Comandos

### 📋 Referencia Completa de Opciones

#### 🔧 Opciones Principales

| Opción | Descripción | Ejemplo |
|--------|-------------|---------|
| `--loops=<n>` | Establecer iteraciones por test | `--loops=500000` |
| `--only=<cat>` | Ejecutar solo una categoría | `--only=array` |
| `--exclude=<tests>` | Omitir tests específicos | `--exclude=500.501.502` |
| `--nolog` | No crear archivo de log | `--nolog` |
| `--noenv` | Ocultar encabezado de entorno | `--noenv` |
| `--help` o `-h` | Mostrar mensaje de ayuda | `--help` |

#### 🧵 Opciones Multi-Hilo

| Opción | Descripción | Ejemplo |
|--------|-------------|---------|
| `--mt` | Habilitar tests MT (ejecutar después de ST) | `--mt` |
| `--mt-only` | Ejecutar SOLO tests MT | `--mt-only` |
| `--threads=<n>` | Número de hilos (1-16) | `--threads=8` |

#### 💾 Opciones de Exportación

| Opción | Descripción | Ejemplo |
|--------|-------------|---------|
| `--csv` | Exportar resultados a CSV | `--csv` |
| `--json` | Exportar resultados a JSON | `--json` |
| `--output=<name>` | Nombre de archivo personalizado | `--output=mitest` |

### 🎯 Categorías Disponibles para `--only=`

```
vm        → Tests de Máquina Virtual (000-004)
string    → Operaciones de cadena (100-102)
array     → Operaciones de Array/Hash (200-204)
numdate   → Operaciones Numéricas/Fecha (300-301)
eval      → Evaluación de bloques de código (400-401)
dbf       → Operaciones de base de datos (500-502)
file      → Operaciones de E/S de archivos (600-601)
regex     → Expresiones regulares (700-701)
memobj    → Operaciones de Memoria/Objeto (800-804)
concur    → Primitivas de concurrencia (900-901)
```

---

## 6. 📊 Categorías de Tests Explicadas

### 🖥️ Categoría 1: VM (Tests 000-004)

Mide el rendimiento del **core de la máquina virtual**.

| Test | Descripción | Qué Revela |
|------|-------------|------------|
| 🔹 **000** | Overhead de loop vacío | Medición base |
| 🔹 **001** | Asignación local char | Velocidad de asignación de variables |
| 🔹 **002** | Asignación local numérica | Manejo numérico |
| 🔹 **003** | Eval de codeblock pre-compilado | Eficiencia de codeblocks |
| 🔹 **004** | Macro `&` directa | Overhead de compilación de macros |

> 💡 **Consejo:** El test 000 se resta de todos los demás tests para eliminar el overhead del loop.

### 🔤 Categoría 2: String (Tests 100-102)

| Test | Función | Caso de Uso |
|------|---------|-------------|
| 🔹 **100** | `Upper()` | Normalización de texto |
| 🔹 **101** | `Lower()` | Conversión de mayúsculas/minúsculas |
| 🔹 **102** | `AllTrim()` | Eliminación de espacios en blanco |

### 📚 Categoría 3: Array (Tests 200-204)

| Test | Descripción | Complejidad |
|------|-------------|-------------|
| 🔹 **200** | Asignación de elementos de array | ⭐ Básica |
| 🔹 **201** | Búsqueda `AScan()` | ⭐⭐ Búsqueda lineal |
| 🔹 **202** | Asignación de hash (1M iter) | ⭐⭐⭐ Operaciones de hash |
| 🔹 **203** | Test de estrés GC | ⭐⭐⭐⭐ Garbage collection |
| 🔹 **204** | Iteración de hash | ⭐⭐⭐ Recorrido de hash |

### 🗄️ Categoría 5: DBF (Tests 500-502)

> ⚠️ **Nota:** Estos tests requieren un archivo `data\bench.dbf` válido (creado automáticamente).

| Test | Operación | Registros |
|------|-----------|-----------|
| 🔹 **500** | `SEEK` indexado (CODE) | 50,000 búsquedas |
| 🔹 **501** | Recorrido secuencial | 500 iteraciones × 500 registros |
| 🔹 **502** | Append + unlock | 5,000 inserciones |

### 💾 Categoría 6: File (Tests 600-601)

| Test | Operación | Iteraciones |
|------|-----------|-------------|
| 🔹 **600** | `MemoWrit()` | 1,000 escrituras |
| 🔹 **601** | `MemoRead()` | 5,000 lecturas |

### 🧠 Categoría 8: MemObj (Tests 800-804)

| Test | Operación | Descripción |
|------|-----------|-------------|
| 🔹 **800** | Args de `ErrorNew` | Acceso a propiedades de objeto |
| 🔹 **801** | `hb_Base64Encode` | Velocidad de codificación |
| 🔹 **802** | `HB_Serialize` | Serialización binaria |
| 🔹 **803** | `HB_DeSerialize` | Deserialización binaria |
| 🔹 **804** | Roundtrip de serialización | Ciclo completo (200,000 iter) |

---

## 7. 🧵 Tests Multi-Hilo

### 🎯 Cómo Habilitar los Tests MT

```cmd
hbbench.exe --mt
```

### 📊 Suite de Tests MT (Tests 1000-1005)

| Test | Descripción | Qué Mide |
|------|-------------|----------|
| 🔹 **1000** | Creación + join de hilos | Overhead de hilos (5,000 hilos) |
| 🔹 **1001** | Contención de mutex | Lock/unlock bajo carga |
| 🔹 **1002** | Hash compartido MT | Acceso concurrente a hash |
| 🔹 **1003** | Trabajo paralelo | **Test de escalabilidad** (speedup) |
| 🔹 **1004** | Productor/Consumidor | Locking de grano fino |
| 🔹 **1005** | P/C por chunks | Procesamiento por bloques **optimizado** |

### 📈 Entendiendo el Speedup (Test 1003)

La métrica **speedup** compara el rendimiento single-thread vs multi-thread:

```
Speedup = ST_Baseline / MT_Time
```

| Speedup | Significado |
|---------|-------------|
| 🟢 **> 1.00x** | MT es MÁS RÁPIDO que ST (buen escalado) |
| 🟡 **= 1.00x** | Sin beneficio del multi-hilo |
| 🔴 **< 1.00x** | MT es MÁS LENTO (el overhead supera el beneficio) |

### 🔧 Configurando el Número de Hilos

```cmd
hbbench.exe --mt --threads=8
```

Rango válido: **1 a 16 hilos** (por defecto: 4)

---

## 8. 🔍 Entendiendo los Resultados

### 📊 Leyendo la Salida

```
[ 202: Hash assign (1000000 iter, pre-alloc) ]...0.500
│     │                                          │
│     │                                          └─ Tiempo en segundos
│     └─ Descripción del test
└─ ID del test
```

### 🎯 Métricas Clave

| Métrica | Significado |
|---------|-------------|
| **SECONDS** | Tiempo neto de ejecución (overhead restado) |
| **Total CPU time** | Suma de todos los tiempos de tests |
| **Total real time** | Tiempo transcurrido real (wall-clock) |
| **ST Baseline** | Tiempo de referencia para cálculo de speedup |

### 📈 Benchmarks de Rendimiento (Valores Típicos)

| Test | Rápido 🚀 | Promedio 🏃 | Lento 🐢 |
|------|-----------|-------------|----------|
| 001 (asignación char) | < 0.020s | 0.020-0.050s | > 0.050s |
| 202 (asignación hash) | < 0.400s | 0.400-0.600s | > 0.600s |
| 500 (búsqueda indexada) | < 0.100s | 0.100-0.200s | > 0.200s |
| 804 (roundtrip) | < 1.500s | 1.500-2.000s | > 2.000s |

---

## 9. 💾 Exportando Resultados

### 📄 Exportación CSV

```cmd
hbbench.exe --csv
```

**Salida:** `reports\bench_YYYYMMDD_HHMMSS.csv`

**Estructura CSV:**
```csv
test_id,test_name,category,seconds,loops,compiler
"001","local char assign",1,0.016000,1000000,"Borland C++ 5.8.2"
"202","Hash assign",3,0.500000,1000000,"Borland C++ 5.8.2"
```

### 📄 Exportación JSON

```cmd
hbbench.exe --json
```

**Salida:** `reports\bench_YYYYMMDD_HHMMSS.json`

**Estructura JSON:**
```json
{
  "benchmark": "hbbench",
  "version": "14.0-beta",
  "compiler": "Borland C++ 5.8.2",
  "date": "20260924 17:21:21",
  "results": [
    {
      "id": "001",
      "name": "local char assign",
      "category": 1,
      "seconds": 0.016000,
      "loops": 1000000
    }
  ]
}
```

### 🎯 Nombre de Archivo Personalizado

```cmd
hbbench.exe --csv --output=reports\mi_reporte_personalizado
```

Crea: `reports\mi_reporte_personalizado.csv`

---

## 10. 📂 Estructura de Archivos

### 📁 Después de la Primera Ejecución

```
C:\hbbench\
│
├── 📄 hbbench.exe              ← Ejecutable principal
│
├── 📁 data\
│   ├── 📄 bench.dbf            ← Tabla de test temporal
│   ├── 📄 bench.cdx            ← Índice estructural
│   └── 📄 bench_io.tmp         ← Archivo de test I/O
│
├── 📁 logs\
│   ├── 📄 hbbench_20260924_131137.log
│   ├── 📄 hbbench_20260924_160638.log
│   └── 📄 hbbench_20260924_172121.log
│
└── 📁 reports\
    ├── 📄 bench_20260924_172121.csv
    └── 📄 bench_20260924_172121.json
```

### 🗑️ Limpieza

hbbench **elimina automáticamente** los archivos temporales (`bench.dbf`, `bench.cdx`) después de la ejecución. Los archivos de log y reportes se **conservan** para análisis histórico.

---

## 11. 🛠️ Solución de Problemas

### ❌ Problema: "DBF bootstrap failed"

**Causa:** No se puede crear `data\bench.dbf`

**Soluciones:**
1. ✅ Asegurar que la carpeta `data\` tenga permisos de escritura
2. ✅ Verificar espacio en disco (mínimo 10 MB libres)
3. ✅ Cerrar otros programas que estén usando el archivo

### ❌ Problema: Los tests MT muestran "MT disabled in this build"

**Causa:** Harbour fue compilado sin soporte multi-hilo

**Solución:** Recompile Harbour con `HB_MULTITHREAD` habilitado, o ignore los tests MT.

### ❌ Problema: Algunos tests muestran `0.000s`

**Causa:** El test se completa más rápido que la resolución del temporizador

**Soluciones:**
1. ✅ Aumentar iteraciones: `--loops=5000000`
2. ✅ Ejecutar múltiples veces y promediar resultados
3. ✅ Usar `--only=<categoría>` para enfocarse en tests lentos

### ❌ Problema: Speedup < 1.00x en test 1003

**Causa:** El overhead de hilos supera el beneficio del paralelismo

**Esto es NORMAL** para cargas de trabajo pequeñas. Intente:
- Aumentar `--threads=8` o superior
- Ejecutar en una CPU multi-core
- Aceptar que algunas operaciones no se benefician del MT

### ❌ Problema: "Mutex creation failed"

**Causa:** Agotamiento de recursos del sistema

**Solución:** Reducir el número de hilos o cerrar otras aplicaciones.

---

## 12. 🎓 Ejemplos Prácticos

### 📝 Ejemplo 1: Test Rápido (Feedback Rápido)

```cmd
hbbench.exe --loops=100000 --only=vm
```

**Caso de uso:** Validación rápida después de cambios de código

### 📝 Ejemplo 2: Enfoque en Rendimiento de Base de Datos

```cmd
hbbench.exe --loops=50000 --only=dbf --csv
```

**Caso de uso:** Evaluar rendimiento DBF antes del despliegue en producción

### 📝 Ejemplo 3: Test de Escalabilidad Multi-Hilo

```cmd
hbbench.exe --mt-only --threads=8 --json
```

**Caso de uso:** Probar qué tan bien escala tu aplicación en sistemas multi-core

### 📝 Ejemplo 4: Excluir Tests Lentos

```cmd
hbbench.exe --exclude=804.502.1004
```

**Caso de uso:** Omitir tests conocidos como lentos para iteración más rápida

### 📝 Ejemplo 5: Benchmark Completo con Todas las Exportaciones

```cmd
hbbench.exe --mt --csv --json --output=reports\bench_completo
```

**Caso de uso:** Benchmark exhaustivo para documentación

### 📝 Ejemplo 6: Modo Silencioso (Sin Log)

```cmd
hbbench.exe --nolog --noenv --loops=500000
```

**Caso de uso:** Pipelines automatizados de CI/CD

---

## 🏁 Conclusión

🎉 **¡Felicitaciones!** Ahora tienes un conocimiento completo de hbbench v1.0.

### 🔑 Puntos Clave

✅ hbbench mide **12 categorías** de rendimiento de Harbour  
✅ Usa `--only=<cat>` para enfocarte en áreas específicas  
✅ Habilita `--mt` para análisis multi-hilo  
✅ Exporta a `--csv` o `--json` para seguimiento histórico  
✅ Revisa `logs\` para registros detallados de ejecución  
✅ Usa `reports\` para análisis de datos y comparaciones

### 📞 Soporte

- 📧 **Email:** marvijarrin@gmail.com
- 🌐 **Sitio Web:** badasystem.com
- 📅 **Versión:** 1.0 (Septiembre 2026)

---

**🎓 ¡Felices benchmarks! 🚀**