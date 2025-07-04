USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RH].[spIAprobadoresPlazas](
	@IDPlaza int,
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

	select @SecuenciaMax = isnull(MAX(isnull(secuencia,0)),0) from [RH].[tblAprobadoresPlazas] where IDPlaza = @IDPlaza

	IF(@SecuenciaMax = 0)
	BEGIN
		set @Secuencia = @SecuenciaMax + 1
	END 
	ELSE IF exists(select top 1 1 
			from [RH].[tblAprobadoresPlazas] 
			where IDPlaza = @IDPlaza and secuencia = @SecuenciaMax and isnull(Aprobacion,0) = 0
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

	insert into [RH].[tblAprobadoresPlazas](IDPlaza, IDUsuario,Aprobacion, Secuencia, Orden)
	select @IDPlaza, IDUsuario, 0, @Secuencia, Orden
	from @aprobadores

	Select @CountAprobadores = count(*) from [RH].[tblAprobadoresPlazas] where IDPlaza = @IDPlaza and Secuencia = @Secuencia

	--IF(@CountAprobadores = 1)
	--BEGIN
		EXEC [App].[INotificacionModuloPlazas] 0,@IDPlaza,'CREATE-AUTORIZA'
	--END

END;
GO
