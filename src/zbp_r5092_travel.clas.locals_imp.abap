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
    METHODS validate_customer FOR VALIDATE ON SAVE
       keys FOR travel~validate_customer.
    METHODS overall_status FOR DETERMINE ON MODIFY
       keys FOR travel~overall_status.
    METHODS earlynumbering_create FOR NUMBERING
       entities FOR CREATE travel.

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

  METHOD validate_customer.

    READ ENTITIES OF ZR5092_travel IN LOCAL MODE
         ENTITY travel
            FIELDS ( customerid )
            WITH CORRESPONDING #( keys )
            RESULT DATA(lt_travel).

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY Customer_ID.

    " Optimization of DB select: extract distinct non-initial customer IDs
    lt_customer = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = customerid EXCEPT * ).
    DELETE lt_customer WHERE customer_id IS INITIAL.

    IF lt_customer IS NOT INITIAL.
      " Check if customer ID exist
      SELECT FROM /dmo/customer FIELDS customer_id
        FOR ALL ENTRIES IN @lt_customer
        WHERE customer_id EQ @lt_customer-customer_id
        INTO TABLE @DATA(tb_valid_customers).
    ENDIF.

    LOOP AT lt_travel INTO DATA(ls_travel).

      READ TABLE tb_valid_customers INTO DATA(wa_valid_customers) WITH KEY customer_id = ls_travel-CustomerId.
      IF sy-subrc <> 0.
        " Customer is not specified
        APPEND VALUE #(  %key = ls_travel-%key ) TO failed-travel.
        APPEND VALUE #(  %key = ls_travel-%key
                         %msg = new_message( id       = 'ZR5092_TRAVEL'
                                             number   = '003'
                                             v1       = ls_travel-CustomerID
                                             severity = if_abap_behv_message=>severity-error )
                         %element-customerid = if_abap_behv=>mk-on )

                       TO  reported-travel.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD earlynumbering_create.
    DATA(agencyid) = /lrn/cl_s4d437_model=>get_agency_by_user(  ).

    mapped-travel = CORRESPONDING #( entities ).

    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<mapping>).
      <mapping>-AgencyId = agencyid.
      <mapping>-TravelId = /lrn/cl_s4d437_model=>get_next_travelid( ).
    ENDLOOP.

  ENDMETHOD.

  METHOD overall_status.

    READ ENTITIES OF ZR5092_travel IN LOCAL MODE
           ENTITY travel
              FIELDS ( status )
              WITH CORRESPONDING #( keys )
              RESULT DATA(lt_travel).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-status = ' '.
        MODIFY ENTITIES OF ZR5092_travel IN LOCAL MODE
           ENTITY travel
              UPDATE
                 FIELDS ( Status )
                 WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                                  Status = 'N' ) )
                             REPORTED DATA(update_reported).
        reported = CORRESPONDING #( DEEP update_reported ).

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
