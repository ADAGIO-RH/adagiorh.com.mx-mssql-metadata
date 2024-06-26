USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [App].[INotificacionReciboNomina] @IDTipoNotificacion=N'ReciboNomina',@IDHistorialEmpleadoPeriodo=13587,@Adjuntos=N'C:\AdagioTFS\adagioRHSolutions\Development\Version 1.3.0.0\adagioRH.Web\RecibosNomina\4\001_04_202001\PDF\CBS1310252C8_ADG0003_ABREU COLON ANEUDY .PDF' 

CREATE proc [App].[INotificacionSolicitudIntranet](  
 @IDSolicitud int    
 ,@TipoCambio Varchar(50)
) as  
	declare   
		--@IDUsuario int = 1  
		--,@key varchar(1000) = 'ZMqvYHEdJNDs3GkCkIkDoBz7ONvav2lnvUfArDZy670'  
		@IDNotificacion int = 0  
		,@IDTipoNotificacion varchar(100) = 'SolicitudIntranet'  
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
	
	;

	if object_id('tempdb..#tempParams') is not null drop table #tempParams;

	create table #tempParams(
		ID int identity(1,1) not null,
		Variable varchar(max),
		Valor varchar(max)
	);

	select @IDEmpleado = SE.IDEmpleado 
		,@ClaveEmpleado = m.ClaveEmpleado
		,@Nombre = m.Nombre
		,@SegundoNombre = m.SegundoNombre
		,@Paterno = m.Paterno
		,@Materno = m.Materno
		,@Email = isnull(ce.Value,UU.Email)
		,@Fecha = SE.FechaCreacion
		,@Fechaini = SE.FechaIni
		,@Folio = 'S'+cast(IDSolicitud as Varchar(10))
		,@TipoSolicitud = TS.Descripcion
		,@EstatusSolicitud = ES.Descripcion
		,@IDIncidencia = I.Descripcion
		,@UsuarioAutoriza = U.Nombre +' '+ U.Apellido
	from Intranet.tblSolicitudesEmpleado SE with (nolock)
		INNER JOIN Intranet.tblCatEstatusSolicitudes ES
			on ES.IDEstatusSolicitud = SE.IDEstatusSolicitud
		INNER JOIN Intranet.tblCatTipoSolicitud TS
			on TS.IDTipoSolicitud = SE.IDTipoSolicitud
		INNER join RH.tblEmpleadosMaster M with (nolock)
			on SE.IDEmpleado = m.IDEmpleado
		INNER join RH.tblContactoEmpleado ce with (nolock)
			on ce.IDEmpleado = M.IDEmpleado
		INNER join rh.tblCatTipoContactoEmpleado tce with (nolock)
			on ce.IDTipoContactoEmpleado = tce.IDTipoContacto
				and tce.Descripcion = 'EMAIL'
		LEFT JOIN Asistencia.tblCatIncidencias I
			on SE.IDIncidencia = I.IDIncidencia
		left join Seguridad.tblUsuarios U
			on SE.IDUsuarioAutoriza = U.IDUsuario
		left join Seguridad.tblUsuarios UU
			on UU.IDEmpleado = SE.IDEmpleado
	WHERE SE.IDSolicitud = @IDSolicitud




	insert #tempParams(Variable, Valor)
	values('NombreColaborador',coalesce(@Nombre,'')+' '+coalesce(@SegundoNombre,'') +' '+coalesce(@Paterno,'')+' '+coalesce(@Materno,''))
		,('ClaveColaborador',coalesce(@ClaveEmpleado,''))
	
	IF(@TipoCambio = 'CREATE-SUPERVISOR')
	BEGIN
		insert #tempParams(Variable, Valor)
		VALUES('Mensaje', 'Se ha generado una solicitud de Intranet por parte de') 
			  ,('Folio', isnull(@Folio,'')) 		
			  ,('Tipo', isnull(@TipoSolicitud,'')) 		
			  ,('Estatus', @EstatusSolicitud)	
			  ,('Fecha', FORMAT(@Fecha,'dd/MM/yyyy HH:mm')) 		
			  ,('Favor', 'Favor de revisar.') 		
			  ,('confirmar', 'No es necesario confirmar de recibido.') 		
					
	END

	IF(@TipoCambio = 'UPDATE-SUPERVISOR')
	BEGIN
			insert #tempParams(Variable, Valor)
			VALUES('Mensaje', 'Se ha Modificado la solicitud de Intranet por parte de ') 
			  ,('Folio', isnull(@Folio,'')) 		
			  ,('Tipo', isnull(@TipoSolicitud,'')) 
			  ,('Estatus', @EstatusSolicitud)			
			  ,('Fecha', FORMAT(@Fecha,'dd/MM/yyyy HH:mm')) 		
			  ,('Favor', 'Favor de revisar.') 		
			  ,('confirmar', 'No es necesario confirmar de recibido.') 

	END
	IF(@TipoCambio = 'CREATE-USUARIO')
	BEGIN
			insert #tempParams(Variable, Valor)
			VALUES('Mensaje', 'Se ha creado tu solicitud de Intranet.') 
			  ,('Folio', isnull(@Folio,'')) 		
			  ,('Tipo', isnull(@TipoSolicitud,'')) 	
			  ,('Estatus', @EstatusSolicitud)	
			  ,('Fecha', FORMAT(@Fecha,'dd/MM/yyyy HH:mm')) 		
			  ,('Favor', 'Favor de revisar.') 		
			  ,('confirmar', 'No es necesario confirmar de recibido.') 
	END
	IF(@TipoCambio = 'UPDATE-USUARIO')
	BEGIN
			insert #tempParams(Variable, Valor)
			VALUES('Mensaje', 'Has Modificado tu solicitud de Intranet') 
			  ,('Folio', isnull(@Folio,'')) 		
			  ,('Tipo', isnull(@TipoSolicitud,'')) 	
			  ,('Estatus', @EstatusSolicitud)	
			  ,('Fecha', FORMAT(@Fecha,'dd/MM/yyyy HH:mm')) 		
			  ,('Favor', 'Favor de revisar.') 		
			  ,('confirmar', 'No es necesario confirmar de recibido.') 
	END	
 
	IF(@TipoCambio = 'APROBADA-USUARIO')
	BEGIN
			insert #tempParams(Variable, Valor)
			VALUES('Mensaje', 'La solicitud de Intranet fue APROBADA') 
			  ,('Folio', isnull(@Folio,'')) 		
			  ,('Tipo', isnull(@TipoSolicitud,'')) 	
			  ,('Estatus', @EstatusSolicitud)	
			  ,('Fecha', FORMAT(@Fecha,'dd/MM/yyyy HH:mm')) 		
			  ,('Favor', 'Favor de revisar.') 		
			  ,('confirmar', 'No es necesario confirmar de recibido.')
	END	

	IF(@TipoCambio = 'RECHAZADA-USUARIO')
	BEGIN
			insert #tempParams(Variable, Valor)
			VALUES('Mensaje', 'La solicitud de Intranet fue RECHAZADA') 
			  ,('Folio', isnull(@Folio,'')) 		
			  ,('Tipo', isnull(@TipoSolicitud,'')) 	
			  ,('Estatus', @EstatusSolicitud)	
			  ,('Fecha', FORMAT(@Fecha,'dd/MM/yyyy HH:mm')) 		
			  ,('Favor', 'Favor de revisar.') 		
			  ,('confirmar', 'No es necesario confirmar de recibido.')
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
			insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
			SELECT @IDTipoNotificacion,@valor
	 --select @IDTipoNotificacion,N'NombreColaborador|'+coalesce(@Nombre,'')
		--   +',ClaveColaborador|'+coalesce(@ClaveEmpleado,'')  
		--   +',Mensaje|'+'Hola '+coalesce(@Nombre,'')+' '+coalesce(@SegundoNombre,'') +' '+coalesce(@Paterno,'')+' '+coalesce(@Materno,'') +' - ('+@ClaveEmpleado+') te hacemos entrega de tu recibo de nómina correspondiente al periodo del día '+ cast(@Fechaini as varchar)+' al día '+cast(@FechaFin as varchar)+'.

		--				No es necesario confirmar de recibido.' 
  
			set @IDNotificacion = @@IDENTITY  
			 IF(@TipoCambio = 'CREATE-SUPERVISOR')
			BEGIN
				 insert [App].[tblEnviarNotificacionA](  
					  IDNotifiacion  
					 ,IDMedioNotificacion  
					 ,Destinatario
					 ,Adjuntos) 
					select 
					  @IDNotificacion  
					  ,templateNot.IDMedioNotificacion  
					  ,case when templateNot.IDMedioNotificacion = 'Email' then rtrim(ltrim(CE.Value)) else null end  
					  ,NULL 
					from RH.tblJefesEmpleados JE
						INNER join RH.tblContactoEmpleado ce with (nolock)
							on ce.IDEmpleado = JE.IDJefe
						INNER join rh.tblCatTipoContactoEmpleado tce with (nolock)
							on CE.IDTipoContactoEmpleado = tce.IDTipoContacto
							and tce.Descripcion = 'EMAIL'
					  INNER JOIN	[App].[tblTiposNotificaciones] tn  
						on tn.IDTipoNotificacion = @IDTipoNotificacion
					  INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
					where JE.IDEmpleado = @IDEmpleado
					and CE.Value is not null
			END

			IF(@TipoCambio = 'UPDATE-SUPERVISOR')
			BEGIN
					insert [App].[tblEnviarNotificacionA](  
				  IDNotifiacion  
				 ,IDMedioNotificacion  
				 ,Destinatario
				 ,Adjuntos) 
				select 
				  @IDNotificacion  
				  ,templateNot.IDMedioNotificacion  
				  ,case when templateNot.IDMedioNotificacion = 'Email' then rtrim(ltrim(CE.Value)) else null end  
				  ,NULL 
				from RH.tblJefesEmpleados JE
					INNER join RH.tblContactoEmpleado ce with (nolock)
						on ce.IDEmpleado = JE.IDJefe
					INNER join rh.tblCatTipoContactoEmpleado tce with (nolock)
						on CE.IDTipoContactoEmpleado = tce.IDTipoContacto
						and tce.Descripcion = 'EMAIL'
				  INNER JOIN	[App].[tblTiposNotificaciones] tn  
					on tn.IDTipoNotificacion = @IDTipoNotificacion
				  INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
				where JE.IDEmpleado = @IDEmpleado
				and CE.Value is not null
			END
			IF(@TipoCambio = 'CREATE-USUARIO')
			BEGIN
				insert [App].[tblEnviarNotificacionA](  
				  IDNotifiacion  
				 ,IDMedioNotificacion  
				 ,Destinatario
				 ,Adjuntos)  
				 select @IDNotificacion  
					  ,templateNot.IDMedioNotificacion  
					  ,case when templateNot.IDMedioNotificacion = 'Email' then @Email else null end  
					  ,NULL
				 from [App].[tblTiposNotificaciones] tn  
				  join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
				 where tn.IDTipoNotificacion = @IDTipoNotificacion
			END
			IF(@TipoCambio = 'UPDATE-USUARIO')
			BEGIN
				insert [App].[tblEnviarNotificacionA](  
				  IDNotifiacion  
				 ,IDMedioNotificacion  
				 ,Destinatario
				 ,Adjuntos)  
				 select @IDNotificacion  
					  ,templateNot.IDMedioNotificacion  
					  ,case when templateNot.IDMedioNotificacion = 'Email' then @Email else null end  
					  ,NULL
				 from [App].[tblTiposNotificaciones] tn  
				  join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
				 where tn.IDTipoNotificacion = @IDTipoNotificacion
			END	
			IF(@TipoCambio = 'APROBADA-USUARIO')
			BEGIN
				insert [App].[tblEnviarNotificacionA](  
				  IDNotifiacion  
				 ,IDMedioNotificacion  
				 ,Destinatario
				 ,Adjuntos)  
				 select @IDNotificacion  
					  ,templateNot.IDMedioNotificacion  
					  ,case when templateNot.IDMedioNotificacion = 'Email' then @Email else null end  
					  ,NULL
				 from [App].[tblTiposNotificaciones] tn  
				  join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
				 where tn.IDTipoNotificacion = @IDTipoNotificacion
			END	
			IF(@TipoCambio = 'RECHAZADA-USUARIO')
			BEGIN
				insert [App].[tblEnviarNotificacionA](  
				  IDNotifiacion  
				 ,IDMedioNotificacion  
				 ,Destinatario
				 ,Adjuntos)  
				 select @IDNotificacion  
					  ,templateNot.IDMedioNotificacion  
					  ,case when templateNot.IDMedioNotificacion = 'Email' then @Email else null end  
					  ,NULL
				 from [App].[tblTiposNotificaciones] tn  
				  join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
				 where tn.IDTipoNotificacion = @IDTipoNotificacion
			END	
	COMMIT TRAN TransaccionNotificaciones
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN TransaccionNotificaciones
	END CATCH
GO
