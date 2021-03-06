/* Copyright 2009-2016 Viktor Szakats */

#require "hbssl"

PROCEDURE Main()

   LOCAL cString
   LOCAL bioe

   SSL_init()

   ? "Version built against:", hb_NumToHex( OPENSSL_VERSION_NUMBER() )
   ? "Version loaded:", hb_NumToHex( OpenSSL_version_num() )

   ? ERR_load_PEM_strings()
   ? OpenSSL_add_all_algorithms()

   bioe := BIO_new_fd( hb_GetStdOut(), HB_BIO_NOCLOSE )

   ? PEM_READ_BIO_RSAPRIVATEKEY( "private.pem", {| lWrite | Output( "Callback (block)", lWrite, hb_eol() ), "test" } )
   ? 1; ERR_print_errors( bioe )
   ? PEM_READ_BIO_RSAPRIVATEKEY( "private.pem", @cb_function() )
   ? 2; ERR_print_errors( bioe )
   ? PEM_READ_BIO_RSAPRIVATEKEY( "private.pem", "test" )
   ? 3; ERR_print_errors( bioe )
   ? PEM_READ_BIO_RSAPUBLICKEY( "private.pem", {| lWrite | Output( "Callback (block)", lWrite, hb_eol() ), "test" } )
   ? 4; ERR_print_errors( bioe )
   ? PEM_READ_BIO_RSAPUBLICKEY( "private.pem", "test" )
   ? 5; ERR_print_errors( bioe )

   #pragma __streaminclude "private.pem" | cString := %s

   ? PEM_READ_BIO_RSAPRIVATEKEY( BIO_new_mem_buf( cString ), {| lWrite | QOut( "Callback", lWrite, hb_eol() ), "test" } )
   ? 6; ERR_print_errors( bioe )

   ? PEM_READ_BIO_RSAPRIVATEKEY( BIO_new_mem_buf( cString ), "test" )
   ? 7; ERR_print_errors( bioe )

   ? PEM_READ_BIO_RSAPRIVATEKEY( BIO_new_mem_buf( cString ), "<wrong>" )
   ? 8; ERR_print_errors( bioe )

   bioe := NIL

   RETURN

STATIC FUNCTION cb_function( lWrite )

   ? "Callback (func)", lWrite

   RETURN "test"

STATIC PROCEDURE Output( ... )

   ? ...

   RETURN
