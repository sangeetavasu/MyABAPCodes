CLASS lhc_ZR5092_TRAVEL DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR travel RESULT result.
    METHODS approve_travel FOR MODIFY
       keys FOR ACTION travel~approve_travel RESULT result.
    METHODS cancel_travel FOR MODIFY
      keys FOR ACTION travel~cancel_travel RESULT result.

ENDCLASS.

CLASS lhc_ZR5092_TRAVEL IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD approve_travel.

    READ ENTITIES OF ZR5092_travel IN LOCAL MODE
       ENTITY travel
          FIELDS ( status )
          WITH CORRESPONDING #( keys )
          RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-status = 'A'.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = new_message( id       = 'ZR5092_TRAVEL'
                                            number   = '001'
                                            v1       = <travel>-travelid
                                            severity = if_abap_behv_message=>severity-success )
                        %element-status = if_abap_behv=>mk-on
                        ) TO reported-travel.
      ELSE.
        MODIFY ENTITIES OF ZR5092_travel IN LOCAL MODE
           ENTITY travel
              UPDATE
                 FIELDS ( status )
                 WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                                 status = 'A' ) )
           FAILED failed
           REPORTED reported.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD cancel_travel.

      READ ENTITIES OF ZR5092_travel IN LOCAL MODE
       ENTITY travel
          FIELDS ( status )
          WITH CORRESPONDING #( keys )
          RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-status = 'C'.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = new_message( id       = 'ZR5092_TRAVEL'
                                            number   = '002'
                                            v1       = <travel>-travelid
                                            severity = if_abap_behv_message=>severity-success )
                        %element-status = if_abap_behv=>mk-on
                        ) TO reported-travel.
      ELSE.
        MODIFY ENTITIES OF ZR5092_travel IN LOCAL MODE
           ENTITY travel
              UPDATE
                 FIELDS ( status )
                 WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                                 status = 'C' ) )
           FAILED failed
           REPORTED reported.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
