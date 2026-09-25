/*
 * BadaSystem
 * Program       : hbbench
 * Module        : hbbench.prg
 * Compiler      : Harbour 3.2.0dev Console
 * Author        : Marcos Jarrín
 * Email         : marvijarrin@gmail.com
 * Website       : badasystem.com
 * Date          : 20/09/2026
 * Update        : 24/09/2026
 * Rev           : 1.0
 * SPDX-License-Identifier: MIT
 *
 * Description:
 *   Harbour Benchmark Suite — Industrial Edition v1.0
 *   Measures performance across VM, String, Array, NumDate, Eval, DBF, 
 *   File, Regex, MemObj, Concurrency, and Multi-Thread categories.
 *
 */

#include "dbstruct.ch"
#include "fileio.ch"
#include "hbver.ch"

REQUEST DBFCDX

#define BENCH_VERSION      "1.0"
#define BENCH_NAME         "Harbour Benchmark Suite"
#define N_LOOPS_DEFAULT    1000000
#define ARR_LEN            16
#define DBF_FILE           "data" + hb_osPathSeparator() + "bench.dbf"
#define LOG_DIR            "logs"
#define REPORTS_DIR        "reports"

#define CAT_VM        1
#define CAT_STRING    2
#define CAT_ARRAY     3
#define CAT_NUMDATE   4
#define CAT_EVAL      5
#define CAT_DBF       6
#define CAT_FILE      7
#define CAT_REGEX     8
#define CAT_MEMOBJ    9
#define CAT_CONCUR    10
#define CAT_MT        11
#define CAT_NET       12

// ======================================================================
// MODULE-LEVEL STATIC VARIABLES
// ======================================================================
STATIC h_nLoops      := N_LOOPS_DEFAULT
STATIC h_cExclude    := ""
STATIC h_nCatMask    := -1
STATIC h_lNoLog      := .F.
STATIC h_lNoEnv      := .F.
STATIC h_cLogFile    := ""
STATIC h_lDbfReady   := .F.
STATIC h_hLang       := { => }
STATIC h_lExportCSV  := .F.
STATIC h_lExportJSON := .F.
STATIC h_cOutput     := ""

// MT-specific statics
STATIC h_lEnableMT     := .F.
STATIC h_lMTOnly       := .F.
STATIC h_nThreads      := 4
STATIC h_nOpsPerThread := 10000

#command ?           => BenchOut()
#command ? <xx,...>  => BenchOut(); BenchOut( <xx> )
#command ?? <xx,...> => BenchOut( <xx> )

/* ================================================================== */
/*  ENTRY POINT                                                       */
/* ================================================================== */

