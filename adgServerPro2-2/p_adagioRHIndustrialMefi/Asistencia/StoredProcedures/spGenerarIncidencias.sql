USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Generar las incidencias de los colaboradores en función de sus checadas, descansos y ausentismos.
** Autor			: Jose Rafael Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2019-11-22			Aneudy Abreu		Se agrega la validación de la configuración para generar o no 
										las incidencias, esto podrá variar por cliente y se pueda modificar
										desde el catálogo de ausentismos.
2022-09-21			Joseph Roman		Se modifico el procedimiento para poder personalizar los procedimientos
										de generación de cualquier incidencia. Se agrego a la tabla 
										Asistencia.tblcatIncidencias el campo [NombreProcedure] para poder 
										especificar el procedimiento que se desea ejecutar.
										En el PostDeployCustome se definen los Sp's del Core que van
										a ejecutarse por Default.
2023-03-09          Javier Peña         Se agrega el procedimiento para borrar faltas incorrectas desde el mismo generador                                        
2023-05-04          Javier Peña         [FIX] Se direcciona procedimiento para eliminar las faltas incorrectas a [Asistencia].[EliminarFaltasIncorrectas] para que pudiera direccionar
                                        a la configuracion del procedimiento personalizado o Core, anteriormente se llamaba directo al core
