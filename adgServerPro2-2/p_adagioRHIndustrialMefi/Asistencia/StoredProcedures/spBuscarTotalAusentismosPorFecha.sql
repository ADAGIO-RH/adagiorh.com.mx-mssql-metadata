USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc [Asistencia].[spBuscarTotalAusentismosPorFecha](
		@Fecha date  
		,@IDUsuario int
) as
	DECLARE  
		@IDIdioma varchar(225)
	;

	DECLARE @tempIncidencias as table (
		IDIncidencia varchar(10) collate database_default,
		Descripcion	varchar(255) collate database_default
	);

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	insert @tempIncidencias(IDIncidencia, Descripcion)
	SELECT 
		IDIncidencia,
		JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
    FROM [Asistencia].[tblCatIncidencias] WITH(NOLOCK)  
	where isnull(EsAusentismo, 0) = 1

	select 
		coalesce(i.IDIncidencia,'')
			+'-'+coalesce(i.Descripcion, '') as Incidencia, count(*) as Total
	from Asistencia.tblIncidenciaEmpleado ie
		join @tempIncidencias i on i.IDIncidencia = ie.IDIncidencia
	where ie.Fecha = @Fecha
	group by i.IDIncidencia, i.Descripcion
GO
