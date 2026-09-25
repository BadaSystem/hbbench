/*
 * BadaSystem
 * Program       : hbbench
 * Module        : hbbench_mt.prg
 * Compiler      : Harbour 3.2.0dev Console
 * Author        : Marcos Jarrín
 * Email         : marvijarrin@gmail.com
 * Website       : badasystem.com
 * Date          : 22/09/2026
 * Update        : 24/09/2026
 * Rev           : 1.0
 * SPDX-License-Identifier: MIT
 *
 * Description:
 *   Multi-Thread benchmark tests for hbbench v14.0-beta.
 *   Measures real concurrency performance: thread creation, mutex contention,
 *   parallel independent work, and producer/consumer coordination.
 *
 */

#include "hbver.ch"

#define CAT_MT 11

// ======================================================================
// MODULE-LEVEL STATIC VARIABLES
// ======================================================================
STATIC mt_nThreadCount  := 4
STATIC mt_nOpsPerThread := 1000
STATIC mt_nStTime       := 0
STATIC mt_aWorkArray    := {}

// ======================================================================
// MT CONFIGURATION PROCEDURES
// ======================================================================

/// Sets the number of threads to be used in MT tests.
/// @param nCount Number of threads (1 to 16).
PROCEDURE SetMTThreadCount( nCount )
    IF ValType( nCount ) == "N" .AND. nCount > 0 .AND. nCount <= 16
        mt_nThreadCount := nCount
    ENDIF
RETURN

/// Sets the number of operations each thread should perform.
/// @param nOps Number of operations per thread (1 to 100000).
PROCEDURE SetMTOpsPerThread( nOps )
    IF ValType( nOps ) == "N" .AND. nOps > 0 .AND. nOps <= 100000
        mt_nOpsPerThread := nOps
    ENDIF
RETURN

/// Sets the single-thread baseline time for Speedup calculation.
/// @param nTime Baseline execution time in seconds.
PROCEDURE SetMTStTime( nTime )
    IF ValType( nTime ) == "N" .AND. nTime >= 0
        mt_nStTime := nTime
    ENDIF
RETURN

// ======================================================================
// MT TEST REGISTRY
// ======================================================================

/// Builds and returns the registry of multi-thread benchmark tests.
/// @return Array of test definitions { cTestID, bTestBlock, nCategory }
FUNCTION BuildMTTestRegistry()
    LOCAL a := {}

    AAdd( a, { "1000", { || t1000() }, CAT_MT } )
    AAdd( a, { "1001", { || t1001() }, CAT_MT } )
    AAdd( a, { "1002", { || t1002() }, CAT_MT } )
    AAdd( a, { "1003", { || t1003() }, CAT_MT } )
    AAdd( a, { "1004", { || t1004() }, CAT_MT } )
    AAdd( a, { "1005", { || t1005() }, CAT_MT } )

RETURN a

// ======================================================================
// MT BENCHMARK TESTS
// ======================================================================

/// Test 1000: Measures thread creation and join overhead.
FUNCTION t1000()
    LOCAL time         := 0
    LOCAL i            := 0
    LOCAL aThreads     := {}
    LOCAL nThreadLoops := 5000
    LOCAL thread       := NIL

    IF ! HB_MultiThread()
        RETURN { "1000: MT disabled in this build", 0, CAT_MT }
    ENDIF

    time := hb_MilliSeconds()

    FOR i := 1 TO nThreadLoops
        thread := StartThread( { |nId| mt_worker_simple( nId ) }, i )
        IF thread != NIL
            AAdd( aThreads, thread )
        ENDIF
    NEXT

    FOR i := 1 TO Len( aThreads )
        JoinThread( aThreads[ i ] )
    NEXT

    time := ( hb_MilliSeconds() - time ) / 1000

RETURN { "1000: Thread create+join (" + LTrim( Str( nThreadLoops ) ) + " threads)", time, CAT_MT }

