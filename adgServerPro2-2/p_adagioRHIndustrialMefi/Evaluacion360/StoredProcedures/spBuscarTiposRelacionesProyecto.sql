USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Busca Tipos de relaciones por proyectos  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2018-12-11  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  
CREATE proc [Evaluacion360].[spBuscarTiposRelacionesProyecto](  
 @IDProyecto int = 0  
 ) as  
 begin  
 Declare @IDIdioma varchar(max)
 select @IDIdioma = App.fnGetPreferencia('Idioma',1,'esmx')
 select   
 ctp.IDTipoRelacion  
 ,ctp.Codigo  
 ,JSON_VALUE(ctp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion
 from [Evaluacion360].[tblEvaluadoresRequeridos] er  
  join [Evaluacion360].[tblCatTiposRelaciones] ctp on er.IDTipoRelacion = ctp.IDTipoRelacion  
 where (er.IDProyecto = @IDProyecto)  
  
 end;
GO
