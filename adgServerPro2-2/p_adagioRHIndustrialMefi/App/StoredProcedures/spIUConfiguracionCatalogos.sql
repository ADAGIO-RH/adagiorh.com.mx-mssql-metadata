USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE App.spIUConfiguracionCatalogos
(
	@IDCliente int
)
AS
BEGIN
	
		if object_id('tempdb..#TemptblCatCatalogos') is not null
				drop table #TemptblCatCatalogos

		create table #TemptblCatCatalogos(IDCatalogo int
													, Catalogo varchar(50) COLLATE database_default
													,IDUrl int)

		insert into #TemptblCatCatalogos 
		select IDCatalogo,Catalogo,IDUrl 
		from App.tblCatCatalogos

		
			MERGE [App].[tblConfiguracionCatalogos] AS TARGET
			USING #TemptblCatCatalogos as SOURCE
			on TARGET.IDCliente = @IDCliente AND
			   TARGET.IDCatalogo = Source.IDCatalogo
			WHEN MATCHED THEN
				update 
				 set TARGET.IDCatalogo = SOURCE.IDCatalogo,
					 TARGET.IDUrl = SOURCE.IDUrl

			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDCliente,IDCatalogo,IDValue,Visible,Habilitado,IDUrl)
				values(@IDCliente,SOURCE.IDCatalogo,0,1,1,SOURCE.IDUrl);

		
END
GO
