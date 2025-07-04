USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Evaluacion360].[spClonarProyecto](
	@IDProyecto int
	,@ClonadoAutomatico bit = 1
	,@Nombre varchar(255) = null
	,@IDUsuario int = null
)
as
	declare
		 @IDProyectoNuevo int
		,@Descripcion nvarchar(max)	
		,@AutoEvaluacion bit = 0
		,@Calendarizado bit = 0
		,@IDSchedule int
		,@Frecuencia varchar(50)

		,@FechaInicio date
		,@FechaFin date

		,@IdiomaSQL varchar(100) = 'Spanish'
		,@IDWizardUsuario int

		,@Introduccion nvarchar(max)
		,@Indicacion nvarchar(max)

		,@IDTipoProyecto int

		,@Privacidad bit
		,@CLIMA_LABORAL INT = 3
	;

	if (@IDUsuario is null) 
	begin
		select @IDUsuario = cast(Valor as int) from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'IDUsuarioAdmin'
	end

	declare 
		@OldJSON varchar(Max) = '',
		@NewJSON varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spClonarProyecto]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblCatGrupos]',
		@Accion		varchar(20)	= 'INSERT',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)	
	;

	SET LANGUAGE @IdiomaSQL;

	IF object_id('tempdb..#tempProyectoAClonar') IS NOT NULL DROP TABLE #tempProyectoAClonar;  
	IF object_id('tempdb..#tempProyectoNuevo') IS NOT NULL DROP TABLE #tempProyectoNuevo;  
  
	CREATE TABLE #tempProyectoNuevo (  
		IDProyecto int  
		,Nombre varchar(max)  
		,Descripcion varchar(max)  
		,IDEstatus int  
		,Estatus varchar(max)  
		,FechaCreacion datetime  
		,IDUsuario int  
		,Usuario  varchar(max)  
		,AutoEvaluacion bit  
		,TotalPruebasARealizar int  
		,TotalPruebasRealizadas int  
		,Progreso int  
		,FechaInicio date  
		,FechaFin date  
		,Calendarizado bit  
		,IDTask int  
		,IDSchedule int
		,Introduccion varchar(max)
		,Indicacion varchar(max)
		,IDTipoProyecto int
	);

	CREATE TABLE #tempProyectoAClonar (  
		IDProyecto int  
		,Nombre varchar(max)  
		,Descripcion varchar(max)  
		,IDEstatus int  
		,Estatus varchar(max)  
		,FechaCreacion datetime  
		,IDUsuario int  
		,Usuario  varchar(max)  
		,AutoEvaluacion bit  
		,TotalPruebasARealizar int  
		,TotalPruebasRealizadas int  
		,Progreso int  
		,FechaInicio date  
		,FechaFin date  
		,Calendarizado bit  
		,IDTask int  
		,IDSchedule int
		,Introduccion varchar(max)
		,Indicacion varchar(max)
		,IDTipoProyecto int
		,Privacidad bit 				
	 );

	insert #tempProyectoAClonar
	select 
		p.IDProyecto
		,p.Nombre
		,p.Descripcion
		,0 AS IDEstatus
		,'Sin estatus' AS Estatus
		,isnull(p.FechaCreacion,getdate()) as FechaCreacion
		,p.IDUsuario
		,Usuario = case when emp.IDEmpleado is not null then coalesce(emp.Nombre,'')+' '+coalesce(emp.Paterno,'')+' '+coalesce(emp.Materno,'')
					   else coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'') END
		,AutoEvaluacion = CASE WHEN EXISTS (SELECT TOP 1 1 
												FROM [Evaluacion360].[tblEvaluadoresRequeridos] 
												WHERE IDProyecto = p.IDProyecto AND IDTipoRelacion = 4) THEN cast(1 as bit) else cast(0 as bit) END
		,isnull(p.TotalPruebasARealizar,0)	 as TotalPruebasARealizar
		,isnull(p.TotalPruebasRealizadas,0)	 as TotalPruebasRealizadas
		,isnull(p.Progreso,0)				 AS Progreso
		,isnull(p.FechaInicio,'1990-01-01') AS FechaInicio
		,isnull(p.FechaFin,'1990-01-01') AS FechaFin
		,isnull(Calendarizado,cast(0 AS bit)) AS Calendarizado
		,isnull(IDTask,0) AS IDTask
		,isnull(IDSchedule,0) AS IDSchedule
		,p.Introduccion
		,p.Indicacion
		,p.IDTipoProyecto
		,p.Privacidad				
	from [Evaluacion360].[tblCatProyectos] p with (nolock)
		join [Seguridad].[TblUsuarios] u with (nolock) on p.IDUsuario = u.IDUsuario
		left join [RH].[tblEmpleados] emp with (nolock) on u.IDEmpleado = emp.IDEmpleado
	where p.IDProyecto = @IDProyecto

	select 
		@Calendarizado = Calendarizado
		,@IDSchedule = IDSchedule
		,@Nombre = case when @Nombre is null then Nombre else @Nombre end
		,@Descripcion = Descripcion
		,@AutoEvaluacion = AutoEvaluacion
		--,@IDUsuario = IDUsuario
		,@Introduccion = Introduccion
		,@Indicacion = Indicacion
		,@IDTipoProyecto = IDTipoProyecto
		,@Privacidad = Privacidad		
	from #tempProyectoAClonar

	select 
		@Frecuencia = OcurrsFrecuency 
	from Scheduler.tblSchedule 
	where IDSchedule = @IDSchedule
 
	select
		@FechaInicio = GETDATE()
		,@FechaFin = case 
						when @Frecuencia = 'Diario' then DATEADD(day,1,GETDATE())
						when @Frecuencia = 'Semanal' then DATEADD(WEEK,1,GETDATE())
						when @Frecuencia = 'Mensual' then DATEADD(MONTH,1,GETDATE())
					end
			 
	--select @FechaInicio,@FechaFin
	--	set @Nombre =  @Nombre+' - '+convert(varchar(11), @FechaInicio,106);
	--select @Nombre  

	if (@ClonadoAutomatico = 1) 
	begin
		set @Nombre = upper(@Nombre)+' - COPIA';
	end else 
	begin
		set @Nombre = upper(@Nombre);
	end;
	
	BEGIN -- Creando nuevo proyecto y Wizard
		insert into [Evaluacion360].[tblCatProyectos](Nombre, Descripcion, FechaCreacion, IDUsuario, Introduccion, Indicacion, IDTipoProyecto, Privacidad)
		select @Nombre, @Descripcion, getdate(), @IDUsuario, @Introduccion, @Indicacion, @IDTipoProyecto, @Privacidad

		set @IDProyectoNuevo = @@IDENTITY

		INSERT [Evaluacion360].[tblEstatusProyectos] ([IDProyecto],[IDEstatus],[IDUsuario])
		values(@IDProyectoNuevo,1,@IDUsuario)

		insert Evaluacion360.tblAdministradoresProyecto(IDProyecto, IDUsuario, FechaHoraReg, CreadoPorIDUsuario)
		values(@IDProyectoNuevo, @IDUsuario, getdate(), @IDUsuario)

		exec [Evaluacion360].[spIniciarWizardUsuario]
			@IDProyecto = @IDProyectoNuevo 
			,@IDUsuario = @IDUsuario
	END;
	
	BEGIN -- Evaluadores requeridos
		IF ((@AutoEvaluacion = 1) AND NOT EXISTS (SELECT TOP 1 1 
												FROM [Evaluacion360].[tblEvaluadoresRequeridos] with (nolock)
												WHERE IDProyecto = @IDProyectoNuevo AND IDTipoRelacion = 4 ))
		BEGIN
			EXEC [Evaluacion360].[spIUEvaluadorRequerido] 
				@IDEvaluadorRequerido = 0
				,@IDProyecto		   = @IDProyectoNuevo
				,@IDTipoRelacion	   = 4
				,@Minimo			   = 1
				,@Maximo			   = 1
				,@IDUsuario			  = @IDUsuario
				,@WithResult = 0
		END;

		insert [Evaluacion360].tblEvaluadoresRequeridos(IDProyecto,IDTipoRelacion,Minimo,Maximo)
		select @IDProyectoNuevo
			,IDTipoRelacion
			,Minimo
			,Maximo
		from [Evaluacion360].tblEvaluadoresRequeridos with (nolock)
		where IDProyecto = @IDProyecto and IDTipoRelacion <> 4
	END; 

	BEGIN -- Encargados de proyecto
		insert [Evaluacion360].[tblEncargadosProyectos](IDProyecto,IDCatalogoGeneral,Nombre,Email)
		select 
			@IDProyectoNuevo
			,IDCatalogoGeneral
			,Nombre
			,Email
		from [Evaluacion360].[tblEncargadosProyectos] with (nolock)
		where IDProyecto = @IDProyecto 
	END;

	BEGIN -- Configuraciones Avanzadas
		insert [Evaluacion360].[tblConfiguracionAvanzadaProyecto](IDConfiguracionAvanzada,IDProyecto,Valor)
		select 
			IDConfiguracionAvanzada
			,@IDProyectoNuevo
			,Valor
		from [Evaluacion360].[tblConfiguracionAvanzadaProyecto] with (nolock)
		where IDProyecto = @IDProyecto 
	END;

	BEGIN -- Escala de valoración del proyecto
		insert [Evaluacion360].[tblEscalasValoracionesProyectos](IDProyecto,Nombre,Descripcion,Valor)
		select @IDProyectoNuevo,Nombre,Descripcion,Valor
		from [Evaluacion360].[tblEscalasValoracionesProyectos] with (nolock)
		where IDProyecto = @IDProyecto 
	END;

	BEGIN -- Grupos del proyecto
		exec [Evaluacion360].[spCopiarGrupo]
			@CopiarDeTipoReferencia = 1
			,@CopiarDeIDReferencia = @IDProyecto
			,@ATipoReferencia = 1 
			,@AIDReferencia = @IDProyectoNuevo
	END;
	
	BEGIN -- Filtros del proyecto
		insert [Evaluacion360].[tblFiltrosProyectos](IDProyecto,TipoFiltro,ID,Descripcion)
		select @IDProyectoNuevo,TipoFiltro,ID,Descripcion
		from [Evaluacion360].[tblFiltrosProyectos] with (nolock)
		where IDProyecto = @IDProyecto 

		exec [Evaluacion360].[spAsginarEmpleadosAProyecto]
			 @IDProyecto  = @IDProyectoNuevo
			,@IDUsuario = @IDUsuario 
	END;

		   
	BEGIN -- Satisfaccion y Relevancia

		IF(@IDTipoProyecto = @CLIMA_LABORAL)
			BEGIN 
			
				INSERT INTO [Evaluacion360].[tblEscalaSatisfaccionGeneral]
				SELECT Nombre
						, Descripcion
						, [Min] 
						, [Max]
						, Color
						, IndiceSatisfaccion
						, @IDProyectoNuevo
				FROM [Evaluacion360].[tblEscalaSatisfaccionGeneral] WHERE IDProyecto = @IDProyecto

				INSERT INTO [Evaluacion360].[tblEscalaRelevanciaIndicadores]
				SELECT Descripcion
						, [Min] 
						, [Max]
						, IndiceRelevancia
						, @IDProyectoNuevo
				FROM [Evaluacion360].[tblEscalaRelevanciaIndicadores] WHERE IDProyecto = @IDProyecto
			
			END		
	END;


	update [Evaluacion360].[tblCatProyectos]
		set FechaInicio = @FechaInicio
			,FechaFin = @FechaFin
			,Calendarizado = 0
	where IDProyecto = @IDProyectoNuevo 

	select top 1 @IDWizardUsuario = IDWizardUsuario
	from Evaluacion360.tblWizardsUsuarios with (nolock)
	where IDProyecto = @IDProyectoNuevo

	update dwu  
	set dwu.Completo = 1
		,dwu.FechaHora = GETDATE()
	from [Evaluacion360].[tblDetalleWizardUsuario] dwu 
		join Evaluacion360.tblCatWizardItem cwi on dwu.IDWizardItem = cwi.IDWizardItem
	where dwu.IDWizardUsuario = @IDWizardUsuario and cwi.Orden < 5

	select @NewJSON = a.JSON
	from [Evaluacion360].[tblCatProyectos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE IDProyecto = @IDProyectoNuevo 

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra = @InformacionExtra

	IF(@ClonadoAutomatico = 1 OR @ClonadoAutomatico = 0)
		BEGIN		
			/*	FLUJO OLD
			exec [App].[spINotificacionProyectoClonado] @IDProyecto = @IDProyectoNuevo 
			*/
			-- FLUJO NEW
			EXEC [Evaluacion360].[spITareaDeProyectoClonado] @IDProyectoOriginal = @IDProyecto, @IDProyectoClonado = @IDProyectoNuevo, @IDUsuario = @IDUsuario;			
		END

	exec [Evaluacion360].[spActualizarTotalEvaluacionesPorEstatus]

	select @IDWizardUsuario as IDWizardUsuario
GO
