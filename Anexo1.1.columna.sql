--NOMBRE FICHERO: 20111065013001201900.01
--00:45
/*SELECT 
    RUCCOOP||'|'||
    TIPODOCUMENTO||'|'||
    RPAD(NVL(NUMERODOCUMENTO, ' '), 15, ' ')||'|'||
    RPAD(NVL(APELLIDOPATERNO, ' '), 50, ' ')||'|'||
    RPAD(NVL(APELLIDOMATERNO, ' '), 50, ' ')||'|'||
    RPAD(NVL(NOMBRESOCIO, ' '), 80, ' ')||'|'||
    RPAD(NVL(RAZONSOCIAL, ' '), 100, ' ')||'|'||
    LPAD(NVL(TO_CHAR(FECHAINGRESO, 'DD/MM/YYYY'), ' '), 10, ' ')||'|'||
    LPAD(NVL(TO_CHAR(FECHARETIRO, 'DD/MM/YYYY'), ' '), 10, ' ')||'|'||
    ANOINFORMADO
    AS CONCATENADO
FROM
(*/
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
                PKG_PERSONANATURAL.F_OBT_NUMERODOCUMENTOID(CODIGOPERSONA)
            WHEN 2 THEN --JURIDICA
                TO_CHAR(PKG_PERSONA.F_OBT_NUMERORUC(CODIGOPERSONA))
        END AS NUMERODOCUMENTO,     --NUMERODOCUMENTO
        CASE TIPOPERSONA
            WHEN 1 THEN --NATURAL
                PKG_PERSONANATURAL.F_OBT_APELLIDOPATERNO(CODIGOPERSONA)
            WHEN 2 THEN --JURIDICA
                ' '
        END AS APELLIDOPATERNO,     --APELLIDOPATERNO
        CASE TIPOPERSONA
            WHEN 1 THEN --NATURAL
                PKG_PERSONANATURAL.F_OBT_APELLIDOMATERNO(CODIGOPERSONA)
            WHEN 2 THEN --JURIDICA
                ' '
        END AS APELLIDOMATERNO,     --APELLIDOMATERNO
        CASE TIPOPERSONA
            WHEN 1 THEN --NATURAL
                PKG_PERSONANATURAL.F_OBT_NOMBRES(CODIGOPERSONA)
            WHEN 2 THEN --JURIDICA
                ' '
        END AS NOMBRESOCIO,         --NOMBRESOCIO
        CASE TIPOPERSONA
            WHEN 1 THEN --NATURAL
                ' '
            WHEN 2 THEN --JURIDICA
                REPLACE(REPLACE(REPLACE(PKG_PERSONA.F_OBT_NOMBRECOMPLETO(CODIGOPERSONA), '''', ''),' & ', ' Y '),'&', ' Y ')
        END AS RAZONSOCIAL,         --RAZONSOCIAL
        PKG_DATOSSOCIO.F_OBT_FECHAINGRESOCOOP(CODIGOPERSONA) AS FECHAINGRESO,
                                    --FECHAINGRESO
        FECHARENUNCIA AS FECHARETIRO,
                                    --FECHARETIRO
        '2019' AS ANOINFORMADO      --ANOINFORMADO
    FROM
    (
        SELECT DISTINCT     CS.CODIGOPERSONA,
                            PKG_PERSONA.F_OBT_TIPOPERSONA(CS.CODIGOPERSONA) AS TIPOPERSONA,
                            (SELECT MAX(FECHARENUNCIA) FROM SOLICITUDRENUNCIA SR WHERE SR.CODIGOPERSONA = CS.CODIGOPERSONA AND (SR.ESTADORENUNCIA = 2 OR SR.ESTADORENUNCIA = 4) GROUP BY CODIGOPERSONA) AS FECHARENUNCIA
        FROM
        (
        SELECT CC.CODIGOPERSONA FROM APORTES APO
            LEFT JOIN 
                (
                    SELECT CODIGOPERSONA, NUMEROCUENTA
                    FROM CUENTACORRIENTE
                ) CC
            ON CC.NUMEROCUENTA = APO.NUMEROCUENTA
            WHERE
                TO_CHAR(APO.FECHAMOVIMIENTO, 'YYYY') = 2019
                AND APO.ESTADO = 1
        UNION ALL
        SELECT P.CODIGOPERSONA FROM PRESTAMOPAGOS PP
            LEFT JOIN 
                (
                    SELECT CODIGOPERSONA, PERIODOSOLICITUD, NUMEROSOLICITUD
                    FROM PRESTAMO
                ) P
            ON P.PERIODOSOLICITUD = PP.PERIODOSOLICITUD
                AND P.NUMEROSOLICITUD = PP.NUMEROSOLICITUD
            WHERE
                TO_CHAR(PP.FECHADEPOSITO, 'YYYY') = 2019
                AND PP.ESTADO = 1
        ) CS
        WHERE CS.CODIGOPERSONA <> 1
    )
--)
;