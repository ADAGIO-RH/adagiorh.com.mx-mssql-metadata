USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spCrearEmpleadoEncuesta]
(
	@IDEncuesta int,
	@IDEmpleado int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @IDCatEncuesta int = 0,
			@CantidadPreguntas int = 0,
			@CantidadEmpleados int = 0

	Select @IDCatEncuesta = IDCatEncuesta from [Norma35].[tblEncuestas] where IDEncuesta = @IDEncuesta

	select @CantidadPreguntas = count(*)
	from Norma35.tblCatGrupos G with(nolock)
		join Norma35.tblCatPreguntas p with(nolock)
			on p.IDCatGrupo = G.IDCatGrupo
	 where  G.TipoReferencia = 1
		and G.IDReferencia =@IDCatEncuesta

		IF EXISTS(Select Top 1 1 from  [Norma35].[tblEncuestasEmpleados] where IDEncuesta = @IDEncuesta and IDEmpleado = @IDEmpleado)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END
	

	insert into [Norma35].[tblEncuestasEmpleados](IDEncuesta,IDEmpleado,IDCatEstatus,FechaAsignacion,FechaUltimaActualizacion,TotalPreguntas,Resultado)
	select @IDEncuesta,@IDEmpleado,1,getdate(),getdate(),@CantidadPreguntas,'SIN EVALUAR' 

	select @CantidadEmpleados = count(*)
	from Norma35.tblEncuestasEmpleados
	where IDEncuesta = @IDEncuesta

	update Norma35.tblEncuestas
		set CantidadEmpleados = @CantidadEmpleados
	where IDEncuesta = @IDEncuesta 

END
GO
