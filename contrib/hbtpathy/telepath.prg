/*
 * Telepathy emulation library
 *
 * Copyright 2000-2001 Dan Levitt <dan@boba-fett.net>
 * Copyright 2004-2005 Maurilio Longo <maurilio.longo@libero.it>
 * Copyright 2010 Viktor Szakats
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file LICENSE.txt.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA (or visit https://www.gnu.org/licenses/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

/* This is based upon a library originally made by Dan Levitt <dan@boba-fett.net>
   The original files have been committed as v1.0. So you can always retrieve them
   (see VCS docs on how to) */

#include "telepath.ch"

#include "hbcom.ch"

#define TPFP_NAME          1  /* Structure of ports array */
#define TPFP_HANDLE        2
#define TPFP_BAUD          3
#define TPFP_DBITS         4
#define TPFP_PARITY        5
#define TPFP_SBITS         6
#define TPFP_OC            7  /* Open/Close Flag */
#define TPFP_INBUF         8
#define TPFP_INBUF_SIZE    9  /* Size of input buffer */

THREAD STATIC t_aPorts           // Array with port info
THREAD STATIC t_nErrorCode := 0  // Error code from last operation, 0 if no error

FUNCTION tp_baud( nPort, nNewBaud )

   IF ! isport( nPort ) .OR. Empty( t_aPorts[ nPort ][ TPFP_NAME ] )
      RETURN TE_NOPORT
   ENDIF

   IF isopenport( nPort )

      hb_default( @nNewBaud, 0 )

      IF nNewBaud > 0
         IF hb_comInit( t_aPorts[ nPort ][ TPFP_HANDLE ], nNewBaud, t_aPorts[ nPort ][ TPFP_PARITY ], t_aPorts[ nPort ][ TPFP_DBITS ], t_aPorts[ nPort ][ TPFP_SBITS ] )
            t_aPorts[ nPort ][ TPFP_BAUD ] := nNewBaud
         ELSE
            // set error code
         ENDIF
      ENDIF

      RETURN t_aPorts[ nPort ][ TPFP_BAUD ]
   ENDIF

   RETURN 0


FUNCTION tp_inkey( ... )
   RETURN Inkey( ... )

PROCEDURE tp_delay( nTime )

   hb_default( @nTime, 0 )

   IF nTime < 0
      RETURN
   ELSEIF nTime > 1800
      nTime := 1800
   ENDIF

   hb_idleSleep( nTime )

   RETURN

FUNCTION tp_close( nPort, nTimeout )

   /* Cl*pper returns 0 even if a port is not open */
   IF isopenport( nPort )

      hb_default( @nTimeout, 0 )

      IF nTimeout > 0
         tp_flush( nPort, nTimeout )
      ENDIF

      IF t_aPorts[ nPort ][ TPFP_HANDLE ] >= 0

         hb_comClose( t_aPorts[ nPort ][ TPFP_HANDLE ] )

         /* Port parameters should stay the same for the case the port gets reopened */
         t_aPorts[ nPort ][ TPFP_OC ] := .F.
         t_aPorts[ nPort ][ TPFP_INBUF ] := ""
         t_aPorts[ nPort ][ TPFP_HANDLE ] := -1
      ENDIF
   ENDIF

   RETURN 0

FUNCTION tp_reopen( nPort, nInSize, nOutSize )

   LOCAL nBaud, nData, cParity, nStop, cPortName

   IF ! isport( nPort ) .OR. Empty( t_aPorts[ nPort ][ TPFP_NAME ] )
      RETURN TE_NOPORT
   ENDIF

   cPortName := t_aPorts[ nPort ][ TPFP_NAME ]
   nBaud     := t_aPorts[ nPort ][ TPFP_BAUD ]
   nData     := t_aPorts[ nPort ][ TPFP_DBITS ]
   cParity   := t_aPorts[ nPort ][ TPFP_PARITY ]
   nStop     := t_aPorts[ nPort ][ TPFP_SBITS ]

   RETURN tp_open( nPort, nInSize, nOutSize, nBaud, nData, cParity, nStop, cPortName )

