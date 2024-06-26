USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [App].[INotificacionReciboNomina] @IDTipoNotificacion=N'ReciboNomina',@IDHistorialEmpleadoPeriodo=13587,@Adjuntos=N'C:\AdagioTFS\adagioRHSolutions\Development\Version 1.3.0.0\adagioRH.Web\RecibosNomina\4\001_04_202001\PDF\CBS1310252C8_ADG0003_ABREU COLON ANEUDY .PDF' 

--[App].[INotificacionModuloDocumentos] 35,'CREATE-AUTORIZA'

CREATE proc [App].[INotificacionModuloDocumentos](  
 @IDDocumento int    
 ,@TipoCambio Varchar(50)
) as  
	declare   
		--@IDUsuario int = 1  
		--,@key varchar(1000) = 'ZMqvYHEdJNDs3GkCkIkDoBz7ONvav2lnvUfArDZy670'  
		@IDNotificacion int = 0  
		,@IDTipoNotificacion varchar(100) = 'AprobacionDocumentos'  
		,@ClaveEmpleado  varchar(50)  
		,@NombrePublicador  varchar(255)    
		,@ApellidoPublicador  varchar(255)    
		,@EmailPublicador   varchar(255)  
		,@NombreAutorizar  varchar(255)    
		,@ApellidoAutorizar  varchar(255)    
		,@EmailAutorizar   varchar(255)  
		,@Fecha date  
		,@Folio Varchar(50)
		,@NombreDocumento Varchar(255)
		,@DescripcionDocumento Varchar(255)
		,@TipoDocumento Varchar(255)
		,@valor varchar(max)
	;

	DECLARE @CountAprobadores int = 0,
		@Secuencia int = 0,
		@SecuenciaMax int = 0

	select @SecuenciaMax = isnull(MAX(isnull(secuencia,0)),0) from Docs.tblAprobadoresDocumentos where IDDocumento = @IDDocumento

	if object_id('tempdb..#tempParams') is not null drop table #tempParams;

	create table #tempParams(
		ID int identity(1,1) not null,
		Variable varchar(max),
		Valor varchar(max)
	);

	SELECT TOP 1
		@NombrePublicador = UP.Nombre
		,@ApellidoPublicador = UP.Apellido
		,@EmailPublicador = UP.Email
		,@NombreAutorizar  = U.Nombre
		,@ApellidoAutorizar  = U.Apellido
		,@EmailAutorizar   = U.Email
		,@Fecha = CD.FechaCreacion
		,@Folio = CD.IDItem
		,@NombreDocumento = CD.Nombre
		,@DescripcionDocumento = CD.Descripcion
		,@TipoDocumento = TD.Descripcion
	from Docs.tblCarpetasDocumentos CD with (nolock)
		inner join Docs.tblAprobadoresDocumentos AD
			on CD.IDItem = AD.IDDocumento
		inner join Seguridad.tblUsuarios U
			on U.IDUsuario = AD.IDUsuario
		inner join Seguridad.tblUsuarios UP	
			on UP.IDUsuario = CD.IDPublicador
		left join Docs.tblCatTiposDocumento TD
			on CD.IDTipoDocumento = TD.IDTipoDocumento
	WHERE CD.IDItem = @IDDocumento
	and AD.Aprobacion = 0
	and AD.Secuencia = @SecuenciaMax
	ORDER BY AD.IDAprobadorDocumento ASC




	insert #tempParams(Variable, Valor)
	values('NombreColaborador',coalesce(@NombreAutorizar,''))
		


	IF(ISNULL(@Folio,'') = '')
	BEGIN
		RETURN;
	END
	
	IF(@TipoCambio = 'CREATE-AUTORIZA')
	BEGIN

		--select @Folio,@NombreDocumento,@DescripcionDocumento,@TipoDocumento,@Fecha

		insert #tempParams(Variable, Valor)
		VALUES
			('Mensaje', 'Se ha generado un documento que requiere su autorización.')
			,('Folio', isnull(@Folio,''))
			,('Nombre', isnull(@NombreDocumento,''))
			,('Descripcion', isnull(@DescripcionDocumento,'SIN DESCRIPCIÓN'))
			,('Tipo', isnull(@TipoDocumento,''))
			,('Fecha', FORMAT(isnull(@Fecha,''),'dd/MM/yyyy HH:mm'))
		 
		--select * from #tempParams
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
  
	
   select @valor
	
	BEGIN TRY
		BEGIN TRAN TransaccionNotificaciones
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
					select 
					  @IDNotificacion  
					  ,templateNot.IDMedioNotificacion  
					  ,case when templateNot.IDMedioNotificacion = 'Email' then @EmailAutorizar else null end  
					  ,NULL 
					from 	[App].[tblTiposNotificaciones] tn  
					  INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
					  and tn.IDTipoNotificacion = @IDTipoNotificacion
				
		

	COMMIT TRAN TransaccionNotificaciones
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN TransaccionNotificaciones
	END CATCH
GO
