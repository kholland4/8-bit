//TODO: POKE and PEEK
//TODO: figure out subroutine issue with expression parser
//TODO: PRINT w/o trailing newline
//TODO: CLEAR, LIST

//lcd setup
34 io
32 io

34 io
32 io
130 io
128 io

2 io
0 io
98 io
96 io

2 io
0 io
242 io
240 io

//setup subroutine call stack
254 rh
0 rl
0 rh,rl

::exec_loop rh
:exec_loop rl
0 rh,rl

::expr_stack_frame rh
0 rl
0 rh,rl


call :tty_cls

.loopMain

//get input
call :tty_get_line
::getline_buf_index rh
rh,:getline_buf_index rl
::tty_getline_buf rh
0 rh,rl
//output a newline
255 rh
0 rl
10 rh,rl
call :tty_putch

//--------------------
//tokenize line
::curs rh
:curs rl
0 rh,rl

//output length
::tokenize_len rh
:tokenize_len rl
0 rh,rl

.tokenize_loop
//get current char
::curs rh
rh,:curs rl
::tty_getline_buf rh
rh,rl a
::ch rh
a rh,:ch
//get next char
::curs rh
rh,:curs a
1 b
0 flags
add rl
::tty_getline_buf rh
rh,rl a
::ch2 rh
a rh,:ch2
//get 3rd char
::curs rh
rh,:curs a
2 b
0 flags
add rl
::tty_getline_buf rh
rh,rl a
::ch3 rh
a rh,:ch3

//if it's nul
::ch rh
rh,:ch a
0 b
branch :tokenize_quit a=b

//if it's a letter
::ch rh
rh,:ch a
96 b
::temp rh
a>b rh,:temp
123 b
a<b b
rh,:temp a
and a
branch :tokenize_is_letter a

//if it's a space
::ch rh
rh,:ch a
32 b
branch :tokenize_end a=b

//if it's a quote
::ch rh
rh,:ch a
'"' b
branch :tokenize_is_quote a=b

//if it's another symbol
branch :tokenize_is_symbol 1

.tokenize_is_letter
::ch2 rh
rh,:ch2 a
96 b
::temp rh
a>b rh,:temp
123 b
a<b b
rh,:temp a
and a
branch :tokenize_is_double_letter a

.tokenize_is_single_letter
branch :tokenize_is_symbol 1

.tokenize_is_double_letter
//double letter - keyword



//'p'?
::ch rh
rh,:ch a
'p' b
a=b a
255 b
xor a
branch :tokenize_dl_next1 a
//"print"
::tokenize_len rh
rh,:tokenize_len rl
::basic_line_buf rh
128 rh,rl
branch :tokenize_dl_fin 1


.tokenize_dl_next1
//'i'?
::ch rh
rh,:ch a
'i' b
a=b a
255 b
xor a
branch :tokenize_dl_next2 a
//'f'?
::ch2 rh
rh,:ch2 a
'f' b
branch :tokenize_dl_next1_a a=b
//"input"
::tokenize_len rh
rh,:tokenize_len rl
::basic_line_buf rh
132 rh,rl
branch :tokenize_dl_fin 1
.tokenize_dl_next1_a
//"if"
::tokenize_len rh
rh,:tokenize_len rl
::basic_line_buf rh
129 rh,rl
branch :tokenize_dl_fin 1


.tokenize_dl_next2
//'t'?
::ch rh
rh,:ch a
't' b
a=b a
255 b
xor a
branch :tokenize_dl_next3 a
//"then"
::tokenize_len rh
rh,:tokenize_len rl
::basic_line_buf rh
130 rh,rl
branch :tokenize_dl_fin 1


.tokenize_dl_next3
//'g'?
::ch rh
rh,:ch a
'g' b
a=b a
255 b
xor a
branch :tokenize_dl_next4 a
//'t'?
::ch3 rh
rh,:ch3 a
't' b
branch :tokenize_dl_next3_a a=b
//"gosub"
::tokenize_len rh
rh,:tokenize_len rl
::basic_line_buf rh
134 rh,rl
branch :tokenize_dl_fin 1
.tokenize_dl_next3_a
//"goto"
::tokenize_len rh
rh,:tokenize_len rl
::basic_line_buf rh
131 rh,rl
branch :tokenize_dl_fin 1


.tokenize_dl_next4
//'l'?
::ch rh
rh,:ch a
'l' b
a=b a
255 b
xor a
branch :tokenize_dl_next5 a
//'e'?
::ch2 rh
rh,:ch2 a
'e' b
branch :tokenize_dl_next4_a a=b
//"list"
::tokenize_len rh
rh,:tokenize_len rl
::basic_line_buf rh
137 rh,rl
branch :tokenize_dl_fin 1
.tokenize_dl_next4_a
//"let"
::tokenize_len rh
rh,:tokenize_len rl
::basic_line_buf rh
133 rh,rl
branch :tokenize_dl_fin 1


.tokenize_dl_next5
//'r'?
::ch rh
rh,:ch a
'r' b
a=b a
255 b
xor a
branch :tokenize_dl_next6 a
//'e'?
::ch2 rh
rh,:ch2 a
'e' b
branch :tokenize_dl_next5_a a=b
//"run"
::tokenize_len rh
rh,:tokenize_len rl
::basic_line_buf rh
138 rh,rl
branch :tokenize_dl_fin 1
.tokenize_dl_next5_a
//"return"
::tokenize_len rh
rh,:tokenize_len rl
::basic_line_buf rh
135 rh,rl
branch :tokenize_dl_fin 1


.tokenize_dl_next6
//'c'?
::ch rh
rh,:ch a
'c' b
a=b a
255 b
xor a
branch :tokenize_dl_next7 a
//"clear"
::tokenize_len rh
rh,:tokenize_len rl
::basic_line_buf rh
136 rh,rl
branch :tokenize_dl_fin 1