FUNCTION tp_open( nPort, nInSize, nOutSize, nBaud, nData, cParity, nStop, cPortName )

   HB_SYMBOL_UNUSED( nOutSize )

   IF ! isport( nPort )
      RETURN TE_NOPORT
   ENDIF

   IF HB_ISSTRING( cPortName )
      hb_comSetDevice( nPort, cPortName )
   ENDIF

   t_aPorts[ nPort ][ TPFP_NAME       ] := cPortName
   t_aPorts[ nPort ][ TPFP_BAUD       ] := hb_defaultValue( nBaud, 1200 )
   t_aPorts[ nPort ][ TPFP_DBITS      ] := hb_defaultValue( nData, 8 )
   t_aPorts[ nPort ][ TPFP_PARITY     ] := hb_defaultValue( cParity, "N" )
   t_aPorts[ nPort ][ TPFP_SBITS      ] := hb_defaultValue( nStop, 1 )
   t_aPorts[ nPort ][ TPFP_OC         ] := .F.
   t_aPorts[ nPort ][ TPFP_INBUF      ] := ""
   t_aPorts[ nPort ][ TPFP_INBUF_SIZE ] := hb_defaultValue( nInSize, 1536 )
   t_aPorts[ nPort ][ TPFP_HANDLE     ] := -1

   IF hb_comOpen( nPort )

      t_aPorts[ nPort ][ TPFP_HANDLE ] := nPort

      IF hb_comInit( t_aPorts[ nPort ][ TPFP_HANDLE ], t_aPorts[ nPort ][ TPFP_BAUD ], t_aPorts[ nPort ][ TPFP_PARITY ], t_aPorts[ nPort ][ TPFP_DBITS ], t_aPorts[ nPort ][ TPFP_SBITS ] )
         t_aPorts[ nPort ][ TPFP_OC ] := .T.
         RETURN 0
      ELSE
         tp_close( t_aPorts[ nPort ][ TPFP_HANDLE ] )
         RETURN TE_PARAM
      ENDIF
   ENDIF

   t_aPorts[ nPort ][ TPFP_NAME       ] := ""
   t_aPorts[ nPort ][ TPFP_HANDLE     ] := -1
   t_aPorts[ nPort ][ TPFP_BAUD       ] := 1200
   t_aPorts[ nPort ][ TPFP_DBITS      ] := 8
   t_aPorts[ nPort ][ TPFP_PARITY     ] := "N"
   t_aPorts[ nPort ][ TPFP_SBITS      ] := 1
   t_aPorts[ nPort ][ TPFP_OC         ] := .F.
   t_aPorts[ nPort ][ TPFP_INBUF      ] := ""
   t_aPorts[ nPort ][ TPFP_INBUF_SIZE ] := 0

   RETURN TE_CONFL  /* maybe should return something different? */

FUNCTION tp_recv( nPort, nLength, nTimeout )

   LOCAL nDone
   LOCAL cRet

   IF ! HB_ISNUMERIC( nLength )
      nLength := t_aPorts[ nPort ][ TPFP_INBUF_SIZE ]
   ENDIF

   FetchChars( nPort )

   hb_default( @nTimeout, 0 )

   nDone := Seconds() + iif( nTimeout >= 0, nTimeout, 0 )

   DO WHILE hb_BLen( t_aPorts[ nPort ][ TPFP_INBUF ] ) < nLength .AND. ;
      ( nTimeout < 0 .OR. Seconds() < nDone )

      IF tp_idle()
         EXIT
      ELSE
         FetchChars( nPort )
      ENDIF
   ENDDO

   IF nLength > hb_BLen( t_aPorts[ nPort ][ TPFP_INBUF ] )
      cRet := t_aPorts[ nPort ][ TPFP_INBUF ]
      t_aPorts[ nPort ][ TPFP_INBUF ] := ""
   ELSE
      cRet := hb_BLeft( t_aPorts[ nPort ][ TPFP_INBUF ], nLength )
      t_aPorts[ nPort ][ TPFP_INBUF ] := hb_BSubStr( t_aPorts[ nPort ][ TPFP_INBUF ], nLength + 1 )
   ENDIF

   RETURN cRet

FUNCTION tp_send( nPort, cString, nTimeout )

   IF isopenport( nPort )

      hb_default( @cString, "" )

      IF ! cString == ""
         RETURN hb_comSend( t_aPorts[ nPort ][ TPFP_HANDLE ], cString,, hb_defaultValue( nTimeout, 0 ) )
      ENDIF
   ENDIF

   RETURN 0

FUNCTION tp_sendsub( nPort, cString, nStart, nLength, nTimeout )
   RETURN tp_send( nPort, ;
      hb_BSubStr( cString, hb_defaultValue( nStart, 1 ), ;
      iif( HB_ISNUMERIC( nLength ), nLength, hb_BLen( cString ) ) ), nTimeout )

