USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[spUICarpetaDocumento]
(
	@IDItem int = 0
	,@TipoItem int
	,@IDParent int = 0
	,@Nombre Varchar(254)
	,@FilePath Varchar(max) = null
	,@Descripcion Varchar(max) = null
	,@Version Varchar(max) = null
	,@PalabrasClave Varchar(max) = null
	,@Comentario Varchar(max) = null
	,@ValidoDesde datetime = null
	,@ValidoHasta datetime = null
	,@Expira bit = null
	,@DiasAntesCaducidad int = null
	,@IDTipoDocumento int = null
	,@Icono Varchar(max) = null
	,@IDAutor int = null
	,@IDPublicador int = null
	,@Visualizar bit = null
	,@Descargar  bit = null
	,@Color varchar(max) = null
	,@IDUsuario int
)
AS
BEGIN

SET @Nombre = UPPER(@Nombre);
SET @Descripcion = UPPER(@Descripcion);
SET @PalabrasClave = UPPER(@PalabrasClave);
SET @Comentario = UPPER(@Comentario);
SET @IDPublicador = ISNULL(@IDPublicador,@IDUsuario)
	if(@TipoItem = 0)
	BEGIN
		IF(isnull(@IDItem,0) = 0 )
		BEGIN
			Insert into Docs.tblCarpetasDocumentos(TipoItem,IDParent,Nombre,FilePath, Descripcion,IDPublicador,Color, Icono)
			Values(@TipoItem,@IDParent,@Nombre,@FilePath, @Descripcion,@IDPublicador,@Color, @Icono)
			set @IDItem = @@IDENTITY
		END
		ELSE
		BEGIN
			Update Docs.tblCarpetasDocumentos
				set Nombre = @Nombre,
					IDParent = @IDParent,
					FilePath = @FilePath,
					Descripcion = @Descripcion,
					Color = @Color,
					Icono = @Icono
			where IDItem = @IDItem
		END
	END
	ELSE
	BEGIN
		IF(isnull(@IDItem,0) = 0 )
		BEGIN
			Insert into Docs.tblCarpetasDocumentos(TipoItem
													,IDParent
													,Nombre
													
													,Descripcion
													,Version
													,PalabrasClave
													,Comentario
													,ValidoDesde
													,ValidoHasta
													,Expira
													,DiasAntesCaducidad
													,IDTipoDocumento
													,Icono
													,IDAutor
													,IDPublicador
													,FechaCreacion
													,FechaUltimaActualizacion
													,Visualizar
													,Descargar
													,Color)
			Values(@TipoItem
					,@IDParent
					,@Nombre
					
					,@Descripcion
					,@Version
					,@PalabrasClave
					,@Comentario
					,@ValidoDesde
					,@ValidoHasta
					,@Expira
					,@DiasAntesCaducidad
					,case when isnull(@IDTipoDocumento,0) = 0 then null else @IDTipoDocumento end
					,@Icono
					,@IDUsuario
					,@IDUsuario
					,getdate()
					,getdate()
					,@Visualizar
					,@Descargar
					,@Color)
			set @IDItem = @@IDENTITY
		END
		ELSE
		BEGIN
		
			Update Docs.tblCarpetasDocumentos
				set Nombre = @Nombre
					,IDParent = @IDParent
					
					,Descripcion				=@Descripcion				
					,Version					=@Version					
					,PalabrasClave				=@PalabrasClave				
					,Comentario					=@Comentario					
					,ValidoDesde				=@ValidoDesde				
					,ValidoHasta				=@ValidoHasta				
					,Expira						=isnull(@Expira,0)						
					,DiasAntesCaducidad			=isnull(@DiasAntesCaducidad,0)			
					,IDTipoDocumento			=case when isnull(@IDTipoDocumento,0) = 0 then null else @IDTipoDocumento end			
					,Icono						=isnull(@Icono,'fa fa-file-o')						
					,IDAutor					=@IDUsuario					
					,FechaUltimaActualizacion	=getdate()	
					,Visualizar					=isnull(@Visualizar,0)					
					,Descargar					=isnull(@Descargar,0)					
					,Color						=isnull(@Color,'#000')						
			where IDItem = @IDItem
		END
	END

	select @IDItem as IDItem
	--Exec Docs.spBuscarCarpetasDocumentos @IDItem = @IDItem, @IDUsuario=@IDUsuario
END
GO
