USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RH].[spIAprobadoresPosiciones](
	@IDPlaza int,
	@IDPosicion int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE 
		@CountAprobadores int = 0,
		@Secuencia int = 0,
		@SecuenciaMax int = 0
	;

	declare @aprobadores as table (
		IDUsuario int,
		Usuario varchar(max),
		Orden int
	);

	select @SecuenciaMax = isnull(MAX(isnull(secuencia,0)),0) from [RH].[tblAprobadoresPosiciones] where IDPosicion = @IDPosicion

	IF(@SecuenciaMax = 0)
	BEGIN
		set @Secuencia = @SecuenciaMax + 1
	END 
	ELSE IF exists(select top 1 1 
			from [RH].[tblAprobadoresPosiciones] 
			where IDPosicion = @IDPosicion and secuencia = @SecuenciaMax and isnull(Aprobacion,0) = 0
	)
	BEGIN
		set @Secuencia = @SecuenciaMax
	END
	ELSE
	BEGIN
		set @Secuencia = @SecuenciaMax + 1
	END

	insert @aprobadores
	exec RH.spDeterminarAprobadoresPlazasSegunSuSolicitante @IDPlaza, @IDUsuario

	insert into [RH].[tblAprobadoresPosiciones](IDPosicion, IDUsuario,Aprobacion, Secuencia, Orden)
	select @IDPosicion, IDUsuario, 0, @Secuencia, Orden
	from @aprobadores

	Select @CountAprobadores = count(*) from [RH].[tblAprobadoresPosiciones] where IDPosicion = @IDPosicion and Secuencia = @Secuencia

	--IF(@CountAprobadores = 1)
	--BEGIN
		EXEC [App].[INotificacionModuloPosiciones] 0,@IDPosicion,'CREATE-AUTORIZA'
	--END

END;
GO
