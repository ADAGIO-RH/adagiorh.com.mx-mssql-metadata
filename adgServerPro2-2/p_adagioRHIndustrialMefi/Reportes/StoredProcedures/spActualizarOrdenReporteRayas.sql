USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Reorganiza el Orden de Reporte de Rayas 
** Autor   : Jose Roman 
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 2019-02-26  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  
CREATE PROC [Reportes].[spActualizarOrdenReporteRayas](  
    @IDConcepto int   
    ,@OldIndex int    
    ,@NewIndex int 
	,@IDUsuario int  
    )  
    as  
  
    declare   
         @i int = 1     
        ,@Total int = 0
        ,@MaxOrden int; 
  
    if OBJECT_ID('tempdb..#tblTempConceptos') is not null  
    drop table #tblTempConceptos;  
  
    if OBJECT_ID('tempdb..#tblTempConceptos1') is not null  
    drop table #tblTempConceptos1;  
  
    if ((@NewIndex < @OldIndex) or (@OldIndex = 0))  
    begin  
        select cr.IDConcepto,c.Codigo,c.Descripcion,cr.Orden, ROW_NUMBER() over(order by cr.orden asc) as ID  
        INTO #tblTempConceptos  
        from Reportes.tblConfigReporteRayas  cr
            inner join Nomina.tblCatConceptos c
                on cr.IDConcepto = c.IDConcepto
        where cr.Orden >= @NewIndex and cr.IDConcepto <> @IDConcepto;  
    
        update Reportes.tblConfigReporteRayas
        set Orden = @NewIndex  
        where IDConcepto=@IDConcepto  
    
        while exists(select 1 from #tblTempConceptos where ID >= @i)  
        begin  
            select @IDConcepto=IDConcepto from #tblTempConceptos where  ID=@i  
            set @NewIndex = @NewIndex+1  
        
            update Reportes.tblConfigReporteRayas
            set Orden = @NewIndex  
            where IDConcepto=@IDConcepto  
            
            select @i=@i+1;  
        end;  
    end else  
    begin  
        select cr.IDConcepto,c.Codigo,c.Descripcion,cr.Orden, ROW_NUMBER() over(order by cr.Orden asc) as ID  
        INTO #tblTempConceptos1  
        from Reportes.tblConfigReporteRayas  cr
            inner join Nomina.tblCatConceptos c
                on cr.IDConcepto = c.IDConcepto
        where (cr.Orden between @OldIndex and @NewIndex) and cr.IDConcepto <> @IDConcepto;  
    
        update Reportes.tblConfigReporteRayas
        set Orden = @NewIndex  
        where IDConcepto=@IDConcepto  
    
        while exists(select 1 from #tblTempConceptos1 where ID >= @i)  
        begin  
            select @IDConcepto=IDConcepto from #tblTempConceptos1 where  ID=@i  
        
            update Reportes.tblConfigReporteRayas
            set Orden = @OldIndex  
            where IDConcepto=@IDConcepto  
        
            set @OldIndex = @OldIndex+1  
        
            select @i=@i+1;  
        end;  
    end;

      SELECT @MaxOrden = MAX(Orden) FROM Reportes.tblConfigReporteRayas;
      
         RETURN @MaxOrden;
GO
