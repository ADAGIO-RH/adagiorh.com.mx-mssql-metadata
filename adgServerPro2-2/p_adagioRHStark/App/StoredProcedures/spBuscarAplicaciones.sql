USE [p_adagioRHStark]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[spBuscarAplicaciones] 
(
	@IDAplicacion varchar(max) = null
)   
as    
 select     
  IDAplicacion    
  ,Descripcion  
  ,Orden  
 ,Icon
 ,Url    
 ,case when Url='#/' then 'Redirige a la SinglePage.'
	 when Url like '%http%' then 'Abre una nueva pestaña con el link externo.'
	 else 'Sale de la SinglePage y redirige a https://{host}/{ControllerName}'
	 end as Informacion 
 
 from app.tblCatAplicaciones
 where IDAplicacion = @IDAplicacion OR isnull(@IDAplicacion,'') = ''
 order by Orden
GO
