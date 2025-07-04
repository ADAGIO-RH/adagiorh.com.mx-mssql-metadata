USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [App].[spUIConfiguracionCatalogosValores]
(
	@IDCliente int,
	@IDCatalogo int,
	@IDValue int,
	@Visible bit,
	@Habilitado bit
)
AS
BEGIN
    declare @IDUrl int = 0;

    select top 1 @IDUrl = IDUrl
    from app.tblCatCatalogos
    where IDCatalogo = @IDCatalogo

    if exists(select top 1 1 
		  from App.tblConfiguracionCatalogos
		  Where IDCatalogo = @IDCatalogo
			and IDCliente = @IDCliente) 
	BEGIN
	    UPDATE App.tblConfiguracionCatalogos
		    set IDValue = @IDValue,
			    Visible = @Visible,
			    Habilitado = @Habilitado
		    Where IDCatalogo = @IDCatalogo
			    and IDCliente = @IDCliente
	end ELSE
	BEGIN
	   insert into App.tblConfiguracionCatalogos(IDCliente,IDCatalogo,IDValue,Visible,Habilitado,IDUrl)
	   select @IDCliente,@IDCatalogo,@IDValue,@Visible,@Habilitado,@IDUrl
	end;


	Select
		cc.IDCliente 
		,cat.IDCatalogo
		,cat.Catalogo
		,IDValue
		,Visible
		,Habilitado
	From App.tblConfiguracionCatalogos cc
		
		Inner join App.tblcatCatalogos cat
			on cat.IDCatalogo = CC.IDCatalogo
	Where (cc.IDCatalogo = @IDCatalogo and IDCliente =  @IDCliente)
END
GO
