USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatTiposPrestaciones]  
(  
 @IDTipoPrestacion int = 0 
 ,@IDUsuario int = null 
)  
AS  
BEGIN  


IF OBJECT_ID('tempdb..#TempTiposPrestaciones') IS NOT NULL
		DROP TABLE #TempTiposPrestaciones
	
	select ID 
	 Into #TempTiposPrestaciones
	from Seguridad.tblFiltrosUsuarios 
	where IDUsuario = @IDUsuario and Filtro = 'Prestaciones'

 SELECT   
 IDTipoPrestacion  
 ,Codigo  
 ,Descripcion+' '+case when isnull(tp.Sindical,0) = 1 then '(SINDICAL)' else '(CONFIANZA)' end as FacIntegracion  
 ,ConfianzaSindical  
 ,Factor = isnull((Select top 1 Factor from [RH].[tblCatTiposPrestacionesDetalle] where IDTipoPrestacion = tp.IDTipoPrestacion order by Antiguedad asc),0)  
 ,isnull(tp.PorcentajeFondoAhorro,0) as PorcentajeFondoAhorro  
 ,tp.IDsConceptosFondoAhorro  
 ,ConceptosFondoAhorro = ISNULL( STUFF(  
       (   SELECT ', ['+ cast(Codigo as varchar(10))+'] '+ CONVERT(NVARCHAR(100), Descripcion)   
        FROM Nomina.tblCatConceptos  
        WHERE IDConcepto in (select cast(rtrim(ltrim(item)) as int) from app.Split(tp.IDsConceptosFondoAhorro,','))  
        ORDER BY OrdenCalculo  asc  
        FOR xml path('')  
       )  
       , 1  
       , 1  
       , ''), 'Conceptos no definidos')  
 ,isnull(tp.ToparFondoAhorro,0) as ToparFondoAhorro  
 ,isnull(tp.Sindical,0) as Sindical  
 ,ROW_NUMBER()over(ORDER BY IDTipoPrestacion)as ROWNUMBER   
 FROM [RH].[tblCatTiposPrestaciones] tp  
 WHERE (IDTipoPrestacion = @IDTipoPrestacion or isnull(@IDTipoPrestacion,0) = 0)  
    and (IDTipoPrestacion in  ( select ID from #TempTiposPrestaciones)
	OR Not Exists(select ID from #TempTiposPrestaciones))
 ORDER BY Descripcion ASC  
END
GO
