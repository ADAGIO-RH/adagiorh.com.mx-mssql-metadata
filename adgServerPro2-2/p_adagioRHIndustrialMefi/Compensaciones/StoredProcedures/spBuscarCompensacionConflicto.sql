USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Compensaciones].[spBuscarCompensacionConflicto]
(
	@IDCompensacion int
	,@IDUsuario int 
)
AS
BEGIN

declare  
	   @SalarioMinimo decimal(18,2)
	   ,@IDCatTipoCompensacion int
	   ,@IDTipoNomina int
	   ,@IDMatrizIncremento int
	   ,@Fecha Date
	   ,@bPorcentaje bit
	   ,@bDiasSueldo bit
	   ,@bMonto bit
	   ,@Porcentaje Decimal(18,4)
	   ,@DiasSueldo Decimal(18,4)
	   ,@Monto Decimal(18,4)
	   ,@IDCliente int
	   ,@IDPeriodo int
	   ,@IDConcepto int
	   ;
SELECT 
		@IDCatTipoCompensacion	= IDCatTipoCompensacion
		,@IDCliente				= IDCliente	
		,@IDTipoNomina			= IDTipoNomina
		,@IDPeriodo				= IDPeriodo	
		,@IDMatrizIncremento	= IDMatrizIncremento
		,@Fecha					= Fecha	
		,@bPorcentaje			= bPorcentaje	
		,@bDiasSueldo			= bDiasSueldo	
		,@bMonto				= bMonto
		,@Porcentaje			= Porcentaje
		,@DiasSueldo			= DiasSueldo
		,@Monto					= Monto
		,@IDConcepto			= IDConcepto
	FROM Compensaciones.TblCompensaciones with(nolock)
	WHERE IDCompensacion = @IDCompensacion

	IF(@IDCatTipoCompensacion in (1,2,3))
	BEGIN
		Select  M.IDEmpleado,
				M.ClaveEmpleado,
			    M.NOMBRECOMPLETO as NombreCompleto
		from Compensaciones.TblCompensacionesDetalle CD WITH(nolock)
			inner join IMSS.tblMovAfiliatorios mov WITH(NOLOCK)
				on mov.IDEmpleado = CD.IDEmpleado
				and mov.Fecha = @Fecha
			inner join RH.tblEmpleadosMaster M WITH(NOLOCK)
				on CD.IDEmpleado = M.IDEmpleado
			WHERE CD.IDCompensacion = @IDCompensacion
	END
	IF(@IDCatTipoCompensacion = 4)
	BEGIN
		Select  M.IDEmpleado,
				M.ClaveEmpleado,
			    M.NOMBRECOMPLETO as NombreCompleto
		from Compensaciones.TblCompensacionesDetalle CD WITH(nolock)
			inner join RH.tblEmpleadosMaster M WITH(NOLOCK)
				on CD.IDEmpleado = M.IDEmpleado
			inner join Nomina.tblDetallePeriodo DP WITH(nolock)
				on DP.IDEmpleado = m.IDEmpleado
				and DP.IDConcepto = @IDConcepto
				and DP.IDPeriodo = @IDPeriodo
				and ISNULL(DP.CantidadMonto,0) <> 0
		WHERE CD.IDCompensacion = @IDCompensacion

	END
END
GO
