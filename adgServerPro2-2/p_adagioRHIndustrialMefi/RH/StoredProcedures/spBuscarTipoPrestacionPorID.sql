USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
CREATE PROCEDURE [RH].[spBuscarTipoPrestacionPorID] --5,1   
(    
 @IDTipoPrestacion int = 0 ,  
 @IDUsuario int     
)    
AS    
BEGIN    
  Declare 
  @IDIdioma varchar(max);
  
select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

IF OBJECT_ID('tempdb..#TempTiposPrestaciones') IS NOT NULL    
  DROP TABLE #TempTiposPrestaciones    
     
 select ID     
  Into #TempTiposPrestaciones    
 from Seguridad.tblFiltrosUsuarios     
 where IDUsuario = @IDUsuario and Filtro = 'Prestaciones'    
  
 SELECT     
 IDTipoPrestacion    
 ,Codigo    
 ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as FacIntegracion    
 ,Sindical    
 ,isnull(PorcentajeFondoAhorro,0) as PorcentajeFondoAhorro    
 FROM [RH].[tblCatTiposPrestaciones]    
 WHERE (IDTipoPrestacion=@IDTipoPrestacion or @IDTipoPrestacion =0)   
 and (IDTipoPrestacion in  ( select ID from #TempTiposPrestaciones)    
 OR Not Exists(select ID from #TempTiposPrestaciones))   
END
GO
