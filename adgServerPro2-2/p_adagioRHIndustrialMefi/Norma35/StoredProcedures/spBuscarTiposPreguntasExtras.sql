USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [Norma35].[spBuscarTiposPreguntasExtras](
	@IDTipoPreguntaExtra varchar(20) = null,
	@IDUsuario int
) as
	select 
		IDTipoPreguntaExtra,
		Nombre
	from [Norma35].[tblCatTiposPreguntasExtras]
	where IDTipoPreguntaExtra = @IDTipoPreguntaExtra or isnull(@IDTipoPreguntaExtra, '') = ''
GO
