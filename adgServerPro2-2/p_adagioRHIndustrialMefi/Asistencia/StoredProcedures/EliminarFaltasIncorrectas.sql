USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [Asistencia].[EliminarFaltasIncorrectas]    Script Date: 04/06/2019 10:30:18 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
-- =============================================  
-- Author.............: Ing. Jose Roman
-- Create date........: 20/06/2013  
-- Last Date Modified.: 04/06/2019  
-- Description: Elimina todas las Faltas mas generadas y La Incidencia FR  
-- =============================================  
CREATE PROCEDURE [Asistencia].[EliminarFaltasIncorrectas] 
(
	@FechaIni DATE = null, 
	@FechaFin DATE =  null, 
	@EmpleadoIni Varchar(20) = '0',                
	@EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',      
	@IDUsuario int = null
) 
AS BEGIN  
  
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
            @IDUsuarioAdmin int, 
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

	SELECT top 1 @NombreProcedure = Valor FROM @dtConfig WHERE IDConfiguracion = 'ProcedureBorrarFaltasIncorrectas'

	IF(@IDUsuario is null)
	BEGIN    
		SELECT TOP 1 @IDUsuarioAdmin = Valor FROM app.tblConfiguracionesGenerales WITH(NOLOCK) WHERE IDConfiguracion = 'IDUsuarioAdmin' 
	END ELSE
	BEGIN
		set @IDUsuarioAdmin = @IDUsuario
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
			,@IDUsuario		= @IDUsuarioAdmin 


	INSERT INTO @dtFechas  
	EXEC [App].[spListaFechas] @FechaIni = @FechaIni, @FechaFin = @FechaFin  

	SELECT @OldJSON = a.JSON from (SELECT @FechaIni as FechaIni, @FechaFin as FechaFin, EmpleadoIni = @EmpleadoIni, EmpleadoFin = @EmpleadoFin, IDUsuario = @IDUsuarioAdmin ) b
	CROSS APPLY (Select JSON=[Utilerias].[fnStrJSON](0,1,(SELECT b.* For XML Raw)) ) a
	
	EXEC [Auditoria].[spIAuditoria] @IDUsuarioAdmin,'[Asistencia].[tblIncidenciaEmpleado]','[Asistencia].[EliminarFaltasIncorrectas] ','BORRAR FALTAS INCORRECTAS','',@OldJSON

	IF(ISNULL(@NombreProcedure,'') <> '')
	BEGIN
		exec sp_executesql N'exec @miSP @dtFechas, @dtEmpleados, @IDUsuario'                   
			,N'  @dtFechas as [App].[dtFechas] READONLY 
				,@dtEmpleados [RH].[dtEmpleados] READONLY
				,@IDUsuario int              
				,@miSP varchar(MAX)',                          
				@dtFechas =@dtFechas                   
				,@dtempleados =@dtempleados                                   
				,@IDUsuario =@IDUsuario                  
				,@miSP = @NombreProcedure ;    
	END
	ELSE
	BEGIN
		EXEC [Asistencia].[spCoreEliminarFaltasIncorrectas] @dtFechas, @dtEmpleados, @IDUsuarioAdmin
	END

END
GO
