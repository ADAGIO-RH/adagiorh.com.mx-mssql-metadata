USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create   PROCEDURE  [Reportes].[spBuscarAniversariosByFecha]  
	-- Add the parameters for the stored procedure here
	 @FechaIni date = null    
   ,@FechaFin date = null    
   ,@IDUsuario int    
AS
BEGIN
	Declare @lista [App].[dtFechasFull]  
  
	insert into @lista  
	exec [App].[spListaFechas] @fechaIni, @fechaFin  
  
  
	 select * from 
	(
				select
				e.ClaveEmpleado,
				e.NOMBRECOMPLETO,
				e.RFC,
				e.CURP,
				e.IMSS,
				e.Departamento,
				e.Sucursal,
				e.Puesto,
				mov.Fecha,
				ROW_NUMBER()over(partition by mov.IDEmpleado order by mov.IDEmpleado,mov.Fecha desc )  as [ROW]
				
				from [RH].[tblEmpleadosMaster] e with (nolock)    
				inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU
					on FEU.IDEmpleado = E.IDEmpleado and FEU.IDUsuario = @IDUsuario
				inner join IMSS.tblMovAfiliatorios mov 
					on mov.IDEmpleado=e.IDEmpleado  and mov.IDTipoMovimiento in (1,3)
				where e.Vigente = 1  
	) as dt
	WHERE dt.ROW=1 
	and ((datepart(month,dt.Fecha) in (select Mes from @lista) )    
   and     
   (datepart(day,dt.Fecha)in (select Dia from @lista)))    
	order by dt.ClaveEmpleado asc


	--select *    
 --   from [RH].[tblEmpleadosMaster] e with (nolock)    
	--	inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU
	--		on FEU.IDEmpleado = E.IDEmpleado
	--		and FEU.IDUsuario = @IDUsuario
	--		inner join IMSS.tblMovAfiliatorios mov on mov.IDEmpleado=e.IDEmpleado 
 --   where e.Vigente = 1 and    
 --  ((datepart(month,e.FechaNacimiento) in (select Mes from @lista) )    
 --  and     
 --  (datepart(day,e.FechaNacimiento)in (select Dia from @lista)))    
 --   order by ClaveEmpleado asc    

END
GO
