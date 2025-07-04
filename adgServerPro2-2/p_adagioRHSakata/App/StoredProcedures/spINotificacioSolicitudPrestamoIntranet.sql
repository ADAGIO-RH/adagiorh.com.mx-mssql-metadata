USE [p_adagioRHSakata]
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
		@IDNotificacion int,
		@IDEmpleado int
	    ,@IDTIPOREFERENCIA_SOLICITUDPRESTAMO as varchar(max)
        ,@IDUSUARIO_SOLICITUD int ;  

	declare 
		--@IDSolicitudPrestamo int = 9,
		@htmlColaborador varchar(max),
		@subjectColaborador varchar(300),
		@htmlNominista varchar(max),
		@subjectNominista varchar(300),
		@EmailColaborador		varchar(1000)	
	;

	select @IDEmpleado = IDEmpleado
	from Intranet.tblSolicitudesPrestamos
	where IDSolicitudPrestamo = @IDSolicitudPrestamo

    SELECT @IDUSUARIO_SOLICITUD =IDUsuario from Seguridad.tblUsuarios where IDEmpleado=@IDEmpleado

	select 
		@IDEstatusSolicitudPrestamoActual	= IDEstatusSolicitudPrestamo
	from [Intranet].[tblSolicitudesPrestamos] with (nolock)
	where IDSolicitudPrestamo = @IDSolicitudPrestamo 
	
	--select 
	--	@EmailColaborador = case when c.Email is not null then c.Email else u.Email end
	--from  Seguridad.tblUsuarios u with (nolock)
	--	left join (
	--		select ce.IDEmpleado
	--			,lower(ce.[Value]) as Email
	--			,ce.Predeterminado
	--			,ROW_NUMBER()OVER(partition by ce.IDEmpleado order by ce.Predeterminado desc) as [ROW]
	--		from RH.tblContactoEmpleado ce with (nolock)
	--			join [RH].[tblCatTipoContactoEmpleado] ctce with (nolock) on ctce.IDTipoContacto = ce.IDTipoContactoEmpleado and ctce.Descripcion like '%email%'
	--		where ce.[Value] is not null
	--	) c on c.IDEmpleado = u.IDEmpleado and c.[ROW] = 1
	--where u.IDEmpleado = @IDEmpleado


    SELECT @EmailColaborador= [Utilerias].[fnGetCorreoEmpleado] (@IDEmpleado,0,@IDTipoNotificacion);
    --select @EmailColaborador
    --SELECT   [Utilerias].[fnGetCorreoEmpleado] (424,0,'SolicitudPrestamoIntranet');
	/*select top 1 @EmailColaborador = ISNULL(CE.Value,U.Email) 
		from APP.tblTiposNotificaciones TN
		inner join App.tblTemplateNotificaciones Template
			on TN.IDTipoNotificacion = Template.IDTipoNotificacion
		LEFT join [RH].[tblContactosEmpleadosTiposNotificaciones] CETN
			on TN.IDTipoNotificacion = CETN.IDTipoNotificacion
				and CETN.IDEmpleado = @IDEmpleado
		left join RH.tblContactoEmpleado CE
			on CE.IDContactoEmpleado = CETN.IDContactoEmpleado
		left join Seguridad.tblUsuarios u 
			on  U.IDEmpleado=@IDEmpleado
		WHERE TN.IDTipoNotificacion = @IDTipoNotificacion
			and Template.IDMedioNotificacion = 'EMAIL'*/

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
		
            if(@EmailColaborador is not null)
            begin 
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
                    ,Adjuntos
                    ,TipoReferencia,IDReferencia,IDUsuario)    

                select 
                    @IDNotificacion  
                    ,templateNot.IDMedioNotificacion  
                    ,case when templateNot.IDMedioNotificacion = 'Email' then @EmailColaborador else null end  
                    ,NULL 
                    ,@IDTIPOREFERENCIA_SOLICITUDPRESTAMO
                    ,@IDSolicitudPrestamo
                    ,@IDUSUARIO_SOLICITUD
                from [App].[tblTiposNotificaciones] tn  

                    INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
                where tn.IDTipoNotificacion = @IDTipoNotificacion
            end

            exec [App].[spINotificacionesEspeciales_NuevoPrestamo]  
            @IDSolicitudPrestamo = @IDSolicitudPrestamo
            
        /*
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
			,case when templateNot.IDMedioNotificacion = 'Email' then 'aherros@afosa.com.mx' else null end  
			,NULL 
		from [App].[tblTiposNotificaciones] tn  
			INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
		where tn.IDTipoNotificacion = @IDTipoNotificacion

		insert [App].[tblEnviarNotificacionA](  
			IDNotifiacion  
			,IDMedioNotificacion  
			,Destinatario
			,Adjuntos) 
		select 
			@IDNotificacion  
			,templateNot.IDMedioNotificacion  
			,case when templateNot.IDMedioNotificacion = 'Email' then 'lgil@afosa.com.mx' else null end  
			,NULL 
		from [App].[tblTiposNotificaciones] tn  
			INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
		where tn.IDTipoNotificacion = @IDTipoNotificacion

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
		where tn.IDTipoNotificacion = @IDTipoNotificacion */
	end

	if (@IDEstatusSolicitudPrestamoActual = 2) 
	begin
        if(@EmailColaborador is not null)
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
                </table>' 
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
                ,Adjuntos
                ,TipoReferencia,IDReferencia,IDUsuario)    
            select 
                @IDNotificacion  
                ,templateNot.IDMedioNotificacion  
                ,case when templateNot.IDMedioNotificacion = 'Email' then @EmailColaborador else null end  
                ,NULL 
                ,@IDTIPOREFERENCIA_SOLICITUDPRESTAMO
                ,@IDSolicitudPrestamo
                ,@IDUSUARIO_SOLICITUD
                
            from [App].[tblTiposNotificaciones] tn  
                INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
            where tn.IDTipoNotificacion = @IDTipoNotificacion
        end

	end	
	if (@IDEstatusSolicitudPrestamoActual = 3) 
	begin
        if(@EmailColaborador is not null)
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
                ,Adjuntos
                ,TipoReferencia,IDReferencia,IDUsuario)    
            select 
                @IDNotificacion  
                ,templateNot.IDMedioNotificacion  
                ,case when templateNot.IDMedioNotificacion = 'Email' then @EmailColaborador else null end  
                ,NULL 
                ,@IDTIPOREFERENCIA_SOLICITUDPRESTAMO
                ,@IDSolicitudPrestamo
                ,@IDUSUARIO_SOLICITUD
            from [App].[tblTiposNotificaciones] tn  
                INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
            where tn.IDTipoNotificacion = @IDTipoNotificacion
        end
	end

	if (@IDEstatusSolicitudPrestamoActual = 4) 
	begin
        if(@EmailColaborador is not null)
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
                ,Adjuntos
                ,TipoReferencia,IDReferencia,IDUsuario)    
            select 
                @IDNotificacion  
                ,templateNot.IDMedioNotificacion  
                ,case when templateNot.IDMedioNotificacion = 'Email' then @EmailColaborador else null end  
                ,NULL 
                ,@IDTIPOREFERENCIA_SOLICITUDPRESTAMO
                ,@IDSolicitudPrestamo
                ,@IDUSUARIO_SOLICITUD
            from [App].[tblTiposNotificaciones] tn  
                INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
            where tn.IDTipoNotificacion = @IDTipoNotificacion
        end
	end

	--print @htmlColaborador
GO
