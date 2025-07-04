USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Function para obtener Anios de diferencia entre dos fechas
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


CREATE function [Asistencia].[fnBuscarAniosDiferencia] --'2018-06-21','2018-08-16'
(

	@FechaIni Date,
	@FechaFin Date	
)
returns Decimal(18,2)
AS
BEGIN
	return CAST(DATEDIFF(DAY,@FechaIni,@FechaFin)as decimal(18,2))/365.00 
END
GO
