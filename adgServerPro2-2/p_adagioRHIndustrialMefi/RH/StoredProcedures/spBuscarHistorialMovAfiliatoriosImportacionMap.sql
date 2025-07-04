USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Map Historial de Movimientos Afiliatorios
** Autor			: Jose Román
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE PROCEDURE [RH].[spBuscarHistorialMovAfiliatoriosImportacionMap]
(
	@dtHistorial [RH].[dtHistorialMovAfiliatoriosMap] READONLY
	,@IDUsuario int
)
AS
BEGIN
		
		SELECT 
		 dt.[IDMovAfiliatorio]
		 ,dt.[Fecha] as Fecha
		,case when exists (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado]) then (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado])
			else 0
			end as IDEmpleado
		,dt.[ClaveEmpleado]

		,CASE WHEN EXISTS (SELECT TOP 1 IDTipoMovimiento FROM IMSS.tblCatTipoMovimientos where Codigo = dt.[Codigo]) THEN (SELECT TOP 1 IDTipoMovimiento FROM IMSS.tblCatTipoMovimientos where Codigo = dt.[Codigo])
			ELSE 0
			END as IDTipoMovimiento
		,dt.[Codigo]
		,CASE WHEN EXISTS (SELECT TOP 1 IDTipoMovimiento FROM IMSS.tblCatTipoMovimientos where Codigo = dt.[Codigo]) THEN (SELECT TOP 1 Descripcion FROM IMSS.tblCatTipoMovimientos where Codigo = dt.[Codigo])
			ELSE ''
			END as Descripcion

		,CASE WHEN EXISTS (SELECT TOP 1 IDRazonMovimiento FROM [IMSS].[tblCatRazonesMovAfiliatorios] where Codigo = dt.[CodigoRazon]) THEN (SELECT TOP 1 IDRazonMovimiento FROM [IMSS].[tblCatRazonesMovAfiliatorios] where Codigo = dt.[CodigoRazon])
			ELSE 0
			END as IDRazonMovimiento
		,dt.[CodigoRazon]
		,CASE WHEN EXISTS (SELECT TOP 1 IDRazonMovimiento FROM [IMSS].[tblCatRazonesMovAfiliatorios] where Codigo = dt.[CodigoRazon]) THEN (SELECT TOP 1 Descripcion FROM [IMSS].[tblCatRazonesMovAfiliatorios] where Codigo = dt.[CodigoRazon])
			ELSE ''
			END as Razon

		,dt.SalarioDiario
		,dt.SalarioIntegrado
		,dt.SalarioVariable
		,dt.SalarioDiarioReal

		,CASE WHEN EXISTS (SELECT TOP 1 IDRegPatronal FROM [RH].[tblCatRegPatronal] where RegistroPatronal = dt.[RegPatronal]) THEN (SELECT TOP 1 IDRegPatronal FROM [RH].[tblCatRegPatronal] where RegistroPatronal = dt.[RegPatronal])
			ELSE 0
			END as IDRegPatronal

		,dt.[RegPatronal]
		
		,dt.[FechaIMSS]
		,dt.[FechaIDSE]
		FROM @dtHistorial dt
			join RH.tblEmpleadosMaster e on dt.ClaveEmpleado = e.ClaveEmpleado
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where dt.ClaveEmpleado <> '' 
	
END
GO
