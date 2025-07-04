USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Procedimiento para obtener 20 Dias Proporcionales por Anio
** Autor			: Jose Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 16-08-2018
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/


CREATE PROCEDURE [Asistencia].[spBuscar20DiasAnio] --'2018-06-21','2018-08-16'
(

	@FechaIni Date,
	@FechaFin Date	
)
AS
BEGIN
	select CAST(DATEDIFF(DAY,@FechaIni,@FechaFin)as decimal(18,2))/365 * 20 as Saldo
END
GO