FUNCTION tp_recvto( nPort, cDelim, nMaxlen, nTimeout )

   LOCAL cChar
   LOCAL nAt
   LOCAL nStartPos := 1, nFirst := 0
   LOCAL nDone, cRet := ""

   IF isopenport( nPort ) .AND. HB_ISSTRING( cDelim ) .AND. ! cDelim == ""

      hb_default( @nMaxLen, 64999 )  /* MS-DOS telepathy default. In Harbour could be higher. */
      hb_default( @nTimeout, 0 )

      FetchChars( nPort )

      /* Telepathy NG: [...] If nTimeout is omitted or zero, reads until finding the
                       delimiter or the input buffer is empty. */
      IF nTimeout == 0 .AND. t_aPorts[ nPort ][ TPFP_INBUF ] == ""
         RETURN ""
      ENDIF

      nDone := Seconds() + iif( nTimeout >= 0, nTimeout, 0 )

      DO WHILE ( nTimeout < 0 .OR. Seconds() < nDone )

         IF hb_BLen( cDelim ) == 1
            IF ( nAt := hb_BAt( cDelim, t_aPorts[ nPort ][ TPFP_INBUF ], nStartPos ) ) > 0 .AND. ;
               iif( nFirst > 0, nAt < nFirst, .T. )
               nFirst := nAt
            ENDIF
         ELSE
            FOR EACH cChar IN cDelim
               IF ( nAt := hb_BAt( cChar, t_aPorts[ nPort ][ TPFP_INBUF ], nStartPos ) ) > 0 .AND. ;
                  iif( nFirst > 0, nAt < nFirst, .T. )
                  nFirst := nAt
               ENDIF
            NEXT
         ENDIF

         // I've found it
         IF nFirst > 0
            EXIT
         ELSE
            // Next loop I don't need to search that part of the input buffer that
            // I've already just searched for
            nStartPos := Max( hb_BLen( t_aPorts[ nPort ][ TPFP_INBUF ] ), 1 )

            // I've read more characters than I'm allowed to, so I exit
            IF nStartPos >= nMaxLen
               EXIT
            ENDIF

            IF tp_idle()
               EXIT
            ELSE
               FetchChars( nPort )
            ENDIF
         ENDIF
      ENDDO

      IF nFirst > 0
         cRet := hb_BLeft( t_aPorts[ nPort ][ TPFP_INBUF ], nFirst )
         t_aPorts[ nPort ][ TPFP_INBUF ] := hb_BSubStr( t_aPorts[ nPort ][ TPFP_INBUF ], nFirst + 1 )
      ENDIF
   ENDIF

   RETURN cRet

/* Here's an improvement over original TP... you can "lookfor" a string
   here rather than just a char.  yay me.
   of course, if you're using Cl*pper/tp code and you search for a single char it will work
   the same. */
FUNCTION tp_lookfor( nPort, cLookfor )

   IF isopenport( nPort )
      FetchChars( nPort )
      RETURN hb_BAt( cLookfor, t_aPorts[ nPort ][ TPFP_INBUF ] )
   ENDIF

   RETURN 0

FUNCTION tp_inchrs( nPort )

   IF isopenport( nPort )
      FetchChars( nPort )
      RETURN hb_BLen( t_aPorts[ nPort ][ TPFP_INBUF ] )
   ENDIF

   RETURN 0

FUNCTION tp_infree( nPort )

   IF isopenport( nPort )
      RETURN __tp_infree( t_aPorts[ nPort ][ TPFP_HANDLE ] )
   ENDIF

   RETURN 0

FUNCTION tp_outfree( nPort )

   IF isopenport( nPort )
      RETURN __tp_outfree( t_aPorts[ nPort ][ TPFP_HANDLE ] )
   ENDIF

   RETURN 0

PROCEDURE tp_clearin( nPort )

   IF isopenport( nPort )
      FetchChars( nPort )
      t_aPorts[ nPort ][ TPFP_INBUF ] := ""
   ENDIF

   RETURN

PROCEDURE tp_clrkbd()

   CLEAR TYPEAHEAD

   RETURN

FUNCTION tp_crc16( cString )
   RETURN hb_ByteSwapW( hb_CRCCT( cString ) )  /* swap lo and hi bytes */

FUNCTION tp_crc32( cString )
   RETURN hb_CRC32( cString )

FUNCTION tp_waitfor( ... )  /* nPort, nTimeout, acList|cString..., lIgnorecase */

   LOCAL aParam := hb_AParams()
   LOCAL nPort
#if 0
   LOCAL nTimeout, lIgnorecase
#endif

   nPort := aParam[ 1 ]

   IF isopenport( nPort )

