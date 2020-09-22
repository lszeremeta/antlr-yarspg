/*
 [The "BSD licence"]
 Copyright (c) 2018-2020, Łukasz Szeremeta (@ University of Bialystok, https://lukasz.science)
 Copyright (c) 2018, Dominik Tomaszuk (@ University of Bialystok, http://www.uwb.edu.pl/)
 Copyright (c) 2018, Karol Litman (@ University of Bialystok, http://www.uwb.edu.pl/)
 All rights reserved.

 Based on YARS grammar
 (https://github.com/lszeremeta/antlr-yars/blob/master/yars/YARS.g4)
 distributed under BSD licence.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
*/

grammar YARSpg;

yarspg
    : statement* EOF
    ;

statement
    : node
    | edge
    | prefix_directive
    | doc_metadata
    | var_declaration
    | node_schema
    | edge_schema
    | var_declaration_schema
    | section
    | graph
    | graph_schema
    ;

prefix_directive
    : pname IRI
    ;

pname
    : ':' ALNUM_PLUS ':'
    ;

pn_local
    : ALNUM_PLUS
    ;

doc_metadata
    : '-' ((pn_local pname) | (IRI ':')) (STRING | IRI)
    ;

var
    : '$' var_name
    ;

var_declaration
    : var '=' prop (',' prop)*
    ;

var_declaration_schema
    : var '=' prop_schema (',' prop_schema)*
    ;

var_name
    : ALNUM_PLUS
    ;

graph_id
    : ALNUM_PLUS
    ;

local_metadata
    : string_local_metadata
    | rdf_local_metadata
    ;

string_local_metadata
    : key ':' STRING
    ;

rdf_local_metadata
    : ((pn_local pname) | (IRI ':')) (STRING | IRI)
    ;

local_metadata_list
    : '+' '[' local_metadata (',' local_metadata)* ']'
    ;

props_list
    : '[' ( ( prop | var ) (',' ( prop | var ) )* )? ']'
    ;

meta_prop
    : '@' key ':' value
    ;

graphs_list
    : '/' graph_id (',' graph_id)* '/'
    ;

graph
    : '/' graph_id '/' ( '{' ( graph_label ( ',' graph_label )* )? '}' )? props_list?
    ;

node
    : '(' node_id ( '{' ( node_label ( ',' node_label )* )? '}' )? props_list? ')' graphs_list? local_metadata_list?
    ;

edge
    : directed
    | undirected
    ;

section
    : '%' SECTION_NAME
    ;

directed
    : '(' node_id ')' '-' '(' edge_id? ( '{' ( edge_label ( ',' edge_label )* )? '}' )? props_list? ')' '->' '(' node_id ')' graphs_list? local_metadata_list?
    ;

undirected
    : '(' node_id ')' '-' '(' edge_id? ( '{' ( edge_label ( ',' edge_label )* )? '}' )? props_list? ')' '-' '(' node_id ')' graphs_list? local_metadata_list?
    ;

node_id
    : ALNUM_PLUS
    ;

node_label
    : STRING
    ;

prop
    : key ':' value meta_prop*
    ;

edge_id
    : ALNUM_PLUS
    ;

edge_label
    : STRING
    ;

graph_label
    : STRING
    ;

key
    : STRING
    ;

value
    : primitive_value
    | complex_value
    ;

primitive_value
    : STRING
    | DATETYPE
    | number
    | BOOL
    | NULL
    ;

complex_value
    : set
    | list
    | struct
    ;

set
    : '{' (primitive_value | set) meta_prop* (',' (primitive_value | set) meta_prop*)* '}'
    ;

list
    : '[' (primitive_value | list) meta_prop* (',' (primitive_value | list) meta_prop*)* ']'
    ;

struct
    : '{' key ':' (primitive_value | struct) meta_prop* (',' key ':' (primitive_value | struct) meta_prop*)* '}'
    ;

node_schema
    : 'S' '(' node_id_schema ( '{' ( node_label ( ',' node_label )* )? '}' )? prop_list_schema? ')' graphs_list? local_metadata_list?
    ;

node_id_schema
    : ALNUM_PLUS
    ;

prop_list_schema
    : '[' ( ( prop_schema | var ) (',' ( prop_schema | var ) )* )? ']'
    ;

prop_schema
    : key ':' value_schema
    ;

meta_prop_schema
    : '@' key ':' value_schema
    ;

cardinality
    : min_cardinality max_cardinality?
    | max_cardinality
    ;

min_cardinality
    : MIN card_num
    ;

max_cardinality
    : MAX card_num
    ;

card_num
    : UNSIGNED_INT
    ;

value_schema
    : primitive_value_schema (UNIQUE | NULL)? OPTIONAL?  meta_prop_schema*
    | complex_value_schema NULL? OPTIONAL? meta_prop_schema*
    ;

primitive_value_schema
    // NUMBER
    : 'Decimal'
    | 'SmallInt'
    | 'Integer'
    | 'BigInt'
    | 'Float'
    | 'Real'
    | 'Double'
    // BOOL
    | 'Bool'
    // STRING
    | 'String'
    // DATETYPE
    | 'Date'
    | 'DateTime'    
    | 'Time'
    ;

complex_value_schema
    : set_schema
    | list_schema
    | struct_schema
    ;

