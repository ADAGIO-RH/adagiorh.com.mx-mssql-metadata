USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Resguardo].[spUValorPropiedad](
	@IDPropiedad int
	,@Valor varchar(max)
	,@IDUsuario int
) as
	update [Resguardo].[tblCatPropiedadesArticulos]
		set Valor = @Valor
	where IDPropiedad = @IDPropiedad
GO
