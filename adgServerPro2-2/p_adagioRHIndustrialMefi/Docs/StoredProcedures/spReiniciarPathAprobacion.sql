USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[spReiniciarPathAprobacion]--12,1
(
	@IDDocumento int,
	@IDUsuario int
)
AS
BEGIN

DECLARE @CountAprobadores int = 0,
		@Secuencia int = 0,
		@SecuenciaMax int = 0

	select @SecuenciaMax = isnull(MAX(isnull(secuencia,0)),0) from Docs.tblAprobadoresDocumentos where IDDocumento = @IDDocumento
	set @Secuencia = @SecuenciaMax + 1
	IF exists( select top 1 1  from Docs.tblAprobadoresDocumentos where IDDocumento = @IDDocumento and secuencia = @SecuenciaMax and isnull(Aprobacion,0) = 0)
	BEGIN
			
			insert into Docs.tblAprobadoresDocumentos(IDDocumento, IDUsuario,Aprobacion, Secuencia)
			select IDDocumento,IDUsuario,0, @Secuencia
			from Docs.tblAprobadoresDocumentos where IDDocumento = @IDDocumento and secuencia = @SecuenciaMax
			order by IDAprobadorDocumento asc

			delete Docs.tblAprobadoresDocumentos where IDDocumento = @IDDocumento and secuencia = @SecuenciaMax and isnull(Aprobacion,0) = 0
	END
	ELSE
	BEGIN
	
			insert into Docs.tblAprobadoresDocumentos(IDDocumento, IDUsuario,Aprobacion, Secuencia)
			select IDDocumento,IDUsuario,0, @Secuencia
			from Docs.tblAprobadoresDocumentos where IDDocumento = @IDDocumento and secuencia = @SecuenciaMax
			order by IDAprobadorDocumento asc
	END


	EXEC [App].[INotificacionModuloDocumentos] @IDDocumento = @IDDocumento,@TipoCambio ='CREATE-AUTORIZA'
END
GO