#if 0
      nTimeout := aParam[ 2 ]
      lIgnorecase := ATail( aParam )

      hb_default( @nTimeout, -1 )
      hb_default( @lIgnorecase, .F. )

      DO CASE
      CASE ntimeout < 0
         nDone := _clock() + 999999
      CASE ntimeout == 0
         nDone := 4
      OTHERWISE
         nDone := _clock() + nTimeout
      ENDCASE

      DO WHILE ( nDone > _clock() .OR. nFirst == 100000 ) .AND. ! tp_idle()

         IF nFirst == 100000
            nFirst := 99999
         ENDIF

         FetchChars( nPort )

         FOR EACH x IN acList
            IF lIgnorecase
               nAt := hb_BAt( Upper( x ), Upper( t_aPorts[ nPort ][ TPFP_INBUF ] ) )
            ELSE
               nAt := hb_BAt( x, t_aPorts[ nPort ][ TPFP_INBUF ] )
            ENDIF
            IF nAt > 0 .AND. nAt < nFirst
               nFirst := nAt
               nRet := x:__enumIndex()
            ENDIF
         NEXT

         IF nFirst < 64000
            EXIT
         ENDIF

#if 0
         sched_yield()  // C level function
#endif

      ENDDO

      IF nFirst < 64000
         tp_recv( nPort, nAt + hb_BLen( acList[ nRet ] ) )
         RETURN nRet
      ENDIF
#endif
   ENDIF

   RETURN 0

/* We cannot set, well, _I_ think we cannot, CTS without setting RTS flow control, so this
   function and tp_ctrlrts() do the same thing, that is set/reset CRTSCTS flow contol */
FUNCTION tp_ctrlcts( nPort, nNewCtrl )

   LOCAL nCurValue
   LOCAL nFlag

   IF isopenport( nPort )

      IF hb_comFlowControl( t_aPorts[ nPort ][ TPFP_HANDLE ], @nCurValue )
         nFlag := hb_bitOr( HB_COM_FLOW_IRTSCTS, HB_COM_FLOW_ORTSCTS )
         IF HB_ISNUMERIC( nNewCtrl )
            IF nNewCtrl == 0
               nNewCtrl := hb_bitAnd( nCurValue, hb_bitNot( nFlag ) )
            ELSE
               nNewCtrl := hb_bitOr( nCurValue, nFlag )
            ENDIF

            hb_comFlowControl( t_aPorts[ nPort ][ TPFP_HANDLE ],, nNewCtrl )
         ENDIF
         nCurValue := iif( hb_bitAnd( nCurValue, nFlag ) != 0, 1, 0 )
      ENDIF

      RETURN nCurValue
   ENDIF

   RETURN 0


// Simply calls tp_ctrlcts()
FUNCTION tp_ctrlrts( nPort, nNewCtrl )
   RETURN tp_ctrlcts( nPort, nNewCtrl )


// telepathy says...
// returns old dtr value 0,1,2
// sets to 0: dtr off, 1: dtr on, 2: dtr flow control autotoggle
// I don't support 2.  who uses dtr for flow control anyway...
FUNCTION tp_ctrldtr( nPort, nNewCtrl )

   LOCAL nCurValue
   LOCAL nFlag

   IF isopenport( nPort )

      IF hb_comFlowControl( t_aPorts[ nPort ][ TPFP_HANDLE ], @nCurValue )
         nFlag := hb_bitOr( HB_COM_FLOW_IDTRDSR, HB_COM_FLOW_ODTRDSR )
         IF HB_ISNUMERIC( nNewCtrl )
            IF nNewCtrl == 0
               nNewCtrl := hb_bitAnd( nCurValue, hb_bitNot( nFlag ) )
            ELSE
               nNewCtrl := hb_bitOr( nCurValue, nFlag )
            ENDIF

            hb_comFlowControl( t_aPorts[ nPort ][ TPFP_HANDLE ],, nNewCtrl )
         ENDIF
         nCurValue := iif( hb_bitAnd( nCurValue, nFlag ) != 0, 1, 0 )
      ENDIF

      RETURN nCurValue
   ENDIF

   RETURN 0

FUNCTION tp_isdcd( nPort )

   LOCAL nValue

   IF isopenport( nPort )
      hb_comMSR( nPort, @nValue )
      RETURN hb_bitAnd( nValue, HB_COM_MSR_DCD ) != 0
   ENDIF

   RETURN .F.

FUNCTION tp_isri( nPort )

   LOCAL nValue

   IF isopenport( nPort )
      hb_comMSR( nPort, @nValue )
      RETURN hb_bitAnd( nValue, HB_COM_MSR_RI ) != 0
   ENDIF

   RETURN .F.

FUNCTION tp_isdsr( nPort )

   LOCAL nValue

   IF isopenport( nPort )
      hb_comMSR( nPort, @nValue )
      RETURN hb_bitAnd( nValue, HB_COM_MSR_DSR ) != 0
   ENDIF

   RETURN .F.