set_schema
    : 'Set' '(' (primitive_value_schema | set_schema) NULL? cardinality? ')' meta_prop_schema*
    ;

list_schema
    : 'List' '(' (primitive_value_schema | list_schema) NULL? cardinality? ')' meta_prop_schema*
    ;

struct_schema
    : 'Struct' '(' (primitive_value_schema | struct_schema) NULL? cardinality? ')' meta_prop_schema*
    ;

edge_schema
    : directed_schema
    | undirected_schema
    ;

directed_schema
    : 'S' '(' node_id_schema ')' '-' '(' ( '{' ( edge_label ( ',' edge_label )* )? '}' )? prop_list_schema? ')' '->' '(' node_id_schema ')'
    ;

undirected_schema
    : 'S' '(' node_id_schema ')' '-' '(' ( '{' ( edge_label ( ',' edge_label )* )? '}' )? prop_list_schema? ')' '-' '(' node_id_schema ')'
    ;

graph_schema
    : 'S' '/' graph_id '/' ( '{' ( graph_label ( ',' graph_label )* )? '}' )? prop_list_schema?
    ;

number
    : UNSIGNED_INT
    | SIGNED_INT
    | DECIMAL
    | DOUBLE
    ;

fragment A : [aA];
fragment B : [bB];
fragment C : [cC];
fragment D : [dD];
fragment E : [eE];
fragment F : [fF];
fragment G : [gG];
fragment H : [hH];
fragment I : [iI];
fragment J : [jJ];
fragment K : [kK];
fragment L : [lL];
fragment M : [mM];
fragment N : [nN];
fragment O : [oO];
fragment P : [pP];
fragment Q : [qQ];
fragment R : [rR];
fragment S : [sS];
fragment T : [tT];
fragment U : [uU];
fragment V : [vV];
fragment W : [wW];
fragment X : [xX];
fragment Y : [yY];
fragment Z : [zZ];

OPTIONAL
    : O P T I O N A L
    ;

NULL
    : N U L L
    ;

UNIQUE
    : U N I Q U E
    ;

MIN
    : M I N
    ;

MAX
    : M A X
    ;

SECTION_NAME
    : 'GRAPH'
    | 'METADATA'
    | 'NODE SCHEMAS'
    | 'EDGE SCHEMAS'
    | 'NODES'
    | 'EDGES'
    ;

COMMENT
    : '#' ~[\r\n\f]* -> skip
    ;

STRING
    : STRING_LITERAL_QUOTE
    ;

UNSIGNED_INT
    : [0-9]+
    ;

SIGNED_INT
   : SIGN [0-9]+
   ;

DECIMAL
   : SIGN? [0-9]* '.' [0-9]+
   ;

DOUBLE
   : SIGN? ([0-9]+ '.' [0-9]* EXPONENT | '.' [0-9]+ EXPONENT | [0-9]+ EXPONENT)
   ;

EXPONENT
   : [eE] SIGN? [0-9]+
   ;

BOOL
    : 'true'
    | 'false'
    ;

DATETYPE
    : DATETIME | DATE | TIME
    ;

DATE
    : '-'? [0-9][0-9][0-9][0-9] '-' [0-9][0-9] '-' [0-9][0-9] TIMEZONE?
    ;

TIME
    : [0-9][0-9] ':' [0-9][0-9] ':' [0-9][0-9] ('.' [0-9]+)? TIMEZONE?
    ;

TIMEZONE
    : SIGN? [0-9][0-9] ':' [0-9][0-9]
    ;

DATETIME
    : '-'? [0-9][0-9][0-9][0-9] '-' [0-9][0-9] '-' [0-9][0-9] 'T' [0-9][0-9] ':' [0-9][0-9] ':' [0-9][0-9] ('.' [0-9]+)? TIMEZONE?
    ;

SIGN
    : '+'
    | '-'
    ;

STRING_LITERAL_QUOTE
    : '"' (~ ["\\\r\n] | '\'' | '\\"')* '"'
    ;

ALNUM_PLUS
    : PN_CHARS_BASE ((PN_CHARS | '.')* PN_CHARS)?
    ;

IRI
    : '<' (PN_CHARS | '.' | ':' | '/' | '\\' | '#' | '@' | '%' | '&' | UCHAR)* '>'
    ;

PN_CHARS
    : PN_CHARS_U | '-' | [0-9] | '\u00B7' | [\u0300-\u036F] | [\u203F-\u2040]
    ;

PN_CHARS_U
    : PN_CHARS_BASE | '_'
    ;

UCHAR
    : '\\u' HEX HEX HEX HEX | '\\U' HEX HEX HEX HEX HEX HEX HEX HEX
    ;

PN_CHARS_BASE
    : 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '\u00C0' .. '\u00D6' | '\u00D8' .. '\u00F6' | '\u00F8' .. '\u02FF' | '\u0370' .. '\u037D' | '\u037F' .. '\u1FFF' | '\u200C' .. '\u200D' | '\u2070' .. '\u218F' | '\u2C00' .. '\u2FEF' | '\u3001' .. '\uD7FF' | '\uF900' .. '\uFDCF' | '\uFDF0' .. '\uFFFD'
    ;
    
HEX
    : [0-9] | [A-F] | [a-f]
    ;

WS
    : [ \t\n]+ -> skip
    ;
