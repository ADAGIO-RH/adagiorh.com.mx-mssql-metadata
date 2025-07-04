USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************   
** Descripción  : Calcula la vigencia de un colaborador en un rango de fechas  
** Autor   : Aneudy Abreu & Jose Román  
** Email   : aneudy.abreu@adagio.com  
** FechaCreacion : 2018-06-19  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
2018-07-05  Aneudy Abreu  Corregí esta parte que estaba mal:  
            where IDEmpleado = @IDEmpleado and Fecha < @FechaIni   
            order by m.Fecha desc, cm.Prioridad DESC  
***************************************************************************************************/  
  
CREATE FUNCTION [RH].[fnFueVigente](@IDEmpleado int  
       ,@FechaIni date  
       ,@FechaFin date  
                           )  
RETURNS bit AS  
BEGIN  
	declare @resp bit = 0;  

	if exists (select top 1 1   
				from [IMSS].[tblMovAfiliatorios] m WITH (NOLOCK)  
							join [IMSS].[tblCatTipoMovimientos] cm WITH (NOLOCK) on m.IDTipoMovimiento = cm.IDTipoMovimiento  
				where IDEmpleado = @IDEmpleado and Fecha BETWEEN @FechaIni and @FechaFin and cm.Codigo <> 'M')
    BEGIN  
		set @resp = cast(1 as bit);  
    end else  
	if (@resp = 0 and (select top 1 cm.Codigo  
						from [IMSS].[tblMovAfiliatorios]  m WITH (NOLOCK)  
							join [IMSS].[tblCatTipoMovimientos] cm WITH (NOLOCK)   on m.IDTipoMovimiento = cm.IDTipoMovimiento  
						where IDEmpleado = @IDEmpleado and Fecha < @FechaIni   
						order by m.Fecha desc, cm.Prioridad DESC  
						) <> 'B')  
    begin   
		set @resp = cast(1 as bit);  
    end ELSE  
    BEGIN  
		set @resp = cast(0 as bit);  
    end;  
  
    return @resp;  
END
GO