/// Main entry point for the benchmark suite.
/// Parses command-line arguments, initializes environment, and runs tests.
PROCEDURE Main( ... )
    LOCAL aParams   := hb_AParams()
    LOCAL lSyntax   := .F.
    LOCAL cParam    := ""
    LOCAL j         := 0
    LOCAL cOnly     := ""

    h_nLoops      := N_LOOPS_DEFAULT
    h_cExclude    := ""
    h_nCatMask    := -1
    h_lNoLog      := .F.
    h_lNoEnv      := .F.
    h_lExportCSV  := .F.
    h_lExportJSON := .F.
    h_cOutput     := ""

    HB_SetCodePage( "UTF8" )
    RddSetDefault( "DBFCDX" )
    SET CENTURY ON
    SET EXACT ON
    SET EXCLUSIVE OFF
    SET DELETED ON
    SET AUTOPEN ON
    SET AUTORDER TO 1
    SET SOFTSEEK ON

    h_hLang[ "app.title" ]    := BENCH_NAME
    h_hLang[ "msg.dbf.fail" ] := "DBF bootstrap failed"

    FOR j := 1 TO Len( aParams )
        cParam := Lower( AllTrim( aParams[ j ] ) )
        IF cParam == NIL
            cParam := ""
        ENDIF

        DO CASE
        CASE Left( cParam, 8 ) == "--loops="
            h_nLoops := Max( 1, Val( SubStr( cParam, 9 ) ) )

        CASE Left( cParam, 7 ) == "--only="
            cOnly := SubStr( cParam, 8 )
            DO CASE
            CASE cOnly == "vm"       ; h_nCatMask := CAT_VM
            CASE cOnly == "string"   ; h_nCatMask := CAT_STRING
            CASE cOnly == "array"    ; h_nCatMask := CAT_ARRAY
            CASE cOnly == "numdate"  ; h_nCatMask := CAT_NUMDATE
            CASE cOnly == "eval"     ; h_nCatMask := CAT_EVAL
            CASE cOnly == "dbf"      ; h_nCatMask := CAT_DBF
            CASE cOnly == "file"     ; h_nCatMask := CAT_FILE
            CASE cOnly == "regex"    ; h_nCatMask := CAT_REGEX
            CASE cOnly == "memobj"   ; h_nCatMask := CAT_MEMOBJ
            CASE cOnly == "concur"   ; h_nCatMask := CAT_CONCUR
            OTHERWISE
                h_nCatMask := Val( cOnly )
            ENDCASE

        CASE Left( cParam, 10 ) == "--threads="
            h_nThreads := Max( 1, Min( 16, Val( SubStr( cParam, 11 ) ) ) )

        CASE Left( cParam, 9 ) == "--mt-only"
            h_lMTOnly := .T.
            h_lEnableMT := .T.

        CASE cParam == "--mt"
            h_lEnableMT := .T.

        CASE Left( cParam, 10 ) == "--exclude="
            h_cExclude += StrTran( SubStr( cParam, 11 ), ".", " " ) + " "

        CASE Left( cParam, 9 ) == "--output="
            h_cOutput := SubStr( cParam, 10 )

        CASE cParam == "--csv"
            h_lExportCSV := .T.

        CASE cParam == "--json"
            h_lExportJSON := .T.

        CASE cParam == "--nolog"
            h_lNoLog := .T.

        CASE cParam == "--noenv"
            h_lNoEnv := .T.

        CASE cParam == "--help" .OR. cParam == "-h"
            ShowUsage()
            RETURN

        OTHERWISE
            lSyntax := .T.
        ENDCASE
    NEXT

    IF lSyntax
        ShowUsage()
        RETURN
    ENDIF

    IF ! IsDir( "data" )
        DirMake( "data" )
    ENDIF
    IF ! IsDir( LOG_DIR )
        DirMake( LOG_DIR )
    ENDIF
    IF ! IsDir( REPORTS_DIR )
        DirMake( REPORTS_DIR )
    ENDIF

    h_cLogFile := LOG_DIR + hb_osPathSeparator() + ;
                 "hbbench_" + DToS( Date() ) + "_" + ;
                 StrTran( Time(), ":", "" ) + ".log"

    IF ! h_lNoLog
        SET ALTERNATE TO ( h_cLogFile ) ADDITIVE
        SET ALTERNATE ON
    ENDIF

    IF h_nCatMask == -1 .OR. h_nCatMask == CAT_DBF
        BootstrapBenchTable()
    ENDIF

    // Configure MT settings if enabled
    IF h_lEnableMT
        SetMTThreadCount( h_nThreads )
        SetMTOpsPerThread( h_nOpsPerThread )
    ENDIF

    IF h_lMTOnly
        RunMTBenchmark()
    ELSE
        RunBenchmark()
        IF h_lEnableMT
            QOut()
            QOut( Replicate( "=", 78 ) )
            QOut( "MULTI-THREAD TESTS" )
            QOut( Replicate( "=", 78 ) )
            RunMTBenchmark()
        ENDIF
    ENDIF

    IF h_lDbfReady
        dbf_ensure_closed()
        IF File( DBF_FILE )
            FErase( DBF_FILE )
            FErase( Left( DBF_FILE, Len( DBF_FILE ) - 4 ) + ".cdx" )
        ENDIF
    ENDIF

    IF ! h_lNoLog
        SET ALTERNATE OFF
        SET ALTERNATE TO
    ENDIF

RETURN

/* ================================================================== */
/*  USAGE                                                             */
/* ================================================================== */

/// Displays command-line usage information.
STATIC PROCEDURE ShowUsage()
    QOut( T( "app.title" ) + " v" + BENCH_VERSION )
    QOut()
    QOut( "Usage: hbbench [options]" )
    QOut()
    QOut( "Core Options:" )
    QOut( "  --loops=<n>         Iterations per test (default: 1000000)" )
    QOut( "  --only=<cat>        Run only one category:" )
    QOut( "                      vm|string|array|numdate|eval|dbf|file|regex|memobj|concur" )
    QOut( "  --exclude=<tests>   Exclude tests (e.g. 500.501.502)" )
    QOut( "  --nolog             Suppress log file generation" )
    QOut( "  --noenv             Suppress environment header" )
    QOut( "  --help              Show this help" )
    QOut()
    QOut( "Export Options :" )
    QOut( "  --csv               Export results to reports/bench_<date>.csv" )
    QOut( "  --json              Export results to reports/bench_<date>.json" )
    QOut( "  --output=<name>     Custom base name for export files" )
    QOut()
    QOut( "Multi-Thread Options :" )
    QOut( "  --mt                Enable multi-thread tests (category 10xx)" )
    QOut( "  --threads=<n>       Number of threads for MT tests (1-16, default: 4)" )
    QOut( "  --mt-only           Run ONLY multi-thread tests" )
    QOut()
RETURN

/* ================================================================== */
/*  OUTPUT HELPER                                                     */
/* ================================================================== */

/// Helper procedure for console output, handling variable parameter counts.
/// @param cText Text to output (optional).
STATIC PROCEDURE BenchOut( cText )
    LOCAL nPCount := PCount()
    IF nPCount == 0
        QOut()
    ELSE
        QOut( cText )
    ENDIF