.tokenize_dl_next7
//'e'?
::ch rh
rh,:ch a
'e' b
a=b a
255 b
xor a
branch :tokenize_dl_next8 a
//"end"
::tokenize_len rh
rh,:tokenize_len rl
::basic_line_buf rh
139 rh,rl
branch :tokenize_dl_fin 1


.tokenize_dl_next8
branch :tokenize_error 1



.tokenize_dl_fin
//increment tokenize_len
::tokenize_len rh
rh,:tokenize_len a
0 flags
1 b
add rh,:tokenize_len
.tokenize_dl_fin_loop
//done, scan to last letter
::curs rh
rh,:curs a
0 flags
1 b
add a
a rh,:curs
::tty_getline_buf rh
a rl
rh,rl a
//get current char
::curs rh
rh,:curs rl
::tty_getline_buf rh
rh,rl a
//if it's a letter
96 b
::temp rh
a>b rh,:temp
123 b
a<b b
rh,:temp a
and a
branch :tokenize_dl_fin_loop a
branch :tokenize_loop 1


.tokenize_is_quote
::ch rh
rh,:ch a
//append
::tokenize_len rh
rh,:tokenize_len rl
::basic_line_buf rh
a rh,rl
//increment tokenize_len
::tokenize_len rh
rh,:tokenize_len a
0 flags
1 b
add rh,:tokenize_len
.tokenize_is_quote_loop
//increment curs
::curs rh
rh,:curs a
0 flags
1 b
add a
a rh,:curs
::tty_getline_buf rh
a rl
rh,rl a
::ch rh
a rh,:ch
//append
::tokenize_len rh
rh,:tokenize_len rl
::basic_line_buf rh
a rh,rl
//increment tokenize_len
::tokenize_len rh
rh,:tokenize_len a
0 flags
1 b
add rh,:tokenize_len
//if it's a quote
::ch rh
rh,:ch a
'"' b
branch :tokenize_end a=b
//loop
branch :tokenize_is_quote_loop 1

.tokenize_is_symbol
::ch rh
rh,:ch a
::tokenize_len rh
rh,:tokenize_len b
b rl
::basic_line_buf rh
a rh,rl
0 flags
1 a
add a
::tokenize_len rh
a rh,:tokenize_len
branch :tokenize_end 1

//loop de loop
.tokenize_end
::curs rh
rh,:curs a
1 b
0 flags
add rh,:curs
branch :tokenize_loop 1

.tokenize_error
255 rh
0 rl
'e' rh,rl
call :tty_putch
255 rh
0 rl
'r' rh,rl
call :tty_putch
255 rh
0 rl
'r' rh,rl
call :tty_putch
255 rh
0 rl
'o' rh,rl
call :tty_putch
255 rh
0 rl
'r' rh,rl
call :tty_putch
255 rh
0 rl
''' rh,rl
call :tty_putch
::ch rh
rh,:ch a
255 rh
a rh,0
call :tty_putch
255 rh
0 rl
''' rh,rl
call :tty_putch
::curs rh
rh,:curs a
255 rh
0 rl
0 rh,rl
255 rh
a rh,1
call :print_num
255 rh
0 rl
10 rh,rl
call :tty_putch
branch :loopMain 1

.tokenize_quit
//null-terminate
::tokenize_len rh
rh,:tokenize_len rl
::basic_line_buf rh
0 rh,rl

//starts with a number?
::basic_line_buf rh
rh,0 a
47 b
::temp rh
a>b rh,:temp
58 b
a<b b
rh,:temp a
branch :run_is_number and

.main_eloop

::curs rh
:curs rl
0 rh,rl
call :basic_exec

::exec_loop rh
rh,:exec_loop a
branch :main_eloop a

branch :loopMain 1

.run_is_number
//reset curs
::curs rh
:curs rl
0 rh,rl
//get number
255 rh
0 rl
::basic_line_buf rh,rl
call :get_num
call :line_to_addr

//copy 64 bytes starting at curs
0 flags
0 a
.store_copy_loop
::curs rh
rh,:curs b
add rl
::basic_line_buf rh
rh,rl b
::temp rh
b rh,:temp

::store_target_lo rh
rh,:store_target_lo b
add rl
::temp rh
rh,:temp b
::store_target_hi rh
rh,:store_target_hi rh
b rh,rl

1 b
add a

64 b
branch :store_copy_loop a<b

branch :loopMain 1

//---BEGIN line_to_addr---

.line_to_addr
255 rh
rh,0 a
::store_line_num_hi rh
a rh,:store_line_num_hi
255 rh
rh,1 a
::store_line_num_lo rh
a rh,:store_line_num_lo

//low address - xx000000
0 flags
a b
add a
0 flags
a b
add a
0 flags
a b
add a
0 flags
a b
add a
0 flags
a b
add a
0 flags
a b
add a
::store_target_lo rh
a rh,:store_target_lo

//high address - 0zxxxxxx
::store_line_num_hi rh
rh,:store_line_num_hi a
0 flags
a b
add a
0 flags
a b
add a
0 flags
a b
add a
0 flags
a b
add a
0 flags
a b
add a
0 flags
a b
add a

0b01000000 b
and a

::store_line_num_lo rh
rh,:store_line_num_lo b
bsr b
bsr b
or a
0 flags
::basic_prgm b
add a
::store_target_hi rh
a rh,:store_target_hi

ret

//---END line_to_addr---

//---BEGIN basic_exec---
.basic_exec

//get token
::curs rh
rh,:curs rl
::basic_line_buf rh
rh,rl a
::tok rh
a rh,:tok

//increment curs
::curs rh
rh,:curs a
0 flags
1 b
add rh,:curs
//load tok
::tok rh
rh,:tok a

