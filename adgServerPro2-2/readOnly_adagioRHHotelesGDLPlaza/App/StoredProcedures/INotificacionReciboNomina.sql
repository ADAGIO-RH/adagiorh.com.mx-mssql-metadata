USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[INotificacionReciboNomina](  
	@IDTipoNotificacion varchar(100)    
	,@IDHistorialEmpleadoPeriodo int
	,@Adjuntos nvarchar(max)  =  null
) as  
	declare   
		--@IDUsuario int = 1  
		--,@key varchar(1000) = 'ZMqvYHEdJNDs3GkCkIkDoBz7ONvav2lnvUfArDZy670'  
		-- ,@IDTipoNotificacion varchar(100) = 'ActivarCuenta'  
		@IDNotificacion int = 0  
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
	;

	if object_id('tempdb..#tempParams') is not null drop table #tempParams;

	create table #tempParams(
		ID int identity(1,1) not null,
		Variable varchar(max),
		Valor varchar(max)
	);

	select top 1 
		@ClaveEmpleado = m.ClaveEmpleado
		,@Nombre = m.Nombre
		,@SegundoNombre = m.SegundoNombre
		,@Paterno = m.Paterno
		,@Materno = m.Materno
		,@Email = case when isnull(ce.Value,'') != '' then LOWER(ce.Value) else u.Email end
		,@Periodo = p.Descripcion
		,@Fecha = cast(getdate() as date)
		,@Fechaini = p.FechaInicioPago
		,@FechaFin = p.FechaFinPago
	from Nomina.tblHistorialesEmpleadosPeriodos HEP with (nolock)
		inner join Nomina.tblCatPeriodos p with (nolock) on hep.IDPeriodo = p.IDPeriodo
		inner join RH.tblEmpleadosMaster M with (nolock) on hep.IDEmpleado = m.IDEmpleado
		inner join RH.tblContactoEmpleado ce with (nolock) on ce.IDEmpleado = hep.IDEmpleado
		inner join rh.tblCatTipoContactoEmpleado tce with (nolock) on ce.IDTipoContactoEmpleado = tce.IDTipoContacto
				and tce.Descripcion  like '%EMAIL%'
		left join Seguridad.tblUsuarios u with (nolock) on u.IDEmpleado = HEP.IDEmpleado
	WHERE HEP.IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo

	insert #tempParams(Variable, Valor)
	values('NombreColaborador',coalesce(@Nombre,''))
		,('ClaveColaborador',coalesce(@ClaveEmpleado,''))
		,('Mensaje',coalesce(@Nombre,'')+' '+coalesce(@SegundoNombre,'') +' '+coalesce(@Paterno,'')+' '+coalesce(@Materno,'') +' - ('+@ClaveEmpleado+') te hacemos entrega de tu recibo de nómina correspondiente al periodo del día '+ cast(FORMAT(@Fechaini,'dd/MM/yyyy') as varchar)+' al día '+cast(FORMAT(@FechaFin,'dd/MM/yyyy') as varchar)+'.

						No es necesario confirmar de recibido.' )
 
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
		insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
		SELECT @IDTipoNotificacion,@valor
		--select @IDTipoNotificacion,N'NombreColaborador|'+coalesce(@Nombre,'')
		--   +',ClaveColaborador|'+coalesce(@ClaveEmpleado,'')  
		--   +',Mensaje|'+'Hola '+coalesce(@Nombre,'')+' '+coalesce(@SegundoNombre,'') +' '+coalesce(@Paterno,'')+' '+coalesce(@Materno,'') +' - ('+@ClaveEmpleado+') te hacemos entrega de tu recibo de nómina correspondiente al periodo del día '+ cast(@Fechaini as varchar)+' al día '+cast(@FechaFin as varchar)+'.

		--				No es necesario confirmar de recibido.' 
  
		 set @IDNotificacion = @@IDENTITY  
   
		 insert [App].[tblEnviarNotificacionA](  
			  IDNotifiacion  
			 ,IDMedioNotificacion  
			 ,Destinatario
			 ,Adjuntos)  
		 select @IDNotificacion  
			  ,templateNot.IDMedioNotificacion  
			  ,case when templateNot.IDMedioNotificacion = 'Email' then @Email else null end  
			  ,@Adjuntos
		 from [App].[tblTiposNotificaciones] tn  
		  join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
		 where tn.IDTipoNotificacion = @IDTipoNotificacion
	end
GO
