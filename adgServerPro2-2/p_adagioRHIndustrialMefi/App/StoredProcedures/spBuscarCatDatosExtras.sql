USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc App.spBuscarCatDatosExtras(
	@IDDatoExtra int = 0,
	@IDTipoDatoExtra varchar(100) = null,
	@IDUsuario int
) as
	DECLARE 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	select 
		de.IDDatoExtra
		,de.IDTipoDatoExtra
		,de.IDInputType
		,JSON_VALUE(de.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as Nombre
		,de.Traduccion
		,de.[Data]
		,de.IDUsuario
		,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
		,de.FechaHoraReg
		,(
			select 
				it.IDInputType,
				JSON_VALUE(it.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre,
				it.TipoDato,
				JSON_QUERY(it.ConfiguracionSizeInput) as ConfiguracionSizeInput
			from App.tblCatInputsTypes it
				join App.tblCatTiposDatos td on td.TipoDato = it.TipoDato
			where (it.IDInputType = de.IDInputType)
			for json auto, without_array_wrapper
		) InputType
	from App.tblCatDatosExtras de
		join Seguridad.tblUsuarios u on u.IDUsuario = de.IDUsuario
	where (de.IDDatoExtra = @IDDatoExtra or isnull(@IDDatoExtra, 0) = 0)
		and (de.IDTipoDatoExtra = @IDTipoDatoExtra or isnull(@IDTipoDatoExtra, '') = '')
GO