//token PRINT?
128 b
branch :exec_tok_print a=b
//token IF?
129 b
branch :exec_tok_if a=b
//token GOTO?
131 b
branch :exec_tok_goto a=b
//token INPUT?
132 b
branch :exec_tok_input a=b
//token LET?
133 b
branch :exec_tok_let a=b
//token GOSUB?
134 b
branch :exec_tok_gosub a=b
//token RETURN?
135 b
branch :exec_tok_return a=b
//token CLEAR?
136 b
branch :exec_tok_clear a=b
//token LIST?
137 b
branch :exec_tok_list a=b
//token RUN?
138 b
branch :exec_tok_run a=b
//token END?
139 b
branch :exec_tok_end a=b

'1' a
branch :exec_error 1


.exec_tok_print
.exec_tok_print_loop
//get ch
::curs rh
rh,:curs rl
::basic_line_buf rh
rh,rl a
::ch rh
a rh,:ch

//clear flag
::tok_print_last_char_comma rh
:tok_print_last_char_comma rl
0 rh,rl

//is it null?
::ch rh
rh,:ch a
0 b
branch :exec_tok_print_end a=b

//is it ','?
::ch rh
rh,:ch a
',' b
a=b a
255 b
xor a
branch :exec_tok_print_next1 a
//increment curs
::curs rh
rh,:curs a
0 flags
1 b
add rh,:curs
//set flag
::tok_print_last_char_comma rh
:tok_print_last_char_comma rl
1 rh,rl
branch :exec_tok_print_loop 1

.exec_tok_print_next1
//is it '"'?
::ch rh
rh,:ch a
'"' b
a=b a
255 b
xor a
branch :exec_tok_print_next2 a
.exec_tok_print_qloop
//increment curs
::curs rh
rh,:curs a
0 flags
1 b
add rh,:curs
//get ch
rh,:curs rl
::basic_line_buf rh
rh,rl a
::ch rh
a rh,:ch
//is it '"'?
'"' b
branch :exec_tok_print_qloop_end a=b
//print
255 rh
a rh,0
call :tty_putch
branch :exec_tok_print_qloop 1

.exec_tok_print_qloop_end
//increment curs
::curs rh
rh,:curs a
0 flags
1 b
add rh,:curs

branch :exec_tok_print_loop 1

.exec_tok_print_next2
//is it '0'-'9'?
::ch rh
rh,:ch a
47 b
::temp rh
a>b rh,:temp
58 b
a<b b
rh,:temp a
and a
255 b
xor a
branch :exec_tok_print_next3 a
::expr_stack_len rh
:expr_stack_len rl
0 rh,rl
::expr_stack_frame_len rh
:expr_stack_frame_len rl
0 rh,rl
call :basic_expr

//TODO
::expr_out_hi rh
rh,:expr_out_hi a
255 rh
a rh,0
::expr_out_lo rh
rh,:expr_out_lo a
255 rh
a rh,1

call :print_num
branch :exec_tok_print_loop 1

.exec_tok_print_next3
//is it 'a'-'z'?
::ch rh
rh,:ch a
96 b
::temp rh
a>b rh,:temp
123 b
a<b b
rh,:temp a
and a
255 b
xor a
branch :exec_tok_print_next4 a
::expr_stack_len rh
:expr_stack_len rl
0 rh,rl
::expr_stack_frame_len rh
:expr_stack_frame_len rl
0 rh,rl
call :basic_expr
call :print_num
branch :exec_tok_print_loop 1

.exec_tok_print_next4
'2' a
branch :exec_error 1

.exec_tok_print_end
::tok_print_last_char_comma rh
rh,:tok_print_last_char_comma a
1 b
branch :exec_end a=b
255 rh
0 rl
10 rh,rl
call :tty_putch
branch :exec_end 1

.exec_tok_if
//TODO: syntax checking?
//get expr
::expr_stack_len rh
:expr_stack_len rl
0 rh,rl
::expr_stack_frame_len rh
:expr_stack_frame_len rl
0 rh,rl
call :basic_expr
//increment curs ("then" token")
::curs rh
rh,:curs a
0 flags
1 b
add rh,:curs
//
255 rh
rh,1 a
branch :basic_exec a

branch :exec_end 1

.exec_tok_goto
255 rh
0 rl
::basic_line_buf rh,rl
call :get_num
255 rh
rh,1 a
::goto_line rh
a rh,:goto_line
branch :exec_end 1

.exec_tok_input
//TODO: syntax checking?
//get ch
::curs rh
rh,:curs rl
::basic_line_buf rh
rh,rl a
::ch rh
a rh,:ch
//::ch rh
//rh,:ch a
::exec_let_target rh
a rh,:exec_let_target
//reset curs
::curs rh
:curs rl
0 rh,rl
//get input
call :tty_get_line
::getline_buf_index rh
rh,:getline_buf_index rl
::tty_getline_buf rh
0 rh,rl
//output a newline
255 rh
0 rl
10 rh,rl
call :tty_putch
//reset curs
::curs rh
:curs rl
0 rh,rl
//process number
255 rh
0 rl
::tty_getline_buf rh,rl
call :get_num
//store res
::expr_var_hi rh
rh,:expr_var_hi a
::exec_let_target rh
rh,:exec_let_target b
b rl
::basic_vars rh
a rh,rl
0 flags
128 a
add rl
::expr_var_lo rh
rh,:expr_var_lo a
::basic_vars rh
a rh,rl
//FIXME: curs is invalid
branch :exec_end 1

.exec_tok_let
//TODO: syntax checking?
//get ch
::curs rh
rh,:curs rl
::basic_line_buf rh
rh,rl a
::ch rh
a rh,:ch
//::ch rh
//rh,:ch a
::exec_let_target rh
a rh,:exec_let_target
//increment curs by 2
::curs rh
rh,:curs a
0 flags
2 b
add rh,:curs
//get expr
::expr_stack_len rh
:expr_stack_len rl
0 rh,rl
::expr_stack_frame_len rh
:expr_stack_frame_len rl
0 rh,rl
call :basic_expr
//store res
255 rh
rh,0 a
::exec_let_target rh
rh,:exec_let_target b
b rl
::basic_vars rh
a rh,rl
0 flags
128 a
add rl
255 rh
rh,1 a
::basic_vars rh
a rh,rl
branch :exec_end 1