/// Test 1001: Measures mutex contention under parallel load.
FUNCTION t1001()
    LOCAL time         := 0
    LOCAL i            := 0
    LOCAL aThreads     := {}
    LOCAL mutex        := NIL
    LOCAL thread       := NIL
    LOCAL nThreadLoops := 100

    IF ! HB_MultiThread()
        RETURN { "1001: MT disabled in this build", 0, CAT_MT }
    ENDIF

    mutex := HB_MutexCreate()
    IF mutex == NIL
        RETURN { "1001: Mutex creation failed", 0, CAT_MT }
    ENDIF

    time := hb_MilliSeconds()

    FOR i := 1 TO nThreadLoops
        thread := StartThread( { |m, ops| mt_worker_mutex( m, ops ) }, mutex, mt_nOpsPerThread )
        IF thread != NIL
            AAdd( aThreads, thread )
        ENDIF
    NEXT

    FOR i := 1 TO Len( aThreads )
        JoinThread( aThreads[ i ] )
    NEXT

    time := ( hb_MilliSeconds() - time ) / 1000

RETURN { "1001: Mutex contention (" + LTrim( Str( nThreadLoops ) ) + "T x " + LTrim( Str( mt_nOpsPerThread ) ) + " ops)", time, CAT_MT }

/// Test 1002: Measures shared hash contention with thread-safe writes.
FUNCTION t1002()
    LOCAL time     := 0
    LOCAL i        := 0
    LOCAL aThreads := {}
    LOCAL mutex    := NIL
    LOCAL hShared  := { => }
    LOCAL thread   := NIL

    IF ! HB_MultiThread()
        RETURN { "1002: MT disabled in this build", 0, CAT_MT }
    ENDIF

    mutex := HB_MutexCreate()
    IF mutex == NIL
        RETURN { "1002: Mutex creation failed", 0, CAT_MT }
    ENDIF

    FOR i := 1 TO 100
        hShared[ "key_" + StrZero( i, 4 ) ] := 0
    NEXT

    time := hb_SecondsCPU()

    FOR i := 1 TO mt_nThreadCount
        thread := StartThread( { |m, h, ops| mt_worker_hash( m, h, ops ) }, mutex, hShared, mt_nOpsPerThread )
        IF thread != NIL
            AAdd( aThreads, thread )
        ENDIF
    NEXT

    FOR i := 1 TO Len( aThreads )
        JoinThread( aThreads[ i ] )
    NEXT

    time := hb_SecondsCPU() - time

RETURN { "1002: Shared hash MT (" + LTrim( Str( mt_nThreadCount ) ) + "T, 100 keys)", time, CAT_MT }

/// Test 1003: Parallel independent work (NO mutex — pure scalability test).
/// Each thread processes the shared array using ONLY thread-safe read operations.
FUNCTION t1003()
    LOCAL time       := 0
    LOCAL i          := 0
    LOCAL aThreads   := {}
    LOCAL thread     := NIL
    LOCAL nArraySize := 150000
    LOCAL nTotalSum  := 0
    LOCAL nResult    := 0

    IF ! HB_MultiThread()
        RETURN { "1003: MT disabled in this build", 0, CAT_MT }
    ENDIF

    // Prepare shared work array BEFORE creating threads (thread-safe initialization)
    mt_aWorkArray := Array( nArraySize )
    AFill( mt_aWorkArray, 42 )

    time := hb_SecondsCPU()

    FOR i := 1 TO mt_nThreadCount
        thread := StartThread( { |nDummy| mt_worker_independent( nDummy ) }, i )
        IF thread != NIL
            AAdd( aThreads, thread )
        ENDIF
    NEXT

    FOR i := 1 TO Len( aThreads )
        nResult := JoinThread( aThreads[ i ] )
        IF ValType( nResult ) == "N"
            nTotalSum += nResult
        ENDIF
    NEXT

    time := hb_SecondsCPU() - time

    // Calculate Speedup with protection against division by zero
    IF mt_nStTime > 0 .AND. time > 0.001
        RETURN { "1003: Parallel work (" + LTrim( Str( mt_nThreadCount ) ) + "T, " + ;
                 LTrim( Str( nArraySize ) ) + " elems, speedup=" + ;
                 Str( mt_nStTime / time, 5, 2 ) + "x)", time, CAT_MT }
    ENDIF

