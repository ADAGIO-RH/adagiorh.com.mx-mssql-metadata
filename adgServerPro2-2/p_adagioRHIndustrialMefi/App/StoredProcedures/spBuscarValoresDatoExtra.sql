USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [App].[spBuscarValoresDatoExtra](
	@IDValorDatoExtra int = 0, 
	@IDDatoExtra int = 0, 
	@IDTipoDatoExtra varchar(100) = null,
	@IDReferencia int,
	@IDUsuario int
) as
	DECLARE 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	select 
		isnull(vde.IDValorDatoExtra, 0) as IDValorDatoExtra
		,de.IDDatoExtra
		,JSON_VALUE(de.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as Nombre
		,@IDReferencia as IDReferencia
		,vde.Valor
	from App.tblCatDatosExtras de with (nolock)
		left join App.tblValoresDatosExtras vde with (nolock) on de.IDDatoExtra = vde.IDDatoExtra
			and (vde.IDReferencia = @IDReferencia or isnull(@IDReferencia, 0) = 0)
		--join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = de.IDUsuario
	where (vde.IDValorDatoExtra = @IDValorDatoExtra or isnull(@IDValorDatoExtra, 0) = 0)
		and (vde.IDDatoExtra = @IDDatoExtra or isnull(@IDDatoExtra, 0) = 0)
		and (de.IDTipoDatoExtra = @IDTipoDatoExtra or isnull(@IDTipoDatoExtra, '') = '')

/*
exec [App].[spBuscarValoresDatoExtra] @IDReferencia = 1, @IDUsuario = 1

*/
GO