RETURN

/* ================================================================== */
/*  TRANSLATION (zero-dependency)                                     */
/* ================================================================== */

/// Retrieves a translated string by key. Falls back to the key itself if not found.
/// @param cKey Translation key.
/// @return Translated string or the original key.
STATIC FUNCTION T( cKey )
    IF ValType( h_hLang ) == "H" .AND. hb_HHasKey( h_hLang, cKey )
        RETURN h_hLang[ cKey ]
    ENDIF
RETURN cKey

/* ================================================================== */
/*  DBF BOOTSTRAP                                                     */
/* ================================================================== */

/// Creates and initializes the benchmark DBF table with structural indexes.
STATIC PROCEDURE BootstrapBenchTable()
    LOCAL aStruct := {}
    LOCAL nIdx    := 0

    FIELD ID, CODE, NAME, REG_DATE IN bench

    IF File( DBF_FILE )
        FErase( DBF_FILE )
        FErase( Left( DBF_FILE, Len( DBF_FILE ) - 4 ) + ".cdx" )
    ENDIF

    AAdd( aStruct, { "ID",         "N", 10, 0 } )
    AAdd( aStruct, { "CODE",       "C", 15, 0 } )
    AAdd( aStruct, { "NAME",       "C", 60, 0 } )
    AAdd( aStruct, { "AMOUNT",     "N", 12, 2 } )
    AAdd( aStruct, { "REG_DATE",   "D",  8, 0 } )
    AAdd( aStruct, { "CREATED_AT", "D",  8, 0 } )
    AAdd( aStruct, { "IS_DELETED", "L",  1, 0 } )

    IF ! dbCreate( DBF_FILE, aStruct, "DBFCDX" )
        QOut( T( "msg.dbf.fail" ) + ": dbCreate failed" )
        RETURN
    ENDIF

    USE ( DBF_FILE ) SHARED NEW VIA "DBFCDX" ALIAS bench
    IF NetErr() .OR. SELECT( "bench" ) == 0
        QOut( T( "msg.dbf.fail" ) + ": USE failed" )
        RETURN
    ENDIF

    INDEX ON STR( ID, 10, 0 ) TAG ID
    INDEX ON CODE             TAG CODE
    INDEX ON Upper( NAME )    TAG NAME
    INDEX ON DTOS( REG_DATE ) TAG REGDATE

    nIdx := bench->( OrdCount() )
    IF nIdx != 4
        QOut( "ERROR: Expected 4 indexes, got " + LTrim( Str( nIdx ) ) )
        bench->( dbCloseArea() )
        RETURN
    ENDIF

    SeedBenchTable()

    IF SELECT( "bench" ) > 0
        bench->( dbCloseArea() )
    ENDIF
RETURN

/// Populates the benchmark table with seed data.
STATIC PROCEDURE SeedBenchTable()
    LOCAL nI      := 0
    LOCAL nRecs   := 500
    LOCAL lLocked := .F.
    LOCAL nActual := 0

    FOR nI := 1 TO nRecs
        lLocked := .F.
        IF NetAppend( 3 )
            lLocked := .T.
            bench->ID          := nI
            bench->CODE        := "C" + StrZero( nI, 6 )
            bench->NAME        := "Record_" + StrZero( nI, 6 )
            bench->AMOUNT      := hb_RandomInt( 100, 99999 ) + hb_Random()
            bench->REG_DATE    := Date() - hb_RandomInt( 0, 3650 )
            bench->CREATED_AT  := Date()
            bench->IS_DELETED  := .F.
        ENDIF
        IF lLocked
            dbUnlock()
            lLocked := .F.
        ENDIF
    NEXT

    dbCommit()
    nActual := bench->( RecCount() )

    IF nActual != nRecs
        QOut( "WARNING: Expected " + LTrim( Str( nRecs ) ) + ;
              ", got " + LTrim( Str( nActual ) ) )
    ENDIF
RETURN

/// Ensures the benchmark DBF is open and ready for operations.
STATIC PROCEDURE dbf_ensure_open()
    LOCAL nIdx := 0
    IF ! h_lDbfReady
        IF File( DBF_FILE )
            USE ( DBF_FILE ) SHARED NEW VIA "DBFCDX" ALIAS bench
            IF SELECT( "bench" ) > 0
                nIdx := bench->( OrdCount() )
                IF nIdx >= 2
                    h_lDbfReady := .T.
                ELSE
                    bench->( dbCloseArea() )
                ENDIF
            ENDIF
        ENDIF
    ENDIF
RETURN

/// Ensures the benchmark DBF is properly closed and unlocked.
STATIC PROCEDURE dbf_ensure_closed()
    IF h_lDbfReady .AND. SELECT( "bench" ) > 0
        bench->( dbUnlock() )
        bench->( dbCloseArea() )
        h_lDbfReady := .F.
    ENDIF
