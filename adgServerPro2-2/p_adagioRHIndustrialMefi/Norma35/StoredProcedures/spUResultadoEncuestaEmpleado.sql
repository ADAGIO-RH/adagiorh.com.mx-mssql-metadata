USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Norma35].[spUResultadoEncuestaEmpleado](
	@IDEncuestaEmpleado int,
	@Resultado varchar(100)
) as
	
	update Norma35.tblEncuestasEmpleados
		set Resultado = @Resultado
			, IDCatEstatus = 4 -- Cancelada
	where IDEncuestaEmpleado = @IDEncuestaEmpleado
GO
