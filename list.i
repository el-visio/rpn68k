LS_INSERT_BASE macro
  ; \1 compare operator
  ; \2 value offset
  ; \3 next offset

  LS_ARGSIZE 8
  LS_ARG.l list\@                 ; ELEM** list
  LS_ARG.l e\@                    ; ELEM* e

  while_in
    move.l list\@+LOCAL(a7),a1    
    ldc.l (a1)                   
    if_ne.l #0                   ;  while (*list != 0 ...
      restore.l
      sto.l a1
      ldc \2(a1)
      move.l e\@+LOCAL(a7),a1
      and_if_\1 \2(a1)              ;  ... && (*list)->value <compare operator> e->value)
        move.l list\@+LOCAL(a7),a1
        ldc.l (a1)
        add_.l #\3
        sto.l list\@+LOCAL(a7)    ; { list = &(*list)->next; }
  while_out

  move.l list\@+LOCAL(a7),a1
  ldc.l (a1)
  move.l e\@+LOCAL(a7),a1
  sto.l \3(a1)                   ; e->next = *list;
  ldc.l a1
  move.l list\@+LOCAL(a7),a1
  sto.l (a1)                      ; *list = e;

  drop.l
  drop.l

  endm


list_insert_asc macro
  LS_INSERT_BASE lo,\1,\2
  endm

list_insert_desc macro
  LS_INSERT_BASE hi,\1,\2
  endm