RETURN { "1003: Parallel work (" + LTrim( Str( mt_nThreadCount ) ) + "T, " + ;
         LTrim( Str( nArraySize ) ) + " elems)", time, CAT_MT }

/// Test 1004: Producer/Consumer pattern (fine-grained locking).
FUNCTION t1004()
    LOCAL time     := 0
    LOCAL i        := 0
    LOCAL aThreads := {}
    LOCAL mutex    := NIL
    LOCAL aItems   := {}
    LOCAL aIdx     := { 0 }
    LOCAL nItems   := 1000000
    LOCAL thread   := NIL

    IF ! HB_MultiThread()
        RETURN { "1004: MT disabled in this build", 0, CAT_MT }
    ENDIF

    mutex := HB_MutexCreate()
    IF mutex == NIL
        RETURN { "1004: Mutex creation failed", 0, CAT_MT }
    ENDIF

    // Pre-fill items deterministically without locks
    FOR i := 1 TO nItems
        AAdd( aItems, i )
    NEXT

    time := hb_MilliSeconds()

    // Launch consumer threads
    FOR i := 1 TO mt_nThreadCount
        thread := StartThread( { |m, a, x| mt_worker_consumer( m, a, x ) }, mutex, aItems, aIdx )
        IF thread != NIL
            AAdd( aThreads, thread )
        ENDIF
    NEXT

    // Wait for all threads to finish
    FOR i := 1 TO Len( aThreads )
        JoinThread( aThreads[ i ] )
    NEXT

    time := ( hb_MilliSeconds() - time ) / 1000

RETURN { "1004: Producer/Consumer (" + LTrim( Str( mt_nThreadCount ) ) + ;
         "T, " + LTrim( Str( nItems ) ) + " items)", time, CAT_MT }

/// Test 1005: Producer/Consumer pattern with chunked processing (reduced lock contention).
FUNCTION t1005()
    LOCAL time     := 0
    LOCAL i        := 0
    LOCAL aThreads := {}
    LOCAL mutex    := NIL
    LOCAL aItems   := {}
    LOCAL aIdx     := { 0 }
    LOCAL nItems   := 1000000
    LOCAL nChunk   := 1000
    LOCAL thread   := NIL

    IF ! HB_MultiThread()
        RETURN { "1005: MT disabled", 0, CAT_MT }
    ENDIF

    mutex := HB_MutexCreate()
    IF mutex == NIL
        RETURN { "1005: Mutex creation failed", 0, CAT_MT }
ENDI

    // Pre-fill items deterministically without locks
    FOR i := 1 TO nItems
        AAdd( aItems, i )
    NEXT

    time := hb_MilliSeconds()

    // Launch consumer threads
    FOR i := 1 TO mt_nThreadCount
        thread := StartThread( { |m, a, x, c| mt_worker_chunk01( m, a, x, c ) }, mutex, aItems, aIdx, nChunk )
        IF thread != NIL
            AAdd( aThreads, thread )
        ENDIF
    NEXT

    // Wait for all threads to finish
    FOR i := 1 TO Len( aThreads )
        JoinThread( aThreads[ i ] )
    NEXT

    time := ( hb_MilliSeconds() - time ) / 1000

RETURN { "1005: Producer/Consumer (" + LTrim( Str( mt_nThreadCount ) ) + ;
         "T, " + LTrim( Str( nItems ) ) + " items, chunk=" + ;
         LTrim( Str( nChunk ) ) + ")", time, CAT_MT }

// ======================================================================
// MT WORKER FUNCTIONS (Thread-safe, stateless, perform REAL work)
// ======================================================================