RETURN

/* ================================================================== */
/*  FORMATTERS                                                        */
/* ================================================================== */

/// Formats a test result for console output.
/// @param aResult Array containing { cDescription, nTime, nCategory }.
/// @param nOverhead Overhead time to subtract.
/// @return Formatted string.
STATIC FUNCTION FormatResult( aResult, nOverhead )
    LOCAL cDesc := PadR( "[ " + Left( aResult[ 1 ], 56 ) + " ]", 60, "." )
    LOCAL nTime := Max( 0, aResult[ 2 ] - nOverhead )
RETURN cDesc + StrTran( Str( nTime, 10, 3 ), " ", "." )

/// Checks if a test category is allowed based on the current mask.
/// @param nCat Category to check.
/// @return .T. if allowed, .F. otherwise.
STATIC FUNCTION CategoryAllowed( nCat )
    IF h_nCatMask == -1
        RETURN .T.
    ENDIF
RETURN ( h_nCatMask == nCat )

/* ================================================================== */
/*  BENCHMARK RUNNER                                                  */
/* ================================================================== */

/// Executes the single-threaded benchmark tests.
STATIC PROCEDURE RunBenchmark()
    LOCAL aTests     := {}
    LOCAL nOverhead  := 0
    LOCAL aResult    := {}
    LOCAL nI         := 0
    LOCAL cNum       := ""
    LOCAL nStart     := 0
    LOCAL nTotalCPU  := 0
    LOCAL nTotalReal := 0
    LOCAL aResults   := {}
    LOCAL cBaseName  := ""

    IF h_nLoops == NIL .OR. h_nLoops <= 0
        h_nLoops := 10000
    ENDIF

    aTests := BuildTestRegistry()
    aResult   := t000()
    nOverhead := aResult[ 2 ]

    IF ! h_lNoEnv
        QOut( Date(), Time(), OS() )
    ENDIF

    QOut( Version() + "  " + hb_Compiler() )
    QOut( "LOOPS:", LTrim( Str( h_nLoops ) ) )
    IF ! Empty( h_cExclude )
        QOut( "EXCLUDED:", h_cExclude )
    ENDIF
    QOut()
    QOut( Replicate( "=", 78 ) )
    QOut( PadR( "TEST", 60 ) + "SECONDS" )
    QOut( Replicate( "=", 78 ) )

    nStart    := Seconds()
    nTotalCPU := hb_SecondsCPU()

    FOR nI := 1 TO Len( aTests )
        cNum := aTests[ nI ][ 1 ]
        IF nI % 5 == 0
            QOut( "Running test", cNum, "...", hb_SecondsCPU() )
        ENDIF

        IF ( cNum + " " ) $ h_cExclude
            LOOP
        ENDIF

        IF ! CategoryAllowed( aTests[ nI ][ 3 ] )
            LOOP
        ENDIF

        aResult := Eval( aTests[ nI ][ 2 ] )
        QOut( FormatResult( aResult, nOverhead ) )
        AAdd( aResults, { cNum, aResult[ 1 ], Max( 0, aResult[ 2 ] - nOverhead ), aTests[ nI ][ 3 ], h_nLoops } )
    NEXT

    nTotalCPU  := hb_SecondsCPU() - nTotalCPU
    nTotalReal := Seconds() - nStart

    QOut( Replicate( "=", 78 ) )
    QOut( FormatResult( { "Total CPU time:",  nTotalCPU  }, 0 ) )
    QOut( FormatResult( { "Total real time:", nTotalReal }, 0 ) )
    QOut()
    QOut( "Log file: " + h_cLogFile )

    IF h_lExportCSV .OR. h_lExportJSON
        IF Empty( h_cOutput )
            cBaseName := REPORTS_DIR + hb_osPathSeparator() + ;
                         "bench_" + DToS( Date() ) + "_" + ;
                         StrTran( Time(), ":", "" )
        ELSE
            cBaseName := h_cOutput
        ENDIF

        IF h_lExportCSV
            ExportResultsToCSV( aResults, cBaseName + ".csv" )
        ENDIF
        IF h_lExportJSON
            ExportResultsToJSON( aResults, cBaseName + ".json" )
        ENDIF
    ENDIF
RETURN

/* ================================================================== */
/*  TEST REGISTRY                                                     */
/* ================================================================== */

