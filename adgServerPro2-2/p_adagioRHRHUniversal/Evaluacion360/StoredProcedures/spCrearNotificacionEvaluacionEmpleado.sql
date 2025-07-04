USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Crear diferentes tipos de notificaciones para una evaluacion de empleado
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-14
** Paremetros		:              

** DataTypes Relacionados: 


	@TipoAccion 
		1 : Termino de Evaluación Evaluador [Template_AgradecimientoPorRealizarAutoEvaluacion,Template_TerminoEvaluacionDeUnEvaluador]
		2 : Recordatorio Evaluacion [Template_RecordatorioARealizarEvaluacionesPen, Template_RecordatorioRealizarEvaluacionesPendiente]
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2021-07-08			Aneudy Abreu	Se modificó el Subject de los correos
***************************************************************************************************/
CREATE PROC [Evaluacion360].[spCrearNotificacionEvaluacionEmpleado](
	@IDEvaluacionEmpleado int
	,@TipoAccion int 
	,@IDUsuario int
) as

--DECLARE  @IDEvaluacionEmpleado int = 110638
--		,@TipoAccion int = 1
--	;

	DECLARE
		@NombreProyecto			varchar(max)
		,@IDEmpleado			int = 0
		,@IDTipoRelacion		int = 0
		,@IDProyecto			int = 0
		,@IDEvaluador			int = 0
		,@NombreColaborador		varchar(max)			 
		,@NombreEvaluador		varchar(max)		
		,@AdministradorProyecto	varchar(max)		
		,@AuditorProyecto		varchar(max)		
		,@ContactoProyecto		varchar(max)	
			
		,@NombreContactoProyecto	varchar(255)		
		,@EmailContactoProyecto		varchar(255)	

		,@EmailColaborador		varchar(1000)					 
		,@EmailEvaluador		varchar(1000)	
			
		,@NombreComercialColaborador	varchar(max)	
		,@NombreComercialEvaluador	varchar(max)	
			
		,@FechaLimitePrueba datetime 

		,@IdiomaSQL varchar(100) = 'Spanish'	
		,@xmlParametros varchar(max)		
		,@HTMLListOut varchar(max)

		,@IDNotificacion int	
		,@cols AS NVARCHAR(MAX)
        ,@IDIdiomaEvaluador VARCHAR(10)
		,@query  AS NVARCHAR(MAX); 
	;
    DECLARE @TipoAccionDesc varchar(50);
        SET @TipoAccionDesc = CASE WHEN @TipoAccion = 1 THEN 'AgradecimientoPorRealizarAutoEvaluacion'
                                ELSE 'RecordatorioRealizarAutoEvaluacionesPendientes'
                                END
	SET LANGUAGE @IdiomaSQL;

	if object_id('tempdb..#tempParams') is not null drop table #tempParams;

	create table #tempParams(
		ID int identity(1,1) not null,
		Variable varchar(max),
		Valor nvarchar(max)
	);

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
		,ExisteFotoColaborador		   bit
		,TipoProyeto				   varchar(max)
		,TipoEvaluacion				   varchar(max)
	);

	SELECT 
		 @IDProyecto		= tep.IDProyecto
		,@IDEmpleado		= tep.IDEmpleado
		,@IDEvaluador		= tee.IDEvaluador
		,@IDTipoRelacion	= tee.IDTipoRelacion

		,@NombreColaborador = temEmp.Nombre+' '+coalesce(temEmp.Paterno, '')
		,@NombreEvaluador	= temEva.Nombre+' '+coalesce(temEva.Paterno, '')+' '+coalesce(temEva.Materno, '')

		,@EmailEvaluador	= 'aparedes@adagio.com.mx'--tuEva.Email

		,@NombreComercialColaborador	= temEmp.Empresa
		,@NombreComercialEvaluador		= temEva.Empresa
	FROM Evaluacion360.tblEmpleadosProyectos tep		with (nolock)
		JOIN Evaluacion360.tblEvaluacionesEmpleados tee with (nolock) ON tep.IDEmpleadoProyecto = tee.IDEmpleadoProyecto
		JOIN RH.tblEmpleadosMaster temEmp		with (nolock) ON tep.IDEmpleado		= temEmp.IDEmpleado
		JOIN RH.tblEmpleadosMaster temEva		with (nolock) ON tee.IDEvaluador	= temEva.IDEmpleado
		LEFT JOIN Seguridad.tblUsuarios tuEmp	with (nolock) ON temEmp.IDEmpleado	= tuEmp.IDEmpleado 
		LEFT JOIN Seguridad.tblUsuarios tuEva	with (nolock) ON temEva.IDEmpleado	= tuEva.IDEmpleado 
	WHERE tee.IDEvaluacionEmpleado = @IDEvaluacionEmpleado

	

	/*select top 1 @EmailColaborador = ISNULL(CE.Value,U.Email) 
	from App.tblTiposNotificaciones TN
		inner join App.tblTemplateNotificaciones Template on TN.IDTipoNotificacion = Template.IDTipoNotificacion
		left join [RH].[tblContactosEmpleadosTiposNotificaciones] CETN on TN.IDTipoNotificacion = CETN.IDTipoNotificacion and CETN.IDEmpleado = @IDEmpleado
		left join RH.tblContactoEmpleado CE on CE.IDContactoEmpleado = CETN.IDContactoEmpleado
		left join Seguridad.tblUsuarios u on CETN.IDEmpleado = U.IDEmpleado
	WHERE TN.IDTipoNotificacion = CASE WHEN @TipoAccion = 1 THEN 'AgradecimientoPorRealizarAutoEvaluacion'
										   ELSE 'RecordatorioRealizarAutoEvaluacionesPendientes'
										   END
		and Template.IDMedioNotificacion = 'EMAIL'
    
	IF (@EmailColaborador IS NULL) 
	BEGIN
		SELECT TOP 1 @EmailColaborador = tce.[Value]
		FROM RH.tblContactoEmpleado tce WITH (nolock)
		WHERE tce.IDTipoContactoEmpleado = 1 AND tce.IDEmpleado = @IDEmpleado
	END;

	IF (@EmailEvaluador IS NULL) 
	BEGIN
		SELECT TOP 1 @EmailEvaluador = tce.[Value]
		FROM RH.tblContactoEmpleado tce WITH (nolock)
		WHERE tce.IDTipoContactoEmpleado = 1 AND tce.IDEmpleado = @IDEvaluador
	END;*/

    
    
    

	SELECT 
		 @AdministradorProyecto	= CASE WHEN tep.IDCatalogoGeneral = 1 THEN coalesce(tep.Nombre,'')+' ('+coalesce(tep.Email,'')+')' ELSE @AdministradorProyecto end
		,@AuditorProyecto		= CASE WHEN tep.IDCatalogoGeneral = 2 THEN coalesce(tep.Nombre,'')+' ('+coalesce(tep.Email,'')+')' ELSE @AuditorProyecto end
		,@ContactoProyecto		= CASE WHEN tep.IDCatalogoGeneral = 3 THEN coalesce(tep.Nombre,'')+' ('+coalesce(tep.Email,'')+')' ELSE @ContactoProyecto end
		,@NombreContactoProyecto= CASE WHEN tep.IDCatalogoGeneral	= 3 THEN coalesce(tep.Nombre,'') ELSE @NombreContactoProyecto end
		,@EmailContactoProyecto = CASE WHEN tep.IDCatalogoGeneral	= 3 THEN coalesce(tep.Email,'') ELSE @EmailContactoProyecto end
	FROM [Evaluacion360].[tblEncargadosProyectos] tep with (nolock)
	WHERE tep.IDProyecto = @IDProyecto 
	
	SELECT 
		@NombreProyecto = Nombre, 
		@FechaLimitePrueba = isnull(tcp.FechaFin, getdate())
	FROM [Evaluacion360].[tblCatProyectos] tcp with (nolock)
	WHERE tcp.IDProyecto = @IDProyecto 
	
	insert #tempParams(Variable, Valor)
	Values('NombreEvaluador',coalesce(@NombreEvaluador,''))
			,('NombreColaborador',coalesce(@NombreColaborador,''))
			,('NombreComercialColaborador',coalesce(@NombreComercialColaborador,''))
			,('NombreComercialEvaluador',coalesce(@NombreComercialEvaluador,''))
			,('AdministradorProyecto',coalesce(@AdministradorProyecto,''))
			,('ContactoProyecto',coalesce(@ContactoProyecto,''))
			,('AuditorProyecto',coalesce(@AuditorProyecto,''))
			,('NombreContactoProyecto',coalesce(@NombreContactoProyecto,''))
			,('EmailContactoProyecto',coalesce(@EmailContactoProyecto,''))
			,('FechaLimitePrueba',convert(varchar(11), @FechaLimitePrueba,100))
			,('Subject',coalesce(@NombreProyecto,'')+ ' - Evaluaciones pendientes')

    select top 1 
		@IDIdiomaEvaluador=App.fnGetPreferencia('Idioma', u.IDUsuario, 'es-MX')
    from Seguridad.tblUsuarios u where IDEmpleado=@IDEvaluador

   

	IF (@TipoAccion = 1)
	BEGIN
        select @EmailEvaluador='aparedes@adagio.com.mx'-- [Utilerias].[fnGetCorreoEmpleado] (@IDEvaluador,0,CASE WHEN @IDTipoRelacion = 4 THEN 'AgradecimientoPorRealizarAutoEvaluacion' ELSE 'AgradecimientoPorRealizarUnaPrueba' end)
		IF (@IDTipoRelacion <> 4)
		BEGIN
			INSERT #evaluacionPendientes(
				IDEvaluacionEmpleado,
				IDEmpleadoProyecto,
				IDTipoRelacion,
				Relacion,
				IDEvaluador,
				ClaveEvaluador,
				Evaluador,
				IDProyecto,
				Proyecto,
				IDEmpleado,
				ClaveEmpleado,
				Colaborador,
				IDEstatusEvaluacionEmpleado,
				IDEstatus,
				Estatus,
				IDUsuario,
				FechaCreacion,
				Progreso,
				ExisteFotoColaborador,
				TipoProyeto,
				TipoEvaluacion
			)
			EXEC [Evaluacion360].[spBuscarPruebasPorEvaluador]  
				@IDProyecto=@IDProyecto
				,@IDUsuario = @IDUsuario
				,@IDEvaluador = @IDEvaluador
				,@Tipo = 1
		 
			set @HTMLListOut  = '<ul  class=''leaders''>'

			select @HTMLListOut = @HTMLListOut + '<li>' + ep.Colaborador + '</li>'
			FROM (SELECT DISTINCT Colaborador FROM #evaluacionPendientes) ep

			set @HTMLListOut = @HTMLListOut+'</ul>'
			
			insert #tempParams(Variable, Valor)
			Values('ListadoPersonasPorEvaluar',coalesce(@HTMLListOut,''))

			DELETE FROM #evaluacionPendientes;

			INSERT #evaluacionPendientes(
			    IDEvaluacionEmpleado,
			    IDEmpleadoProyecto,
			    IDTipoRelacion,
			    Relacion,
			    IDEvaluador,
			    ClaveEvaluador,
			    Evaluador,
			    IDProyecto,
			    Proyecto,
			    IDEmpleado,
			    ClaveEmpleado,
			    Colaborador,
			    IDEstatusEvaluacionEmpleado,
			    IDEstatus,
			    Estatus,
			    IDUsuario,
			    FechaCreacion,
			    Progreso,
				ExisteFotoColaborador,
				TipoProyeto,
				TipoEvaluacion
			)
			EXEC [Evaluacion360].[spBuscarPruebasPorEvaluador]  
					@IDProyecto		= @IDProyecto
					,@IDUsuario		= @IDUsuario
					,@IDEvaluador   = @IDEvaluador
					,@Tipo = 2
		 
			set @HTMLListOut  = '<ul  class=''leaders''>'
			
			select @HTMLListOut = @HTMLListOut + '<li>' + ep.Colaborador + '</li>'
			FROM (SELECT DISTINCT Colaborador FROM #evaluacionPendientes) AS ep

			set @HTMLListOut = @HTMLListOut+'</ul>'
			
			insert #tempParams(Variable, Valor)
			Values
				('ListadoPersonasYaEvaluadas',coalesce(@HTMLListOut,''))
		END;

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
								,Valor
							from #tempParams
						) x
						pivot ( max(Valor)
							for Variable in (' + @cols + ')
						) p '

		execute(@query)
		select @xmlParametros = a.JSON from ##tempParamsPivot b
		 Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

        
		insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros,IDIdioma)  
	 	select CASE WHEN @IDTipoRelacion = 4 THEN 'AgradecimientoPorRealizarAutoEvaluacion' ELSE 'AgradecimientoPorRealizarUnaPrueba' end,@xmlParametros,@IDIdiomaEvaluador

		set @IDNotificacion = @@IDENTITY  ;

		insert [App].[tblEnviarNotificacionA](  
				IDNotifiacion  
				,IDMedioNotificacion  
				,Destinatario)  
		select @IDNotificacion  
			,templateNot.IDMedioNotificacion  
			,case when templateNot.IDMedioNotificacion = 'Email' then isnull(@EmailEvaluador,'') else '' end  
		from [App].[tblTiposNotificaciones] tn with (nolock) 
			join [App].[tblTemplateNotificaciones] templateNot with (nolock) on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
		where tn.IDTipoNotificacion = CASE WHEN @IDTipoRelacion = 4 THEN 'AgradecimientoPorRealizarAutoEvaluacion' ELSE 'AgradecimientoPorRealizarUnaPrueba' end
			and @EmailEvaluador is not null
		--IF (@IDTipoRelacion = 4) --AutoEvaluación
		--BEGIN
		--END ;
	END ELSE
	IF (@TipoAccion = 2)
	BEGIN
        select @EmailEvaluador= 'aparedes@adagio.com.mx'--[Utilerias].[fnGetCorreoEmpleado] (@IDEvaluador,0,CASE WHEN @IDTipoRelacion = 4  THEN 'RecordatorioRealizarAutoEvaluacionesPendientes' ELSE 'RecordatorioRealizarEvaluacionesPendientes'  end)                
		IF (@IDTipoRelacion <> 4)
		BEGIN
			INSERT #evaluacionPendientes(
			    IDEvaluacionEmpleado,
			    IDEmpleadoProyecto,
			    IDTipoRelacion,
			    Relacion,
			    IDEvaluador,
			    ClaveEvaluador,
			    Evaluador,
			    IDProyecto,
			    Proyecto,
			    IDEmpleado,
			    ClaveEmpleado,
			    Colaborador,
			    IDEstatusEvaluacionEmpleado,
			    IDEstatus,
			    Estatus,
			    IDUsuario,
			    FechaCreacion,
			    Progreso,
				ExisteFotoColaborador,
				TipoProyeto,
				TipoEvaluacion
			)
			EXEC [Evaluacion360].[spBuscarPruebasPorEvaluador]  
					 @IDProyecto		= @IDProyecto
					,@IDUsuario   = @IDUsuario
					,@IDEvaluador   = @IDEvaluador
					,@Tipo = 1
		 
			set @HTMLListOut  = '<ul  class=''leaders''>'

			select @HTMLListOut = @HTMLListOut + '<li>' + ep.Colaborador + '</li>'
			FROM (SELECT DISTINCT Colaborador FROM #evaluacionPendientes) ep

			set @HTMLListOut = @HTMLListOut+'</ul>'
			
			insert #tempParams(Variable, Valor)
			Values('ListadoPersonasPorEvaluar',coalesce(@HTMLListOut,''))

			DELETE FROM #evaluacionPendientes;

			INSERT #evaluacionPendientes(
			    IDEvaluacionEmpleado,
			    IDEmpleadoProyecto,
			    IDTipoRelacion,
			    Relacion,
			    IDEvaluador,
			    ClaveEvaluador,
			    Evaluador,
			    IDProyecto,
			    Proyecto,
			    IDEmpleado,
			    ClaveEmpleado,
			    Colaborador,
			    IDEstatusEvaluacionEmpleado,
			    IDEstatus,
			    Estatus,
			    IDUsuario,
			    FechaCreacion,
			    Progreso,
				ExisteFotoColaborador,
				TipoProyeto,
				TipoEvaluacion
			)
			EXEC [Evaluacion360].[spBuscarPruebasPorEvaluador]  
					 @IDProyecto		= @IDProyecto
					,@IDUsuario		= @IDUsuario
					,@IDEvaluador	= @IDEvaluador
					,@Tipo = 2
		 
			set @HTMLListOut  = '<ul  class=''leaders''>'
			
			select @HTMLListOut = @HTMLListOut + '<li>' + ep.Colaborador + '</li>'
			FROM (SELECT DISTINCT Colaborador FROM #evaluacionPendientes) AS ep

			set @HTMLListOut = @HTMLListOut+'</ul>'
			
			insert #tempParams(Variable, Valor)
			Values('ListadoPersonasYaEvaluadas',coalesce(@HTMLListOut,''))
		END;

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


        

		insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros,IDIdioma)  
	 	select CASE WHEN @IDTipoRelacion = 4 THEN 'RecordatorioRealizarAutoEvaluacionesPendientes' ELSE 'RecordatorioRealizarEvaluacionesPendientes' end,@xmlParametros,@IDIdiomaEvaluador

		set @IDNotificacion = @@IDENTITY  ;

		insert [App].[tblEnviarNotificacionA](  
				IDNotifiacion  
				,IDMedioNotificacion  
				,Destinatario)  
		select @IDNotificacion  
			,templateNot.IDMedioNotificacion  
			,case when templateNot.IDMedioNotificacion = 'Email' then isnull(@EmailEvaluador,'') else '' end  
		from [App].[tblTiposNotificaciones] tn with (nolock)
			join [App].[tblTemplateNotificaciones] templateNot with (nolock) on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
		where tn.IDTipoNotificacion = CASE WHEN @IDTipoRelacion = 4 THEN 'RecordatorioRealizarAutoEvaluacionesPendientes' ELSE 'RecordatorioRealizarEvaluacionesPendientes' end
		 and @EmailEvaluador is not null
	END
	;
GO