.exec_tok_gosub
branch :exec_end 1

.exec_tok_return
branch :exec_end 1

.exec_tok_clear
call :basic_clear
branch :exec_end 1

.exec_tok_list
branch :exec_end 1

.exec_tok_run
::curr_line rh
:curr_line rl
0 rh,rl
::goto_line rh
:goto_line rl
0 rh,rl
::exec_loop rh
:exec_loop rl
1 rh,rl
branch :exec_end 1

.exec_tok_end
::exec_loop rh
:exec_loop rl
0 rh,rl
branch :exec_end 1


.exec_error
255 rh
0 rl
a rh,rl
call :tty_putch
255 rh
0 rl
'e' rh,rl
call :tty_putch
255 rh
0 rl
'r' rh,rl
call :tty_putch
255 rh
0 rl
'r' rh,rl
call :tty_putch
255 rh
0 rl
10 rh,rl
call :tty_putch

.exec_end

::exec_loop rh
rh,:exec_loop a
255 b
branch :exec_no_exec_loop xor


::goto_line rh
rh,:goto_line a
0 b
branch :exec_l_has_goto a>b

//find next line
//  get addr of current line
255 rh
0 rl
0 rh,rl
::curr_line rh
rh,:curr_line a
255 rh
a rh,1
call :line_to_addr

.exec_l_search
//  loop until the next valid line
//    add 64
0 flags
::store_target_lo rh
rh,:store_target_lo a
64 b
add rh,:store_target_lo
::store_target_hi rh
rh,:store_target_hi a
0 b
add rh,:store_target_hi
//    increment curr_line
::curr_line rh
rh,:curr_line a
0 flags
1 b
add rh,:curr_line
//    check if out-of-bounds
//FIXME FIXME
::store_target_hi rh
rh,:store_target_hi a
128 b
and a
0 b
branch :exec_l_search_end a>b

//    check if line is valid
::store_target_lo rh
rh,:store_target_lo a
::store_target_hi rh
rh,:store_target_hi b
b rh
a rl
rh,rl a
0 b

branch :exec_l_search a=b


.exec_l_search_found
branch :exec_l_fin 1

.exec_l_search_end
::exec_loop rh
:exec_loop rl
0 rh,rl
branch :exec_no_exec_loop 1
//done

.exec_l_has_goto

::goto_line rh
:goto_line rl
rh,rl a
0 rh,rl
::curr_line rh
a rh,:curr_line

//load curr_line
255 rh
0 rl
0 rh,rl
::curr_line rh
rh,:curr_line a
255 rh
a rh,1
call :line_to_addr

.exec_l_fin

//copy 64 bytes
0 flags
0 a
.exec_store_copy_loop
::store_target_lo rh
rh,:store_target_lo b
add rl
::store_target_hi rh
rh,:store_target_hi rh
rh,rl b

a rl
::basic_line_buf rh
b rh,rl

1 b
add a

64 b
branch :exec_store_copy_loop a<b
//DONE

.exec_no_exec_loop

ret

//---END basic_exec---

//---BEGIN basic_expr---

.basic_expr

//push to stack frame
::expr_stack_len rh
rh,:expr_stack_len a
::expr_stack_frame_len rh
rh,:expr_stack_frame_len b
b rl
::expr_stack_frame rh
a rh,rl
0 flags
1 a
::expr_stack_frame_len rh
add rh,:expr_stack_frame_len


.basic_expr_loop
//get ch
::curs rh
rh,:curs rl
::basic_line_buf rh
rh,rl a
::ch rh
a rh,:ch

//TODO
//call :test_sub
//branch :ts_skip 1
//.test_sub
//ret
//.ts_skip
//::ch rh
//rh,:ch a
0 flags

0 b
branch :basic_expr_end a=b
',' b
branch :basic_expr_end a=b
127 b
branch :basic_expr_end a>b
')' b
branch :basic_expr_rparen a=b
'(' b
branch :basic_expr_lparen a=b
//number?
47 b
::temp rh
a>b rh,:temp
58 b
a<b a
rh,:temp b
branch :basic_expr_num and
::ch rh
rh,:ch a
//letter?
96 b
::temp rh
a>b rh,:temp
123 b
a<b a
rh,:temp b
branch :basic_expr_var and
//other?
branch :basic_expr_sym 1



.basic_expr_rparen
//increment curs
::curs rh
rh,:curs a
0 flags
1 b
add rh,:curs
branch :basic_expr_end 1

.basic_expr_lparen
//increment curs
::curs rh
rh,:curs a
0 flags
1 b
add rh,:curs
//recurse
call :basic_expr
//push expr_out onto stack
::expr_stack_len rh
rh,:expr_stack_len a
a rl
::expr_out_hi rh
rh,:expr_out_hi b
::expr_stack_hi rh
b rh,rl
::expr_out_lo rh
rh,:expr_out_lo b
::expr_stack_lo rh
b rh,rl
0 flags
1 b
::expr_stack_len rh
add rh,:expr_stack_len
branch :basic_expr_loop 1

.basic_expr_num
255 rh
0 rl
::basic_line_buf rh,rl
call :get_num
//push onto expr stack
::expr_stack_len rh
rh,:expr_stack_len a
a rl
::expr_var_hi rh
rh,:expr_var_hi b
::expr_stack_hi rh
b rh,rl
::expr_var_lo rh
rh,:expr_var_lo b
::expr_stack_lo rh
b rh,rl
0 flags
1 b
::expr_stack_len rh
add rh,:expr_stack_len
branch :basic_expr_loop 1


