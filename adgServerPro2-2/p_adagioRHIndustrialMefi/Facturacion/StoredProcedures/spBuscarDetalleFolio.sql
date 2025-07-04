USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Facturacion].[spBuscarDetalleFolio] --13832
(      
	@IDHistorialEmpleadoPeriodo int      
)      
AS      
BEGIN      
      declare
		@empleadosRespuesta [RH].[dtEmpleados],
		@NombreProcedure Varchar(max)
	;
	
	SELECT top 1 @NombreProcedure = Valor FROM App.tblConfiguracionesGenerales WHERE IDConfiguracion = 'SPCustomBuscarDetalleFolio'

	IF(ISNULL(@NombreProcedure,'') <> '')
	BEGIN
		print 'custome'
		exec sp_executesql N'exec @miSP @IDHistorialEmpleadoPeriodo'                   
			,N'  @IDHistorialEmpleadoPeriodo int          
				,@miSP varchar(MAX)',                          
				 @IDHistorialEmpleadoPeriodo =@IDHistorialEmpleadoPeriodo                 
				,@miSP = @NombreProcedure ;    
	END
	ELSE
	BEGIN
		EXEC [Facturacion].[spCoreBuscarDetalleFolio] @IDHistorialEmpleadoPeriodo   
	END
	
END
GO
