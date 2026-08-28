CLASS z5092_eml_code DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070050'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00008766'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z5092_EML_CODE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


    READ ENTITIES OF ZR5092_TRAVEL
      ENTITY Travel " /lrn/437b_r_travel
        ALL FIELDS
        WITH   VALUE #( ( agencyid = c_agency_id
                          travelid = c_travel_id ) )
        RESULT DATA(travels)
        FAILED DATA(failed).

    IF failed IS NOT INITIAL.
      out->write( `Error retrieving the travel` ).
    ELSE.
      MODIFY ENTITIES OF ZR5092_TRAVEL
        ENTITY Travel " /lrn/437b_r_travel
        UPDATE
        FIELDS ( description )
        WITH   VALUE #( ( agencyid    = c_agency_id
                          travelid    = c_travel_id
                          description = `My new Description` ) )
        FAILED failed.

      IF failed IS INITIAL.
        COMMIT ENTITIES.
        out->write( `Description successfully updated` ).

      ELSE.
        ROLLBACK ENTITIES.
        out->write( `Error updating the description` ).
      ENDIF.
    ENDIF.



  ENDMETHOD.
ENDCLASS.
