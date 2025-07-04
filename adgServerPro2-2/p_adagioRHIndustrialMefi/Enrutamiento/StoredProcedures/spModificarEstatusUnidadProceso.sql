USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Enrutamiento].[spModificarEstatusUnidadProceso]
(
	@IDUnidad int,
    @IDStatus int ,
	@IDUsuario int
)
AS
BEGIN
    declare @Parametros Nomina.dtFiltrosRH
    declare @IDReferencia int
    declare @SpEjecutar varchar(255)
    
    insert into @Parametros values(N'Clientes',NULL)
    insert into @Parametros values(N'RegPatronales',NULL)


    UPDATE [Enrutamiento].[tblUnidadProceso]
		set IDEstatus = @IDStatus
                /*(select * from [App].[tblCatalogosGenerales] CG With(Nolock)
				where  CG.IDTipoCatalogo = 6
				and CG.Catalogo = 'Cancelada')*/
	WHERE IDUnidad = @IDUnidad

    select 
        @IDReferencia=up.IDReferencia,
        @SpEjecutar = sp.NameSP
    from Enrutamiento.tblUnidadProceso up
        inner join Enrutamiento.tblCatEstatusSPUnidadProcesos sp on up.IDCatTipoProceso =sp.IDCatTipoProceso and  sp.IDEstatus=@IDStatus
    where up.IDUnidad=@IDUnidad

    insert into @Parametros values(N'IDEstatus',@IDStatus)
    insert into @Parametros values(N'IDReferencia',@IDReferencia)
    
    exec sp_executesql N'exec @miSP @dtFiltros,@IDUsuario '                   
    			     ,N' @dtFiltros [Nomina].[dtFiltrosRH] READONLY                   
					 ,@IDUsuario int                   
					 ,@miSP varchar(255)',                          
				    @dtFiltros = @Parametros                  
				  ,@IDUsuario = @IDUsuario              
				  ,@miSP = @SpEjecutar ;    	    
END
GO
