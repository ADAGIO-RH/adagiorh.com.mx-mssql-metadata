USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Busca trabajadores cumpleaños rango.    
** Autor   : jose roman  
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2019-02-27    
** Paremetros  :      
  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
0000-00-00  NombreCompleto  ¿Qué cambió?    
***************************************************************************************************/    
CREATE PROCEDURE Reportes.spBuscarCumpleaniosByFecha  
(  
   @FechaIni date = null    
   ,@FechaFin date = null    
   ,@IDUsuario int    
)  
AS  
BEGIN  
  
Declare @lista [App].[dtFechasFull]  
  
insert into @lista  
exec [App].[spListaFechas] @fechaIni, @fechaFin  
  
  
 select *    
    from [RH].[tblEmpleadosMaster] e with (nolock)    
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU
			on FEU.IDEmpleado = E.IDEmpleado
			and FEU.IDUsuario = @IDUsuario
    where e.Vigente = 1 and    
   ((datepart(month,e.FechaNacimiento)in(select Mes from @lista))    
   and     
   (datepart(day,e.FechaNacimiento)in (select Dia from @lista)))    
     
   
    order by ClaveEmpleado asc    
  
END
GO
