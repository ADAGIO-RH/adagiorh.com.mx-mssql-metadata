USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [RH].[spBuscarConfiguracionesPlazaByID]@IDPlaza=43,@IDUsuario=1,@WithDescripcion=1
CREATE proc [RH].[spBuscarConfiguracionesPlazaByID] (	
	@IDPlaza int,
	@IDUsuario int,
  @WithDescripcion bit
) as
    
    DECLARE @json varchar(max)
    SELECT @json=Configuraciones   from rh.tblCatPlazas where IDPlaza=@IDPlaza

    IF @WithDescripcion =1
      BEGIN
          select 		
                ctcp.IDTipoConfiguracionPlaza
                ,ctcp.Nombre as TipoConfiguracionPlaza		        
                ,ctcp.Configuracion
                , t.Valor      
                , ff.descripcion   
                ,isnull(ctcp.Orden, 0) Orden                
          from [RH].[tblCatTiposConfiguracionesPlazas] ctcp with (nolock)				 
            left join (
                SELECT IDTipoConfiguracionPlaza,Valor
                    FROM OPENJSON(@json )
                    WITH (   
                      IDTipoConfiguracionPlaza   varchar(200) '$.IDTipoConfiguracionPlaza' ,                
                      Valor int          '$.Valor'  
                    ) 
            ) as t on t.IDTipoConfiguracionPlaza = ctcp.IDTipoConfiguracionPlaza    
            outer APPLY [RH].[fnGetValueMemberFromTable](ctcp.TableName,t.Valor)  as ff  
          where ctcp.Disponible=1
          order by ctcp.Orden        
      END  
	  ELSE
      BEGIN 
          select 		
                ctcp.IDTipoConfiguracionPlaza
                ,ctcp.Nombre as TipoConfiguracionPlaza		        
                ,ctcp.Configuracion
                , t.Valor      
                , '' AS descripcion   
                ,isnull(ctcp.Orden, 0) Orden                
          from [RH].[tblCatTiposConfiguracionesPlazas] ctcp with (nolock)				 
            left join (
                SELECT IDTipoConfiguracionPlaza,Valor
                    FROM OPENJSON(@json )
                    WITH (   
                      IDTipoConfiguracionPlaza   varchar(200) '$.IDTipoConfiguracionPlaza' ,                
                      Valor int          '$.Valor'  
                    ) 
            ) as t on t.IDTipoConfiguracionPlaza = ctcp.IDTipoConfiguracionPlaza                
          where ctcp.Disponible=1        
          order by ctcp.Orden
      END
GO
