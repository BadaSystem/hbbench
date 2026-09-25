/*
 * BadaSystem
 * Program       : hbbench
 * Module        : hbbench_export.prg
 * Compiler      : Harbour 3.2.0dev Console
 * Author        : Marcos Jarrín
 * Email         : marvijarrin@gmail.com
 * Website       : badasystem.com
 * Date          : 23/09/2026
 * Update        : 23/09/2026
 * Rev           : 1.0
 * SPDX-License-Identifier: MIT
 *
 * Description:
 *
 * CSV and JSON exporters for hbbench v1.0
 *
 */

PROCEDURE ExportResultsToCSV( aResults, cFilePath )
   LOCAL nHandle, cLine, nI, cTestName, nTime, nCategory, nLoops
   LOCAL cDir

   cDir := hb_FNameDir( cFilePath )
   IF ! Empty( cDir )
      EnsureDir( cDir )
   ENDIF
   
   nHandle := FCreate( cFilePath )
   IF nHandle == -1
      ? " [ERROR] Cannot create CSV file: " + cFilePath
      RETURN
   ENDIF

   cLine := "test_id,test_name,category,seconds,loops,compiler" + hb_eol()
   FWrite( nHandle, cLine )

   FOR nI := 1 TO Len( aResults )
      cTestName := EscapeJsonString( aResults[ nI ][ 2 ] )
      nTime := aResults[ nI ][ 3 ]
      nCategory := aResults[ nI ][ 4 ]
      nLoops := aResults[ nI ][ 5 ]

      cLine := '"' + aResults[ nI ][ 1 ] + '",' + ;
               '"' + cTestName + '",' + ;
               Str( nCategory ) + "," + ;
               Str( nTime, 10, 6 ) + "," + ;
               Str( nLoops ) + "," + ;
               '"' + hb_Compiler() + '"' + hb_eol()
               
      FWrite( nHandle, cLine )
   NEXT

   FClose( nHandle )
   ? " [OK] Results exported to CSV: " + cFilePath
   RETURN

PROCEDURE ExportResultsToJSON( aResults, cFilePath )
   LOCAL nHandle, cJson, nI, cTestName, nTime, nCategory, nLoops
   LOCAL cDir

   cDir := hb_FNameDir( cFilePath )
   IF ! Empty( cDir )
      EnsureDir( cDir )
   ENDIF

   nHandle := FCreate( cFilePath )
   IF nHandle == -1
      ? " [ERROR] Cannot create JSON file: " + cFilePath
      RETURN
   ENDIF

   cJson := '{' + hb_eol()
   cJson += '  "benchmark": "hbbench",' + hb_eol()
   cJson += '  "version": "14.0-alpha",' + hb_eol()
   cJson += '  "compiler": "' + hb_Compiler() + '",' + hb_eol()
   cJson += '  "date": "' + DToS( Date() ) + " " + Time() + '",' + hb_eol()
   cJson += '  "results": [' + hb_eol()

   FOR nI := 1 TO Len( aResults )
      cTestName := EscapeJsonString( aResults[ nI ][ 2 ] )
      nTime := aResults[ nI ][ 3 ]
      nCategory := aResults[ nI ][ 4 ]
      nLoops := aResults[ nI ][ 5 ]

      cJson += '    {' + hb_eol()
      cJson += '      "id": "' + aResults[ nI ][ 1 ] + '",' + hb_eol()
      cJson += '      "name": "' + cTestName + '",' + hb_eol()
      cJson += '      "category": ' + Str( nCategory ) + ',' + hb_eol()
      cJson += '      "seconds": ' + Str( nTime, 10, 6 ) + ',' + hb_eol()
      cJson += '      "loops": ' + Str( nLoops ) + hb_eol()
      cJson += '    }'
      
      IF nI < Len( aResults )
         cJson += ','
      ENDIF
      cJson += hb_eol()
   NEXT

   cJson += '  ]' + hb_eol()
   cJson += '}' + hb_eol()

   FWrite( nHandle, cJson )
   FClose( nHandle )
   ? " [OK] Results exported to JSON: " + cFilePath
   RETURN