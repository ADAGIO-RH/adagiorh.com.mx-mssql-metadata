USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Busca el acumulado por Fecha, Conceptos y Colaboradores
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2021-04-16
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
create proc [Nomina].[spBuscarAcumuladoPorEjercicioConceptosEmpleados] (
	@Ejercicio int,
	@CodigosConceptos varchar(max) = null,
	@dtEmpleados RH.dtEmpleados readonly,
	@IDUsuario int
) as

	--declare
	--	@FechaInicial date = '2020-01-01',
	--	@FechaFin date = '2020-12-31',
	--	@CodigosConceptos varchar(max) = '101',
	--	@dtEmpleados RH.dtEmpleados --readonly
	--;

	select
		IDEmpleado,
		ClaveEmpleado, 
		Colaborador, 
		CodigoConcepto, 
		Concepto, 
		Total
	from (
		select 
			e.IDEmpleado,
			e.ClaveEmpleado, 
			e.NOMBRECOMPLETO as Colaborador, 
			c.Codigo as CodigoConcepto, 
			c.Descripcion as Concepto, 
			SUM(isnull(dp.ImporteTotal1,0)) as Total, 
			c.OrdenCalculo
		from RH.tblEmpleadosMaster e with (nolock) 
			join Nomina.tblDetallePeriodo dp with (nolock) on e.IDEmpleado = dp.IDEmpleado
			join Nomina.tblCatPeriodos P with (nolock) on dp.IDPeriodo = P.IDPeriodo and 
				isnull(p.Cerrado,0) = 1 and P.Ejercicio = @Ejercicio
			join Nomina.tblCatConceptos c with (nolock) on dp.IDConcepto = c.IDConcepto
		where (c.Codigo in (select item from App.Split(@CodigosConceptos, ',')) or @CodigosConceptos is null) and
			(e.IDEmpleado in (select IDEmpleado from @dtEmpleados) or (select COUNT(IDEmpleado) from @dtEmpleados) = 0)
		group by  e.IDEmpleado,e.ClaveEmpleado, e.NOMBRECOMPLETO, c.Codigo, c.Descripcion, c.OrdenCalculo
	) as [data]
	order by ClaveEmpleado, OrdenCalculo
GO
