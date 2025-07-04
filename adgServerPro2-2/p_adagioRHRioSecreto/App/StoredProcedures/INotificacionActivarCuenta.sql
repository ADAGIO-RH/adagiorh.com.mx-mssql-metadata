USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [App].[INotificacionActivarCuenta](    
	@IDTipoNotificacion varchar(100)  
	,@IDUsuario int
	,@key varchar(255)  
) as    

	declare     
	  @IDNotificacion int = 0    
	  ,@Cuenta  varchar(50)    
	  ,@Nombre  varchar(255)    
	  ,@Apellido  varchar(255)    
	  ,@Email   varchar(255)    
	  ,@ActiveAccountUrl varchar(255)    
	  ,@valor varchar(max)
	  ,@IDEmpleado int
      ,@IDIdioma varchar(20)
	  ,@tempUsuario [Seguridad].[dtUsuarios]
	  ,@cols AS NVARCHAR(MAX)
	  ,@query  AS NVARCHAR(MAX)
      ,@IDTIPOREFERENCIA_ACTIVARCUENTA as varchar(max);  

    set @IDTIPOREFERENCIA_ACTIVARCUENTA='[Seguridad].[tblUsuarios]'
    
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

	select @ActiveAccountUrl = Valor    
	from [App].[tblConfiguracionesGenerales] WITH (nolock)  
	where IDConfiguracion = 'ActiveAccountUrl'    
    
    IF OBJECT_ID('TEMPDB.dbo.##tempParamsPivot') IS NOT NULL DROP TABLE ##tempParamsPivot

	INSERT @tempUsuario    
	exec [Seguridad].[spBuscarUsuario] @IDUsuario = @IDUsuario

	select     
		@Cuenta			= Cuenta      
		,@Nombre		= Nombre      
		,@Apellido		= Apellido      
		--,@Email			= Email       
		,@IDEmpleado	= IDEmpleado       
	from @tempUsuario    


    select @Email= [Utilerias].[fnGetCorreoEmpleado] (@IDEmpleado,@IDUsuario,'ActivarCuenta')
    if ([Utilerias].[fsValidarEmail](@Email) = 1)
	begin        
	    if object_id('tempdb..#tempParams') is not null drop table #tempParams;  
  
	    create table #tempParams(  
		    ID int identity(1,1) not null,  
		    Variable varchar(max),  
		    Valor varchar(max)  
	    );  
    
	    insert #tempParams(Variable, Valor)  
	        Values('NombreColaborador',coalesce(@Nombre,''))  
	            ,('Cuenta',coalesce(@Cuenta,''))  
	            ,('URLActivacion',coalesce(@ActiveAccountUrl+@key,'') )  
	            -- ,('ActivarCuenta','true')  
  
        
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

        select @valor = a.JSON from ##tempParamsPivot b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
  	
		insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros,IDIdioma)    
		select @IDTipoNotificacion,@valor,@IDIdioma  
   
		set @IDNotificacion = @@IDENTITY    
     
     
		insert [App].[tblEnviarNotificacionA](IDNotifiacion,IDMedioNotificacion,Destinatario,
        TipoReferencia,IDReferencia,IDUsuario)    
		select @IDNotificacion    
			,templateNot.IDMedioNotificacion    
			,case when templateNot.IDMedioNotificacion = 'Email' then @Email else null end    
            ,@IDTIPOREFERENCIA_ACTIVARCUENTA, @IDUsuario,@IDUsuario

		from [App].[tblTiposNotificaciones] tn    
			join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion     and templateNot.IDIdioma=@IDIdioma
		where tn.IDTipoNotificacion = @IDTipoNotificacion    
	 end
GO
