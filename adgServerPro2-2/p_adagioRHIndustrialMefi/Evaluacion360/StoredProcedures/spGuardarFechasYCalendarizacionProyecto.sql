USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Evaluacion360].[spGuardarFechasYCalendarizacionProyecto](
	@IDProyecto int
	,@Calendarizado bit
	,@IDSchedule int 
	,@FechaInicio date 
	,@FechaFin date 
	,@IDUsuario int 
) AS 

	--DECLARE 	@IDProyecto int = 36
	--,@Calendarizado bit = 1
	--,@IDSchedule int = 3
	--,@FechaInicio date = '2019-01-01'
	--,@FechaFin date = '2019-01-31'
	--,@IDUsuario int = 1

	 DECLARE 
		@IDTask	int	  
		,@Nombre varchar(255)
		,@StoreProcedure varchar(250) = 'exec [Evaluacion360].[spClonarProyecto] @IDProyecto = '+cast(@IDProyecto as varchar(100))
		,@interval	int = 1
		,@active bit = 1
		,@Accion varchar(255) = 'SQLScript'
		,@IDTipoAccion	int	= 0
		,@IDScheduleActual int = 0
	;

	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spGuardarFechasYCalendarizacionProyecto]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblCatProyectos]',
		@AccionAuditoria		varchar(20)	= 'UPDATE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	begin try
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
	end try
	begin catch
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		return 0;
	end catch

	SELECT @IDTipoAccion = tcta.IDTipoAccion FROM Scheduler.tblCatTipoAcciones tcta WHERE Descripcion = @Accion

	IF object_id('tempdb..#tempTask') IS NOT NULL DROP TABLE #tempTask;

	CREATE TABLE #tempTask (
		IDTask	int	 
		,Nombre	varchar(255)
		,StoreProcedure	varchar(250)
		,interval	int	
		,active	bit	
		,IDTipoAccion	int	
		,TipoAccion	varchar(250)
	);

	select @OldJSON =(SELECT IDProyecto
                        ,Nombre
                        ,FechaCreacion
                        ,IDUsuario
                        ,TotalPruebasARealizar
                        ,Calendarizado
                        ,(SELECT Introduccion  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Introduccion
                        ,(SELECT Indicacion FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Indicacion
                        ,IDTipoProyecto
                        ,Privacidad                      
                        FROM [Evaluacion360].tblCatProyectos                    
                    WHERE IDProyecto = @IDProyecto FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

	IF (@Calendarizado = 1)
	BEGIN
		SELECT @Nombre = 'Tarea del proyecto: '+coalesce(tcp.Nombre,'')
			,@IDTask = isnull(tcp.IDTask,0)
			,@IDScheduleActual = isnull(tcp.IDSchedule,0)
		FROM Evaluacion360.tblCatProyectos tcp 
		WHERE tcp.IDProyecto = @IDProyecto

		IF (@IDTask = 0) 
		begin
			INSERT #tempTask
			EXEC [Scheduler].[spUITask] @IDTask = 0
										,@Nombre = @Nombre
										,@StoreProcedure = @StoreProcedure
										,@interval = 1
										,@active =1 
										,@IDTipoAccion = @IDTipoAccion
										,@IDUsuario = @IDUsuario

			SELECT TOP 1 @IDTask = tt.IDTask from #tempTask tt

			EXEC [Scheduler].[spIUListSchedulerForTask]
				 @IDListScheduleForTask	 = 0
				,@IDTask				= @IDTask
				,@IDSchedule			= @IDSchedule
				,@IDUsuario = @IDUsuario
			
			UPDATE Evaluacion360.tblCatProyectos
			SET
				Evaluacion360.tblCatProyectos.Calendarizado = @Calendarizado,
				Evaluacion360.tblCatProyectos.FechaInicio = @FechaInicio,
				Evaluacion360.tblCatProyectos.FechaFin = @FechaFin,
				Evaluacion360.tblCatProyectos.IDTask = @IDTask,
				Evaluacion360.tblCatProyectos.IDSchedule = @IDSchedule 
			WHERE Evaluacion360.tblCatProyectos.IDProyecto = @IDProyecto

			select @NewJSON = (SELECT IDProyecto
                        ,Nombre
                        ,FechaCreacion
                        ,IDUsuario
                        ,TotalPruebasARealizar
                        ,Calendarizado
                        ,(SELECT Introduccion  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Introduccion
                        ,(SELECT Indicacion FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Indicacion
                        ,IDTipoProyecto
                        ,Privacidad                      
                        FROM [Evaluacion360].tblCatProyectos                    
                    WHERE IDProyecto = @IDProyecto FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)


		END ELSE
		begin
			IF ((@IDSchedule != 0) AND (@IDScheduleActual != @IDSchedule))
			BEGIN
				DELETE FROM [Scheduler].[tblListSchedulersForTask] WHERE IDTask = @IDTask;
				EXEC [Scheduler].[spIUListSchedulerForTask]
					 @IDListScheduleForTask	 = 0
					,@IDTask				= @IDTask
					,@IDSchedule			= @IDSchedule
					,@IDUsuario = @IDUsuario

				UPDATE Evaluacion360.tblCatProyectos
				SET
					Evaluacion360.tblCatProyectos.Calendarizado = @Calendarizado,
					Evaluacion360.tblCatProyectos.FechaInicio = @FechaInicio,
					Evaluacion360.tblCatProyectos.FechaFin = @FechaFin,
					Evaluacion360.tblCatProyectos.IDTask = @IDTask,
					Evaluacion360.tblCatProyectos.IDSchedule = @IDSchedule 
				WHERE Evaluacion360.tblCatProyectos.IDProyecto = @IDProyecto

				select @NewJSON = (SELECT IDProyecto
                        ,Nombre
                        ,FechaCreacion
                        ,IDUsuario
                        ,TotalPruebasARealizar
                        ,Calendarizado
                        ,(SELECT Introduccion  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Introduccion
                        ,(SELECT Indicacion FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Indicacion
                        ,IDTipoProyecto
                        ,Privacidad                      
                        FROM [Evaluacion360].tblCatProyectos                    
                    WHERE IDProyecto = @IDProyecto FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

			end;
		end;

	END ELSE 
	BEGIN		
		UPDATE Evaluacion360.tblCatProyectos
		SET
		    Evaluacion360.tblCatProyectos.Calendarizado = @Calendarizado,
		    Evaluacion360.tblCatProyectos.FechaInicio = @FechaInicio,
		    Evaluacion360.tblCatProyectos.FechaFin = @FechaFin,
			Evaluacion360.tblCatProyectos.IDTask = null,
			Evaluacion360.tblCatProyectos.IDSchedule = null 
		WHERE Evaluacion360.tblCatProyectos.IDProyecto = @IDProyecto

		select @NewJSON = (SELECT IDProyecto
                        ,Nombre
                        ,FechaCreacion
                        ,IDUsuario
                        ,TotalPruebasARealizar
                        ,Calendarizado
                        ,(SELECT Introduccion  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Introduccion
                        ,(SELECT Indicacion FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Indicacion
                        ,IDTipoProyecto
                        ,Privacidad                      
                        FROM [Evaluacion360].tblCatProyectos                    
                    WHERE IDProyecto = @IDProyecto FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

	end;


	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra		= @InformacionExtra


 --SELECT * FROM Scheduler.tblSchedule ts
GO