/// Builds the registry of all single-threaded benchmark tests.
/// @return Array of test definitions.
STATIC FUNCTION BuildTestRegistry()
    LOCAL a := {}

    AAdd( a, { "000", { || t000() }, CAT_VM } )
    AAdd( a, { "001", { || t001() }, CAT_VM } )
    AAdd( a, { "002", { || t002() }, CAT_VM } )
    AAdd( a, { "003", { || t003() }, CAT_VM } )
    AAdd( a, { "004", { || t004() }, CAT_VM } )
    AAdd( a, { "100", { || t100() }, CAT_STRING } )
    AAdd( a, { "101", { || t101() }, CAT_STRING } )
    AAdd( a, { "102", { || t102() }, CAT_STRING } )
    AAdd( a, { "200", { || t200() }, CAT_ARRAY } )
    AAdd( a, { "201", { || t201() }, CAT_ARRAY } )
    AAdd( a, { "202", { || t202() }, CAT_ARRAY } )
    AAdd( a, { "203", { || t203() }, CAT_ARRAY } )
    AAdd( a, { "204", { || t204() }, CAT_ARRAY } )
    AAdd( a, { "300", { || t300() }, CAT_NUMDATE } )
    AAdd( a, { "301", { || t301() }, CAT_NUMDATE } )
    AAdd( a, { "400", { || t400() }, CAT_EVAL } )
    AAdd( a, { "401", { || t401() }, CAT_EVAL } )
    AAdd( a, { "500", { || t500() }, CAT_DBF } )
    AAdd( a, { "501", { || t501() }, CAT_DBF } )
    AAdd( a, { "502", { || t502() }, CAT_DBF } )
    AAdd( a, { "600", { || t600() }, CAT_FILE } )
    AAdd( a, { "601", { || t601() }, CAT_FILE } )
    AAdd( a, { "700", { || t700() }, CAT_REGEX } )
    AAdd( a, { "701", { || t701() }, CAT_REGEX } )
    AAdd( a, { "800", { || t800() }, CAT_MEMOBJ } )
    AAdd( a, { "801", { || t801() }, CAT_MEMOBJ } )
    AAdd( a, { "802", { || t802() }, CAT_MEMOBJ } )
    AAdd( a, { "803", { || t803() }, CAT_MEMOBJ } )
    AAdd( a, { "804", { || t804() }, CAT_MEMOBJ } )
    AAdd( a, { "900", { || t900() }, CAT_CONCUR } )
    AAdd( a, { "901", { || t901() }, CAT_CONCUR } )

RETURN a

/* ================================================================== */
/*  TESTS — CAT_VM (0)                                                */
/* ================================================================== */

FUNCTION t000()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL

    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        x := 0
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "000: empty loop overhead", time, CAT_VM }

FUNCTION t001()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL
    LOCAL L_C  := ""

    L_C := DToS( Date() )
    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        x := L_C
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "001: local char assign", time, CAT_VM }

FUNCTION t002()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL
    LOCAL L_N  := 0

    L_N := 112345.67
    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        x := L_N
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "002: local num assign", time, CAT_VM }

FUNCTION t003()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL
    LOCAL bc   := { || 100 + 200 + 300 }

    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        x := Eval( bc )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "003: Eval pre-compiled codeblock", time, CAT_VM }

FUNCTION t004()
    LOCAL time        := 0
    LOCAL i           := 0
    LOCAL x           := NIL
    LOCAL cExpr       := "100 + 200 + 300"
    LOCAL nActualLoop := Min( h_nLoops, 100000 )

    time := hb_SecondsCPU()
    FOR i := 1 TO nActualLoop
        x := &cExpr
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "004: Direct & macro (literal overhead)", time, CAT_VM }

/* ================================================================== */
/*  TESTS — CAT_STRING (1)                                            */
/* ================================================================== */

FUNCTION t100()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL
    LOCAL s    := ""

    s := "Hello, Harbour World!"
    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        x := Upper( s )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "100: Upper()", time, CAT_STRING }

FUNCTION t101()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL
    LOCAL s    := ""

    s := "Hello, Harbour World!"
    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        x := Lower( s )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "101: Lower()", time, CAT_STRING }

FUNCTION t102()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL
    LOCAL s    := ""

    s := "  padded  "
    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        x := AllTrim( s )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "102: AllTrim()", time, CAT_STRING }

/* ================================================================== */
/*  TESTS — CAT_ARRAY (2)                                             */
/* ================================================================== */

FUNCTION t200()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL
    LOCAL a    := {}

    a := Array( ARR_LEN )
    AFill( a, 0 )
    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        a[ ( i % ARR_LEN ) + 1 ] := i
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "200: Array assign", time, CAT_ARRAY }

FUNCTION t201()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL
    LOCAL a    := {}

    a := Array( ARR_LEN )
    AFill( a, 0 )
    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        AScan( a, i % ARR_LEN )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "201: AScan()", time, CAT_ARRAY }

FUNCTION t202()
    LOCAL time      := 0
    LOCAL i         := 0
    LOCAL x         := NIL
    LOCAL h         := { => }
    LOCAL nHashLoop := Min( h_nLoops, 1000000 )
    LOCAL cKey      := ""

    hb_HAllocate( h, nHashLoop )
    time := hb_SecondsCPU()
    FOR i := 1 TO nHashLoop
        cKey := Str( i, 10, 0 )
        h[ cKey ] := i
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "202: Hash assign (" + LTrim( Str( nHashLoop ) ) + " iter, pre-alloc)", time, CAT_ARRAY }

