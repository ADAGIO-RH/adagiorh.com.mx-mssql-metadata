USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Asistencia].[spBuscarAusentismosPorSaldosTomandos](  
    @IDEmpleado int  
    ,@IDUsuario int  
) as  
	DECLARE  
		@IDIdioma varchar(225)
		,@traduccionYESNO varchar(500) = N'
			{
				"esmx": {
					"SI": "SI",
					"NO": "NO"
				},
				"enus": {
					"SI": "YES",
					"NO": "NO"
				}
			}
		'
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))

	select 
		ie.IDIncidenciaEmpleado,
		ie.IDEmpleado,
		ie.Fecha,
		ie.IDIncidencia,
		JSON_VALUE(i.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Ausentismo,
		case when 
			isnull(ie.Autorizado,0) = 0 
				then JSON_VALUE(@traduccionYESNO, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NO'))
				else JSON_VALUE(@traduccionYESNO, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'SI'))
		end as Autorizado,
		UsuarioAutoriza = upper( ua.Cuenta +' - '+ua.Nombre +' '+ua.Apellido),
		ie.Comentario,
		CreadoPor =  upper(uc.Cuenta +' - '+uc.Nombre +' '+uc.Apellido)
	from Asistencia.tblIncidenciaEmpleado ie 
		join Asistencia.tblCatIncidencias i on i.IDIncidencia = ie.IDIncidencia
		left join Seguridad.tblUsuarios ua on ie.AutorizadoPor = ua.IDUsuario
		left join Seguridad.tblUsuarios uc on ie.CreadoPorIDUsuario = uc.IDUsuario
	where ie.IDEmpleado = @IDEmpleado and isnull(i.AdministrarSaldos, 0) = 1
GO