.basic_expr_var
//get var value
::ch rh
rh,:ch a
a rl
::basic_vars rh
rh,rl b
::expr_var_hi rh
b rh,:expr_var_hi
0 flags
128 b
add rl
::basic_vars rh
rh,rl b
::expr_var_lo rh
b rh,:expr_var_lo
//push onto expr stack
::expr_stack_len rh
rh,:expr_stack_len a
a rl
::expr_var_hi rh
rh,:expr_var_hi b
::expr_stack_hi rh
b rh,rl
::expr_var_lo rh
rh,:expr_var_lo b
::expr_stack_lo rh
b rh,rl
0 flags
1 b
::expr_stack_len rh
add rh,:expr_stack_len
//increment curs
::curs rh
rh,:curs a
0 flags
1 b
add rh,:curs
branch :basic_expr_loop 1

.basic_expr_sym
::ch rh
rh,:ch b
//push onto expr_stack
::expr_stack_len rh
rh,:expr_stack_len a
a rl
::expr_stack_lo rh
b rh,rl
::expr_stack_hi rh
0 rh,rl
0 flags
1 b
::expr_stack_len rh
add rh,:expr_stack_len
//increment curs
::curs rh
rh,:curs a
0 flags
1 b
add rh,:curs
branch :basic_expr_loop 1

.basic_expr_end




//get current stack frame
::expr_stack_frame_len rh
rh,:expr_stack_frame_len a
0 flags
255 b
add rl
::expr_stack_frame rh
rh,rl a
::expr_sidx rh
a rh,:expr_sidx

//get first item on stack
::expr_sidx rh
rh,:expr_sidx rl
::expr_stack_lo rh
rh,rl a
::expr_out_lo rh
a rh,:expr_out_lo
::expr_stack_hi rh
rh,rl a
::expr_out_hi rh
a rh,:expr_out_hi
//increment expr_sidx
::expr_sidx rh
rh,:expr_sidx a
0 flags
1 b
add rh,:expr_sidx

.basic_expr_eloop

//if over length, quit
::expr_sidx rh
rh,:expr_sidx a
::expr_stack_len rh
rh,:expr_stack_len b
a<b a
255 b
branch :basic_expr_eloop_end xor

//get next value on stack, store it in expr_temp
::expr_sidx rh
rh,:expr_sidx a
0 flags
1 b
add rl
::expr_stack_lo rh
rh,rl a
::expr_temp_lo rh
a rh,:expr_temp_lo
::expr_stack_hi rh
rh,rl a
::expr_temp_hi rh
a rh,:expr_temp_hi

//get operator, store it in expr_op
::expr_sidx rh
rh,:expr_sidx rl
::expr_stack_lo rh
rh,rl a
::expr_op rh
a rh,:expr_op

'+' b
branch :expr_op_add a=b
'-' b
branch :expr_op_sub a=b
'<' b
branch :expr_op_lt a=b
'=' b
branch :expr_op_eq a=b
'>' b
branch :expr_op_gt a=b
'|' b
branch :expr_op_or a=b
'&' b
branch :expr_op_and a=b
'^' b
branch :expr_op_xor a=b
'/' b
branch :expr_op_divide a=b
branch :expr_error 1



.expr_op_add
0 flags
::expr_temp_lo rh
rh,:expr_temp_lo b
::expr_out_lo rh
rh,:expr_out_lo a
add rh,:expr_out_lo
::expr_temp_hi rh
rh,:expr_temp_hi b
::expr_out_hi rh
rh,:expr_out_hi a
add rh,:expr_out_hi
branch :expr_op_end 1

.expr_op_sub
//two's comp on expr_temp
0 flags
::expr_temp_lo rh
rh,:expr_temp_lo a
255 b
xor a
1 b
add rh,:expr_temp_lo
::expr_temp_hi rh
rh,:expr_temp_hi a
255 b
xor a
0 b
add rh,:expr_temp_hi
//add
0 flags
::expr_temp_lo rh
rh,:expr_temp_lo b
::expr_out_lo rh
rh,:expr_out_lo a
add rh,:expr_out_lo
::expr_temp_hi rh
rh,:expr_temp_hi b
::expr_out_hi rh
rh,:expr_out_hi a
add rh,:expr_out_hi
branch :expr_op_end 1

//TODO: 16-bit compare
.expr_op_lt
0 flags
::expr_temp_lo rh
rh,:expr_temp_lo b
::expr_out_lo rh
rh,:expr_out_lo a
a<b a
1 b
and rh,:expr_out_lo
::expr_out_hi rh
:expr_out_hi rl
0 rh,rl
branch :expr_op_end 1

.expr_op_eq
0 flags
::expr_temp_lo rh
rh,:expr_temp_lo b
::expr_out_lo rh
rh,:expr_out_lo a
a=b a
1 b
and rh,:expr_out_lo
::expr_out_hi rh
:expr_out_hi rl
0 rh,rl
branch :expr_op_end 1

.expr_op_gt
0 flags
::expr_temp_lo rh
rh,:expr_temp_lo b
::expr_out_lo rh
rh,:expr_out_lo a
a>b a
1 b
and rh,:expr_out_lo
::expr_out_hi rh
:expr_out_hi rl
0 rh,rl
branch :expr_op_end 1

.expr_op_or
0 flags
::expr_temp_lo rh
rh,:expr_temp_lo b
::expr_out_lo rh
rh,:expr_out_lo a
or rh,:expr_out_lo
::expr_temp_hi rh
rh,:expr_temp_hi b
::expr_out_hi rh
rh,:expr_out_hi a
or rh,:expr_out_hi
branch :expr_op_end 1

.expr_op_and
0 flags
::expr_temp_lo rh
rh,:expr_temp_lo b
::expr_out_lo rh
rh,:expr_out_lo a
and rh,:expr_out_lo
::expr_temp_hi rh
rh,:expr_temp_hi b
::expr_out_hi rh
rh,:expr_out_hi a
and rh,:expr_out_hi
branch :expr_op_end 1

