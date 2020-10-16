--NOMBRE FICHERO: 20111065013001201900.01
SELECT RUCCOOP||'|'||TIPODOCUMENTO||'|'||NUMERODOCUMENTO||'|'||APELLIDOPATERNO||'|'||APELLIDOMATERNO||'|'||NOMBRESOCIO||'|'||RAZONSOCIAL||'|'||FECHAINGRESO||'|'||FECHARETIRO||'|'||ANOINFORMADO AS CONCATENADO
FROM
(
    SELECT 
        '20111065013' AS RUCCOOP,   --RUCCOOP
        CASE TIPOPERSONA
            WHEN 1 THEN --NATURAL
                CASE PKG_PERSONANATURAL.F_OBT_TIPODOCUMENTOID(CODIGOPERSONA)
                    WHEN 1 THEN --DNI
                        '01'
                    WHEN 4 THEN --CARNET EXTRANJERIA
                        '04'
                    WHEN 5 THEN --PERMISO PROVISIONAL
                        '08'
                    WHEN 7 THEN --PASAPORTE
                        '07'
                    WHEN 8 THEN --DNI
                        '01'
                    ELSE        --OTRO
                        '09'
                END
            WHEN 2 THEN --JURIDICA
                '06'            --RUC
        END AS TIPODOCUMENTO,       --TIPODOCUMENTO

        CASE TIPOPERSONA
            WHEN 1 THEN --NATURAL
                LPAD(PKG_PERSONANATURAL.F_OBT_NUMERODOCUMENTOID(CODIGOPERSONA), 15, ' ')
            WHEN 2 THEN --JURIDICA
                LPAD(PKG_PERSONA.F_OBT_NUMERORUC(CODIGOPERSONA), 15, ' ')
        END AS NUMERODOCUMENTO,     --NUMERODOCUMENTO
        CASE TIPOPERSONA
            WHEN 1 THEN --NATURAL
                LPAD(PKG_PERSONANATURAL.F_OBT_APELLIDOPATERNO(CODIGOPERSONA), 50, ' ')
            WHEN 2 THEN --JURIDICA
                ''--LPAD(' ', 50, ' ')
        END AS APELLIDOPATERNO,     --APELLIDOPATERNO
        CASE TIPOPERSONA
            WHEN 1 THEN --NATURAL
                LPAD(PKG_PERSONANATURAL.F_OBT_APELLIDOMATERNO(CODIGOPERSONA), 50, ' ')
            WHEN 2 THEN --JURIDICA
                ''--LPAD(' ', 50, ' ')
        END AS APELLIDOMATERNO,     --APELLIDOMATERNO
        CASE TIPOPERSONA
            WHEN 1 THEN --NATURAL
                LPAD(PKG_PERSONANATURAL.F_OBT_NOMBRES(CODIGOPERSONA), 80, ' ')
            WHEN 2 THEN --JURIDICA
                ''--LPAD(' ', 80, ' ')
        END AS NOMBRESOCIO,         --NOMBRESOCIO
        CASE TIPOPERSONA
            WHEN 1 THEN --NATURAL
                ''--LPAD(' ', 100, ' ')
            WHEN 2 THEN --JURIDICA
                LPAD(REPLACE(REPLACE(REPLACE(PKG_PERSONA.F_OBT_NOMBRECOMPLETO(CODIGOPERSONA), '''',''),' & ', ' Y '),'&', ' Y ') , 100, ' ')
        END AS RAZONSOCIAL,         --RAZONSOCIAL
        TO_CHAR(PKG_DATOSSOCIO.F_OBT_FECHAINGRESOCOOP(CODIGOPERSONA), 'DD/MM/YYYY') AS FECHAINGRESO,
                                    --FECHAINGRESO
        TO_CHAR(FECHARENUNCIA, 'DD/MM/YYYY') AS FECHARETIRO,
                                    --FECHARETIRO
        '2019' AS ANOINFORMADO      --ANOINFORMADO
    FROM
    (
        SELECT DISTINCT 
            PKG_PERSONA.F_OBT_TIPOPERSONA(CC.CODIGOPERSONA) AS TIPOPERSONA,
            CC.CODIGOPERSONA,
            FECHARENUNCIA
        FROM 
        (
            APORTES APO
            LEFT JOIN 
                (
                    SELECT CODIGOPERSONA, NUMEROCUENTA
                    FROM CUENTACORRIENTE
                ) CC
            ON CC.NUMEROCUENTA = APO.NUMEROCUENTA
        )
        LEFT JOIN SOLICITUDRENUNCIA SR
        ON CC.CODIGOPERSONA = SR.CODIGOPERSONA
        WHERE TO_CHAR(APO.FECHAMOVIMIENTO,'YYYY') = 2019
            AND ESTADO = 1
            AND APO.NUMEROCUENTA <> 0
            AND TIPOMOVIMIENTO <> 5
            AND CC.CODIGOPERSONA <> 1
    )
);