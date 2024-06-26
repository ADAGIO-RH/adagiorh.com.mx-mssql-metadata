USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE proc [Evaluacion360].[spSiguienteItemWizard](
	@Url varchar(max)
	,@IDProyecto int  
	,@IDUsuario int  
) as 
declare 
	--@Url varchar(max) =  '#/Evaluacion360/Proyectos/Index'
			--'#/Evaluacion360/Proyectos/relacionesmasivas?id=32'
			--'#/Evaluacion360/Proyectos/seleccionColaboradores?id=32'
			--'#/Evaluacion360/EscalaValoracionProyecto?id=32'
			--'#/Evaluacion360/Proyectos/Configuracion?id=28'
	--,@IDProyecto int = 32
	--,@IDUsuario int = 1
	
	@IDWizardUsuario int = 0
	,@IDWizardItemActual int
	,@OrderWizardItemActual int
	,@ItemActualCompleto bit
	,@UrlSiguiente varchar(max)
	,@IDDetalleWizardUsuario int = 0
	,@dtEvaluadoresRequeridos [Evaluacion360].[dtEvaluadoresRequeridos]
	,@IDItemCompetencias int = 4
	,@TareaCompleta varchar(255) = 'Tarea a completada'
	;
	
	if object_id('tempdb..#tempRespuesta') is not null
		drop table #tempRespuesta;


	create table #tempRespuesta(
		Avanzar bit not null
		,Mensaje varchar(255)
	--	,Redirect bit
		,[Url] varchar(max) 
		,IDWizardUsuario int
		,IDWizardItem int
	);
	--	select  REVERSE(RTRIM(SUBSTRING(REVERSE (@Url), 1, CHARINDEX('?', REVERSE (@Url), 1) - 1))) 
	--	select (CHARINDEX('//', @Url, 1) + 2), 
	--			CHARINDEX('/', REVERSE (@Url), 1)  

	--select CHARINDEX('/',@Url)
	--select CHARINDEX('?',@Url)

	select @Url=SUBSTRING(@url,
		CHARINDEX('/',@Url) +1,
		case when CHARINDEX('?',@Url) > 0 then CHARINDEX('?',@Url) - CHARINDEX('/',@Url) -1 else len(@url) end)

	--select @Url