FUNCTION t203()
    LOCAL time      := 0
    LOCAL i         := 0
    LOCAL aOuter    := {}
    LOCAL aInner    := {}
    LOCAL nLoops    := Min( h_nLoops, 100000 )
    LOCAL nChecksum := 0

    time := hb_SecondsCPU()
    FOR i := 1 TO nLoops
        aOuter := Array( 200 )
        aInner := Array( 20 )
        AFill( aInner, i )
        aOuter[ 1 ] := aInner
        nChecksum += i
        aOuter := NIL
        aInner := NIL
        IF i % 10000 == 0
            hb_GCAll()
        ENDIF
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "203: GC stress (" + LTrim( Str( nLoops ) ) + " nested arrays, checksum=" + LTrim( Str( nChecksum ) ) + ")", time, CAT_ARRAY }

FUNCTION t204()
    LOCAL time       := 0
    LOCAL i          := 0
    LOCAL h          := { => }
    LOCAL aKeys      := {}
    LOCAL nHashLoops := Min( h_nLoops, 200000 )
    LOCAL nSum       := 0
    LOCAL cKey       := ""

    hb_HAllocate( h, nHashLoops )
    FOR i := 1 TO nHashLoops
        h[ Str( i, 8, 0 ) ] := i
    NEXT

    time := hb_SecondsCPU()
    aKeys := HGetKeys( h )
    FOR i := 1 TO Len( aKeys )
        cKey := aKeys[ i ]
        IF hb_HHasKey( h, cKey )
            nSum += h[ cKey ]
        ENDIF
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "204: Hash iteration (" + LTrim( Str( nHashLoops ) ) + " keys, sum=" + LTrim( Str( nSum ) ) + ")", time, CAT_ARRAY }

/* ================================================================== */
/*  TESTS — CAT_NUMDATE (3)                                           */
/* ================================================================== */

FUNCTION t300()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL

    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        x := Round( i / 1000, 2 )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "300: Round()", time, CAT_NUMDATE }

FUNCTION t301()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL
    LOCAL d    := Date()

    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        x := d - ( i % 10000 )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "301: Date math", time, CAT_NUMDATE }

/* ================================================================== */
/*  TESTS — CAT_EVAL (4)                                              */
/* ================================================================== */

FUNCTION t400()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL

    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        Eval( { | n | n % ARR_LEN }, i )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "400: Eval block", time, CAT_EVAL }

FUNCTION t401()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL
    LOCAL bc   := NIL

    bc := { | n | n * n }
    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        Eval( bc, i )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "401: Eval var block", time, CAT_EVAL }

/* ================================================================== */
/*  TESTS — CAT_DBF (5)                                               */
/* ================================================================== */

FUNCTION t500()
    LOCAL time    := 0
    LOCAL i       := 0
    LOCAL x       := NIL
    LOCAL cSeek   := ""
    LOCAL lFound  := .F.
    LOCAL nCount  := 0
    LOCAL lOpened := .F.

    IF ! h_lDbfReady
        dbf_ensure_open()
        lOpened := .T.
    ENDIF

    IF ! h_lDbfReady
        RETURN { "500: DBF open failed", 0, CAT_DBF }
    ENDIF

    IF bench->( OrdCount() ) < 2
        IF lOpened
            dbf_ensure_closed()
        ENDIF
        RETURN { "500: Index CODE not found", 0, CAT_DBF }
    ENDIF

    bench->( DbSetOrder( 2 ) )
    time := hb_SecondsCPU()
    nCount := Min( h_nLoops, 50000 )

    FOR i := 1 TO nCount
        cSeek := "C" + StrZero( ( i % 500 ) + 1, 6 )
        lFound := bench->( dbSeek( cSeek ) )
        IF lFound
            x := bench->CODE
        ELSE
            EXIT
        ENDIF
    NEXT
    time := hb_SecondsCPU() - time

    IF lOpened
        dbf_ensure_closed()
    ENDIF
RETURN { "500: indexed seek (CODE) " + LTrim( Str( nCount ) ) + " iter", time, CAT_DBF }

FUNCTION t501()
    LOCAL time    := 0
    LOCAL i       := 0
    LOCAL x       := NIL
    LOCAL nTotal  := 0
    LOCAL nCount  := 0
    LOCAL lOpened := .F.

    IF ! h_lDbfReady
        dbf_ensure_open()
        lOpened := .T.
    ENDIF

    IF ! h_lDbfReady
        RETURN { "501: DBF open failed", 0, CAT_DBF }
    ENDIF

    bench->( DbSetOrder( 0 ) )
    time := hb_SecondsCPU()
    nCount := Min( h_nLoops, 500 )

    FOR i := 1 TO nCount
        bench->( dbGoTop() )
        nTotal := 0
        DO WHILE ! bench->( EOF() )
            nTotal += bench->AMOUNT
            bench->( dbSkip() )
        ENDDO
        x := nTotal
    NEXT
    time := hb_SecondsCPU() - time

    IF lOpened
        dbf_ensure_closed()
    ENDIF
