USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[INotificacionSolicitudIntranetComentario](  
	@IDSolicitud int    
	,@IDComentario int
	,@TipoCambio Varchar(50)
) as  
	declare   
		@IDNotificacion int = 0  
		,@IDTipoNotificacion varchar(100) = 'ComentarioIntranet'  
		,@ClaveEmpleado  varchar(50)  
		,@Nombre  varchar(255)    
		,@SegundoNombre  varchar(255)    
		,@Paterno  varchar(255)    
		,@Materno  varchar(255)    
		,@Email   varchar(255)  
		,@Fecha date  
		,@Fechaini date  
		,@FechaFin date  
		,@valor varchar(max)
		,@Folio Varchar(50)
		,@TipoSolicitud Varchar(50)
		,@EstatusSolicitud Varchar(50)
		,@IDIncidencia Varchar(10)
		,@UsuarioAutoriza Varchar(100)
		,@CantidadDias int
		,@IDEmpleado int
		,@Comentario Varchar(max)
		,@IDUsuarioComentario int
		,@NombreComentario Varchar(max)
		,@IDIdioma varchar(10)
		,@CreateSupervisorMensaje	varchar(100)
		,@CreateUsuarioMensaje		varchar(100)
		,@UpdateSupervisorMensaje	varchar(100)
		,@UpdateUsuarioMensaje		varchar(100)
		,@Confirmar	varchar(100)
		,@json nvarchar(max)
		,@notificaciones nvarchar(max) = N'
			{
				"esmx": {
					"Create": {
						"Supervisor": "Se ha generado un comentario en la solicitud de Intranet por parte de ",
						"Usuario": "Tu comentario en la solicitud de Intranet se ha enviado."
					},
					"Update": {
						"Supervisor": "Se ha modificado un comentario en la solicitud de Intranet por parte de ",
						"Usuario": "Tu comentario en la solicitud de Intranet se ha modificado y enviado."
					},
					"Confirmar": "No es necesario confirmar de recibido."
				},
				"enus": {
					"Create": {
						"Supervisor": "A new comment has been added to the intranet request by ",
						"Usuario": "Your comment on the Intranet request has been sent."
					},
					"Update": {
						"Supervisor": "A comment on the Intranet request has been modified by",
						"Usuario": "Your comment on the intranet request has been modified and submitted."
					},
					"Confirmar": "It is not necessary to confirm receipt."
				}
			}
		'
	;

	if object_id('tempdb..#tempParams') is not null drop table #tempParams;

	create table #tempParams(
		ID int identity(1,1) not null,
		Variable varchar(max),
		Valor varchar(max)
	);

	select top 1 
		@IDIdioma=App.fnGetPreferencia('Idioma', u.IDUsuario, 'es-MX')
	from Intranet.tblSolicitudesEmpleado SE
		join Seguridad.tblUsuarios u on u.IDEmpleado = SE.IDEmpleado
	WHERE SE.IDSolicitud = @IDSolicitud

	select 
		@IDEmpleado		= SE.IDEmpleado 
		,@ClaveEmpleado = m.ClaveEmpleado
		,@Nombre		= m.Nombre
		,@SegundoNombre = m.SegundoNombre
		,@Paterno = m.Paterno
		,@Materno = m.Materno
		,@Fecha		= SE.FechaCreacion
		,@Fechaini	= SE.FechaIni
		,@Folio		= 'S'+cast(se.IDSolicitud as Varchar(10))
		,@TipoSolicitud		= JSON_VALUE(TS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))
		,@EstatusSolicitud	= JSON_VALUE(ES.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))
		,@IDIncidencia		= I.Descripcion
		,@UsuarioAutoriza	= U.Nombre +' '+ U.Apellido
	from Intranet.tblSolicitudesEmpleado SE with (nolock)
		inner join Intranet.tblCatEstatusSolicitudes ES on ES.IDEstatusSolicitud = SE.IDEstatusSolicitud
		inner join Intranet.tblCatTipoSolicitud TS on TS.IDTipoSolicitud = SE.IDTipoSolicitud
		inner join RH.tblEmpleadosMaster M with (nolock) on SE.IDEmpleado = m.IDEmpleado
		--INNER join RH.tblContactoEmpleado ce with (nolock)
		--	on ce.IDEmpleado = M.IDEmpleado
		--INNER join rh.tblCatTipoContactoEmpleado tce with (nolock)
		--	on ce.IDTipoContactoEmpleado = tce.IDTipoContacto
		--		and tce.Descripcion = 'EMAIL'
		left join Asistencia.tblCatIncidencias I on SE.IDIncidencia = I.IDIncidencia
		left join Seguridad.tblUsuarios U on SE.IDUsuarioAutoriza = U.IDUsuario
		left join Seguridad.tblUsuarios UU on UU.IDEmpleado = SE.IDEmpleado
	where SE.IDSolicitud = @IDSolicitud

    select @Email= [Utilerias].[fnGetCorreoEmpleado] (@IDEmpleado,0,@IDTipoNotificacion);

	select 
		@CreateSupervisorMensaje	= info.CreateSupervisor
		,@CreateUsuarioMensaje		= info.CreateUsuario
		,@UpdateSupervisorMensaje	= info.UpdateSupervisor
		,@UpdateUsuarioMensaje		= info.UpdateUsuario
		,@Confirmar					= info.Confirmar		
	from OPENJSON(@notificaciones, formatmessage('$.%s', lower(replace(@IDIdioma, '-',''))))
		WITH  (
			CreateSupervisor varchar(100) N'$.Create.Supervisor',
			UpdateSupervisor varchar(100) N'$.Update.Supervisor',
			CreateUsuario varchar(100) N'$.Create.Usuario',
			UpdateUsuario varchar(100) N'$.Update.Usuario',
			Confirmar	varchar(100) N'$.Confirmar'
		) info

	select 
		@Comentario = C.Comentario
		,@IDUsuarioComentario = C.IDUsuario 
		,@NombreComentario = coalesce(U.Nombre, '') +' '+ coalesce(U.Apellido, '') +' - '+ coalesce(u.Cuenta, '')
	from App.tblComentarios C 
		Join Seguridad.tblUsuarios U on C.IDUsuario = U.IDUsuario
	where C.IDComentario = @IDComentario

	insert #tempParams(Variable, Valor)
	values('NombreColaborador',coalesce(@Nombre,''))
		,('ClaveColaborador',coalesce(@ClaveEmpleado,''))

	insert #tempParams(Variable, Valor)
	VALUES ('Folio', @Folio)
			,('NombreComentario', @NombreComentario)
			,('Comentario', @Comentario)
			,('Fecha', FORMAT(getdate(), 'd',  @IDIdioma )+' '+FORMAT(getdate(), 'HH:mm',  @IDIdioma))
			,('confirmar', 'No es necesario confirmar de recibido.')

	IF(@TipoCambio = 'CREATE-SUPERVISOR')
	BEGIN
		insert #tempParams(Variable, Valor)
		VALUES ('Mensaje', @CreateSupervisorMensaje) 
	END

	IF(@TipoCambio = 'UPDATE-SUPERVISOR')
	BEGIN
		insert #tempParams(Variable, Valor)
		VALUES ('Mensaje', @UpdateSupervisorMensaje) 
	END

	IF(@TipoCambio = 'CREATE-USUARIO')
	BEGIN
		insert #tempParams(Variable, Valor)
		VALUES('Mensaje', @CreateUsuarioMensaje) 
	END

	IF(@TipoCambio = 'UPDATE-USUARIO')
	BEGIN
		insert #tempParams(Variable, Valor)
		VALUES('Mensaje', @UpdateUsuarioMensaje) 
	END	

	DECLARE 
		@cols AS NVARCHAR(MAX),
		@query  AS NVARCHAR(MAX)
	;

	IF OBJECT_ID('TEMPDB.dbo.##tempParamsPivot') IS NOT NULL DROP TABLE ##tempParamsPivot
	
	SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(c.Variable) 
            FROM #tempParams c
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')

	set @query = 'SELECT  ' + @cols + ' 
			into ##tempParamsPivot
			from 
            (
                select Variable
                    , Valor
                   
                from #tempParams
           ) x
            pivot 
            (
                 max(Valor)
                for Variable in (' + @cols + ')
            ) p '


	execute(@query)

	select @valor = a.JSON 
	from ##tempParamsPivot b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	
	BEGIN TRY
		BEGIN TRAN TransaccionNotificaciones
			insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros, IDIdioma)  
			select @IDTipoNotificacion,@valor, @IDIdioma

			set @IDNotificacion = @@IDENTITY  
			IF(@TipoCambio = 'CREATE-SUPERVISOR')
			BEGIN

                insert [App].[tblEnviarNotificacionA](  
					  IDNotifiacion  
					 ,IDMedioNotificacion  
					 ,Destinatario
					 ,Adjuntos) 
                SELECT @IDNotificacion,
                        templateNot.IDMedioNotificacion,
                        c.Email,
                        NULL
                from RH.tblJefesEmpleados JE					
					LEFT JOIN Utilerias.fnBuscarCorreosEmpleados(@IDTipoNotificacion) c on c.IDEmpleado=JE.IDJefe					
					INNER JOIN [App].[tblTemplateNotificaciones] templateNot on templateNot.IDTipoNotificacion = @IDTipoNotificacion and templateNot.IDIdioma = @IDIdioma
				where JE.IDEmpleado = @IDEmpleado and c.Email is not null
			END
			IF(@TipoCambio = 'UPDATE-SUPERVISOR')
			BEGIN
				insert [App].[tblEnviarNotificacionA](  
					IDNotifiacion  
					,IDMedioNotificacion  
					,Destinatario
					,Adjuntos
				) 
				select 
					@IDNotificacion  
					,templateNot.IDMedioNotificacion  
					, c.Email
					,NULL 
				from RH.tblJefesEmpleados JE					
					LEFT JOIN Utilerias.fnBuscarCorreosEmpleados(@IDTipoNotificacion) c on c.IDEmpleado=JE.IDJefe					
					INNER JOIN [App].[tblTemplateNotificaciones] templateNot on templateNot.IDTipoNotificacion = @IDTipoNotificacion and templateNot.IDIdioma = @IDIdioma
				where JE.IDEmpleado = @IDEmpleado and c.Email is not null
			END
			IF(@TipoCambio = 'CREATE-USUARIO' and @Email is not null)
			BEGIN
				insert [App].[tblEnviarNotificacionA](  
					IDNotifiacion  
					,IDMedioNotificacion  
					,Destinatario
					,Adjuntos
				)  
				select 
					@IDNotificacion  
					,templateNot.IDMedioNotificacion  
					,@Email 
					,NULL
				from [App].[tblTiposNotificaciones] tn  
					join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion
						and templateNot.IDIdioma = @IDIdioma
				where tn.IDTipoNotificacion = @IDTipoNotificacion
			END
			IF(@TipoCambio = 'UPDATE-USUARIO' and @Email is not null)
			BEGIN
				insert [App].[tblEnviarNotificacionA](  
					IDNotifiacion  
					,IDMedioNotificacion  
					,Destinatario
					,Adjuntos)  
				select 
					@IDNotificacion  
					,templateNot.IDMedioNotificacion  
					,@Email 
					,NULL
				from [App].[tblTiposNotificaciones] tn  
					join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion
						and templateNot.IDIdioma = @IDIdioma
				where tn.IDTipoNotificacion = @IDTipoNotificacion
			END	
	
	COMMIT TRAN TransaccionNotificaciones
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN TransaccionNotificaciones
	END CATCH
GO