.expr_op_xor
0 flags
::expr_temp_lo rh
rh,:expr_temp_lo b
::expr_out_lo rh
rh,:expr_out_lo a
xor rh,:expr_out_lo
::expr_temp_hi rh
rh,:expr_temp_hi b
::expr_out_hi rh
rh,:expr_out_hi a
xor rh,:expr_out_hi
branch :expr_op_end 1

.expr_op_divide
//FIXME - this only divides by 2
::expr_out_hi rh
rh,:expr_out_hi b
bsr rh,:expr_out_hi
1 a
and a
0 flags
a b
add a
a b
add a
a b
add a
a b
add a
a b
add a
a b
add a
a b
add a
::expr_out_lo rh
rh,:expr_out_lo b
bsr b
or rh,:expr_out_lo
branch :expr_op_end 1


.expr_op_end

//increment expr_sidx by 2 (op + val)
::expr_sidx rh
rh,:expr_sidx a
0 flags
2 b
add rh,:expr_sidx
//loop de loop
branch :basic_expr_eloop 1

.basic_expr_eloop_end


//pop stack frame
::expr_stack_frame_len rh
rh,:expr_stack_frame_len a
0 flags
255 b
add a
a rl
::expr_stack_frame rh
rh,rl b
::expr_stack_len rh
b rh,:expr_stack_len
::expr_stack_frame_len rh
a rh,:expr_stack_frame_len

//TODO
0 flags

//high half is 255,0
::expr_out_hi rh
rh,:expr_out_hi a
255 rh
a rh,0
//low half is 255,1
::expr_out_lo rh
rh,:expr_out_lo a
255 rh
a rh,1
//call :print_num

ret

.expr_error
255 rh
0 rl
'#' rh,rl
call :tty_putch
255 rh
0 rl
'$' rh,rl
call :tty_putch
//TODO: jump to interactive mode?
255 rh
0 rl
0 rh,rl
255 rh
1 rl
0 rh,rl
ret


//---END basic_expr---

//---BEGIN basic_clear---

.basic_clear
//clear basic_prgm (32k bytes)
::temp rh
:temp rl
::basic_prgm rh,rl
0 flags
::basic_prgm a
128 b
::ch rh
add rh,:ch
.clear_pre_loop_outer
0 a
::temp rh
rh,:temp rh
.clear_pre_loop_inner
a rl
0 rh,rl
0 flags
64 b
add a
0 b
branch :clear_pre_loop_inner_end a=b
branch :clear_pre_loop_inner 1
.clear_pre_loop_inner_end
::temp rh
rh,:temp a
0 flags
1 b
add a
a rh,:temp
::ch rh
rh,:ch b
branch :clear_pre_loop_outer a<b
ret

//---END basic_clear---

//---BEGIN get_num---

.get_num
::expr_var_hi rh
:expr_var_hi rl
0 rh,rl
::expr_var_lo rh
:expr_var_lo rl
0 rh,rl
.basic_expr_num_loop
//get ch
::curs rh
rh,:curs rl
//::basic_line_buf rh
255 rh
rh,0 rh
//
rh,rl a
::ch rh
a rh,:ch
//is it (not) a number?
47 b
::temp rh
a>b rh,:temp
58 b
a<b a
rh,:temp b
and a
255 b
xor a
branch :basic_expr_num_loop_end a
//multiply stored number by 10
//  double it
0 flags
::expr_var_lo rh
rh,:expr_var_lo a
a b
add rh,:expr_var_lo
::expr_var_hi rh
rh,:expr_var_hi a
a b
add a
a rh,:expr_var_hi
//  store in expr_temp
::expr_temp_hi rh
a rh,:expr_temp_hi
::expr_var_lo rh
rh,:expr_var_lo a
::expr_temp_lo rh
a rh,:expr_temp_lo
//  add expr_temp to expr_var 4 times
0 flags
::expr_temp_lo rh
rh,:expr_temp_lo b
::expr_var_lo rh
rh,:expr_var_lo a
add rh,:expr_var_lo
::expr_temp_hi rh
rh,:expr_temp_hi b
::expr_var_hi rh
rh,:expr_var_hi a
add rh,:expr_var_hi
0 flags
::expr_temp_lo rh
rh,:expr_temp_lo b
::expr_var_lo rh
rh,:expr_var_lo a
add rh,:expr_var_lo
::expr_temp_hi rh
rh,:expr_temp_hi b
::expr_var_hi rh
rh,:expr_var_hi a
add rh,:expr_var_hi
0 flags
::expr_temp_lo rh
rh,:expr_temp_lo b
::expr_var_lo rh
rh,:expr_var_lo a
add rh,:expr_var_lo
::expr_temp_hi rh
rh,:expr_temp_hi b
::expr_var_hi rh
rh,:expr_var_hi a
add rh,:expr_var_hi
0 flags
::expr_temp_lo rh
rh,:expr_temp_lo b
::expr_var_lo rh
rh,:expr_var_lo a
add rh,:expr_var_lo
::expr_temp_hi rh
rh,:expr_temp_hi b
::expr_var_hi rh
rh,:expr_var_hi a
add rh,:expr_var_hi
//add new digit
0 flags
::ch rh
rh,:ch a
0b11010000 b //two's comp of 48 ('0')
add a
0 flags
::expr_var_lo rh
rh,:expr_var_lo b
add rh,:expr_var_lo
::expr_var_hi rh
rh,:expr_var_hi b
0 a
add rh,:expr_var_hi
//increment curs
::curs rh
rh,:curs a
0 flags
1 b
add rh,:curs
branch :basic_expr_num_loop 1
//DONE:
.basic_expr_num_loop_end

::expr_var_hi rh
rh,:expr_var_hi a
255 rh
a rh,0
::expr_var_lo rh
rh,:expr_var_lo a
255 rh
a rh,1

ret

//---END get_num---

