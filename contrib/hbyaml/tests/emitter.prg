/* Copyright 2017-present Viktor Szakats */

#require "hbyaml"

PROCEDURE Main()

   OutStd( hb_yaml_encode( { ;
      "hello", ;
      { "key1" => "value1", ;
        "key2" => { "item1", "item2", "item3" }, ;
        "key3" => { "subkey1" => "valueA", "subkey2" => "valueB" } }, ;
      { "itemA", "itemB" }, ;
      "world" } ) )

   RETURN
