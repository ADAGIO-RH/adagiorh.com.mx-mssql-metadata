USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  proc [Evaluacion360].[spBuscarDatosGraficaAvanceObjetivoEmpleado](
	@IDObjetivoEmpleado int
	,@IDUsuario int
) as

	SET FMTONLY OFF;  

    DECLARE @IDIdioma varchar(10);
    
    SET @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

    
    SELECT  (
    SELECT
        CASE 
                WHEN LEN(OE.Nombre) > 60 THEN LEFT(OE.Nombre, 60) + '...'
                ELSE OE.Nombre
            END AS Objetivo,
        (
            SELECT
                CAST(AOE.Valor AS DECIMAL(18, 2)) AS Resultado,
                FORMAT(AOE.Fecha, 'dd/MMMM/yyyy') AS Fecha
            FROM Evaluacion360.tblAvanceObjetivoEmpleado AOE            
            WHERE OE.IDObjetivoEmpleado = AOE.IDObjetivoEmpleado
            ORDER BY AOE.Fecha ASC
            FOR JSON PATH
        ) AS Grupo
    FROM Evaluacion360.tblObjetivosEmpleados OE
    WHERE
        OE.IDObjetivoEmpleado = @IDObjetivoEmpleado     
    FOR JSON PATH
) as ResultJson
GO
