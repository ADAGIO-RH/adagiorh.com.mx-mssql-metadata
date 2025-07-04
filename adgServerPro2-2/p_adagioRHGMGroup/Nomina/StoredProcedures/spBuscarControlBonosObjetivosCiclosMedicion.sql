USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca ciclos de medicion asociados a un bono por objetivos
** Autor			: Javier Peña Fuentes
** Email			: jpena@adagio.com.mx
** FechaCreacion	: 2025-02-18
** Paremetros		:              
*****************************************************************************************************/

CREATE PROCEDURE [Nomina].[spBuscarControlBonosObjetivosCiclosMedicion](
    @IDControlBonosObjetivos INT,
    @IDUsuario INT
) AS
BEGIN
    SET FMTONLY OFF
    
    BEGIN -- Set Idioma 
        DECLARE  
            @IDIdioma VARCHAR(5),
            @IdiomaSQL VARCHAR(100) = NULL;

        SET DATEFIRST 7;

        SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');

        SELECT @IdiomaSQL = [SQL]
        FROM app.tblIdiomas
        WHERE IDIdioma = @IDIdioma;

        IF (@IdiomaSQL IS NULL OR LEN(@IdiomaSQL) = 0)
        BEGIN
            SET @IdiomaSQL = 'Spanish';
        END;
  
        SET LANGUAGE @IdiomaSQL;
    END;

    SELECT 
        cboc.IDControlBonosObjetivosCiclo,
        cboc.IDControlBonosObjetivos,
        ccmo.IDCicloMedicionObjetivo,
        UPPER(ccmo.Nombre) AS Nombre,
        ccmo.FechaInicio,
        ccmo.FechaFin,
        ccmo.IDEstatusCicloMedicion,
        UPPER(JSON_VALUE(ecm.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE('esmx', '-','')), 'Nombre'))) AS EstatusCicloMedicion,
        ccmo.FechaParaActualizacionEstatusObjetivos,
        ccmo.PermitirIngresoObjetivosEmpleados,
        ccmo.EmpleadoApruebaObjetivos,
        ccmo.IDUsuario,
        COALESCE(u.Nombre, '')+' '+COALESCE(u.Apellido, '') AS Usuario
    FROM Evaluacion360.tblCatCiclosMedicionObjetivos ccmo
        INNER JOIN Evaluacion360.tblCatEstatusCiclosMedicion ecm ON ecm.IDEstatusCicloMedicion = ccmo.IDEstatusCicloMedicion
        INNER JOIN Seguridad.tblUsuarios u ON u.IDUsuario = ccmo.IDUsuario
        INNER JOIN [Nomina].[tblControlBonosObjetivosCiclosMedicion] cboc ON cboc.IDCicloMedicionObjetivo = ccmo.IDCicloMedicionObjetivo 
            AND cboc.IDControlBonosObjetivos = @IDControlBonosObjetivos;
END;
GO