//---BEGIN print_num---

.print_num

//high half is 255,0
255 rh
rh,0 a
::print_num_hi rh
a rh,:print_num_hi
//low half is 255,1
255 rh
rh,1 a
::print_num_lo rh
a rh,:print_num_lo


255 rh
0 rl
'#' rh,rl
call :tty_putch
//first hex digit
::print_num_hi rh
rh,:print_num_hi b
bsr b
bsr b
bsr b
bsr b
15 a
and b
255 rh
0 rl
b rh,rl
call :print_hex_digit
//second hex digit
::print_num_hi rh
rh,:print_num_hi b
15 a
and b
255 rh
0 rl
b rh,rl
call :print_hex_digit
//third hex digit
::print_num_lo rh
rh,:print_num_lo b
bsr b
bsr b
bsr b
bsr b
15 a
and b
255 rh
0 rl
b rh,rl
call :print_hex_digit
//fourth hex digit
::print_num_lo rh
rh,:print_num_lo b
15 a
and b
255 rh
0 rl
b rh,rl
call :print_hex_digit


ret

//---END print_num---

//---BEGIN print_hex_digit---

.print_hex_digit

255 rh
rh,0 a

9 b
branch :print_hex_digit_letter a>b
'0' b
0 flags
add a
255 rh
a rh,0
call :tty_putch
ret

.print_hex_digit_letter
55 b
0 flags
add a
255 rh
a rh,0
call :tty_putch
ret

//---END print_hex_digit---

//---BEGIN tty_get_line---

.tty_get_line

::getline_buf_index rh
:getline_buf_index rl
0 rh,rl

.tty_get_line_loop

.loopInput
io a 1
0b10000000 b
and a
branch :kbdReady a=b
branch :loopInput 1

.kbdReady
//wait for data
wait 20

io a 2
io a 4
0xF0 b
branch :breakCode a=b
io a 2
0xF0 b
branch :tty_get_line_loop a=b

branch :haveCode 1

//check for shift
.breakCode
io a 2
0x12 b //scancode for LSHIFT
a=b a
255 b
xor a
::tty_get_line_loop iph
:tty_get_line_loop ipl
a branch
//LSHIFT release detected
::shift rh
:shift rl
0 rh,rl
branch :tty_get_line_loop 1

//have scancode
.haveCode
//save data
::scancode rh
:scancode rl
a rh,rl

0x12 b //scancode for lshift
a=b a
255 b
xor a
::noLSHIFT iph
:noLSHIFT ipl
a branch
//LSHIFT press detected
::shift rh
:shift rl
1 rh,rl
branch :tty_get_line_loop 1

.noLSHIFT
//check shift state
::shift rh
:shift rl
rh,rl a
1 b

branch :lookup_has_shift a=b

::scancode rh
:scancode rl
rh,rl a
::lookup_lower rh
branch :lookup_end 1

.lookup_has_shift
::scancode rh
:scancode rl
rh,rl a
::lookup_upper rh

.lookup_end

//decode data
a rl
rh,rl a
//store
255 rh
a rh,0

//if newline, ret
10 b
branch :tty_get_line_end a=b

::getline_buf_index rh
:getline_buf_index rl
rh,rl b
::tty_getline_buf rh
b rl
a rh,rl
1 a
::getline_buf_index rh
:getline_buf_index rl
0 flags
add rh,rl

call :tty_putch

branch :tty_get_line_loop 1

.tty_get_line_end

ret

//---END tty_get_line---

//---BEGIN tty_putch

.tty_putch
//load data
255 rh
rh,0 b

//if newline
10 a
a=b a
255 b
xor a
branch :tty_putch_no_newline a

//newline
.tty_putch_nl_loop

::tty_len rh
rh,:tty_len a

//save to scroll buf
::tty_scroll_buf rh
a rl
32 rh,rl

0 flags
1 b
add a
::tty_len rh
a rh,:tty_len

20 b
branch :tty_putch_newline a=b
40 b
branch :tty_putch_newline a=b
60 b
branch :tty_putch_newline a=b
80 b
branch :tty_putch_newline a=b

branch :tty_putch_nl_loop 1

.tty_putch_no_newline
//load data
255 rh
rh,0 b

0 flags
//high nibble
0b11110000 a
and b
//output
0b11 a
add io
0b01 a
add io
//load data
rh,0 b
//low nibble
15 a
and a
a b
add a
a b
add a
a b
add a
a b
add a
a b
0 flags
//output
0b11 a
add io
0b01 a
add io

//positioning
::tty_len rh
rh,:tty_len a

//save to scroll buf
255 rh
rh,0 b
::tty_scroll_buf rh
a rl
b rh,rl

1 b
add a
::tty_len rh
a rh,:tty_len

.tty_putch_newline

20 b
branch :tty_putch_line1 a=b
40 b
branch :tty_putch_line2 a=b
60 b
branch :tty_putch_line3 a=b
80 b
branch :tty_putch_line4 a=b
branch :tty_putch_end 1

.tty_putch_line1
0xC2 io
0xC0 io
2 io
0 io
branch :tty_putch_end 1

.tty_putch_line2
0x92 io
0x90 io
0x42 io
0x40 io
branch :tty_putch_end 1

.tty_putch_line3
0xD2 io
0xD0 io
0x42 io
0x40 io
branch :tty_putch_end 1

.tty_putch_line4

call :tty_scroll

0xD2 io
0xD0 io
0x42 io
0x40 io

::tty_len rh
:tty_len rl
60 rh,rl

branch :tty_putch_end 1

.tty_putch_end

ret

//---END tty_putch---

//---BEGIN tty_cls---

.tty_cls
::tty_len rh
:tty_len rl
0 rh,rl

//clear screen
2 io
0 io
18 io
16 io

ret

//---END tty_cls

//---BEGIN tty_scroll---

.tty_scroll

//clear screen
2 io
0 io
18 io
16 io