RETURN { "501: sequential scan (500 recs) " + LTrim( Str( nCount ) ) + " iter", time, CAT_DBF }

FUNCTION t502()
    LOCAL time     := 0
    LOCAL i        := 0
    LOCAL x        := NIL
    LOCAL lLocked  := .F.
    LOCAL nCount   := 0
    LOCAL nAttempt := 0
    LOCAL lOpened  := .F.

    IF ! h_lDbfReady
        dbf_ensure_open()
        lOpened := .T.
    ENDIF

    IF ! h_lDbfReady
        RETURN { "502: DBF open failed", 0, CAT_DBF }
    ENDIF

    time := hb_SecondsCPU()
    nCount := Min( h_nLoops, 5000 )

    FOR i := 1 TO nCount
        lLocked := .F.
        FOR nAttempt := 1 TO 3
            IF NetAppend( 1 )
                lLocked := .T.
                EXIT
            ENDIF
            hb_IdleSleep( 0.1 )
        NEXT
        IF lLocked
            bench->ID   := 90000 + i
            bench->CODE := "Z" + StrZero( i, 6 )
            dbUnlock()
        ENDIF
    NEXT
    dbCommit()
    time := hb_SecondsCPU() - time

    IF lOpened
        dbf_ensure_closed()
    ENDIF
RETURN { "502: append + unlock " + LTrim( Str( nCount ) ) + " iter", time, CAT_DBF }

/* ================================================================== */
/*  TESTS — CAT_FILE (6)                                              */
/* ================================================================== */

FUNCTION t600()
    LOCAL time    := 0
    LOCAL i       := 0
    LOCAL x       := NIL
    LOCAL cFile   := ""
    LOCAL nIoLoop := Min( h_nLoops, 1000 )

    cFile := "data" + hb_osPathSeparator() + "bench_io.tmp"
    time := hb_SecondsCPU()
    FOR i := 1 TO nIoLoop
        MemoWrit( cFile, "line " + Str( i ) + hb_eol() )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "600: MemoWrit (" + LTrim( Str( nIoLoop ) ) + " iter)", time, CAT_FILE }

FUNCTION t601()
    LOCAL time    := 0
    LOCAL i       := 0
    LOCAL x       := NIL
    LOCAL cFile   := ""
    LOCAL nIoLoop := Min( h_nLoops, 5000 )

    cFile := "data" + hb_osPathSeparator() + "bench_io.tmp"
    MemoWrit( cFile, Replicate( "x", 10000 ) )
    time := hb_SecondsCPU()
    FOR i := 1 TO nIoLoop
        x := MemoRead( cFile )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "601: MemoRead (" + LTrim( Str( nIoLoop ) ) + " iter)", time, CAT_FILE }

/* ================================================================== */
/*  TESTS — CAT_REGEX (7)                                             */
/* ================================================================== */

FUNCTION t700()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL
    LOCAL c    := ""

    c := "user@example.com"
    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        x := hb_regexLike( "^[^@]+@[^@]+\.[^@]+$", c )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "700: hb_regexLike email", time, CAT_REGEX }

FUNCTION t701()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL
    LOCAL c    := ""

    c := "Order #12345 total 99.99 USD"
    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        x := hb_RegExMatch( "\d+", c )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "701: hb_RegExMatch digits", time, CAT_REGEX }

/* ================================================================== */
/*  TESTS — CAT_MEMOBJ (8)                                            */
/* ================================================================== */

FUNCTION t800()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL
    LOCAL o    := NIL

    o := ErrorNew()
    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        x := o:Args
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "800: ErrorNew args", time, CAT_MEMOBJ }

FUNCTION t801()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL
    LOCAL c    := ""

    c := "Hello Harbour"
    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        x := hb_Base64Encode( c )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "801: hb_Base64Encode", time, CAT_MEMOBJ }

FUNCTION t802()
    LOCAL time        := 0
    LOCAL i           := 0
    LOCAL hData       := { => }
    LOCAL cBinary     := ""
    LOCAL nActualLoop := Min( h_nLoops, 100000 )

    hData[ "name" ]    := "Harbour Benchmark"
    hData[ "version" ] := "14.0"
    hData[ "payload" ] := Array( 100 )
    AFill( hData[ "payload" ], 12345 )

    time := hb_SecondsCPU()
    FOR i := 1 TO nActualLoop
        cBinary := HB_Serialize( hData )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "802: HB_Serialize (complex hash)", time, CAT_MEMOBJ }

