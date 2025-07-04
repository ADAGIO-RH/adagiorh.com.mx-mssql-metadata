USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Reclutamiento.spIURequisitosPuestoCandidatoPlaza
(
	@IDResultadosCandidatoPlaza int = 0
	,@IDCandidatoPlaza int 
	,@IDRequisitoPuesto int
	,@Resultado Varchar(max)
	,@IDUsuario int
)
AS
BEGIN
	IF(ISNULL(@IDResultadosCandidatoPlaza,0) = 0)
	BEGIN
		insert into Reclutamiento.tblResultadosCandidatoPlaza(IDCandidatoPlaza,IDRequisitoPuesto,Resultado)
		values(@IDCandidatoPlaza,@IDRequisitoPuesto,@Resultado)
	END
	ELSE
	BEGIN
		UPDATE Reclutamiento.tblResultadosCandidatoPlaza
			set Resultado = @Resultado
				,FechaAplicacion = getdate()
				,IDCandidatoPlaza = @IDCandidatoPlaza
				,IDRequisitoPuesto = @IDRequisitoPuesto
		WHERE IDResultadosCandidatoPlaza = @IDResultadosCandidatoPlaza
	END
END
GO
