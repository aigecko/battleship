// The functions contained in this file are pretty dummy
// and are included only as a placeholder. Nevertheless,
// they *will* get included in the shared library if you
// don't remove them :)
//
// Obviously, you 'll have to write yourself the super-duper
// functions to include in the resulting library...
// Also, it's not necessary to write every function in this file.
// Feel free to add more files in this project. They will be
// included in the resulting library.
#include <stdlib.h>
#include "ruby.h"
#include "MH.h"
VALUE name(VALUE self){
    return rb_str_new_cstr("MHPlayer");
}
VALUE new_game(VALUE self){
    const struct Ship *ships=getNewGameShips();
    VALUE table=rb_ary_new_capa(5);
    for(int i=0;i<5;i++){
        struct Ship ship=ships[i];
        rb_ary_store(table,i,
            rb_ary_new_from_args(4,
                INT2FIX(ship.x),
                INT2FIX(ship.y),
                INT2FIX(ship.length),
                (ship.direct==ACROSS)?ID2SYM(rb_intern("across")):ID2SYM(rb_intern("down"))
            ));
    }
    return table;
}
VALUE take_turn(VALUE state,VALUE ships_remaining){
    int packed=getFirePosition();
    int y=packed&0xf;
    int x=packed>>16;
    return rb_ary_new_from_args(2,INT2FIX(x),INT2FIX(y));
}
void Init_MHPlayer(){
    VALUE MHPlayer=rb_define_class("MHPlayer",rb_cObject);
    rb_define_method(MHPlayer,"name",name,0);
    rb_define_method(MHPlayer,"new_game",new_game,0);
    rb_define_method(MHPlayer,"take_turn",take_turn,2);
}
