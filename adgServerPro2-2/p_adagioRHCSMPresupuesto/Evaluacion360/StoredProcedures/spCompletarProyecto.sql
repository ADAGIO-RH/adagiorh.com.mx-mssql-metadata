USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Este sp cambia de estatus el proyecto a COMPLETO siempre y cuando todas las evaluaciones estén listas y se ejecuta cada vez que una evaluación de completa.
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-15
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-03-08			Aneudy Abreu	Se agregó la ejecución del SP [Evaluacion360].[spCalcularTotalesEvaluacionesEmpleadosPorProyecto]
2021-07-08			Aneudy Abreu	Se modificó el Subject de los correos
***************************************************************************************************/
CREATE PROC [Evaluacion360].[spCompletarProyecto](
	@IDProyecto int  
	,@IDUsuario int  
) AS 
	DECLARE 
		@IDUsuarioAdmin int 
	;

	select @IDUsuarioAdmin = cast(Valor as int) from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'IDUsuarioAdmin'

	DECLARE 
		@NombreProyecto		varchar(max)
		,@TotalPruebas		int = 0
		,@TotalRealizadas	int = 0 

		,@NombreAdministradorProyecto	varchar(max)		
		,@EmailAdministradorProyecto	varchar(max)	

		,@HTMLListOut varchar(max)
		,@xmlParametros varchar(max)		
		,@IDNotificacion int
		,@cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)
		,@LinkResultados varchar(max)-- = 'http://localhost/adagioRH.Web/#/Evaluacion360/Proyectos/Configuracion?id=36'
		,@IDTipoProyecto int
		,@ID_TIPO_PROYECTO_CLIMA_LABORAL int = 3

		,@OldJSON Varchar(Max) = ''
		,@NewJSON Varchar(Max)
		,@NombreSP	varchar(max) = '[Evaluacion360].[spCompletarProyecto]'
		,@Tabla		varchar(max) = '[Evaluacion360].[tblCatProyectos]'
		,@Accion		varchar(20)	= 'UPDATE'
		,@Mensaje	varchar(max)
		,@InformacionExtra	varchar(max)
        ,@IDIdioma VARCHAR(max)
	;
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
    
	select top 1 @LinkResultados=valor 
	from App.tblConfiguracionesGenerales 
	where IDConfiguracion = 'Url'

	SELECT 
		@NombreProyecto = Nombre
		,@IDTipoProyecto = IDTipoProyecto
	FROM [Evaluacion360].[tblCatProyectos] tcp with (nolock)
	WHERE tcp.IDProyecto = @IDProyecto

	if object_id('tempdb..#tempParams') is not null drop table #tempParams;

	create table #tempParams(
		ID int identity(1,1) not null,
		Variable varchar(max),
		Valor nvarchar(max)
	);

	SELECT 
		 @NombreAdministradorProyecto = CASE WHEN tep.IDCatalogoGeneral = 1 THEN coalesce(tep.Nombre,'') ELSE @NombreAdministradorProyecto end
		 ,@EmailAdministradorProyecto = CASE WHEN tep.IDCatalogoGeneral = 1 THEN coalesce(tep.Email,'') ELSE @EmailAdministradorProyecto end
	FROM [Evaluacion360].[tblEncargadosProyectos] tep with (nolock)
	WHERE tep.IDProyecto = @IDProyecto 

	if object_id('tempdb..#evaluacionPendientes') is not null drop table #evaluacionPendientes;

	CREATE TABLE #evaluacionPendientes(
		 IDEvaluacionEmpleado		   int
		,IDEmpleadoProyecto			   int
		,IDTipoRelacion				   int
		,Relacion					   varchar(max)
		,IDEvaluador				   int
		,ClaveEvaluador				   varchar(max)
		,Evaluador					   varchar(max)
		,IDProyecto					   int
		,Proyecto					   varchar(max)
		,IDEmpleado					   int
		,ClaveEmpleado 				   varchar(max)
		,Colaborador				   varchar(max)
		,IDEstatusEvaluacionEmpleado   int
		,IDEstatus					   int
		,Estatus					   varchar(max)
		,IDUsuario					   int
		,FechaCreacion				   datetime
		,Progreso 					   int
	);

	INSERT #evaluacionPendientes(IDEvaluacionEmpleado,IDEmpleadoProyecto,IDTipoRelacion,Relacion,IDEvaluador,ClaveEvaluador,Evaluador,IDProyecto,Proyecto,
			IDEmpleado,ClaveEmpleado,Colaborador,IDEstatusEvaluacionEmpleado,IDEstatus,Estatus,IDUsuario,FechaCreacion,Progreso)
	EXEC [Evaluacion360].[spBuscarPruebasPorProyecto]  
			 @IDProyecto	= @IDProyecto
			,@Tipo			= 3
			,@IDUsuario		= @IDUsuarioAdmin

	SELECT @TotalPruebas=count(*) 
	FROM #evaluacionPendientes
	WHERE #evaluacionPendientes.IDEstatus <> 14 -- Todas menos las evaluaciones canceladas.

	SELECT @TotalRealizadas=count(*) 
	FROM #evaluacionPendientes
	WHERE #evaluacionPendientes.IDEstatus = 13

	IF (@TotalPruebas = @TotalRealizadas)
	BEGIN
		select @OldJSON = a.JSON 
		from (
			select 
				 tep.IDProyecto
				,tcp.Nombre
				,tcp.Descripcion
				,tep.IDEstatusProyecto
				,isnull(tep.IDEstatus,0) AS IDEstatus
				,isnull(JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')),'Sin estatus') AS Estatus
				,tep.IDUsuario
				,tep.FechaCreacion 
			from Evaluacion360.tblCatProyectos tcp with (nolock)
				left join [Evaluacion360].[tblEstatusProyectos] tep	 with (nolock) on tep.IDProyecto = tcp.IDProyecto --and eee.IDEstatus = 10
				left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus = 1) estatus on tep.IDEstatus = estatus.IDEstatus
			where tcp.IDProyecto = @IDProyecto
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	
		INSERT INTO [Evaluacion360].[tblEstatusProyectos](IDProyecto,IDEstatus,IDUsuario)
		VALUES(@IDProyecto,6,@IDUsuario)

		exec [Evaluacion360].[spActualizarTotalEvaluacionesPorEstatus]

		select @NewJSON = a.JSON 
		from (
			select 
				 tep.IDProyecto
				,tcp.Nombre
				,tcp.Descripcion
				,tep.IDEstatusProyecto
				,isnull(tep.IDEstatus,0) AS IDEstatus
				,isnull(JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')),'Sin estatus') AS Estatus				
				,tep.IDUsuario
				,tep.FechaCreacion 
			from Evaluacion360.tblCatProyectos tcp with (nolock)
				left join [Evaluacion360].[tblEstatusProyectos] tep	 with (nolock) on tep.IDProyecto = tcp.IDProyecto --and eee.IDEstatus = 10
				left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus = 1) estatus on tep.IDEstatus = estatus.IDEstatus
			where tcp.IDProyecto = @IDProyecto
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
			,@Mensaje		= @Mensaje
			,@InformacionExtra		= @InformacionExtra

		set @HTMLListOut  = '<ul class=''leaders''>'

		select @HTMLListOut = @HTMLListOut + '<li>' + m.Evaluador + '</span></li>'
		FROM (
			select distinct ep.Evaluador FROM #evaluacionPendientes ep WHERE ep.IDEstatus <> 14
		) m

		set @HTMLListOut = @HTMLListOut+'</ul>'

		insert #tempParams(Variable, Valor)
		Values('NombreAdministradorProyecto',coalesce(@NombreAdministradorProyecto,''))
			 ,('ListaEvaluadores',coalesce(@HTMLListOut,''))
			 ,('NombreEmpresa',coalesce('Adagio',''))
			 ,('LinkResultados',coalesce(@LinkResultados,''))
			 ,('Subject','¡Enhorabuena, la prueba '+coalesce(@NombreProyecto, '')+' a finalizado, revisa los resultados!')
			 
		IF OBJECT_ID('TEMPDB.dbo.##tempParamsPivot') IS NOT NULL DROP TABLE ##tempParamsPivot
	
		SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(c.Variable) 
					FROM #tempParams c
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')

		set @query = 'SELECT  ' + @cols + ' 
						into ##tempParamsPivot
						from (
							select Variable
								, Valor
							from #tempParams
						) x
						pivot (
								max(Valor)
							for Variable in (' + @cols + ')
						) p '

		execute(@query)

		select @xmlParametros = a.JSON from ##tempParamsPivot b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		if ([Utilerias].[fsValidarEmail](@EmailAdministradorProyecto) = 1)
		begin
			insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
	 		select 'EntregaDeResultadosEvaluacion',@xmlParametros

			set @IDNotificacion = @@IDENTITY;

			insert [App].[tblEnviarNotificacionA](  
					IDNotifiacion  
					,IDMedioNotificacion  
					,Destinatario)  
			select @IDNotificacion  
				,templateNot.IDMedioNotificacion  
				,case when templateNot.IDMedioNotificacion = 'Email' then @EmailAdministradorProyecto else null end  
			from [App].[tblTiposNotificaciones] tn  
				join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
			where tn.IDTipoNotificacion = 'EntregaDeResultadosEvaluacion'
		end

		exec [Evaluacion360].[spCalcularTotalesEvaluacionesEmpleadosPorProyecto] @IDProyecto = @IDProyecto
	END;

	if (@IDTipoProyecto = @ID_TIPO_PROYECTO_CLIMA_LABORAL)
	begin
		exec InfoDir.spSincronizarEvaluacionesClimaLaboral_V1 @IDProyecto = @IDProyecto
	end;
GO