::tty_scroll_counter rh
:tty_scroll_counter rl
0 rh,rl
::tty_scroll_max rh
:tty_scroll_max rl
20 rh,rl

.tty_scroll_loop

::tty_scroll_counter rh
rh,:tty_scroll_counter a
0 flags
20 b
add rl
::tty_scroll_buf rh
rh,rl b
a rl
b rh,rl
::tty_scroll_temp rh
b rh,:tty_scroll_temp
//--------
//high nibble
0b11110000 a
and b
//output
0b11 a
or io
0b01 a
or io
//load data
rh,:tty_scroll_temp b
//low nibble
0 flags
15 a
and a
a b
add a
a b
add a
a b
add a
a b
add a
a b
//output
0b11 a
or io
0b01 a
or io
//-------

::tty_scroll_counter rh
rh,:tty_scroll_counter a
1 b
0 flags
add a
a rh,:tty_scroll_counter
::tty_scroll_max rh
rh,:tty_scroll_max b
branch :tty_scroll_loop a<b

20 a
branch :tty_scroll_next1 a<b
//set cursor to line 2
0xC2 io
0xC0 io
2 io
0 io
::tty_scroll_max rh
:tty_scroll_max rl
40 rh,rl
branch :tty_scroll_loop 1

.tty_scroll_next1
40 a
branch :tty_scroll_next2 a<b
//set cursor to line 3
0x92 io
0x90 io
0x42 io
0x40 io
::tty_scroll_max rh
:tty_scroll_max rl
60 rh,rl
branch :tty_scroll_loop 1

.tty_scroll_next2

ret

//---END tty_scroll---

..lookup_lower
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0B
dw 0x60
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x71
dw 0x31
dw 0x0
dw 0x0
dw 0x0
dw 0x7A
dw 0x73
dw 0x61
dw 0x77
dw 0x32
dw 0x0
dw 0x0
dw 0x63
dw 0x78
dw 0x64
dw 0x65
dw 0x34
dw 0x33
dw 0x0
dw 0x0
dw 0x20
dw 0x76
dw 0x66
dw 0x74
dw 0x72
dw 0x35
dw 0x0
dw 0x0
dw 0x6E
dw 0x62
dw 0x68
dw 0x67
dw 0x79
dw 0x36
dw 0x0
dw 0x0
dw 0x0
dw 0x6D
dw 0x6A
dw 0x75
dw 0x37
dw 0x38
dw 0x0
dw 0x0
dw 0x2C
dw 0x6B
dw 0x69
dw 0x6F
dw 0x30
dw 0x39
dw 0x0
dw 0x0
dw 0x2E
dw 0x2F
dw 0x6C
dw 0x3B
dw 0x70
dw 0x2D
dw 0x0
dw 0x0
dw 0x0
dw 0x27
dw 0x0
dw 0x5B
dw 0x3D
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0A
dw 0x5D
dw 0x0
dw 0x5C
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x8
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x1B
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0

..lookup_upper
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0B
dw 0x7E
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x51
dw 0x21
dw 0x0
dw 0x0
dw 0x0
dw 0x5A
dw 0x53
dw 0x41
dw 0x57
dw 0x40
dw 0x0
dw 0x0
dw 0x43
dw 0x58
dw 0x44
dw 0x45
dw 0x24
dw 0x23
dw 0x0
dw 0x0
dw 0x20
dw 0x56
dw 0x46
dw 0x54
dw 0x52
dw 0x25
dw 0x0
dw 0x0
dw 0x4E
dw 0x42
dw 0x48
dw 0x47
dw 0x59
dw 0x5E
dw 0x0
dw 0x0
dw 0x0
dw 0x4D
dw 0x4A
dw 0x55
dw 0x26
dw 0x2A
dw 0x0
dw 0x0
dw 0x3C
dw 0x4B
dw 0x49
dw 0x4F
dw 0x29
dw 0x28
dw 0x0
dw 0x0
dw 0x3E
dw 0x3F
dw 0x4C
dw 0x3A
dw 0x50
dw 0x5F
dw 0x0
dw 0x0
dw 0x0
dw 0x22
dw 0x0
dw 0x7B
dw 0x2B
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0A
dw 0x7D
dw 0x0
dw 0x7C
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x8
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x1B
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0
dw 0x0

..label_align
//main
.store_line_num_hi
dw 0
.store_line_num_lo
dw 0
.store_target_hi
dw 0
.store_target_lo
dw 0

.curs
dw 0
.ch
dw 0
.ch2
dw 0
.ch3
dw 0
.temp
dw 0
.tokenize_len
dw 0

.exec_loop
dw 0

//---basic_exec---
.exec_loop
dw 0
.curr_line
dw 0
.goto_line
dw 0
.tok
dw 0
.exec_let_target
dw 0
.tok_print_last_char_comma
dw 0

//---basic_expr---
.expr_stack_len
dw 0
.expr_stack_frame_len
dw 0

.expr_out_hi
dw 0
.expr_out_lo
dw 0

.expr_var_hi
dw 0
.expr_var_lo
dw 0
.expr_temp_hi
dw 0
.expr_temp_lo
dw 0

.expr_sidx
dw 0

.expr_op
dw 0

//---print_num---
.print_num_hi
dw 0
.print_num_lo
dw 0

//---tty_get_line---
.scancode
dw 0
.shift
dw 0
.getline_buf_index
dw 0

//---tty_cls---
.tty_len
dw 0

//---tty_scroll---
.tty_scroll_counter
dw 0
.tty_scroll_max
dw 0
.tty_scroll_temp
dw 0

//---

@section bss

..tty_scroll_buf
dw 0

..tty_getline_buf
dw 0

..expr_stack_hi
dw 0
..expr_stack_lo
dw 0
..expr_stack_frame
dw 0

..basic_line_buf
dw 0

..basic_vars
dw 0

..basic_prgm
dw 0
