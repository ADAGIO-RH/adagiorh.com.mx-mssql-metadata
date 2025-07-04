USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Nomina].[spBuscarColaboradoresAExcluirDelCalculo](
	@FechaIni date
	,@FechaFin date
	,@empleados [RH].[dtEmpleados] readonly                  
	,@fechasUltimaVigencia [App].[dtFechasVigenciaEmpleado] readonly 
	,@IDPeriodo int
	,@ExcluirBajas bit =1 
	,@IDUsuario int                
) as
	declare
		@empleadosRespuesta [RH].[dtEmpleados],
		@NombreProcedure Varchar(max)
	;
	
	SELECT top 1 @NombreProcedure = Valor FROM App.tblConfiguracionesGenerales WHERE IDConfiguracion = 'SPExcluirColaboradoresCalculo'

	IF(@ExcluirBajas = 1)        
	BEGIN 
		IF(ISNULL(@NombreProcedure,'') <> '')
		BEGIN
			exec sp_executesql N'exec @miSP @FechaIni, @FechaFin, @empleados, @fechasUltimaVigencia, @IDPeriodo, @ExcluirBajas, @IDUsuario'                   
				,N' @FechaIni date
					,@FechaFin date
					,@empleados [RH].[dtEmpleados] READONLY
					,@fechasUltimaVigencia [App].[dtFechasVigenciaEmpleado] READONLY 
					,@IDPeriodo int
					,@ExcluirBajas bit
					,@IDUsuario int          
					,@miSP varchar(MAX)',                          
					@FechaIni = @FechaIni
					,@FechaFin = @FechaFin              
					,@empleados =@empleados  
					,@fechasUltimaVigencia = @fechasUltimaVigencia
					,@IDPeriodo = @IDPeriodo
					,@ExcluirBajas  = @ExcluirBajas 
					,@IDUsuario =@IDUsuario                  
					,@miSP = @NombreProcedure ;    
		END
		ELSE
		BEGIN
			EXEC [Nomina].[spCoreBuscarColaboradoresAExcluirDelCalculo]
				@FechaIni 
				,@FechaFin 
				,@empleados       
				,@fechasUltimaVigencia 
				,@IDPeriodo 
				,@ExcluirBajas 
				,@IDUsuario   
		END
	END
	ELSE
	BEGIN
		select *
		from @empleadosRespuesta
	END
GO
