USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Enrutamiento].[spCrearUnidadProceso]
(
	@IDCatTipoProceso int,
	@IDReferencia int,
	@IDCliente int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @IDUnidad int,
	@Prefijo Varchar(50),
	@MAXUnidID int,
	@Codigo Varchar(20),
	@Descripcion Varchar(500)

	select @Prefijo = Prefijo 
	from [Enrutamiento].[tblCatTiposProcesos] WITH(NOLOCK)
	where IDCatTipoProceso = @IDCatTipoProceso

	select @MAXUnidID = ISNULL(MAX(IDUnidad),0)+1
	FROM [Enrutamiento].[tblUnidadProceso] WITH(NOLOCK)

	SELECT @Codigo = @Prefijo + App.fnAddString(5,CAST(@MAXUnidID as varchar(5)),'0',1)

	select @Descripcion = [Enrutamiento].[fnDescripcionUnidadProceso](@IDCatTipoProceso,@IDReferencia)

	Insert into [Enrutamiento].[tblUnidadProceso](
				IDCatTipoProceso
				,Codigo
				,Descripcion
				,IDUsuarioCreador
				,FechaHoraCreacion
				,IDReferencia
				,IDEstatus
				,IDCliente)
	Values(
		@IDCatTipoProceso
		,@Codigo
		,@Descripcion
		,@IDUsuario
		,GETDATE()
		,@IDReferencia
		,(select IDCatalogoGeneral 
		from [App].[tblCatalogosGenerales] CG With(Nolock)
			inner join [App].[TblTiposCatalogosGenerales] TCG With(Nolock)
				on CG.IDTipoCatalogo = TCG.IDTipoCatalogo
		where TCG.TipoCatalogo = 'Estatus de Unidad Proceso'
		and CG.Catalogo = 'En Proceso')
		,@IDCliente
	)

	set @IDUnidad = @@Identity

	EXEC [Enrutamiento].[spCopiarRutaAutorizacionUnidadProceso] @IDUnidad, @IDCatTipoProceso,@IDCliente

END;
GO