exec [Asistencia].[spGenerarIncidencias] @FechaIni='2022-08-22 00:00:00',@FechaFin='2022-09-21 00:00:00',@EmpleadoIni=N'',@EmpleadoFin=N'',@IDUsuario=1
***************************************************************************************************/
CREATE PROCEDURE [Asistencia].[spGenerarIncidencias](
	@FechaIni DATE = null, 
	@FechaFin DATE =  null, 
	@EmpleadoIni Varchar(20) = '0',                
	@EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',      
	@IDUsuario int = null
)
AS
BEGIN

	SET DATEFIRST 7;  
	SET LANGUAGE Spanish;
	SET DATEFORMAT ymd;

	DECLARE @dtFechas app.dtFechas,  
            @dtEmpleados [RH].[dtEmpleados],
			@dtConfig  [App].[dtConfiguracionesGenerales],
			@dtVigenciaEmpleado [app].[dtFechasVigenciaEmpleado],
			@dtChecadas [Asistencia].[dtChecadas],
			@dtIncidenciasEmpleados [Asistencia].[dtIncidenciaEmpleado],
			@dtHorariosEmpleados [Asistencia].[dtHorariosEmpleados],
            --@IDUsuarioAdmin int,             
            @DiasGeneraIncidencia int,
			@RNIncidencia int = 0,
			@RNIncidenciaMax int,
			@NombreProcedure Varchar(max);
			
   DECLARE @OldJSON Varchar(Max),
			@NewJSON Varchar(Max);

	INSERT INTO @dtConfig
	SELECT * 
	FROM App.tblConfiguracionesGenerales WITH(NOLOCK)
	WHERE IDTipoConfiguracionGeneral = 4 -- ASISTENCIA

	-- IF(@IDUsuario is null)
	-- BEGIN    
	-- 	SELECT TOP 1 @IDUsuarioAdmin = Valor FROM app.tblConfiguracionesGenerales WITH(NOLOCK) WHERE IDConfiguracion = 'IDUsuarioAdmin' 
	-- END ELSE
	-- BEGIN
	-- 	set @IDUsuarioAdmin = @IDUsuario
	-- END

    -- SET @IDUsuario = NULL

    IF(@IDUsuario is null)
	BEGIN    
		SELECT TOP 1 @IDUsuario = Valor FROM app.tblConfiguracionesGenerales WITH(NOLOCK) WHERE IDConfiguracion = 'IDUsuarioAdmin'           
	END 

	SELECT TOP 1 @DiasGeneraIncidencia = valor FROM @dtConfig WHERE IDConfiguracion = 'DiasGeneraChecadas' 

	IF(@FechaIni is null and @FechaFin is null)
	BEGIN
		SELECT @FechaIni = dateadd(day,-@DiasGeneraIncidencia,cast(GETDATE() as date)),
			  @FechaFin = getdate()
	END

	IF(ISNULL(@EmpleadoIni,'')= '' and isnull(@EmpleadoFin,'')= '')
	BEGIN
		SELECT @EmpleadoIni = '0',
			  @EmpleadoFin = 'ZZZZZZZZZZZZZZZZZZZZ'
	END


	INSERT INTO @dtEmpleados    
	EXEC [RH].[spBuscarEmpleadosMaster] 
			@FechaIni	= @FechaIni  
			,@FechaFin	= @FechaFin
			,@EmpleadoIni	= @EmpleadoIni
			,@EmpleadoFin	= @EmpleadoFin 
			,@IDUsuario		= @IDUsuario 


	INSERT INTO @dtFechas  
	EXEC [App].[spListaFechas] @FechaIni = @FechaIni, @FechaFin = @FechaFin  

	SELECT @OldJSON = a.JSON from (SELECT @FechaIni as FechaIni, @FechaFin as FechaFin, EmpleadoIni = @EmpleadoIni, EmpleadoFin = @EmpleadoFin, IDUsuario = @IDUsuario ) b
	CROSS APPLY (Select JSON=[Utilerias].[fnStrJSON](0,1,(SELECT b.* For XML Raw)) ) a
	
	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblIncidenciaEmpleado]','[Asistencia].[spGenerarIncidencias]','GENERAR INCIDENCIAS','',@OldJSON

	INSERT INTO @dtVigenciaEmpleado
	EXEC [RH].[spBuscarListaFechasVigenciaEmpleado]  
		@dtEmpleados	= @dtEmpleados  
		,@Fechas		= @dtFechas  
		,@IDUsuario		= 1  

	DELETE  @dtVigenciaEmpleado WHERE Vigente = 0

	INSERT INTO @dtChecadas
	SELECT c.*
	FROM Asistencia.tblChecadas c with (nolock)
		JOIN @dtVigenciaEmpleado tempEmp on c.IDEmpleado = tempEmp.IDEmpleado and c.FechaOrigen = tempEmp.Fecha and tempEmp.Vigente = 1
	WHERE c.IDTipoChecada not in ('EC','SC')

	INSERT INTO @dtIncidenciasEmpleados
	SELECT ie.*
	FROM Asistencia.tblIncidenciaEmpleado ie with (nolock)
		JOIN @dtVigenciaEmpleado tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado and ie.Fecha = tempEmp.Fecha and tempEmp.Vigente = 1

	INSERT INTO @dtHorariosEmpleados
	SELECT ie.*
	FROM Asistencia.tblHorariosEmpleados ie with (nolock)
		JOIN @dtVigenciaEmpleado tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado and ie.Fecha = tempEmp.Fecha and tempEmp.Vigente = 1


	IF object_id('tempdb..#tempCatIncidenciasGenerar') is not null DROP TABLE #tempCatIncidenciasGenerar

	SELECT * , ROW_NUMBER()OVER(ORDER BY IDIncidencia ASC) as RN
	INTO #tempCatIncidenciasGenerar
	FROM Asistencia.tblCatIncidencias WITH(NOLOCK)
	WHERE isnull(GenerarIncidencias,0) = 1
	and ISNULL(NombreProcedure,'') <> ''

	SELECT @RNIncidencia = MIN(RN) ,
		@RNIncidenciaMax = MAX(RN)
	FROM #tempCatIncidenciasGenerar

	WHILE (@RNIncidencia <= @RNIncidenciaMax)
	BEGIN
		SELECT @NombreProcedure = NombreProcedure FROM #tempCatIncidenciasGenerar where RN = @RNIncidencia
		PRINT @NombreProcedure 
		exec sp_executesql N'exec @miSP @dtconfig,@dtempleados,@dtVigenciaEmpleados,@dtChecadas,@dtIncidenciasEmpleados,@dtHorariosEmpleados,@IDUsuario'                   
			,N'  @dtConfig as [App].[dtConfiguracionesGenerales] READONLY 
				,@dtEmpleados [RH].[dtEmpleados] READONLY
				,@dtVigenciaEmpleados [App].[dtFechasVigenciaEmpleado] READONLY
				,@dtChecadas [Asistencia].[dtChecadas] READONLY
				,@dtIncidenciasEmpleados [Asistencia].[dtIncidenciaEmpleado] READONLY
				,@dtHorariosEmpleados [Asistencia].[dtHorariosEmpleados] READONLY
				,@IDUsuario int              
				,@miSP varchar(MAX)',                          
				@dtconfig =@dtconfig                   
				,@dtempleados =@dtempleados                  
				,@dtVigenciaEmpleados = @dtVigenciaEmpleado                  
				,@dtChecadas = @dtChecadas                  
				,@dtIncidenciasEmpleados =@dtIncidenciasEmpleados                  
				,@dtHorariosEmpleados =@dtHorariosEmpleados                  
				,@IDUsuario =@IDUsuario                  
				,@miSP = @NombreProcedure ;    

		SELECT @RNIncidencia = MIN(RN) FROM #tempCatIncidenciasGenerar where RN > @RNIncidencia
	END

    --EXEC [Asistencia].[spCoreEliminarFaltasIncorrectas] @dtFechas=@dtFechas,@dtEmpleados=@dtempleados,@IDUsuario=@IDUsuario    
    EXEC [Asistencia].[EliminarFaltasIncorrectas] @FechaIni=@FechaIni,@FechaFin=@FechaFin,@EmpleadoIni=@EmpleadoIni,@EmpleadoFin=@EmpleadoFin,@IDUsuario=@IDUsuario

END
GO
