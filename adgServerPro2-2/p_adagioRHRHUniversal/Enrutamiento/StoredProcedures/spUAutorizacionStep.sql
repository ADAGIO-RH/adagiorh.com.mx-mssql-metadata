USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Enrutamiento].[spUAutorizacionStep](
	@IDRutaUnidadProceso int,
	@Autorizado int,
	@Observacion Varchar(max),
	@IDUsuario int
)
AS
BEGIN
	DECLARE @IDUnidad int
	

	Select top 1 @IDUnidad = IDUnidad from Enrutamiento.tblRutaUnidadProceso where IDRutaUnidadProceso = @IDRutaUnidadProceso

    Select * from Enrutamiento.tblRutaUnidadProceso 

	UPDATE Enrutamiento.tblAutorizacionUnidadProceso
		set Autorizado = @Autorizado
			,FechaHoraAutorizacion = GETDATE()
			,Observacion = @Observacion
	WHERE IDRutaUnidadProceso = @IDRutaUnidadProceso
	and IDUsuario = @IDUsuario

	IF NOT EXISTS(Select Top 1 1 from Enrutamiento.tblAutorizacionUnidadProceso where isnull(Autorizado,0) = 0 and IDRutaUnidadProceso = @IDRutaUnidadProceso)
	BEGIN
		IF EXISTS(Select Top 1 1 from Enrutamiento.tblAutorizacionUnidadProceso where isnull(Autorizado,0) = 2 and IDRutaUnidadProceso = @IDRutaUnidadProceso)
		BEGIN
                exec [Enrutamiento].[spModificarEstatusUnidadProceso] @IDUnidad =@IDUnidad,
                @IDStatus=6 ,
	            @IDUsuario=@IDUsuario

                /*UPDATE Enrutamiento.tblUnidadProceso
				set IDEstatus = (select IDCatalogoGeneral 
								from [App].[tblCatalogosGenerales] CG With(Nolock)
									inner join [App].[TblTiposCatalogosGenerales] TCG With(Nolock)
										on CG.IDTipoCatalogo = TCG.IDTipoCatalogo
								where TCG.TipoCatalogo = 'Estatus de Unidad Proceso' and CG.Catalogo = 'Detenida por Rechazo')
				WHERE IDUnidad = @IDUnidad*/
		END
		ELSE
		BEGIN
			
			update Enrutamiento.tblRutaUnidadProceso 
				set Completado = 1
				,FechaHoraCompletado = getdate()
			where IDRutaUnidadProceso = @IDRutaUnidadProceso
		END
	END

	exec [Enrutamiento].[spCompletarUnidadProceso] @IDUnidad, @IDUsuario

END
GO