/// Simple worker: minimal work (just returns a calculated value).
STATIC FUNCTION mt_worker_simple( nId )
RETURN nId * 2

/// Mutex contention worker: performs computational work inside a critical section.
STATIC FUNCTION mt_worker_mutex( mutex, nOps )
    LOCAL i    := 0
    LOCAL nSum := 0

    FOR i := 1 TO nOps
        HB_MutexLock( mutex )
        // REAL work inside critical section (not just empty lock)
        nSum += ( i * i ) % 1000
        HB_MutexUnlock( mutex )
    NEXT

RETURN nSum

/// Shared hash worker: performs thread-safe writes with computation.
STATIC FUNCTION mt_worker_hash( mutex, hShared, nOps )
    LOCAL i      := 0
    LOCAL cKey   := ""
    LOCAL nValue := 0
    LOCAL nIndex := 0

    FOR i := 1 TO nOps
        nIndex := ( i % 100 ) + 1
        cKey := "key_" + StrZero( nIndex, 4 )
        
        HB_MutexLock( mutex )
        IF hb_HHasKey( hShared, cKey )
            nValue := hShared[ cKey ]
            hShared[ cKey ] := nValue + ( i % 10 )
        ENDIF
        HB_MutexUnlock( mutex )
    NEXT

RETURN NIL

/// Independent work worker: processes array WITHOUT non-thread-safe operations (e.g., ASort).
/// CRITICAL: ASort() is NOT thread-safe in Harbour 3.2.0dev and can cause deadlocks.
STATIC FUNCTION mt_worker_independent( nDummy )
    LOCAL i    := 0
    LOCAL nSum := 0
    LOCAL nLen := Len( mt_aWorkArray )
    LOCAL nVal := 0

    // Thread-safe operations ONLY: arithmetic + array read
    FOR i := 1 TO nLen
        nVal := mt_aWorkArray[ i ]
        // Simulate real work: multiply, modulo, accumulate
        nSum += ( nVal * nVal ) % 10000
    NEXT

RETURN nSum

/// Consumer worker for Test 1004: processes items one by one with fine-grained locking.
STATIC FUNCTION mt_worker_consumer( mutex, aItems, aIdx )
    LOCAL nIdx  := 0
    LOCAL nLen  := Len( aItems )
    LOCAL nSum  := 0
    LOCAL xItem := NIL

    DO WHILE .T.
        xItem := NIL
        
        HB_MutexLock( mutex )
        nIdx := aIdx[ 1 ]
        IF nIdx < nLen
            aIdx[ 1 ] := nIdx + 1
            xItem     := aItems[ nIdx + 1 ]
        ENDIF
        HB_MutexUnlock( mutex )

        IF xItem == NIL
            EXIT
        ENDIF

        IF ValType( xItem ) == "N"
            nSum += xItem
        ENDIF
    ENDDO

RETURN nSum

/// Consumer worker for Test 1005: processes items in chunks to reduce lock contention.
STATIC FUNCTION mt_worker_chunk01( mutex, aItems, aIdx, nChunk )
    LOCAL nIdx  := 0
    LOCAL nLen  := Len( aItems )
    LOCAL nTake := 0
    LOCAL nSum  := 0
    LOCAL j     := 0

    DO WHILE .T.
        nTake := 0
        nIdx  := 0
        
        // Atomic reservation of a range [nIdx+1 .. nIdx+nTake]
        HB_MutexLock( mutex )
        nIdx := aIdx[ 1 ]
        IF nIdx < nLen
            nTake := Min( nChunk, nLen - nIdx )
            aIdx[ 1 ] := nIdx + nTake
        ENDIF
        HB_MutexUnlock( mutex )

        IF nTake == 0
            EXIT
        ENDIF

        // Process OUTSIDE the mutex — enables real parallelism
        FOR j := 1 TO nTake
            nSum += aItems[ nIdx + j ]
        NEXT
    ENDDO

RETURN nSum