FUNCTION tp_iscts( nPort )

   LOCAL nValue

   IF isopenport( nPort )
      hb_comMSR( nPort, @nValue )
      RETURN hb_bitAnd( nValue, HB_COM_MSR_CTS ) != 0
   ENDIF

   RETURN .F.

FUNCTION tp_flush( nPort, nTimeout )

   LOCAL nDone

   IF isopenport( nPort )

      hb_default( @nTimeout, -1 )

      IF nTimeout > 1800
         nTimeout := 1800
      ENDIF

      nDone := Seconds() + iif( nTimeout >= 0, nTimeout, 0 )

      DO WHILE tp_outfree( nPort ) > 0 .AND. ;
            ( nTimeout < 0 .OR. Seconds() < nDone )
         hb_idleState()
      ENDDO

      RETURN iif( tp_outfree( nPort ) > 0, TE_TMOUT, 0 )
   ENDIF

   RETURN TE_CLOSED

#if 0

// / sorry, but ctrldsr and ctrlcts will act like isdsr and iscts... if you want
// / flow control, talk to the system.
FUNCTION tp_ctrldsr( nPort )
   RETURN tp_isdsr( nPort )

// / you cannot do these things.  try rc.serial
FUNCTION tp_shared()
   RETURN 0

FUNCTION tp_setport()
   RETURN 0

#endif

// internal (static) functions

STATIC FUNCTION isopenport( nPort )
   RETURN isport( nPort ) .AND. t_aPorts[ nPort ][ TPFP_OC ]

STATIC FUNCTION isport( nPort )
   RETURN HB_ISNUMERIC( nPort ) .AND. nPort >= 1 .AND. nPort <= TP_MAXPORTS

STATIC FUNCTION FetchChars( nPort )

   LOCAL cStr

   IF isopenport( nPort )

      cStr := Space( hb_comInputCount( t_aPorts[ nPort ][ TPFP_HANDLE ] ) )
      hb_comRecv( t_aPorts[ nPort ][ TPFP_HANDLE ], @cStr )

      t_aPorts[ nPort ][ TPFP_INBUF ] += cStr

      RETURN hb_BLen( cStr )
   ENDIF

   RETURN 0

INIT PROCEDURE _tpinit()

   LOCAL x

   IF t_aPorts == NIL
      t_aPorts := Array( TP_MAXPORTS )
      FOR EACH x IN t_aPorts
         // port name, file handle, baud, data bits, parity, stop bits, Open?, input buffer, input buff.size
         x := { "", -1, 1200, 8, "N", 1, .F., "", 0 }
      NEXT
   ENDIF

   RETURN

#if 0

// you can uncomment the following section for compatibility with TP code... I figured
// you'd probably want them commented so it won't compile so that you would see where
// you have potential incomplete port problems
FUNCTION tp_mstat()
   RETURN ""

FUNCTION tp_szmodem()
   RETURN 0

FUNCTION tp_noteoff()
   RETURN 0

FUNCTION tp_ontime()
   RETURN 0

FUNCTION tp_rzmodem()
   RETURN 0

FUNCTION tp_error()
   RETURN 0

FUNCTION tp_errmsg()
   RETURN ""

FUNCTION tp_fifo()
   RETURN 0

FUNCTION tp_outchrs()
   RETURN 0

FUNCTION tp_keybd()
   RETURN 0

// / tp_debug() is not a real TP function.  I included it so you can define your own debug
// / output function.
// / the point of the first parameter is a "debug level".  I keep a system variable for how
// / much debugging output is wanted and if the tp_debug() parameter is a LOWER number than
// / the global debug level I print the message.  Since I don't have your system globals,
// / I will ignore the first parameter and always print it.
// / I recommend you modify this function to suit your own debugging needs
PROCEDURE tp_debug( nDebugLevel, cString )

   HB_SYMBOL_UNUSED( nDebugLevel )

   ? cString

   RETURN

#endif

/* NOTE: dummy function, solely for compatibility. */
PROCEDURE tp_uninstall()
   RETURN

STATIC FUNCTION __tp_infree()
   RETURN -1

STATIC FUNCTION __tp_outfree()
   RETURN -1

FUNCTION bin_and( ... )
   RETURN hb_bitAnd( ... )

FUNCTION bin_or( ... )
   RETURN hb_bitOr( ... )

FUNCTION bin_xor( ... )
   RETURN hb_bitXor( ... )

FUNCTION bin_not( ... )
   RETURN hb_bitNot( ... )
