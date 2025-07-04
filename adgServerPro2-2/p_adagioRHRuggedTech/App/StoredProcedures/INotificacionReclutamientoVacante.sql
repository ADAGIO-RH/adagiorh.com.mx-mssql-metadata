USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [App].[INotificacionReclutamientoVacante]
(
	@UUID Varchar(50) ,
	@Emails Varchar(max) 
)
AS
BEGIN

	DECLARE @Asunto Varchar(MAX),
		@IDIdioma varchar(20),
		@Puesto Varchar(MAX),
		@Mensaje Varchar(MAX),
		@Url Varchar(MAX),
		@cols  varchar(max),
		@query varchar(max),
		@valor varchar(max),
		@IDTipoNotificacion varchar(100) = 'ReclutamientoVacante',
		@IDNotificacion int,
        @IDTIPO_REFERENCIA_POSICION varchar(255),
        @IDPosicion int



    set @IDTIPO_REFERENCIA_POSICION='[RH].[tblCatPosiciones]'

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')	

	select @URL = Valor+'careers/index?UUID='+@UUID from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'Url'

	Select 
		 @Asunto = 'Vacante '+ JSON_VALUE(puestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))+' - '+JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial'))
		,@Mensaje = 'Encontré una oportunidad para la que serías perfecto. ¿Por qué no echas un vistazo y ves lo que piensas?'  
        ,@IDPosicion=p.IDPosicion
	from RH.tblCatPosiciones p with(nolock)
		inner join RH.tblCatPlazas pla with(nolock)
			on pla.IDPlaza = p.IDPlaza
		inner join RH.tblCatClientes c	with(nolock)
			on c.IDCliente = pla.IDCliente
		inner join RH.tblCatPuestos puestos with(nolock)
			on puestos.IDPuesto = pla.IDPuesto
	where p.UUID = @UUID

	IF OBJECT_ID('TEMPDB.dbo.#tempParams') IS NOT NULL DROP TABLE #tempParams
	IF OBJECT_ID('TEMPDB.dbo.##tempParamsPivot') IS NOT NULL DROP TABLE ##tempParamsPivot
	
	create table #tempParams(
		ID int identity(1,1) not null,
		Variable varchar(max),
		Valor varchar(max)
	);


		insert #tempParams(Variable, Valor)
		VALUES
			('Mensaje', @Mensaje)
			,('Asunto', @Asunto)
			,('url', isnull(@URL,''))


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

		insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
		SELECT @IDTipoNotificacion,@valor
		
		set @IDNotificacion = @@IDENTITY

		insert [App].[tblEnviarNotificacionA](  
					IDNotifiacion  
					,IDMedioNotificacion  
					,Destinatario
					,Adjuntos
                    ,TipoReferencia
                    ,IDReferencia
                    ) 
				select 
					@IDNotificacion  
					,templateNot.IDMedioNotificacion  
					,case when templateNot.IDMedioNotificacion = 'Email' then sp.item else null end  
					,NULL 
                    ,@IDTIPO_REFERENCIA_POSICION
                    ,@IDPosicion
				from App.Split(@Emails,',') sp 	
					inner join [App].[tblTiposNotificaciones] tn  with(nolock)
						on tn.IDTipoNotificacion = @IDTipoNotificacion
					INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
					and tn.IDTipoNotificacion = @IDTipoNotificacion


END
GO
