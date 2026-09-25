/*
 * BadaSystem
 * Program       : hbbench
 * Module        : hbbench_common.prg
 * Compiler      : Harbour 3.2.0dev Console
 * Author        : Marcos Jarrín
 * Email         : marvijarrin@gmail.com
 * Website       : badasystem.com
 * Date          : 20/09/2026
 * Update        : 20/09/2026
 * Rev           : 1.0
 * SPDX-License-Identifier: MIT
 *
 * Description:
 * Shared utilities for hbbench v1.0
 *
 */

PROCEDURE EnsureDir( cDir )
   IF ! hb_DirExists( cDir )
      hb_DirCreate( cDir )
   ENDIF
   RETURN

FUNCTION EscapeJsonString( cStr )
   LOCAL cRes
   cRes := StrTran( cStr, "\", "\\" )
   cRes := StrTran( cRes, '"', '\"' )
   cRes := StrTran( cRes, hb_eol(), "\n" )
   cRes := StrTran( cRes, hb_osNewLine(), "\n" )
   RETURN cRes