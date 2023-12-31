USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Generar el Saldo de Incidencia PTO cuando cumple aniversario.
** Autor			: Víctor Enrique Martínez Alvarado.
** Email			: vmartinez@adagio.com.mx
** FechaCreacion	: 2023-07-06
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor					Comentario
------------------- ------------------- ------------------------------------------------------------
2023-10-19			Víctor Martínez			Se agrega la validación de dato extra BLOQUEAR_PTO.
***************************************************************************************************/
CREATE PROCEDURE [Asistencia].[spGenerarSaldoPTO](
	 @dtConfig as [App].[dtConfiguracionesGenerales] READONLY 
	,@dtEmpleados [RH].[dtEmpleados] READONLY
	,@dtVigenciaEmpleados [App].[dtFechasVigenciaEmpleado] READONLY
	,@dtChecadas [Asistencia].[dtChecadas] READONLY
	,@dtIncidenciasEmpleados [Asistencia].[dtIncidenciaEmpleado] READONLY
	,@dtHorariosEmpleados [Asistencia].[dtHorariosEmpleados] READONLY
	,@IDUsuario int
)
AS
BEGIN
	Declare 
		@json nvarchar(max)
		,@IDDatoExtraCliente int	
		,@IDDatoExtraBloquearPTO int
	;
	
	select @IDDatoExtraCliente = IDCatDatoExtraCliente from RH.tblCatDatosExtraClientes where Nombre = 'PTO'
	select @IDDatoExtraBloquearPTO = IDDatoExtra from RH.tblCatDatosExtra where Nombre = 'BLOQUEAR_PTO'

	select @json = Valor from rh.tblDatosExtraClientes where IDCatDatoExtraCliente = @IDDatoExtraCliente

	IF object_ID('TEMPDB..#SaldosPTO') IS NOT NULL DROP TABLE #SaldosPTO

	select *
		into #SaldosPTO
		from OPENJSON(@json) with (
			Periodo int '$.P',
			Saldo int '$.S'
		);

	insert into Asistencia.tblIncidenciasSaldos (FechaInicio,FechaFin,FechaRegistro,Cantidad,IDEmpleado,IDIncidencia,IDUsuario)
	select 
		ve.Fecha as FechaInicio
		,DATEADD(DAY,-1,DATEADD(YEAR,1,ve.Fecha)) as FechaFin
		,GETDATE() as FechaRegistro
		,PTO.Saldo as Cantidad
		,ve.IDEmpleado
		,'PTO' as IDIncidencia
		,1 as IDUsuario
		from @dtVigenciaEmpleados ve
			inner join @dtEmpleados e
				on e.IDEmpleado = ve.IDEmpleado 
					and DATEPART(DAY,e.FechaAntiguedad) = DATEPART(DAY,ve.Fecha)
					and DATEPART(MONTH,e.FechaAntiguedad) = DATEPART(MONTH,ve.Fecha)
			left join rh.tblDatosExtraEmpleados dee
				on dee.IDEmpleado = e.IDEmpleado 
					and dee.IDDatoExtra = @IDDatoExtraBloquearPTO
			left join Asistencia.tblIncidenciasSaldos IncS
				on IncS.IDEmpleado = e.IDEmpleado
					and DATEPART(MONTH,IncS.FechaInicio) = DATEPART(MONTH,ve.Fecha)
					and DATEPART(DAY,IncS.FechaInicio) = DATEPART(DAY,ve.Fecha)
					and DATEPART(YEAR,IncS.FechaInicio) = DATEPART(YEAR,ve.Fecha)
					and IncS.IDIncidencia = 'PTO'
			left join #SaldosPTO PTO
				on PTO.Periodo = FLOOR(Asistencia.fnBuscarAniosDiferencia (FechaAntiguedad,ve.Fecha)) + 1
		where IncS.IDIncidencia is null
			and isnull(dee.Valor,'FALSE') = 'FALSE'
END
GO
