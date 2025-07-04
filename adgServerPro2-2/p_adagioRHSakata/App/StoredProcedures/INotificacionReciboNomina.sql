USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Guarda la notificación de Recibo de Nómina
** Autor			: Jose Roman
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2022-02-12			Aneudy Abreu		Se agregó un select final que regresa el 
										nuevo Identity IDEnviarNotificaciónA
2025-03-10			Jose Roman			Se modifica procedimiento para generar el Json sin necesidad
										de usar tablas temporales de tipo # o ##.
***************************************************************************************************/
CREATE proc [App].[INotificacionReciboNomina](  
--DECLARE 
	@IDTipoNotificacion varchar(100)  
	,@IDHistorialEmpleadoPeriodo int 
	,@Adjuntos nvarchar(max)  =  null
	,@IDTipoAdjunto int = 1
) as  
	declare   
		--@IDUsuario int = 1  
		--,@key varchar(1000) = 'ZMqvYHEdJNDs3GkCkIkDoBz7ONvav2lnvUfArDZy670'  
		-- ,@IDTipoNotificacion varchar(100) = 'ActivarCuenta'  
		@IDNotificacion int = 0 
		,@IDEnviarNotificacionA int = 0 
		,@ClaveEmpleado  varchar(50)  
		,@Nombre  varchar(255)    
		,@SegundoNombre  varchar(255)    
		,@Paterno  varchar(255)    
		,@Materno  varchar(255)    
		,@Email   varchar(255)  
		,@Periodo   varchar(255)
		,@Fecha date  
		,@Fechaini date  
		,@FechaFin date  
		,@valor varchar(max)
		,@IDPais int
		,@IDEmpleado int
		,@IDIdioma varchar(10)
		,@ReciboNominaBodyMessage nvarchar(max)
        ,@IDUsuarioEnvio int 
	;

	select @IDPais = IDPais 
	from nomina.tblHistorialesEmpleadosPeriodos HEP
		inner join Nomina.tblCatPeriodos p on p.IDPeriodo = hep.IDPeriodo
		inner join Nomina.tblCatTipoNomina tn on tn.IDTipoNomina= p.IDTipoNomina
	where hep.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo
			 
    SET @Adjuntos=REPLACE(@Adjuntos,'(1)','')
	
	select top 1 
		@ClaveEmpleado = m.ClaveEmpleado
		,@Nombre = m.Nombre
		,@SegundoNombre = isnull(m.SegundoNombre,' ')
		,@Paterno = m.Paterno
		,@Materno = m.Materno
		--,@Email = case when isnull(ce.Value,'') != '' then LOWER(ce.Value) else u.Email end
		,@Periodo = p.Descripcion
		,@Fecha = cast(getdate() as date)
		,@Fechaini = p.FechaInicioPago
		,@FechaFin = p.FechaFinPago
		,@IDEmpleado = HEP.IDEmpleado
		,@IDIdioma=App.fnGetPreferencia('Idioma', u.IDUsuario, 'es-MX')
        
	from Nomina.tblHistorialesEmpleadosPeriodos HEP with (nolock)
		inner join Nomina.tblCatPeriodos p with (nolock) on hep.IDPeriodo = p.IDPeriodo
		inner join RH.tblEmpleadosMaster M with (nolock) on hep.IDEmpleado = m.IDEmpleado
		left join Seguridad.tblUsuarios u with (nolock) on u.IDEmpleado = HEP.IDEmpleado
	WHERE HEP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo

    select @Email= [Utilerias].[fnGetCorreoEmpleado] (@IDEmpleado,0,'ReciboNomina')
    SELECT @IDUsuarioEnvio=IDUsuario from Seguridad.tblUsuarios u where u.IDEmpleado=@IDEmpleado;

	/*select top 1 @Email = ISNULL(CE.Value,U.Email) 
	from App.tblTiposNotificaciones TN
		inner join App.tblTemplateNotificaciones Template on TN.IDTipoNotificacion = Template.IDTipoNotificacion
		left join [RH].[tblContactosEmpleadosTiposNotificaciones] CETN on TN.IDTipoNotificacion = CETN.IDTipoNotificacion
				and CETN.IDEmpleado = @IDEmpleado
		left join RH.tblContactoEmpleado CE on CE.IDContactoEmpleado = CETN.IDContactoEmpleado
		left join Seguridad.tblUsuarios u  on U.IDEmpleado = @IDEmpleado
	WHERE TN.IDTipoNotificacion = 'ReciboNomina' and Template.IDMedioNotificacion = 'EMAIL'*/
	
	select @ReciboNominaBodyMessage=[Message]
	from App.tblMessages 
	where IDMessage = 'ReciboNominaBodyMessage' and IDIdioma = @IDIdioma

	 SELECT @valor = (
        SELECT 
            @ClaveEmpleado AS ClaveColaborador,
            @Nombre AS NombreColaborador,
            FORMATMESSAGE(
                @ReciboNominaBodyMessage,
                @Nombre + ' ' + @SegundoNombre + ' ' + @Paterno + ' ' + @Materno + ' - (' + @ClaveEmpleado + ')',
                FORMAT(@Fechaini, 'dd/MM/yyyy', @IDIdioma),
                FORMAT(@FechaFin, 'dd/MM/yyyy', @IDIdioma) + '. <br /> <br />'
            ) AS Mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );
  
	if ((select Utilerias.fsValidarEmail(@Email)) = 1)
	begin
		insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros, IDIdioma)  
		SELECT @IDTipoNotificacion, @valor, @IDIdioma
			
		 set @IDNotificacion = @@IDENTITY  
   
		insert [App].[tblEnviarNotificacionA](  
			IDNotifiacion  
			,IDMedioNotificacion  
			,Destinatario
			,Adjuntos
			,IDTipoAdjunto
            ,TipoReferencia
            ,IDReferencia
            ,IDUsuario
		)  
		select 
			@IDNotificacion  
			,templateNot.IDMedioNotificacion  
			,case when templateNot.IDMedioNotificacion = 'Email' then @Email else null end  
			,@Adjuntos
			,@IDTipoAdjunto
            ,'[Nomina].[tblHistorialesEmpleadosPeriodos]'
            ,@IDHistorialEmpleadoPeriodo
            ,@IDUsuarioEnvio            
		from [App].[tblTiposNotificaciones] tn  
			join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
				and isnull(templateNot.IDIdioma,'es-MX') = @IDIdioma
		where tn.IDTipoNotificacion = @IDTipoNotificacion
		
		set @IDEnviarNotificacionA = @@IDENTITY
	
	end
	select isnull(@IDEnviarNotificacionA, 0) as IDEnviarNotificacionA
GO
