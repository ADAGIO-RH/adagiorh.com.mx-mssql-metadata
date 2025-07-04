USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Descripción,varchar,Descripción>
** Autor			: <Autor,varchar,Nombre>
** Email			: <Email,varchar,@adagio.com.mx>
** FechaCreacion	: <FechaCreacion,Date,Fecha>
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [RH].[spUAprobacionPosicion](
	@IDAprobadorPosicion int,
	@IDPosicion int,
	@Aprobacion int,
	@Observacion varchar(max),
	@IDUsuario int
)
AS
BEGIN

	DECLARE 
		@CountAprobadores int = 0,
		@Secuencia int = 0,
		@SecuenciaMax int = 0,
		@IDPlaza int,
				
		@ESTATUS_POSICION_AUTORIZADA_DISPONIBLE INT = 2,
		@ESTATUS_POSICION_NO_AUTORIZADA	INT = 5
	;

	select 
		@IDPlaza = IDPlaza
	from RH.tblCatPosiciones
	where IDPosicion = @IDPosicion


	select @SecuenciaMax = isnull(MAX(isnull(Secuencia,0)),0) from RH.tblAprobadoresPosiciones where IDPosicion = @IDPosicion

	update RH.tblAprobadoresPosiciones 
		set Aprobacion = @Aprobacion,
			Observacion = UPPER(@Observacion),
			FechaAprobacion = getdate()
	where  IDPosicion = @IDPosicion
	and Secuencia = @SecuenciaMax
	and IDUsuario = @IDUsuario

	IF(@Aprobacion = 1)
	BEGIN

		IF NOT EXISTS(select top 1 1 from RH.tblAprobadoresPosiciones where IDPosicion = @IDPosicion and Aprobacion <> 1 and Secuencia = @SecuenciaMax)
		BEGIN
			--select 'complete'
			EXEC [App].[INotificacionModuloPosiciones] @IDAprobador=0, @IDPosicion=@IDPosicion, @TipoCambio='COMPLETE-SECUENCIA'

			-- Estatus de autorizada
			insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario)
			select @IDPosicion,@ESTATUS_POSICION_AUTORIZADA_DISPONIBLE,@IDUsuario

		END ELSE
		BEGIN
			EXEC [App].[INotificacionModuloPosiciones] @IDAprobador=0, @IDPosicion=@IDPosicion, @TipoCambio='CREATE-AUTORIZA'
		END
	END

	IF(@Aprobacion = 2)
	BEGIN
		EXEC [App].[INotificacionModuloPosiciones] @IDAprobador=@IDAprobadorPosicion, @IDPosicion=@IDPosicion, @TipoCambio='DECLINE-AUTORIZA'
		-- Estatus de autorizada
		insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario)
		select @IDPosicion,@ESTATUS_POSICION_NO_AUTORIZADA,@IDUsuario
	END

	exec [RH].[spActualizarTotalesPosiciones] @IDPlaza = @IDPlaza, @IDUsuario = @IDUsuario	
END;
GO
