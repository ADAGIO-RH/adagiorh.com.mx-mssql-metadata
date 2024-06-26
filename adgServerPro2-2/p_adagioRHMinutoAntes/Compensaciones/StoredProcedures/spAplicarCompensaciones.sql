USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Compensaciones].[spAplicarCompensaciones] --3,0,1
(
	@IDCompensacion int
	,@BorrarConflictos bit = 0
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
	Declare @EmpleadosBorrar as table (
		IDCliente		int,
		ClaveEmpleado	Varchar(50),
		NombreCompleto  Varchar(500)
	);

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

	insert into @EmpleadosBorrar
	Exec Compensaciones.spBuscarCompensacionConflicto @IDCompensacion = @IDCompensacion, @IDUsuario = @IDUsuario

	IF(@BorrarConflictos = 1)
	BEGIN
			IF(@IDCatTipoCompensacion in (1,2,3))
			BEGIN
				DELETE Mov
				from Compensaciones.TblCompensacionesDetalle CD WITH(nolock)
					inner join IMSS.tblMovAfiliatorios mov WITH(NOLOCK)
						on mov.IDEmpleado = CD.IDEmpleado
						and mov.Fecha = @Fecha
					inner join RH.tblEmpleadosMaster M WITH(NOLOCK)
						on CD.IDEmpleado = M.IDEmpleado
					WHERE CD.IDCompensacion = @IDCompensacion

				INSERT INTO IMSS.tblMovAfiliatorios (IDEmpleado,IDTipoMovimiento,Fecha,IDRegPatronal,RespetarAntiguedad,SalarioDiario,SalarioVariable,SalarioIntegrado,SalarioDiarioReal)
				Select CD.IDEmpleado,4,@Fecha,M.IDRegPatronal,0,CD.SalarioDiarioNuevo,M.SalarioVariable, m.SalarioIntegrado, m.SalarioDiarioReal
				from Compensaciones.TblCompensacionesDetalle CD WITH(nolock)
					inner join RH.tblEmpleadosMaster M WITH(NOLOCK)
						on CD.IDEmpleado = M.IDEmpleado
				WHERE CD.IDCompensacion = @IDCompensacion
				and ISNULL(M.IDRegPatronal,0) > 0
			END ELSE IF(@IDCatTipoCompensacion = 4)
			BEGIN
				Delete DP
				from Compensaciones.TblCompensacionesDetalle CD WITH(nolock)
					inner join RH.tblEmpleadosMaster M WITH(NOLOCK)
						on CD.IDEmpleado = M.IDEmpleado
					inner join Nomina.tblDetallePeriodo DP WITH(nolock)
						on DP.IDEmpleado = m.IDEmpleado
						and DP.IDConcepto = @IDConcepto
						and DP.IDPeriodo = @IDPeriodo
						and ISNULL(DP.CantidadMonto,0) <> 0
					WHERE CD.IDCompensacion = @IDCompensacion

				Insert into Nomina.tblDetallePeriodo(IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto)
				SELECT CD.IDEmpleado,@IDPeriodo,@IDConcepto,CD.Compensacion
				FROM Compensaciones.TblCompensacionesDetalle CD with(nolock)	
				WHERE CD.IDCompensacion = @IDCompensacion
			END
	END
	ELSE
	BEGIN
			IF(@IDCatTipoCompensacion in (1,2,3))
			BEGIN
				INSERT INTO IMSS.tblMovAfiliatorios (IDEmpleado,IDTipoMovimiento,Fecha,IDRegPatronal,RespetarAntiguedad,SalarioDiario,SalarioVariable,SalarioIntegrado,SalarioDiarioReal)
				Select CD.IDEmpleado,4,@Fecha,M.IDRegPatronal,0,CD.SalarioDiarioNuevo,M.SalarioVariable, m.SalarioIntegrado, m.SalarioDiarioReal
				from Compensaciones.TblCompensacionesDetalle CD WITH(nolock)
					inner join RH.tblEmpleadosMaster M WITH(NOLOCK)
						on CD.IDEmpleado = M.IDEmpleado
				WHERE CD.IDCompensacion = @IDCompensacion
				and ISNULL(M.IDRegPatronal,0) > 0
				
			END ELSE IF(@IDCatTipoCompensacion = 4)
			BEGIN
				Insert into Nomina.tblDetallePeriodo(IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto)
				SELECT CD.IDEmpleado,@IDPeriodo,@IDConcepto,CD.Compensacion
				FROM Compensaciones.TblCompensacionesDetalle CD with(nolock)	
				WHERE CD.IDCompensacion = @IDCompensacion
			END
	END

END
GO
