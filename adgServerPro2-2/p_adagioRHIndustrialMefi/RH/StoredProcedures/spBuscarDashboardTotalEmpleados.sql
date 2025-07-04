USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Consulta el Total de empleados vigentes, no vigentes y los cumpleaños del día
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-07-05
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE proc [RH].[spBuscarDashboardTotalEmpleados](
    @IDUsuario int
) as    

    if object_id('tempdb..#tempEmpleadosVigentes') is not null
	   drop table #tempEmpleadosVigentes;

    /* DS 0 - Total de empleados vigentes y no vigentes */
    select em.[Vigente],count(*) as Total
    into #tempEmpleadosVigentes
    from [RH].[tblEmpleadosMaster] em with (nolock)
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
    GROUP by em.Vigente

    select 
	    (select Total from #tempEmpleadosVigentes where Vigente = 0) NoVigentes
	   ,(select Total from #tempEmpleadosVigentes where Vigente = 1) Vigentes

    /* DS 1 - Total de cumpleaños el día de hoy */
    select count(*) as TotalCumpleanios
    from [RH].[tblEmpleadosMaster] em with (nolock)
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
    where em.Vigente = 1 and
	   (datepart(month,em.FechaNacimiento) = datepart(month,getdate()))
	   and 
	   (datepart(day,em.FechaNacimiento) = datepart(day,getdate()))
GO
