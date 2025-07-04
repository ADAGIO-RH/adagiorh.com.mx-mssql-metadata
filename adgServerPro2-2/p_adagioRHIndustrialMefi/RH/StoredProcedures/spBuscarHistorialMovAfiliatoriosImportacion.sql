USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Map Historial de Movimientos Afiliatorios Map
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
CREATE PROCEDURE [RH].[spBuscarHistorialMovAfiliatoriosImportacion]
(
	@dtHistorial [RH].[dtHistorialMovAfiliatorios] READONLY
	,@IDUsuario int
)
AS
BEGIN
		SELECT 
		 ROW_NUMBER()OVER(ORDER BY dt.ClaveEmpleado asc) as [IDMovAfiliatorio]
		 ,[Fecha] as Fecha
		,case when exists (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados with(nolock) where ClaveEmpleado = dt.[ClaveEmpleado]) then (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados with(nolock) where ClaveEmpleado = dt.[ClaveEmpleado])
			else 0
			end as IDEmpleado
		,dt.[ClaveEmpleado]

		,CASE WHEN EXISTS (SELECT TOP 1 IDTipoMovimiento FROM IMSS.tblCatTipoMovimientos with(nolock) where Codigo = dt.[Codigo]) THEN (SELECT TOP 1 IDTipoMovimiento FROM IMSS.tblCatTipoMovimientos with(nolock) where Codigo = dt.[Codigo])
			ELSE 0
			END as IDTipoMovimiento
		,dt.[Codigo]
		,CASE WHEN EXISTS (SELECT TOP 1 IDTipoMovimiento FROM IMSS.tblCatTipoMovimientos with(nolock) where Codigo = dt.[Codigo]) THEN (SELECT TOP 1 Descripcion FROM IMSS.tblCatTipoMovimientos with(nolock) where Codigo = dt.[Codigo])
			ELSE ''
			END as Descripcion

		,CASE WHEN EXISTS (SELECT TOP 1 IDRazonMovimiento FROM [IMSS].[tblCatRazonesMovAfiliatorios] with(nolock) where Codigo = dt.[CodigoRazon]) THEN (SELECT TOP 1 IDRazonMovimiento FROM [IMSS].[tblCatRazonesMovAfiliatorios] with(nolock) where Codigo = dt.[CodigoRazon])
			ELSE 0
			END as IDRazonMovimiento
		,dt.[CodigoRazon]
		,CASE WHEN EXISTS (SELECT TOP 1 IDRazonMovimiento FROM [IMSS].[tblCatRazonesMovAfiliatorios]with(nolock) where Codigo = dt.[CodigoRazon]) THEN (SELECT TOP 1 Descripcion FROM [IMSS].[tblCatRazonesMovAfiliatorios] with(nolock) where Codigo = dt.[CodigoRazon])
			ELSE ''
			END as Razon

		,CASE WHEN isnull(dt.SalarioDiario,0) = 0 THEN isnull((Select Top 1 SalarioDiario from IMSS.tblMovAfiliatorios with(nolock) where Fecha < dt.Fecha and IDEmpleado = e.IDEmpleado and IDTipoMovimiento in (1,3,4) ORDER BY Fecha desc),0)
			  ELSE isnull(dt.SalarioDiario,0) 
			  END as SalarioDiario
		,CASE WHEN isnull(dt.SalarioIntegrado,0) = 0 THEN isnull((Select Top 1 SalarioIntegrado from IMSS.tblMovAfiliatorios with(nolock) where Fecha < dt.Fecha and IDEmpleado = e.IDEmpleado and IDTipoMovimiento in (1,3,4) ORDER BY Fecha desc),0)
			  ELSE isnull(dt.SalarioIntegrado,0) 
			  END as SalarioIntegrado
		,CASE WHEN isnull(dt.SalarioVariable,0) = 0 THEN isnull((Select Top 1 SalarioVariable from IMSS.tblMovAfiliatorios with(nolock) where Fecha < dt.Fecha and IDEmpleado = e.IDEmpleado and IDTipoMovimiento in (1,3,4) ORDER BY Fecha desc),0)
			  ELSE isnull(dt.SalarioVariable,0) 
			  END as  SalarioVariable
		,CASE WHEN isnull(dt.SalarioDiarioReal,0) = 0 THEN isnull((Select Top 1 SalarioDiarioReal from IMSS.tblMovAfiliatorios with(nolock) where Fecha < dt.Fecha and IDEmpleado = e.IDEmpleado and IDTipoMovimiento in (1,3,4) ORDER BY Fecha desc),0)
			  ELSE isnull(dt.SalarioDiarioReal,0) 
			  END as SalarioDiarioReal

		,CASE WHEN EXISTS (SELECT TOP 1 IDRegPatronal FROM [RH].[tblCatRegPatronal] with(nolock) where RegistroPatronal = dt.[RegPatronal]) THEN (SELECT TOP 1 IDRegPatronal FROM [RH].[tblCatRegPatronal] with(nolock) where RegistroPatronal = dt.[RegPatronal])
			ELSE 0
			END as IDRegPatronal

		,dt.[RegPatronal]
		
		,dt.[FechaIMSS] as FechaIMSS
		,dt.[FechaIDSE] as FechaIDSE
		FROM @dtHistorial dt
			join RH.tblEmpleadosMaster e with(nolock) on dt.ClaveEmpleado = e.ClaveEmpleado
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where dt.ClaveEmpleado <> '' 
	
END
GO
