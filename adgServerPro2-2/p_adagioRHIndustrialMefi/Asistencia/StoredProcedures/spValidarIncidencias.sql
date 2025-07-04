USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Asistencia].[spValidarIncidencias]
(
	@IDIncidencia VARCHAR(10),
	@Descripcion VARCHAR(255)
)

AS
	BEGIN  

		--Proposito:			Valida si la incidencia ya existe en la tabla [Asistencia].[tblCatIncidencias]
		--Fecha Creación:		08-03-2020
		--Autor:				aparedes
		--Fecha Modificación:   
		--Autor Modificación:	
		--Version:				1.0
		--Parametros:			
		--Requerimiento:		748
		
		DECLARE @Resultado BIT = 0;
		DECLARE @IDIncidenciaAux VARCHAR(10) = '';		
	
		SELECT @IDIncidenciaAux = I.IDIncidencia
		FROM [Asistencia].[tblCatIncidencias] I
		WHERE I.IDIncidencia = @IDIncidencia OR
			  I.Descripcion = @Descripcion


		IF @IDIncidenciaAux != ''
			SET @Resultado = 1

		SELECT @Resultado AS ExisteIncidencia
			
	END
GO
