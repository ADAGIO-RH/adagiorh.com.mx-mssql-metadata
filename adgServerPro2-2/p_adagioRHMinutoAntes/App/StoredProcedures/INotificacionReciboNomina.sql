USE [p_adagioRHMinutoAntes]
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
***************************************************************************************************/
CREATE proc [App].[INotificacionReciboNomina](  
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
	;

	select @IDPais = IDPais 
	from nomina.tblHistorialesEmpleadosPeriodos HEP
		inner join Nomina.tblCatPeriodos p on p.IDPeriodo = hep.IDPeriodo
		inner join Nomina.tblCatTipoNomina tn on tn.IDTipoNomina= p.IDTipoNomina
	where hep.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo
			 
    -- Comentario ya que se realizaron pruebas sin este bloque y sigue funcionando correctamente
	-- IF(isnull(@IDPais,0) <> 151)
	-- BEGIN
	-- 	set @Adjuntos = replace(@Adjuntos,'\PDF\','\PDF\N_')
	-- END

    SET @Adjuntos=REPLACE(@Adjuntos,'(1)','')

	if object_id('tempdb..#tempParams') is not null drop table #tempParams;

	create table #tempParams(
		ID int identity(1,1) not null,
		Variable varchar(max),
		Valor varchar(max)
	);

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
		--inner join RH.tblContactoEmpleado ce with (nolock) on ce.IDEmpleado = hep.IDEmpleado
		--inner join RH.tblCatTipoContactoEmpleado tce with (nolock) on ce.IDTipoContactoEmpleado = tce.IDTipoContacto
		--		and tce.IDMedioNotificacion = 'EMAIL'
		left join Seguridad.tblUsuarios u with (nolock) on u.IDEmpleado = HEP.IDEmpleado
	WHERE HEP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo


    select @Email= [Utilerias].[fnGetCorreoEmpleado] (@IDEmpleado,0,'ReciboNomina')

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
	
	insert #tempParams(Variable, Valor)
	values
		('NombreColaborador',coalesce(@Nombre,''))
		,('ClaveColaborador',coalesce(@ClaveEmpleado,''))
		,('Mensaje', FORMATMESSAGE(
				@ReciboNominaBodyMessage,
				coalesce(@Nombre,'')+' '+coalesce(@SegundoNombre,'') +' '+coalesce(@Paterno,'')+' '+coalesce(@Materno,'') +' - ('+@ClaveEmpleado+')',
				FORMAT(@Fechaini,'d', @IDIdioma),
				FORMAT(@FechaFin,'d', @IDIdioma)+'. <br /> <br />'
			)
		)

	--IF(@IDPais in (151,52,188))
	--BEGIN
	--	insert #tempParams(Variable, Valor)
	--	values('NombreColaborador',coalesce(@Nombre,''))
	--		,('ClaveColaborador',coalesce(@ClaveEmpleado,''))
	--		,('Mensaje',coalesce(@Nombre,'')+' '+coalesce(@SegundoNombre,'') +' '+coalesce(@Paterno,'')+' '+coalesce(@Materno,'') +' - ('+@ClaveEmpleado+') te hacemos entrega de tu recibo de nómina correspondiente al periodo del día '+ cast(FORMAT(@Fechaini,'dd/MM/yyyy') as varchar)+' al día '+cast(FORMAT(@FechaFin,'dd/MM/yyyy') as varchar)+'.
			
	--						No es necesario confirmar de recibido.' )
	--END
	--ELSE
	--BEGIN
	--	insert #tempParams(Variable, Valor)
	--	values('NombreColaborador',coalesce(@Nombre,''))
	--		,('ClaveColaborador',coalesce(@ClaveEmpleado,''))
	--		,('Mensaje',coalesce(@Nombre,'')+' '+coalesce(@SegundoNombre,'') +' '+coalesce(@Paterno,'')+' '+coalesce(@Materno,'') +' - ('+@ClaveEmpleado+') We deliver your payroll receipt corresponding to the period of the day '+ cast(FORMAT(@Fechaini,'MM/dd/yyyy') as varchar)+' to '+cast(FORMAT(@FechaFin,'MM/dd/yyyy') as varchar)+'.

	--						It is not necessary to confirm receipt.' )
	--END


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


  
	if ((select Utilerias.fsValidarEmail(@Email)) = 1)
	begin
		insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros, IDIdioma)  
		SELECT @IDTipoNotificacion, @valor, @IDIdioma
			
			--CASE WHEN @IDPais in (151,52,188)THEN @IDTipoNotificacion
			--		ELSE 'ReciboNominaIngles'
			--		END
		 set @IDNotificacion = @@IDENTITY  
   
		insert [App].[tblEnviarNotificacionA](  
			IDNotifiacion  
			,IDMedioNotificacion  
			,Destinatario
			,Adjuntos
			,IDTipoAdjunto
		)  
		select 
			@IDNotificacion  
			,templateNot.IDMedioNotificacion  
			,case when templateNot.IDMedioNotificacion = 'Email' then @Email else null end  
			,@Adjuntos
			,@IDTipoAdjunto
		from [App].[tblTiposNotificaciones] tn  
			join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
				and isnull(templateNot.IDIdioma,'es-MX') = @IDIdioma
		where tn.IDTipoNotificacion = @IDTipoNotificacion

		set @IDEnviarNotificacionA = @@IDENTITY

	
	end
	
	select isnull(@IDEnviarNotificacionA, 0) as IDEnviarNotificacionA
GO
