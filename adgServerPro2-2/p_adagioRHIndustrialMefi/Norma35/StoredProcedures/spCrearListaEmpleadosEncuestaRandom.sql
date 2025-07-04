USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spCrearListaEmpleadosEncuestaRandom]
(
	@IDEncuesta int,
	@IDEmpresa int = 0,
	@IDSucursal int = 0,
	@IDCliente int = 0,
	@CantidadEmpleados int = 0,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @IDCatEncuesta int = 0,
			@CantidadPreguntas int = 0

	Select @IDCatEncuesta = IDCatEncuesta from [Norma35].[tblEncuestas] where IDEncuesta = @IDEncuesta

	select @CantidadPreguntas = count(*)
	from Norma35.tblCatGrupos G with(nolock)
		join Norma35.tblCatPreguntas p with(nolock)
			on p.IDCatGrupo = G.IDCatGrupo
	 where  G.TipoReferencia = 1
		and G.IDReferencia =@IDCatEncuesta

	if OBJECT_ID('tempdb..#tempListaEmpleados') is not null drop table #tempListaEmpleados;

	Select M.IDEmpleado , ROW_NUMBER()OVER(Order by NEWID() asc)as ROWNUMBER
	into #tempListaEmpleados
	from RH.tblEmpleadosMaster M with (nolock)
	where ((M.IDEmpresa = @IDEmpresa) or (isnull(@IDEmpresa,0) = 0))
		and ((M.IDSucursal = @IDSucursal) or (isnull(@IDSucursal,0) = 0))	
		and ((M.IDCliente = @IDCliente) or (isnull(@IDCliente,0) = 0))	
		and M.Vigente = 1
	ORDER BY NEWID()

	insert into [Norma35].[tblEncuestasEmpleados](IDEncuesta,IDEmpleado,IDCatEstatus,FechaAsignacion,FechaUltimaActualizacion,TotalPreguntas,Resultado)
	select @IDEncuesta,IDEmpleado,1,getdate(),getdate(),@CantidadPreguntas,'SIN EVALUAR' 
	from #tempListaEmpleados
	WHERE ROWNUMBER <= @CantidadEmpleados


	EXEC APP.spINotificacionIniciarNorma35Empleado @IDEncuesta = @IDEncuesta, @IDUsuario = @IDUsuario

END
GO
