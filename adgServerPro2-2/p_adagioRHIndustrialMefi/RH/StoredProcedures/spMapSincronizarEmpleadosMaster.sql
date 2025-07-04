USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Mapear IDEmpleado con ClaveEmpleado para actualizar tabla Master de Empleados
** Autor			: Jose Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-07-06
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE RH.spMapSincronizarEmpleadosMaster --234
(
	@IDEmpleado int
)
AS
BEGIN

	DECLARE @ClaveEmpleado Varchar(20) = ''

	SELECT @ClaveEmpleado = ClaveEmpleado
	FROM RH.tblEmpleados
	WHERE IDEmpleado = @IDEmpleado

	EXEC [RH].[spSincronizarEmpleadosMaster] @EmpleadoIni = @ClaveEmpleado, @EmpleadoFin = @ClaveEmpleado


END
GO