FUNCTION t803()
    LOCAL time        := 0
    LOCAL i           := 0
    LOCAL hData       := { => }
    LOCAL cBinary     := ""
    LOCAL hOut        := NIL
    LOCAL nActualLoop := Min( h_nLoops, 100000 )

    hData[ "test" ] := "serialization"
    hData[ "data" ] := Array( 50 )
    cBinary := HB_Serialize( hData )

    time := hb_SecondsCPU()
    FOR i := 1 TO nActualLoop
        hOut := HB_DeSerialize( cBinary )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "803: HB_DeSerialize", time, CAT_MEMOBJ }

FUNCTION t804()
    LOCAL time        := 0
    LOCAL i           := 0
    LOCAL hData       := { => }
    LOCAL cBinary     := ""
    LOCAL nActualLoop := Min( h_nLoops, 200000 )
    LOCAL nKey        := 0

    // Create larger hash for meaningful benchmark
    FOR nKey := 1 TO 50
        hData[ "key_" + StrZero( nKey, 3 ) ] := hb_RandomInt( 1, 99999 )
    NEXT

    time := hb_SecondsCPU()
    FOR i := 1 TO nActualLoop
        cBinary := HB_Serialize( hData )
        hData := HB_DeSerialize( cBinary )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "804: Serialize+DeSerialize roundtrip (" + LTrim( Str( nActualLoop ) ) + " iter)", time, CAT_MEMOBJ }

/* ================================================================== */
/*  TESTS — CAT_CONCUR (9)                                            */
/* ================================================================== */

FUNCTION t900()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL x    := NIL

    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        x := hb_mutexCreate()
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "900: hb_mutexCreate", time, CAT_CONCUR }

FUNCTION t901()
    LOCAL time := 0
    LOCAL i    := 0
    LOCAL m    := NIL

    m := hb_mutexCreate()
    time := hb_SecondsCPU()
    FOR i := 1 TO h_nLoops
        hb_mutexLock( m )
        hb_mutexUnlock( m )
    NEXT
    time := hb_SecondsCPU() - time
RETURN { "901: mutex lock/unlock", time, CAT_CONCUR }

/* ================================================================== */
/*  MT BENCHMARK RUNNER & BASELINE CALCULATOR                         */
/* ================================================================== */

/// Calculates the single-thread baseline time for Test 1003.
/// Ensures the exact same workload is measured for accurate speedup calculation.
/// @return Execution time in seconds.
STATIC FUNCTION CalculateStBaseline()
    LOCAL nTime      := 0
    LOCAL nArraySize := 150000
    LOCAL aWorkArray := {}
    LOCAL i          := 0
    LOCAL nSum       := 0
    LOCAL nVal       := 0

    // Execute SAME work as test 1003 but single-threaded
    aWorkArray := Array( nArraySize )
    AFill( aWorkArray, 42 )

    nTime := hb_SecondsCPU()
    FOR i := 1 TO nArraySize
        nVal := aWorkArray[ i ]
        nSum += ( nVal * nVal ) % 10000
    NEXT
    nTime := hb_SecondsCPU() - nTime

RETURN nTime

/// Executes the multi-threaded benchmark tests.
STATIC PROCEDURE RunMTBenchmark()
    LOCAL aTests     := {}
    LOCAL nOverhead  := 0
    LOCAL aResult    := {}
    LOCAL nI         := 0
    LOCAL cNum       := ""
    LOCAL nStart     := 0
    LOCAL nTotalCPU  := 0
    LOCAL nTotalReal := 0
    LOCAL nStBaseline:= 0

    // Calculate ST baseline for Speedup
    nStBaseline := CalculateStBaseline()
    SetMTStTime( nStBaseline )

    aTests := BuildMTTestRegistry()
    aResult := t000()
    nOverhead := aResult[ 2 ]

    QOut( "Threads:", LTrim( Str( h_nThreads ) ) )
    QOut( "Ops/Thread:", LTrim( Str( h_nOpsPerThread ) ) )
    QOut( "ST Baseline:", Str( nStBaseline, 8, 3 ) + "s" )
    QOut()
    QOut( PadR( "TEST", 70 ) + "SECONDS" )
    QOut( Replicate( "-", 78 ) )

    nStart := Seconds()
    nTotalCPU := hb_SecondsCPU()

    FOR nI := 1 TO Len( aTests )
        cNum := aTests[ nI ][ 1 ]
        IF nI % 3 == 0
            QOut( "Running MT test", cNum, "...", hb_SecondsCPU() )
        ENDIF

        aResult := Eval( aTests[ nI ][ 2 ] )
        QOut( FormatResult( aResult, nOverhead ) )
    NEXT

    nTotalCPU := hb_SecondsCPU() - nTotalCPU
    nTotalReal := Seconds() - nStart

    QOut( Replicate( "-", 78 ) )
    QOut( FormatResult( { "MT Total CPU time:", nTotalCPU }, 0 ) )
    QOut( FormatResult( { "MT Total real time:", nTotalReal }, 0 ) )
    QOut()
RETURN

/* ================================================================== */
/*  END OF FILE                                                       */
/* ================================================================== */