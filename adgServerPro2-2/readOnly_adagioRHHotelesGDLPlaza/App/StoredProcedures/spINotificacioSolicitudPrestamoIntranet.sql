USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[spINotificacioSolicitudPrestamoIntranet] (
	@IDSolicitudPrestamo int
) as
	declare 
		@IDEstatusSolicitudPrestamoActual int,
		@Cancelado bit,
		@FechaHoraCancelacion datetime,
		@Autorizado bit,
		@FechaHoraAutorizacion datetime,
		@IDPrestamo int,
		@IDTipoNotificacion varchar(100) = 'SolicitudPrestamoIntranet'  ,
		@IDNotificacion int
	;

	declare 
		--@IDSolicitudPrestamo int = 9,
		@htmlColaborador varchar(max),
		@subjectColaborador varchar(300),
		@htmlNominista varchar(max),
		@subjectNominista varchar(300)
	;

	select 
		@IDEstatusSolicitudPrestamoActual	= IDEstatusSolicitudPrestamo
	from [Intranet].[tblSolicitudesPrestamos] with (nolock)
	where IDSolicitudPrestamo = @IDSolicitudPrestamo 

	if (@IDEstatusSolicitudPrestamoActual = 1) 
	begin
		begin -- campos
			print 1
			--sp.IDSolicitudPrestamo
			--,sp.IDEmpleado
			--,e.ClaveEmpleado
			--,e.NOMBRECOMPLETO as Colaborador
			--,sp.IDTipoPrestamo
			--,ctp.Descripcion as TipoPrestamo
			--,isnull(sp.MontoPrestamo,0.00) as MontoPrestamo
			--,isnull(sp.Cuotas, 0) as Cuotas
			--,sp.CantidadCuotas
			--,sp.FechaCreacion
			--,sp.FechaInicioPago
			--,sp.Autorizado
			--,isnull(sp.IDUsuarioAutorizo,0) as IDUsuarioAutorizo
			--,sp.FechaHoraAutorizacion
			--,sp.Cancelado
			--,isnull(sp.IDUsuarioCancelo,0) as IDUsuarioCancelo	   
			--,sp.FechaHoraCancelacion
			--,sp.MotivoCancelacion
			--,isnull(sp.IDPrestamo,0) as IDPrestamo		   
			--,sp.Descripcion
			--,isnull(sp.Intereses,0.00) as Intereses		
			--,sp.IDEstatusSolicitudPrestamo
			--,cesp.Nombre as Estatus
			--,cesp.CssClass
		end 
		
		select 
			@subjectColaborador = e.Nombre+' Hemos recibido tu solicitud de un nuevo préstamo',
			@htmlColaborador = N'
			<p>Hola '+e.Nombre+', <p> <br />
			Hemos recibido tu solicitud de préstamos por concepto de <b>'+ctp.Descripcion+'.</b> <br />

			<h1>Detalle del préstamos solicitado</h1> <br />
			<table id=''table-detalle''> 
				<tr>
					<td>Tipo de préstamo</td>
					<td>'+ctp.Descripcion+'</t>
				</tr>  
				<tr>
					<td>Monto Solicitado</td>
					<td>'+cast(isnull(sp.MontoPrestamo,0.00) as varchar(20))+'</t>
				</tr>  
				<tr>
					<td>Monto de las Coutas</td>
					<td>'+cast(isnull(sp.Cuotas, 0) as varchar(20))+'</t>
				</tr>  
				<tr>
					<td>Cantidad de Cuotas</td>
					<td>'+cast(isnull(sp.CantidadCuotas, 0) as varchar(20))+'</t>
				</tr>  
				<tr>
					<td>Fecha de inicio</td>
					<td>'+format(sp.FechaInicioPago, 'dd/MM/yyyy')+'</t>
				</tr>  
				<tr>
					<td>Estatus</td>
					<td>'+cesp.Nombre+'</td>
				</tr> 
			</table>
			' 

		from [Intranet].[tblSolicitudesPrestamos] sp with (nolock)
			join [RH].[tblEmpleadosMaster] e with (nolock) on e.IDEmpleado = sp.IDEmpleado
			join [Nomina].[tblCatTiposPrestamo] ctp with (nolock) on ctp.IDTipoPrestamo = sp.IDTipoPrestamo
			join [Intranet].[tblCatEstatusSolicitudesPrestamos] cesp with (nolock) on cesp.IDEstatusSolicitudPrestamo = sp.IDEstatusSolicitudPrestamo 
		where sp.IDSolicitudPrestamo = @IDSolicitudPrestamo

		insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
		SELECT @IDTipoNotificacion,'{ "subject":"'+@subjectColaborador+'", "body": "'+@htmlColaborador+'"}'

		set @IDNotificacion = @@IDENTITY  
		insert [App].[tblEnviarNotificacionA](  
			IDNotifiacion  
			,IDMedioNotificacion  
			,Destinatario
			,Adjuntos) 
		select 
			@IDNotificacion  
			,templateNot.IDMedioNotificacion  
			,case when templateNot.IDMedioNotificacion = 'Email' then 'aneudy.abreu@adagio.com.mx' else null end  
			,NULL 
		from [App].[tblTiposNotificaciones] tn  
 
			INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
		where tn.IDTipoNotificacion = @IDTipoNotificacion

		select 
			@subjectNominista = e.Nombre+' ha solicitado un nuevo préstamo',
			@htmlNominista = N'
			<p>El colaborador(a) '+e.ClaveEmpleado +' - '+e.Nombre+' , <p> <br />
			Ha realizado una solicitud de préstamos por concepto de <b>'+ctp.Descripcion+'.</b> <br />

			<h1>Detalle del préstamos solicitado</h1> <br />
			<table id=''table-detalle''> 
				<tr>
					<td>Tipo de préstamo</td>
					<td>'+ctp.Descripcion+'</t>
				</tr>  
				<tr>
					<td>Monto Solicitado</td>
					<td>'+cast(isnull(sp.MontoPrestamo,0.00) as varchar(20))+'</t>
				</tr>  
				<tr>
					<td>Monto de las Coutas</td>
					<td>'+cast(isnull(sp.Cuotas, 0) as varchar(20))+'</t>
				</tr>  
				<tr>
					<td>Cantidad de Cuotas</td>
					<td>'+cast(isnull(sp.CantidadCuotas, 0) as varchar(20))+'</t>
				</tr>  
				<tr>
					<td>Fecha de inicio</td>
					<td>'+format(sp.FechaInicioPago, 'dd/MM/yyyy')+'</t>
				</tr>
				<tr>
					<td>Estatus</td>
					<td>'+cesp.Nombre+'</td>
				</tr> 
			</table>
			' 

		from [Intranet].[tblSolicitudesPrestamos] sp with (nolock)
			join [RH].[tblEmpleadosMaster] e with (nolock) on e.IDEmpleado = sp.IDEmpleado
			join [Nomina].[tblCatTiposPrestamo] ctp with (nolock) on ctp.IDTipoPrestamo = sp.IDTipoPrestamo
			join [Intranet].[tblCatEstatusSolicitudesPrestamos] cesp with (nolock) on cesp.IDEstatusSolicitudPrestamo = sp.IDEstatusSolicitudPrestamo 
		where sp.IDSolicitudPrestamo = @IDSolicitudPrestamo

		insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
		SELECT @IDTipoNotificacion,'{ "subject":"'+@subjectNominista+'", "body": "'+@htmlNominista+'"}'

		set @IDNotificacion = @@IDENTITY  

		insert [App].[tblEnviarNotificacionA](  
			IDNotifiacion  
			,IDMedioNotificacion  
			,Destinatario
			,Adjuntos) 
		select 
			@IDNotificacion  
			,templateNot.IDMedioNotificacion  
			,case when templateNot.IDMedioNotificacion = 'Email' then 'aneudy.abreu@adagio.com.mx' else null end  
			,NULL 
		from [App].[tblTiposNotificaciones] tn  
 
			INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
		where tn.IDTipoNotificacion = @IDTipoNotificacion
	end

	if (@IDEstatusSolicitudPrestamoActual = 2) 
	begin
		select 
			@subjectColaborador = e.Nombre+' Tu solicitud de préstamo ha sido CANCELADA',
			@htmlColaborador = N'
			<p>Hola '+e.Nombre+', <p> <br />
			Tu solicitud de préstamos por concepto de <b>'+ctp.Descripcion+' fue cancelada.</b> <br />

			<h1>Detalle del préstamos solicitado</h1> <br />
			<table id=''table-detalle''> 
				<tr>
					<td>Tipo de préstamo</td>
					<td>'+ctp.Descripcion+'</t>
				</tr>  
				<tr>
					<td>Monto Solicitado</td>
					<td>'+cast(isnull(sp.MontoPrestamo,0.00) as varchar(20))+'</t>
				</tr>  
				<tr>
					<td>Monto de las Coutas</td>
					<td>'+cast(isnull(sp.Cuotas, 0) as varchar(20))+'</t>
				</tr>  
				<tr>
					<td>Cantidad de Cuotas</td>
					<td>'+cast(isnull(sp.CantidadCuotas, 0) as varchar(20))+'</t>
				</tr>  
				<tr>
					<td>Fecha de inicio</td>
					<td>'+format(sp.FechaInicioPago, 'dd/MM/yyyy')+'</t>
				</tr>  
				<tr>
					<td>Estatus</td>
					<td>'+cesp.Nombre+'</td>
				</tr>  
			</table>
			' 
		from [Intranet].[tblSolicitudesPrestamos] sp with (nolock)
			join [RH].[tblEmpleadosMaster] e with (nolock) on e.IDEmpleado = sp.IDEmpleado
			join [Nomina].[tblCatTiposPrestamo] ctp with (nolock) on ctp.IDTipoPrestamo = sp.IDTipoPrestamo
			join [Intranet].[tblCatEstatusSolicitudesPrestamos] cesp with (nolock) on cesp.IDEstatusSolicitudPrestamo = sp.IDEstatusSolicitudPrestamo 
		where sp.IDSolicitudPrestamo = @IDSolicitudPrestamo

		insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
		SELECT @IDTipoNotificacion,'{ "subject":"'+@subjectColaborador+'", "body": "'+@htmlColaborador+'"}'

		set @IDNotificacion = @@IDENTITY  
		insert [App].[tblEnviarNotificacionA](  
			IDNotifiacion  
			,IDMedioNotificacion  
			,Destinatario
			,Adjuntos) 
		select 
			@IDNotificacion  
			,templateNot.IDMedioNotificacion  
			,case when templateNot.IDMedioNotificacion = 'Email' then 'aneudy.abreu@adagio.com.mx' else null end  
			,NULL 
		from [App].[tblTiposNotificaciones] tn  
			INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
		where tn.IDTipoNotificacion = @IDTipoNotificacion
	end

	if (@IDEstatusSolicitudPrestamoActual = 3) 
	begin
		select 
			@subjectColaborador = 'Felicidades '+e.Nombre+', tu solicitud de Préstamo fue AUTORIZADA',
			@htmlColaborador = N'
			<p>Hola '+e.Nombre+', <p> <br />
			Tu solicitud de préstamos por concepto de <b>'+ctp.Descripcion+' fue AUTORIZADA.</b> <br />

			<h1>Detalle del préstamos solicitado</h1> <br />
			<table id=''table-detalle''> 
				<tr>
					<td>Código del préstamo</td>
					<td>'+p.Codigo+'</t>
				</tr>  
				<tr>
					<td>Tipo de préstamo</td>
					<td>'+ctp.Descripcion+'</t>
				</tr>  
				<tr>
					<td>Monto Solicitado</td>
					<td>'+cast(isnull(sp.MontoPrestamo,0.00) as varchar(20))+'</t>
				</tr>  
				<tr>
					<td>Monto de las Coutas</td>
					<td>'+cast(isnull(sp.Cuotas, 0) as varchar(20))+'</t>
				</tr>  
				<tr>
					<td>Cantidad de Cuotas</td>
					<td>'+cast(isnull(sp.CantidadCuotas, 0) as varchar(20))+'</t>
				</tr>  
				<tr>
					<td>Fecha de inicio</td>
					<td>'+format(sp.FechaInicioPago, 'dd/MM/yyyy')+'</t>
				</tr>  
				<tr>
					<td>Estatus</td>
					<td>'+cesp.Nombre+'</td>
				</tr>   
			</table>
			' 
		from [Intranet].[tblSolicitudesPrestamos] sp with (nolock)
			join [RH].[tblEmpleadosMaster] e with (nolock) on e.IDEmpleado = sp.IDEmpleado
			join [Nomina].[tblCatTiposPrestamo] ctp with (nolock) on ctp.IDTipoPrestamo = sp.IDTipoPrestamo
			join [Intranet].[tblCatEstatusSolicitudesPrestamos] cesp with (nolock) on cesp.IDEstatusSolicitudPrestamo = sp.IDEstatusSolicitudPrestamo 
			left join [Nomina].[tblPrestamos] p on p.IDPrestamo = sp.IDPrestamo
		where sp.IDSolicitudPrestamo = @IDSolicitudPrestamo

		insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
		SELECT @IDTipoNotificacion,'{ "subject":"'+@subjectColaborador+'", "body": "'+@htmlColaborador+'"}'

		set @IDNotificacion = @@IDENTITY  
		insert [App].[tblEnviarNotificacionA](  
			IDNotifiacion  
			,IDMedioNotificacion  
			,Destinatario
			,Adjuntos) 
		select 
			@IDNotificacion  
			,templateNot.IDMedioNotificacion  
			,case when templateNot.IDMedioNotificacion = 'Email' then 'aneudy.abreu@adagio.com.mx' else null end  
			,NULL 
		from [App].[tblTiposNotificaciones] tn  
			INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
		where tn.IDTipoNotificacion = @IDTipoNotificacion
	end

	if (@IDEstatusSolicitudPrestamoActual = 4) 
	begin
		select 
			@subjectColaborador = e.Nombre+' Tu solicitud de préstamo no fue autorizada',
			@htmlColaborador = N'
			<p>Hola '+e.Nombre+', <p> <br />
			
			Lamentamos informarte que por el momento no podemos aprobar la solicitud de préstamo que realizaste por concepto de <b>'+ctp.Descripcion+'.</b> <br />

			<h1>Detalle del préstamos solicitado</h1> <br />
			<table id=''table-detalle''> 
				<tr>
					<td>Tipo de préstamo</td>
					<td>'+ctp.Descripcion+'</t>
				</tr>  
				<tr>
					<td>Monto Solicitado</td>
					<td>'+cast(isnull(sp.MontoPrestamo,0.00) as varchar(20))+'</t>
				</tr>  
				<tr>
					<td>Monto de las Coutas</td>
					<td>'+cast(isnull(sp.Cuotas, 0) as varchar(20))+'</t>
				</tr>  
				<tr>
					<td>Cantidad de Cuotas</td>
					<td>'+cast(isnull(sp.CantidadCuotas, 0) as varchar(20))+'</t>
				</tr>  
				<tr>
					<td>Fecha de inicio</td>
					<td>'+format(sp.FechaInicioPago, 'dd/MM/yyyy')+'</t>
				</tr>  
				<tr>
					<td>Estatus</td>
					<td>'+cesp.Nombre+'</td>
				</tr>  
			</table>
			' 
		from [Intranet].[tblSolicitudesPrestamos] sp with (nolock)
			join [RH].[tblEmpleadosMaster] e with (nolock) on e.IDEmpleado = sp.IDEmpleado
			join [Nomina].[tblCatTiposPrestamo] ctp with (nolock) on ctp.IDTipoPrestamo = sp.IDTipoPrestamo
			join [Intranet].[tblCatEstatusSolicitudesPrestamos] cesp with (nolock) on cesp.IDEstatusSolicitudPrestamo = sp.IDEstatusSolicitudPrestamo 
		where sp.IDSolicitudPrestamo = @IDSolicitudPrestamo

		insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
		SELECT @IDTipoNotificacion,'{ "subject":"'+@subjectColaborador+'", "body": "'+@htmlColaborador+'"}'

		set @IDNotificacion = @@IDENTITY  
		insert [App].[tblEnviarNotificacionA](  
			IDNotifiacion  
			,IDMedioNotificacion  
			,Destinatario
			,Adjuntos) 
		select 
			@IDNotificacion  
			,templateNot.IDMedioNotificacion  
			,case when templateNot.IDMedioNotificacion = 'Email' then 'aneudy.abreu@adagio.com.mx' else null end  
			,NULL 
		from [App].[tblTiposNotificaciones] tn  
			INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
		where tn.IDTipoNotificacion = @IDTipoNotificacion
	end

	--print @htmlColaborador
GO
