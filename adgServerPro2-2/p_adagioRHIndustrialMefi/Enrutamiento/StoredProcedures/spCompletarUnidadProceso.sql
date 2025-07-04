USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Enrutamiento].[spCompletarUnidadProceso] --13,1
(
	@IDUnidad int,
	@IDUsuario int
)
AS
BEGIN
DECLARE @Pendiente bit = 0,
	@spComplete varchar(max),
	@IDReferencia int

	select @spComplete = tp.StoreProcedureComplete
		,@IDReferencia = u.IDReferencia
	from Enrutamiento.tblUnidadProceso u
		inner join Enrutamiento.tblCatTiposProcesos tp
			on u.IDCatTipoProceso = tp.IDCatTipoProceso
	where IDUnidad = @IDUnidad


	IF Exists(select top 1 1 
				from [Enrutamiento].[tblRutaUnidadProceso] RUP 
				where RUP.IDUnidad = @IDUnidad and isnull(Completado,0) = 0 )
	BEGIN
		set @Pendiente = 1
		return;
	END
		print 'aqui'
	IF EXISTS (select top 1 1 from [Enrutamiento].[tblEjecucionUnidadProceso]
				WHERE IDRutaUnidadProceso  in (
					select IDRutaUnidadProceso from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = @IDUnidad
				))
	BEGIN
			IF OBJECT_ID(N'tempdb..#tempEjecucion') IS NOT NULL DROP TABLE #tempEjecucion

			select IDRutaUnidadProceso,
				isnull((select top 1 1 from [Enrutamiento].[tblEjecucionUnidadProceso] where IDRutaUnidadProceso = RUP.IDRutaUnidadProceso and Realizado = 1),1) realizado
				into #tempEjecucion
			from [Enrutamiento].[tblRutaUnidadProceso] RUP 
			where RUP.IDUnidad = @IDUnidad
					and RUP.Orden > 1
			IF EXISTS(select top 1 1 from #tempEjecucion where isnull(realizado,0) = 0)
			BEGIN
				SET @Pendiente = 1
				return;
			END
	END
	

	
	IF EXISTS (select top 1 1 from [Enrutamiento].[tblAutorizacionUnidadProceso]
				WHERE IDRutaUnidadProceso  in (
					select IDRutaUnidadProceso from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = @IDUnidad
				))
	BEGIN
		IF EXISTS(select top 1 1 from [Enrutamiento].[tblAutorizacionUnidadProceso]
				WHERE IDRutaUnidadProceso  in (
					select IDRutaUnidadProceso from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = @IDUnidad
				) and (isnull(Autorizado,0) = 0 OR isnull(Autorizado,0) = 2)
				)
		BEGIN
			SET @Pendiente = 1
			return;
		END
	END

    exec [Enrutamiento].[spModificarEstatusUnidadProceso] @IDUnidad =@IDUnidad,
        @IDStatus=2 ,
	    @IDUsuario=@IDUsuario
	/*exec sp_executesql N'exec @miSP @IDReferencia,@IDUsuario'                   
			,N' @IDReferencia int
				,@IDUsuario int
				,@miSP varchar(255)',                          
				@IDReferencia =@IDReferencia                  
				,@IDUsuario =@IDUsuario                  
				,@miSP = @spComplete ;  
	
	UPDATE Enrutamiento.tblUnidadProceso
				set IDEstatus = (select IDCatalogoGeneral 
								from [App].[tblCatalogosGenerales] CG With(Nolock)
									inner join [App].[TblTiposCatalogosGenerales] TCG With(Nolock)
										on CG.IDTipoCatalogo = TCG.IDTipoCatalogo
								where TCG.TipoCatalogo = 'Estatus de Unidad Proceso'
								and CG.Catalogo = 'Completada - Autorizada')
				WHERE IDUnidad = @IDUnidad*/

END;
GO
