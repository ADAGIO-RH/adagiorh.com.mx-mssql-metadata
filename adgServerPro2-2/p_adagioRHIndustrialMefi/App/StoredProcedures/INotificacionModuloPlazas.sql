USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [App].[INotificacionModuloPlazas](
	@IDAprobador int = 0
	,@IDPlaza int 
	,@TipoCambio Varchar(50)
) as  
	declare   
		--@IDUsuario int = 1  
		--,@key varchar(1000) = 'ZMqvYHEdJNDs3GkCkIkDoBz7ONvav2lnvUfArDZy670'  
		@IDNotificacion int = 0  
		,@IDTipoNotificacion varchar(100) = 'AprobacionPlaza'  
		,@ClaveEmpleado  varchar(50)  
		,@NombreSolicitante  varchar(255)    
		,@ApellidoPublicador  varchar(255)    
		,@EmailPublicador   varchar(255)  
		,@NombreAutorizar  varchar(255)    
		,@ApellidoAutorizar  varchar(255)    
		,@EmailAutorizar   varchar(255)  
		,@Email   varchar(255)  
		,@Fecha date  
		,@Codigo App.SMName
		,@Plaza App.MDName
		,@valor varchar(max)
		,@URL Varchar(max)
		,@Observacion	varchar(max)
		,@htmlBody varchar(max)
		,@subject varchar(300)
		,@IDTableRow int
		,@RowContent varchar(max)
		,@TableContent varchar(max) = N'
		<tr>
			<td><b>Cuenta		</b></t>
			<td><b>Usuario		</b></t>
			<td><b>Estatus		</b></t>
			<td><b>Fecha y hora	</b></t>
			<td><b>Orden		</b></t>
		</tr>  
		'
	;

	DECLARE @CountAprobadores int = 0,
		@Secuencia int = 0,
		@SecuenciaMax int = 0

	select @SecuenciaMax = isnull(MAX(isnull(secuencia,0)),0) 
	from RH.tblAprobadoresPlazas 
	where IDPlaza = @IDPlaza

	select @URL = Valor+'Login/Index?idaplicacion=catalogos' from app.tblConfiguracionesGenerales where IDConfiguracion = 'Url'

	if object_id('tempdb..#tempTableRows') is not null drop table #tempTableRows;

	select
		FORMATMESSAGE(N'
		<tr>
			<td>%s</t>
			<td>%s</t>
			<td>%s</t>
			<td>%s</t>
			<td>%d</t>
		</tr>  
		', 
			u.Cuenta,
			coalesce(u.Nombre, '')+ ' ' +coalesce(u.Nombre, ''),
			case 
							when Aprobacion = 0 then 'Pendiente de aprobación'
							when Aprobacion = 1 then 'Aprobada'
							when Aprobacion = 2 then 'Rechazada'
						else  'Pendiente de aprobación' end,
			isnull(FORMAT(ap.FechaAprobacion, 'dd/MM/yyyy HH:mm'),'PENDIENTE'),
			ap.Orden
		) as table_row
		,ROW_NUMBER() OVER(order by Orden) as ROW
	INTO #tempTableRows
	from RH.tblAprobadoresPlazas ap
		join Seguridad.tblUsuarios u on u.IDUsuario = ap.IDUsuario
	where IDPlaza = @IDPlaza

	select @IDTableRow = MIN([ROW]) from #tempTableRows

	while exists (select top 1 1
					from #tempTableRows 
					where [ROW] >= @IDTableRow)
	begin

		select @RowContent = table_row
		from #tempTableRows 
		where [ROW] = @IDTableRow

		set @TableContent = coalesce(@TableContent,'') + REPLACE(REPLACE(REPLACE(coalesce(@RowContent,''),CHAR(9), ''),CHAR(13), ''),CHAR(10), '')

		select @IDTableRow = MIN([ROW]) from #tempTableRows where [ROW] > @IDTableRow

	end

	--if object_id('tempdb..#tempParams') is not null drop table #tempParams;

	--create table #tempParams(
	--	ID int identity(1,1) not null,
	--	Variable varchar(max),
	--	Valor varchar(max)
	--);



	--insert #tempParams(Variable, Valor)
	--values('NombreColaborador',coalesce(@NombreAutorizar,''))
	
	IF(@TipoCambio = 'CREATE-AUTORIZA')
	BEGIN

		SELECT TOP 1
			@NombreSolicitante		= UP.Nombre
			,@ApellidoPublicador	= UP.Apellido
			,@EmailPublicador		= UP.Email
			,@NombreAutorizar		= U.Nombre
			,@ApellidoAutorizar		= U.Apellido
			,@Email	= U.Email
			,@Fecha				= estatus.FechaReg
			,@Codigo			= CD.Codigo
			,@Plaza				= catpue.Descripcion
		from RH.tblCatPlazas CD with (nolock)
			inner join RH.tblAprobadoresPlazas AD on CD.IDPlaza = AD.IDPlaza
			inner join Seguridad.tblUsuarios U on U.IDUsuario = AD.IDUsuario
			inner join (
				select top 1 *
				from RH.tblEstatusPlazas
				where IDPlaza = @IDPlaza and IDEstatus = 1
				order by FechaReg desc
			) as estatus on estatus.IDPlaza = CD.IDPlaza
			inner join Seguridad.tblUsuarios UP	on UP.IDUsuario = estatus.IDUsuario
			inner join RH.tblCatPuestos catpue with(nolock)
				on catpue.IDPuesto = CD.IDPuesto
		WHERE CD.IDPlaza = @IDPlaza
			and AD.Aprobacion = 0
			and AD.Secuencia = @SecuenciaMax
		ORDER BY AD.Orden ASC

		IF(ISNULL(@Codigo,'') = '')
		BEGIN
			RETURN;
		END
		--select @Folio,@NombreDocumento,@DescripcionDocumento,@TipoDocumento,@Fecha

		set @subject = FORMATMESSAGE(N'Tienes una solicitud pendiente de plaza que aprobar (Codigo de la plaza %s)', @Codigo)
		set @htmlBody = N'
			<p>'+FORMATMESSAGE('Hola %s, %s a solicitado la creación de una nueva Plaza y es tu turno para autorizarla o declinarla.', @NombreAutorizar, @NombreSolicitante)+'</p>
			<br />
			<br />
			<h4>Información de la plaza solicitada</h4>
			<p>'+FORMATMESSAGE('<b>Plaza: </b> %s', @Plaza)+'</p>
			<p>'+FORMATMESSAGE('<b>Código: </b> %s', @Codigo)+'</p>
			<br />
			<br />
			<h4>Aprobadores de esta Plaza</h4>
			<table id=''table-detalle''> 
				'+coalesce(@TableContent, '')+'
			</table>
		'
	END

	IF(@TipoCambio = 'DECLINE-AUTORIZA')
	BEGIN
		SELECT TOP 1
			@NombreSolicitante		= UP.Nombre
			,@ApellidoPublicador	= UP.Apellido
			,@Email					= UP.Email
			--,@NombreAutorizar		= U.Nombre
			--,@ApellidoAutorizar	= U.Apellido
			--,@EmailAutorizar	= U.Email
			,@Fecha				= estatus.FechaReg
			,@Codigo			= CD.Codigo
			,@Plaza				= catpue.Descripcion
		from RH.tblCatPlazas CD with (nolock)
			inner join RH.tblAprobadoresPlazas AD on CD.IDPlaza = AD.IDPlaza
			inner join Seguridad.tblUsuarios U on U.IDUsuario = AD.IDUsuario
			inner join (
				select top 1 *
				from RH.tblEstatusPlazas
				where IDPlaza = @IDPlaza and IDEstatus = 1
				order by FechaReg desc
			) as estatus on estatus.IDPlaza = CD.IDPlaza
			inner join Seguridad.tblUsuarios UP	on UP.IDUsuario = estatus.IDUsuario
				inner join RH.tblCatPuestos catpue with(nolock)
				on catpue.IDPuesto = CD.IDPuesto
		WHERE CD.IDPlaza = @IDPlaza
			and AD.IDAprobadorPlaza = @IDAprobador
			--and AD.Secuencia = @SecuenciaMax
		ORDER BY AD.Orden ASC

		SELECT TOP 1
			--@NombreSolicitante		= UP.Nombre
			--,@ApellidoPublicador	= UP.Apellido
		--	,@EmailPublicador		= UP.Email
			@NombreAutorizar		= U.Nombre
			,@ApellidoAutorizar		= U.Apellido
			,@EmailAutorizar	= U.Email
			--,@Fecha				= estatus.FechaReg
			,@Codigo			= CD.Codigo
			,@Plaza				= catpue.Descripcion
			,@Observacion		= isnull(AD.Observacion, 'SIN OBSERVACIONES')
		from RH.tblCatPlazas CD with (nolock)
			inner join RH.tblAprobadoresPlazas AD on CD.IDPlaza = AD.IDPlaza
			inner join Seguridad.tblUsuarios U on U.IDUsuario = AD.IDUsuario
			inner join RH.tblCatPuestos catpue with(nolock)
				on catpue.IDPuesto = CD.IDPuesto
		WHERE AD.IDAprobadorPlaza = @IDAprobador
			and AD.Secuencia = @SecuenciaMax
		ORDER BY AD.Orden ASC

		set @subject = FORMATMESSAGE(N'Tu solicitud de la Plaza %s fue RECHAZADA (Codigo de la plaza %s)', @Plaza, @Codigo)
		set @htmlBody = N'
			<p>'+FORMATMESSAGE('Hola %s, tu solicitud de la Plaza %s con código %s fue rechazada por %s.',  @NombreSolicitante, @Plaza, @Codigo, @NombreAutorizar)+'</p>
			<br />
			<p>'+FORMATMESSAGE('Este es el motivo del rechazo de la Plaza: %s',  @Observacion)+'</p>
			<br />
			<br />
			<h4>Información de la plaza solicitada</h4>
			<p>'+FORMATMESSAGE('<b>Plaza: </b> %s', @Plaza)+'</p>
			<p>'+FORMATMESSAGE('<b>Código: </b> %s', @Codigo)+'</p>
			<br />
			<br />
			<h4>Aprobadores de esta Plaza</h4>
			<table id=''table-detalle''> 
				'+coalesce(@TableContent, '')+'
			</table>
		'
		
	END

	IF(@TipoCambio = 'COMPLETE-SECUENCIA')
	BEGIN
		SELECT TOP 1
			@NombreSolicitante		= UP.Nombre
			,@ApellidoPublicador	= UP.Apellido
			,@Email		= UP.Email
			--,@NombreAutorizar		= U.Nombre
			--,@ApellidoAutorizar		= U.Apellido
			--,@EmailAutorizar	= U.Email
			,@Fecha				= estatus.FechaReg
			,@Codigo			= CD.Codigo
			,@Plaza				= catpue.Descripcion
		from RH.tblCatPlazas CD with (nolock)
			inner join RH.tblAprobadoresPlazas AD on CD.IDPlaza = AD.IDPlaza
			inner join Seguridad.tblUsuarios U on U.IDUsuario = AD.IDUsuario
			inner join (
				select top 1 *
				from RH.tblEstatusPlazas
				where IDPlaza = @IDPlaza and IDEstatus = 1
				order by FechaReg desc
			) as estatus on estatus.IDPlaza = CD.IDPlaza
			inner join Seguridad.tblUsuarios UP	on UP.IDUsuario = estatus.IDUsuario
			inner join RH.tblCatPuestos catpue with(nolock)
				on catpue.IDPuesto = CD.IDPuesto
		WHERE AD.IDAprobadorPlaza = @IDAprobador
		AND CD.IDPlaza = @IDPlaza
			--and AD.Aprobacion = 0
			and AD.Secuencia = @SecuenciaMax
		ORDER BY AD.Orden ASC

		set @subject = FORMATMESSAGE(N'Tu solicitud de la Plaza con el código %s fue AUTORIZADA', @Codigo)
		set @htmlBody = N'
			<p>'+FORMATMESSAGE('Hola %s, el proceso de autorización de la Plaza %s con el código %s a terminado y la Plaza fue autorizada.', @NombreSolicitante, @Plaza, @Codigo)+'</p>
			<br />
			<br />
			<h4>Información de la plaza solicitada</h4>
			<p>'+FORMATMESSAGE('<b>Plaza: </b> %s', @Plaza)+'</p>
			<p>'+FORMATMESSAGE('<b>Código: </b> %s', @Codigo)+'</p>
			<br />
			<br />
			<h4>Aprobadores de esta Plaza</h4>
			<table id=''table-detalle''> 
				'+coalesce(@TableContent, '')+'
			</table>
		'
	END
	
	BEGIN TRY
		BEGIN TRAN TransNotifPlaza
			insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
			SELECT @IDTipoNotificacion,'{ "subject":"'+@subject+'", "body": "'+@htmlBody+'"}'
  
			set @IDNotificacion = SCOPE_IDENTITY()  
			 
			insert [App].[tblEnviarNotificacionA](IDNotifiacion,IDMedioNotificacion,Destinatario,Adjuntos) 
			select 
				@IDNotificacion  
				,templateNot.IDMedioNotificacion  
				,case when templateNot.IDMedioNotificacion = 'Email' then @Email else null end  
				,NULL 
			from 	[App].[tblTiposNotificaciones] tn  
				INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
				and tn.IDTipoNotificacion = @IDTipoNotificacion
		COMMIT TRAN TransNotifPlaza
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN TransNotifPlaza
	END CATCH
GO