--	return

	select @IDWizardItemActual = IDWizardItem
		,@OrderWizardItemActual = Orden
	from [Evaluacion360].[tblCatWizardItem] with (nolock)
	where lower([Url]) = lower(@Url)

	select @IDWizardUsuario = IDWizardUsuario
	from [Evaluacion360].[tblWizardsUsuarios] with (nolock)
	where IDProyecto = @IDProyecto --and IDUsuario = @IDUsuario
	
	-- Item Anterior
	--select *
	--from [Evaluacion360].[tblDetalleWizardUsuario] dwu with (nolock)
	--	join  [Evaluacion360].[tblCatWizardItem] cw  with (nolock) on dwu.IDWizardItem = cw.IDWizardItem
	--where IDWizardUsuario = @IDWizardUsuario and cw.Orden < @OrderWizardItemActual

	-- ItemActual
	--select dwu.*
	--	,cw.Item
	--	,cw.Descripcion
	--	,cw.[Url]
	--	,cw.Orden
	--from [Evaluacion360].[tblDetalleWizardUsuario] dwu with (nolock)
	--	join  [Evaluacion360].[tblCatWizardItem] cw  with (nolock) on dwu.IDWizardItem = cw.IDWizardItem
	--where IDWizardUsuario = @IDWizardUsuario and cw.Orden = @OrderWizardItemActual

	select @IDDetalleWizardUsuario = dwu.IDDetalleWizardUsuario
			,@ItemActualCompleto = dwu.Completo
	from [Evaluacion360].[tblDetalleWizardUsuario] dwu with (nolock)
		join  [Evaluacion360].[tblCatWizardItem] cw  with (nolock) on dwu.IDWizardItem = cw.IDWizardItem
	where IDWizardUsuario = @IDWizardUsuario and cw.Orden = @OrderWizardItemActual


	-- ItemSiguiente
	select top 1 @UrlSiguiente = case when cw.IDWizardItem = @IDItemCompetencias then [Url]+N'?tiporeferencia=1&idreferencia='+cast(@IDProyecto as varchar(10))
			else [Url] end
	from [Evaluacion360].[tblDetalleWizardUsuario] dwu with (nolock)
		join  [Evaluacion360].[tblCatWizardItem] cw  with (nolock) on dwu.IDWizardItem = cw.IDWizardItem
	where IDWizardUsuario = @IDWizardUsuario and cw.Orden > @OrderWizardItemActual
	ORDER BY cw.Orden asc

	if (@ItemActualCompleto = 1)
	begin
		insert #tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,@TareaCompleta,@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual

		select * from #tempRespuesta; return;
	end;

	if (@IDWizardItemActual = 1) -- Crear proyecto
	begin
		print 'proyecto creado';
		insert #tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'Prueba creada satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from #tempRespuesta; return;
	end;

	if (@IDWizardItemActual = 2) -- Configuraciones generales
	begin
		print 'Configuraciones generales';

		if not exists (select top 1 1 
						from [Evaluacion360].[tblEvaluadoresRequeridos] with (nolock)
						where IDProyecto = @IDProyecto)
		begin
			insert #tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
			select 0,'Es necesario indicar los evaluadores requeridos de la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
			select * from #tempRespuesta; return;
		end;			

		if not exists (select top 1 1 
						from [Evaluacion360].[tblEncargadosProyectos] tep with (nolock)
						where IDProyecto = @IDProyecto AND tep.IDCatalogoGeneral = 1)
		begin
			insert #tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
			select 0,'Es necesario indicar un Adminsitrador de la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
			select * from #tempRespuesta; return;
		end;

		if not exists (select top 1 1 
						from [Evaluacion360].[tblEncargadosProyectos] tep with (nolock)
						where IDProyecto = @IDProyecto AND tep.IDCatalogoGeneral = 3)
		begin
			insert #tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
			select 0,'Es necesario indicar un contacto de la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
			select * from #tempRespuesta; return;
		end;

		insert #tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'Configuraciones generales completo satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from #tempRespuesta; return;
	end;

	if (@IDWizardItemActual = 3) -- Escala de valoracion
	begin
		print 'Escala de valoracion';
		if not exists (select top 1 1 
						from [Evaluacion360].[tblEscalasValoracionesProyectos] with (nolock)
						where IDProyecto = @IDProyecto)
		begin
			insert #tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
			select 0,'Es necesario definir la escala de valoración de la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
			select * from #tempRespuesta; return;
		end;

		insert #tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'Escala de valoración completa satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from #tempRespuesta; return;
	end;

	if (@IDWizardItemActual = 4) -- Competencias del proyecto
	begin
		print 'Competencias';
		if not exists (select top 1 1 
						from [Evaluacion360].[tblCatGrupos] cg with (nolock)
							join Evaluacion360.tblCatPreguntas cp on cg.IDGrupo = cp.IDGrupo
						where cg.TipoReferencia = 1 and cg.IDReferencia = @IDProyecto)
		begin
			insert #tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
			select 0,'Es necesario definir por lo menos un(a) competencia, KPI o valor y que contenga preguntas antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
			select * from #tempRespuesta; return;
		end;

		insert #tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'Competencias de al prueba completa satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from #tempRespuesta; return;
	end;

	if (@IDWizardItemActual = 9) -- Configuraciones de evaluaciones
	begin
		print 'Configuraciones de evaluaciones';

		insert #tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'Configuraciones a completas satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from #tempRespuesta; return;
	end;

	if (@IDWizardItemActual = 5) -- Seleccionar colaboradores
	begin
		print 'Seleccionar colaboradores';

		if not exists (select top 1 1 
						from [Evaluacion360].[tblEmpleadosProyectos] with (nolock)
						where IDProyecto = @IDProyecto)
		begin
			insert #tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
			select 0,'Es necesario asignar colaboradores a la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
			select * from #tempRespuesta; return;
		end;

		insert #tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'La Seleccionar colaboradores a sido completada satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from #tempRespuesta; return;
	end;

	if (@IDWizardItemActual = 10) --Enviar resultados a Colaboradores
	begin
		print 'Enviar resultados a Colaboradores';

		insert #tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'Enviar resultados a Colaboradores a completa satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from #tempRespuesta; return;
	end;

	if (@IDWizardItemActual = 6) -- Asignar evaluadores de forma masiva
	begin
		print 'Asignar evaluadores de forma masiva';

		INSERT @dtEvaluadoresRequeridos
		EXEC [Evaluacion360].[spBuscarRelacionesProyecto] 
			@IDProyecto = @IDProyecto
			,@IDUsuario = @IDUsuario
	
		--SELECT * FROM @dtEvaluadoresRequeridos

		if exists (select top 1 1 
						from @dtEvaluadoresRequeridos  
						where IDEvaluador = 0 and Requerido = 1)
		begin
			insert #tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
			select 0,'Es necesario asignar Evaluadores mínimos requeridos antes de continuar.  </br> Revisa las restricciones incompletas en la pestaña: Relaciones del proyecto la prueba',@IDWizardUsuario,@IDWizardItemActual
			
			select * from #tempRespuesta; return;
		end;

		insert #tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'La Seleccionar colaboradores a sido completada satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from #tempRespuesta; return;	
	end;

	if (@IDWizardItemActual = 8) -- Fechas y Calendarización del proyecto
	begin
		print 'Fechas y Calendarización de la prueba';

		if exists (SELECT * 
					FROM Evaluacion360.tblCatProyectos tcp
					WHERE tcp.IDProyecto = @IDProyecto AND (FechaInicio IS NULL OR FechaFin IS null))
		begin
			insert #tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
			select 0,'Indique la fecha de inicio y fin de la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
			select * from #tempRespuesta; return;
		end;

		insert #tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'Fechas de la prueba seleccionadas satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from #tempRespuesta; return;
	end;

	IF (@IDWizardItemActual = 7) -- Autorizar la prueba
	BEGIN
		insert #tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'El wizard se ha completado satisfactoriamente.','#/',@IDWizardUsuario,@IDWizardItemActual
		
		BEGIN TRY
			EXEC [Evaluacion360].[spAutorizarProyecto] 
				 @IDProyecto = @IDProyecto
				 ,@IDUsuario = @IDUsuario

		END TRY
		BEGIN CATCH
			SELECT cast(0 as bit) as Avanzar,  ERROR_MESSAGE() AS Mensaje,'#/' as [Url],@IDWizardUsuario IDWizardUsuario,@IDWizardItemActual IDWizardItem; 
			return;
		END CATCH

		INSERT INTO [Evaluacion360].[tblEstatusProyectos](IDProyecto,IDEstatus,IDUsuario)
		VALUES(@IDProyecto,3,@IDUsuario)

		--SELECT * FROM Evaluacion360.tblCatEstatus tce	
		--	JOIN Evaluacion360.tblCatTiposEstatus tcte ON tce.IDTipoEstatus = tcte.IDTipoEstatus

		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		update [Evaluacion360].[tblWizardsUsuarios]
		set Completo = 1
		where IDWizardUsuario = @IDWizardUsuario

		select * from #tempRespuesta; return;
	end;


	select * from #tempRespuesta return;
GO
