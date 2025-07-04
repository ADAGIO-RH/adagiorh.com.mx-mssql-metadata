USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Asistencia].[spRegistrarZKChecada]-- 12,390,'2020-11-24 15:00:00.000'      
(      
	@IDLector int,      
	@IDEmpleado int,  
	@FechaHora Datetime     
)      
AS      
BEGIN      
    SET DATEFIRST 7;  
	SET LANGUAGE Spanish;
	SET DATEFORMAT ymd;

	declare 
		@spCustomRegistrarChecadaZK	Varchar(500), 
		@IDClienteLector int
	;

	select @IDClienteLector = IDCliente
	from Asistencia.tblLectores with (nolock)
	where IDLector = @IDLector

	select
		@spCustomRegistrarChecadaZK	= isnull(config.Valor,'')
	from RH.[TblConfiguracionesCliente] config with (nolock)
	where config.IDCliente = @IDClienteLector and config.IDTipoConfiguracionCliente = 'spCustomRegistrarChecadaZK'

	IF(@spCustomRegistrarChecadaZK <> '')
	BEGIN
		/*
			EXEC CUSTOM STORE PROCEDURE 
		*/
		exec sp_executesql N'exec @miSP @IDLector, @IDEmpleado,@FechaHora'                   
			,N' @IDLector int      
				,@IDEmpleado int                   
				,@FechaHora Datetime               
				,@miSP			varchar(255)'                          
				,@IDLector		= @IDLector                  
				,@IDEmpleado	= @IDEmpleado                 
				,@FechaHora		= @FechaHora                  
				,@miSP			= @spCustomRegistrarChecadaZK ;  
	END
	ELSE
	BEGIN
		/*
			EXEC CORE STORE PROCEDURE 
		*/
		exec [Asistencia].[spCORERegistrarZKChecada]	
			@IDLector = @IDLector
			,@IDEmpleado = @IDEmpleado
			,@FechaHora = @FechaHora
	END
END
GO
