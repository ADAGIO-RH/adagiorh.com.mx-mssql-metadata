USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [App].[INotificacionActivarCuenta](    
	@IDTipoNotificacion varchar(100)  
	,@IDUsuario int = 1    
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
	;  
    
	select @ActiveAccountUrl = Valor    
	from [App].[tblConfiguracionesGenerales] WITH (nolock)  
	where IDConfiguracion = 'ActiveAccountUrl'    
    
	if object_id('tempdb..#tempUsuario') is not null drop table #tempUsuario;    
    
	create table #tempUsuario (    
		IDUsuario int     
		,IDEmpleado int    
		,ClaveEmpleado varchar(50)    
		,Cuenta varchar(50)    
		,Password varchar(255)    
		,IDPreferencia int      
		,Nombre varchar(255)    
		,Apellido varchar(255)   
		,Sexo char(1)   
		,Email varchar(255)    
		,Activo bit      
		,IDPerfil int      
		,Perfil varchar(255)    
		,[URL] varchar(255)    
		,[Supervisor] bit
		,ROWNUMBER int    
	);    
     
	INSERT #tempUsuario    
	exec [Seguridad].[spBuscarUsuario] @IDUsuario = @IDUsuario
    
	select     
		@Cuenta			= Cuenta      
		,@Nombre		= Nombre      
		,@Apellido		= Apellido      
		,@Email			= Email       
		,@IDEmpleado	= IDEmpleado       
	from #tempUsuario    

	if (@IDEmpleado is not null)
	begin
		if (@Email is null or @Email = '')
		begin
			select top 1 @Email = ce.Value
			from rh.tblContactoEmpleado ce with (nolock)
				join rh.tblCatTipoContactoEmpleado tce with (nolock) on ce.IDTipoContactoEmpleado = tce.IDTipoContacto
			where ce.IDEmpleado = @IDEmpleado and tce.Descripcion like '%EMAIL%'
			order by ce.IDContactoEmpleado desc
		end;		
	end; 
  
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
  
	DECLARE @cols AS NVARCHAR(MAX),
		@query  AS NVARCHAR(MAX);


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

	select @valor = a.JSON from ##tempParamsPivot b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
  
	if (LEN(@Email) > 0)
	begin
		insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)    
		select @IDTipoNotificacion,@valor  
   
		--N'NombreColaborador|'+coalesce(@Nombre,'')+ ' '+coalesce(@Apellido,'')    
		--      +',Cuenta|'+coalesce(@Cuenta,'')    
		--      +',URLActivacion|'+coalesce(@ActiveAccountUrl+@key,'')    
    
		set @IDNotificacion = @@IDENTITY    
     
		insert [App].[tblEnviarNotificacionA](IDNotifiacion,IDMedioNotificacion,Destinatario)    
		select @IDNotificacion    
			,templateNot.IDMedioNotificacion    
			,case when templateNot.IDMedioNotificacion = 'Email' then @Email else null end    
		from [App].[tblTiposNotificaciones] tn    
			join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion    
		where tn.IDTipoNotificacion = @IDTipoNotificacion    
    
		--select * from app.tblEnviarNotificacionA    
		--update app.tblConfiguracionesGenerales    
		--set Valor = 'http://201.156.176.10:9999/login/ActivarCuenta?key='    
		-- where IDConfiguracion = 'ActiveAccountUrl'    
		-- select * from Seguridad.TblUsuariosKeysActivacion  
    
	 end
GO
